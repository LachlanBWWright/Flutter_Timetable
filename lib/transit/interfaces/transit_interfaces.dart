import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';

class StopSearchRequest {
  const StopSearchRequest({
    required this.query,
    this.limit = 50,
    this.latitude,
    this.longitude,
  });

  final String query;
  final int limit;
  final double? latitude;
  final double? longitude;
}

class StaticImportRequest {
  const StaticImportRequest({this.force = false, this.sourceIds});

  final bool force;
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
  const RealtimeRequest({this.sourceId});

  final TransitSourceId? sourceId;
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
  });

  final TransitStopRef origin;
  final TransitStopRef destination;
  final DateTime? when;
  final bool arrivalBased;
  final List<TransportMode>? enabledModes;
  final Duration? walkingLimit;
  final TransitAccessibility accessibility;
}

class JourneyPlan {
  const JourneyPlan({required this.journeys, this.rawPayload});

  final List<TransitJourney> journeys;
  final Object? rawPayload;
}

class DisruptionRequest {
  const DisruptionRequest({this.stop, this.route});

  final TransitStopRef? stop;
  final TransitRouteRef? route;
}

abstract interface class StopRepository {
  Future<List<TransitStop>> searchStops(StopSearchRequest request);
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
