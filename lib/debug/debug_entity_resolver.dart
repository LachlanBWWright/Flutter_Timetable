import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart' as gtfs_trip;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

import 'resolver/endpoint_resolver.dart';
import 'resolver/entity_data_source.dart';
import 'resolver/gtfs_matcher.dart';
import 'resolver/realtime_matcher.dart';
import 'resolver/resolver_models.dart';

export 'resolver/endpoint_resolver.dart';
export 'resolver/entity_data_source.dart';
export 'resolver/gtfs_matcher.dart';
export 'resolver/realtime_matcher.dart';
export 'resolver/resolver_models.dart';

DebugEntityResolver buildDebugEntityResolver({
  DebugGtfsLoader? getGtfsDataForEndpoint,
  DebugVehicleAggregationLoader? getAllVehiclesAggregated,
  DebugTripUpdateAggregationLoader? getAllTripUpdatesAggregated,
  DebugDbStopLoader? getDbStopsById,
  DebugEndpointForMode endpointsForMode = NewTripService.getEndpointsForMode,
}) {
  final dataSource = DebugEntityDataSource(
    getGtfsDataForEndpoint:
        getGtfsDataForEndpoint ?? NewTripService.fetchGtfsDataForEndpoint,
    getAllVehiclesAggregated:
        getAllVehiclesAggregated ??
        RealtimeService.getAllVehiclePositionsAggregated,
    getAllTripUpdatesAggregated:
        getAllTripUpdatesAggregated ??
        RealtimeService.getAllTripUpdatesAggregated,
    // Creating a debug loader should not open the database before it is used.
    getDbStopsById:
        getDbStopsById ??
        (stopId) => StopsService.database.getStopsById(stopId),
  );
  final endpointResolver = DebugEndpointResolver(
    dataSource: dataSource,
    endpointsForMode: endpointsForMode,
  );
  return DebugEntityResolver._(
    dataSource: dataSource,
    realtimeMatcher: DebugRealtimeMatcher(dataSource: dataSource),
    gtfsMatcher: DebugGtfsMatcher(
      dataSource: dataSource,
      endpointResolver: endpointResolver,
    ),
    endpointResolver: endpointResolver,
  );
}

class DebugEntityResolver {
  final DebugEntityDataSource dataSource;
  final DebugRealtimeMatcher realtimeMatcher;
  final DebugGtfsMatcher gtfsMatcher;
  final DebugEndpointResolver endpointResolver;

  const DebugEntityResolver._({
    required this.dataSource,
    required this.realtimeMatcher,
    required this.gtfsMatcher,
    required this.endpointResolver,
  });

  factory DebugEntityResolver({
    DebugGtfsLoader? getGtfsDataForEndpoint,
    DebugVehicleAggregationLoader? getAllVehiclesAggregated,
    DebugTripUpdateAggregationLoader? getAllTripUpdatesAggregated,
    DebugDbStopLoader? getDbStopsById,
  }) {
    return buildDebugEntityResolver(
      getGtfsDataForEndpoint: getGtfsDataForEndpoint,
      getAllVehiclesAggregated: getAllVehiclesAggregated,
      getAllTripUpdatesAggregated: getAllTripUpdatesAggregated,
      getDbStopsById: getDbStopsById,
    );
  }

  Future<GtfsData?> loadGtfsForEndpoint(StopsEndpoint endpoint) {
    return dataSource.loadGtfsForEndpoint(endpoint);
  }

  Future<VehiclePositionAggregationResult> vehicleAggregation() {
    return dataSource.vehicleAggregation();
  }

  Future<TripUpdateAggregationResult> tripUpdateAggregation() {
    return dataSource.tripUpdateAggregation();
  }

  Future<List<db.Stop>> lookupDbStops(String stopId) {
    return dataSource.lookupDbStops(stopId);
  }

  StopsEndpoint? endpointForKey(String? endpointKey) {
    return endpointResolver.endpointForKey(endpointKey);
  }

  Future<List<VehiclePosition>> matchVehicles({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) {
    return realtimeMatcher.matchVehicles(tripIds: tripIds, routeIds: routeIds);
  }

  Future<List<TripUpdate>> matchTripUpdates({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) {
    return realtimeMatcher.matchTripUpdates(
      tripIds: tripIds,
      routeIds: routeIds,
    );
  }

  Future<VehiclePosition?> resolveVehicle({
    VehiclePosition? preferredVehicle,
    String? vehicleId,
    String? tripId,
    String? routeId,
  }) {
    return realtimeMatcher.resolveVehicle(
      preferredVehicle: preferredVehicle,
      vehicleId: vehicleId,
      tripId: tripId,
      routeId: routeId,
    );
  }

  Future<DebugDerivedVehicleStops> deriveVehicleStops(
    VehiclePosition vehicle, {
    TripUpdate? preferredTripUpdate,
  }) {
    return realtimeMatcher.deriveVehicleStops(
      vehicle,
      preferredTripUpdate: preferredTripUpdate,
    );
  }

  Future<DebugResolvedGtfsRoute?> resolveGtfsRoute({
    required String routeId,
    api.Transportation? transportation,
    api.Leg? leg,
    api.TripJourney? trip,
    gtfs_route.Route? explicitRoute,
    gtfs_agency.Agency? explicitAgency,
    GtfsData? explicitData,
    StopsEndpoint? explicitEndpoint,
    String? explicitMatchReason,
    TransportMode? modeHint,
  }) {
    return gtfsMatcher.resolveGtfsRoute(
      routeId: routeId,
      transportation: transportation,
      leg: leg,
      trip: trip,
      explicitRoute: explicitRoute,
      explicitAgency: explicitAgency,
      explicitData: explicitData,
      explicitEndpoint: explicitEndpoint,
      explicitMatchReason: explicitMatchReason,
      modeHint: modeHint,
    );
  }

  Future<DebugResolvedGtfsStop?> resolveGtfsStop({
    required String stopId,
    GtfsData? explicitData,
    StopsEndpoint? explicitEndpoint,
    Iterable<StopsEndpoint> endpointHints = const <StopsEndpoint>[],
  }) {
    return gtfsMatcher.resolveGtfsStop(
      stopId: stopId,
      explicitData: explicitData,
      explicitEndpoint: explicitEndpoint,
      endpointHints: endpointHints,
    );
  }

  Future<List<StopsEndpoint>> candidateRouteEndpoints({
    api.Leg? leg,
    api.TripJourney? trip,
    TransportMode? modeHint,
    StopsEndpoint? explicitEndpoint,
  }) {
    return endpointResolver.candidateRouteEndpoints(
      leg: leg,
      trip: trip,
      modeHint: modeHint,
      explicitEndpoint: explicitEndpoint,
    );
  }

  List<gtfs_trip.Trip> tripsForRoute(GtfsData? data, String routeId) {
    return gtfsMatcher.tripsForRoute(data, routeId);
  }

  List<StopTime> stopTimesForTrips(GtfsData? data, Set<String> tripIds) {
    return gtfsMatcher.stopTimesForTrips(data, tripIds);
  }
}
