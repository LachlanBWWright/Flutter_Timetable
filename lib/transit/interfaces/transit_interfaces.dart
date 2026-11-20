import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/transit/cache/realtime_query.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';

import '../domain/transit_cancellation.dart';

export '../domain/transit_cancellation.dart';

class StopSearchRequest {
  const StopSearchRequest({
    required this.query,
    this.limit = 50,
    this.latitude,
    this.longitude,
    this.sourceIds,
    this.browse = false,
    this.cancellation,
  });

  final String query;
  final int limit;
  final double? latitude;
  final double? longitude;
  final List<TransitSourceId>? sourceIds;
  final bool browse;
  final StopSearchCancellation? cancellation;
}

typedef StopSearchCancellation = TransitCancellation;

class StopSearchUpdate {
  const StopSearchUpdate({
    required this.stops,
    this.isLoading = false,
    this.progress,
    this.errors = const {},
    this.isStale = false,
  });
  final List<TransitStop> stops;
  final bool isLoading;
  final StaticImportProgress? progress;
  final Map<String, String> errors;
  final bool isStale;
}

abstract interface class ProgressiveStopRepository implements StopRepository {
  Stream<StopSearchUpdate> watchStops(StopSearchRequest request);
}

class StaticImportRequest {
  const StaticImportRequest({
    this.force = false,
    this.sourceIds,
    this.cancellation,
  });

  final bool force;
  final TransitCancellation? cancellation;

  /// Null or empty selects all configured sources. Unknown sources are rejected
  /// before any downloads or database writes.
  final List<TransitSourceId>? sourceIds;
}

class StaticImportProgress {
  const StaticImportProgress({
    required this.sourceId,
    required this.completed,
    required this.total,
    required this.message,
    this.error,
  });

  final TransitSourceId? sourceId;
  final int completed;
  final int total;
  final String message;
  final String? error;
}

class RealtimeRequest {
  const RealtimeRequest({this.sourceId, this.query});

  final TransitSourceId? sourceId;
  final RealtimeQuery? query;
}

class RealtimeSnapshot<T> {
  const RealtimeSnapshot({
    required this.items,
    required this.fetchedAt,
    this.isStale = false,
  });

  final List<T> items;
  final DateTime fetchedAt;
  final bool isStale;
}

class DepartureRequest {
  const DepartureRequest({required this.stop, this.when});

  final TransitStopRef stop;
  final DateTime? when;
}

class JourneyPlanRequest {
  const JourneyPlanRequest({
    required this.origin,
    required this.destination,
    this.when,
    this.arrivalBased = false,
    this.enabledModes,
    this.walkingLimit,
    this.accessibility = TransitAccessibility.none,
    this.cancellation,
  });

  final TransitStopRef origin;
  final TransitStopRef destination;
  final DateTime? when;
  final bool arrivalBased;
  final List<TransportMode>? enabledModes;
  final Duration? walkingLimit;
  final TransitAccessibility accessibility;
  final TransitCancellation? cancellation;
}

class JourneyPlan {
  const JourneyPlan({required this.journeys, this.rawPayload, this.timetable});

  final TimetableProvenance? timetable;
  final List<TransitJourney> journeys;
  final Object? rawPayload;
}

class DisruptionRequest {
  const DisruptionRequest({this.stop, this.route});

  final TransitStopRef? stop;
  final TransitRouteRef? route;
}

abstract interface class StopRepository {
  /// Search only this provider's sources; blank queries return no results.
  Future<List<TransitStop>> searchStops(StopSearchRequest request);

  /// Return null for unknown stops or references owned by another region,
  /// provider, or source. Stop IDs alone are not globally unique.
  Future<TransitStop?> getStop(TransitStopRef stop);
}

abstract interface class StaticGtfsRepository {
  Stream<StaticImportProgress> refreshStaticData(StaticImportRequest request);
}

abstract interface class RealtimeRepository {
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(
    RealtimeRequest request,
  );

  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(
    RealtimeRequest request,
  );

  Future<RealtimeSnapshot<TransitAlert>> getAlerts(RealtimeRequest request);
}

abstract interface class DepartureRepository {
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request);
}

abstract interface class JourneyPlanner {
  Future<JourneyPlan> planJourney(JourneyPlanRequest request);
}

abstract interface class DisruptionRepository {
  Future<List<TransitAlert>> getDisruptions(DisruptionRequest request);
}

class TransitPlanningCapabilities {
  const TransitPlanningCapabilities({
    this.arriveBy = false,
    this.accessibility = false,
    this.walkingLimits = false,
    this.crossFeed = false,
    this.crossRegion = false,
    this.realtime = false,
    this.frequencyServices = false,
    this.maximumServiceDays = 366,
  });
  final bool arriveBy,
      accessibility,
      walkingLimits,
      crossFeed,
      crossRegion,
      realtime,
      frequencyServices;
  final int maximumServiceDays;
}

abstract interface class CapableJourneyPlanner implements JourneyPlanner {
  TransitPlanningCapabilities get capabilities;
}
