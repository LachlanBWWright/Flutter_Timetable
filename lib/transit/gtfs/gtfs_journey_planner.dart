import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

part 'gtfs_journey_planner_timezone.dart';
part 'gtfs_journey_planner_compute.dart';

typedef GtfsDataLoader = Future<GtfsData> Function(TransitSourceId sourceId);

/// Earliest-arrival connection-scan router for a single GTFS feed.
/// Supports any number of scheduled transfers at the same stop.
class GtfsJourneyPlanner implements JourneyPlanner {
  GtfsJourneyPlanner({
    required this.region,
    required this.provider,
    required this.loadData,
    this.requiresSameSource = true,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final GtfsDataLoader loadData;
  final bool requiresSameSource;

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
    if (request.arrivalBased) {
      throw const UnsupportedCapability(
        message: 'Arrival-based local GTFS planning is not yet supported.',
      );
    }
    if (request.accessibility != TransitAccessibility.none) {
      throw const UnsupportedCapability(
        message:
            'Accessibility-constrained local GTFS planning is not supported.',
      );
    }
    if (request.walkingLimit != null && request.walkingLimit! > Duration.zero) {
      throw const UnsupportedCapability(
        message: 'Walking limits are not supported by local GTFS planning.',
      );
    }

    final data = await loadData(request.origin.sourceId);
    final timeZone = _feedTimeZone(data, region);
    final maxHour = _maximumGtfsHour(data);
    if (maxHour > 167) {
      throw const UnsupportedCapability(
        message: 'GTFS service times beyond 167 hours are unsupported.',
      );
    }
    final when = request.when?.toUtc() ?? DateTime.now().toUtc();
    return compute(
      _planLoadedGtfsData,
      _PlanningInput(
        data: GtfsData(
          agencies: const [],
          calendars: data.calendars,
          calendarDates: data.calendarDates,
          routes: data.routes,
          stops: data.stops,
          stopTimes: data.stopTimes,
          trips: data.trips,
          shapes: const [],
          notes: const [],
        ),
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
    );
  }

  void _validateRequest(JourneyPlanRequest request) {
    if (request.origin.stopId.trim().isEmpty ||
        request.destination.stopId.trim().isEmpty ||
        request.origin.stopId.length > 256 ||
        request.destination.stopId.length > 256) {
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
    this.canAlight,
  );
  final String tripId;
  final DateTime serviceDate;
  final String fromStopId;
  final String toStopId;
  final DateTime departure;
  final DateTime arrival;
  final int sequence;
  final bool canBoard;
  final bool canAlight;
}

int _sequence(StopTime time) => int.tryParse(time.stopSequence) ?? 0;

Set<String> _activeServiceIds(GtfsData data, DateTime serviceDate) {
  final date =
      '${serviceDate.year.toString().padLeft(4, '0')}'
      '${serviceDate.month.toString().padLeft(2, '0')}'
      '${serviceDate.day.toString().padLeft(2, '0')}';
  final result = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final active =
        [
          calendar.monday,
          calendar.tuesday,
          calendar.wednesday,
          calendar.thursday,
          calendar.friday,
          calendar.saturday,
          calendar.sunday,
        ][serviceDate.weekday - 1] ==
        '1';
    if (active) result.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates.where(
    (item) => item.date == date,
  )) {
    if (exception.exceptionType == '1') result.add(exception.serviceId);
    if (exception.exceptionType == '2') result.remove(exception.serviceId);
  }
  return result;
}

TransportMode? _mode(String value) {
  final routeType = int.tryParse(value);
  if (routeType == null) return null;
  return switch (routeType) {
    0 || (>= 900 && <= 906) => TransportMode.lightrail,
    1 || 400 || 401 || 402 || 403 || 404 => TransportMode.metro,
    2 || (>= 100 && <= 117) => TransportMode.train,
    3 ||
    (>= 200 && <= 209) ||
    (>= 700 && <= 716) ||
    800 ||
    11 => TransportMode.bus,
    4 || 1200 => TransportMode.ferry,
    // Other core and extended families do not map reliably to the five
    // TransportMode values exposed by this app.
    _ => null,
  };
}
