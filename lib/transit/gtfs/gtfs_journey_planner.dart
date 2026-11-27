import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/timetable_index.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:timezone/timezone.dart' as tz;

import '../runtime/cancellable_compute.dart';
import '../runtime/transit_resource_budget.dart';
import 'gtfs_feed_validation.dart';
import 'gtfs_realtime_updates.dart';
import 'gtfs_service_clock.dart';
import 'gtfs_transfer_graph.dart';
import 'gtfs_trip_instances.dart';

part 'gtfs_journey_planner_compute.dart';

typedef GtfsDataLoader = Future<GtfsData> Function(TransitSourceId sourceId);

/// Earliest-arrival connection-scan router for a single GTFS feed.
/// Supports scheduled transfers and walking between linked station platforms.
class GtfsJourneyPlanner implements CapableJourneyPlanner {
  GtfsJourneyPlanner({
    required this.region,
    required this.provider,
    required this.loadData,
    this.requiresSameSource = true,
    this.loadRealtime,
    this.loadCancellableData,
    this.budget = const TransitResourceBudget(),
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final GtfsDataLoader loadData;
  final Future<GtfsData> Function(TransitSourceId, TransitCancellation)?
  loadCancellableData;
  final bool requiresSameSource;
  final Future<RealtimeSnapshot<TransitTripUpdate>> Function(TransitSourceId)?
  loadRealtime;
  final TransitResourceBudget budget;
  @override
  TransitPlanningCapabilities get capabilities => TransitPlanningCapabilities(
    arriveBy: true,
    accessibility: true,
    walkingLimits: true,
    frequencyServices: true,
    realtime: loadRealtime != null,
    maximumServiceDays: budget.maximumServiceDays,
  );

  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async {
    _validateRequest(request);
    if (request.origin.region != region ||
        request.destination.region != region) {
      throw const UnsupportedCapability(
        message: 'Cross-region journey planning is not supported.',
      );
    }
    if (request.origin.provider != provider ||
        request.destination.provider != provider) {
      throw const UnsupportedCapability(
        message: 'Journey stops must belong to the active transit provider.',
      );
    }
    if (requiresSameSource &&
        request.origin.sourceId != request.destination.sourceId) {
      throw const UnsupportedCapability(
        message:
            'Journeys between separate provider feed areas are not supported.',
      );
    }
    request.cancellation?.throwIfCancelled();
    final futureData = loadCancellableData == null
        ? loadData(request.origin.sourceId)
        : loadCancellableData!(
            request.origin.sourceId,
            request.cancellation ?? TransitCancellation(),
          );
    final data = await (request.cancellation?.wait(futureData) ?? futureData);
    final timeZone = gtfsFeedTimeZone(data, region);
    final index = data.index;
    final maxHour = index.maximumHour;
    if (maxHour ~/ 24 + 1 > budget.maximumServiceDays) {
      throw const TransitResourceLimit(
        message: 'The timetable exceeds the configured service-day budget.',
      );
    }
    final when = request.when?.toUtc() ?? DateTime.now().toUtc();
    final zones = gtfsRouteTimeZones(data, region);
    var updates = <TransitTripUpdate>[];
    String? realtimeError;
    if (loadRealtime != null) {
      try {
        final future = loadRealtime!(request.origin.sourceId);
        final snapshot = await (request.cancellation?.wait(future) ?? future);
        final age = DateTime.now().toUtc().difference(
          snapshot.fetchedAt.toUtc(),
        );
        if (!snapshot.isStale &&
            age >= const Duration(seconds: -5) &&
            age <= const Duration(minutes: 2)) {
          updates = matchGtfsUpdates(
            data,
            snapshot.items
                .where(
                  (u) =>
                      (u.sourceId == null ||
                          u.sourceId == request.origin.sourceId) &&
                      (u.stop == null || u.stop!.belongsTo(region, provider)),
                )
                .toList(),
          );
        } else {
          realtimeError = 'Live updates are stale; using the timetable.';
        }
      } on TransitOperationCancelled {
        rethrow;
      } on Exception {
        realtimeError = 'Live updates unavailable; using the timetable.';
      }
    }
    final plan = await runTransitCompute(
      _planLoadedGtfsData,
      _PlanningInput(
        index: index,
        routeTimeZones: zones,
        updates: updates,
        budget: budget,
        request: JourneyPlanRequest(
          origin: request.origin,
          destination: request.destination,
          when: when,
          arrivalBased: request.arrivalBased,
          enabledModes: request.enabledModes == null
              ? null
              : List<TransportMode>.of(request.enabledModes!),
          walkingLimit: request.walkingLimit,
          accessibility: request.accessibility,
        ),
        when: when,
        timeZoneName: timeZone.name,
        lookbackDays: maxHour ~/ 24 + 1,
        region: region,
        provider: provider,
      ),
      cancellation: request.cancellation,
    );
    return JourneyPlan(
      journeys: plan.journeys,
      rawPayload: {
        if (plan.rawPayload is Map) ...plan.rawPayload as Map,
        'realtimeStatus': ?realtimeError,
      },
      timetable: data.timetable,
    );
  }

  void _validateRequest(JourneyPlanRequest request) {
    if (request.origin.stopId.trim().isEmpty ||
        request.destination.stopId.trim().isEmpty ||
        request.origin.stopId.length >
            (request.origin.sourceId.value == '__network__' ? 4096 : 256) ||
        request.destination.stopId.length >
            (request.destination.sourceId.value == '__network__'
                ? 4096
                : 256)) {
      throw const InvalidJourneyRequest(
        message:
            'Journey planning requires valid origin and destination stop IDs.',
      );
    }
    if (request.walkingLimit?.isNegative == true) {
      throw const InvalidJourneyRequest(
        message: 'Walking limit cannot be negative.',
      );
    }
    final when = request.when;
    if (when != null && (when.year < 1900 || when.year > 2200)) {
      throw const InvalidJourneyRequest(
        message: 'Journey planning date must be between 1900 and 2200.',
      );
    }
  }
}

class _Connection {
  const _Connection(
    this.tripId,
    this.serviceDate,
    this.fromStopId,
    this.toStopId,
    this.departure,
    this.arrival,
    this.sequence,
    this.canBoard,
    this.canAlight, {
    this.isWalking = false,
    this.instanceId,
    this.approximate = false,
    this.plannedDeparture,
    this.plannedArrival,
    this.realtime = false,
  });
  final String tripId;
  final DateTime serviceDate;
  final String fromStopId, toStopId;
  final DateTime departure, arrival;
  final int sequence;
  final bool canBoard, canAlight, isWalking, approximate, realtime;
  final String? instanceId;
  final DateTime? plannedDeparture, plannedArrival;
  String get run => instanceId ?? tripId;
}

TransportMode? _mode(String value) => gtfsRouteMode(value);
