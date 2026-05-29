import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart' as gtfs_trip;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

typedef DebugGtfsLoader = Future<GtfsData?> Function(StopsEndpoint endpoint);
typedef DebugVehicleAggregationLoader =
    Future<VehiclePositionAggregationResult?> Function();
typedef DebugTripUpdateAggregationLoader =
    Future<TripUpdateAggregationResult?> Function();
typedef DebugDbStopLoader = Future<List<db.Stop>> Function(String stopId);
typedef DebugEndpointForMode =
    Iterable<StopsEndpoint> Function(TransportMode mode);

class DebugResolvedGtfsRoute {
  final gtfs_route.Route route;
  final gtfs_agency.Agency? agency;
  final GtfsData? data;
  final StopsEndpoint? endpoint;
  final String matchReason;

  const DebugResolvedGtfsRoute({
    required this.route,
    this.agency,
    this.data,
    this.endpoint,
    required this.matchReason,
  });
}

class DebugResolvedGtfsStop {
  final gtfs_stop.Stop stop;
  final GtfsData? data;
  final StopsEndpoint? endpoint;

  const DebugResolvedGtfsStop({required this.stop, this.data, this.endpoint});
}

class DebugDerivedVehicleStops {
  final TripUpdate_StopTimeUpdate? currentStop;
  final TripUpdate_StopTimeUpdate? nextStop;
  final TripUpdate? matchedTripUpdate;
  final List<TripUpdate> candidateTripUpdates;
  final String reason;

  const DebugDerivedVehicleStops({
    this.currentStop,
    this.nextStop,
    this.matchedTripUpdate,
    this.candidateTripUpdates = const <TripUpdate>[],
    this.reason = 'No stop derivation context available.',
  });
}

class DebugSourceResult<T> {
  final T? value;
  final DebugDataSource source;
  final Object? error;
  final StackTrace? stackTrace;

  const DebugSourceResult({
    required this.value,
    required this.source,
    this.error,
    this.stackTrace,
  });

  bool get hasError => error != null;
}

class DebugEntityDataSource {
  final DebugGtfsLoader _getGtfsData;
  final DebugVehicleAggregationLoader _getVehicles;
  final DebugTripUpdateAggregationLoader _getTripUpdates;
  final DebugDbStopLoader _getDbStops;

  final Map<StopsEndpoint, GtfsData?> _gtfsByEndpoint =
      <StopsEndpoint, GtfsData?>{};
  VehiclePositionAggregationResult? _vehicleAggregation;
  TripUpdateAggregationResult? _tripUpdateAggregation;
  final Map<String, List<db.Stop>> _dbStopsById = <String, List<db.Stop>>{};

  DebugEntityDataSource({
    required DebugGtfsLoader getGtfsDataForEndpoint,
    required DebugVehicleAggregationLoader getAllVehiclesAggregated,
    required DebugTripUpdateAggregationLoader getAllTripUpdatesAggregated,
    required DebugDbStopLoader getDbStopsById,
  }) : _getGtfsData = getGtfsDataForEndpoint,
       _getVehicles = getAllVehiclesAggregated,
       _getTripUpdates = getAllTripUpdatesAggregated,
       _getDbStops = getDbStopsById;

  Future<DebugSourceResult<GtfsData>> loadGtfsForEndpointResult(
    StopsEndpoint endpoint,
  ) async {
    if (_gtfsByEndpoint.containsKey(endpoint)) {
      return DebugSourceResult<GtfsData>(
        value: _gtfsByEndpoint[endpoint],
        source: DebugDataSource.gtfs,
      );
    }
    try {
      final data = await _getGtfsData(endpoint);
      _gtfsByEndpoint[endpoint] = data;
      return DebugSourceResult<GtfsData>(
        value: data,
        source: DebugDataSource.gtfs,
      );
    } catch (error, stackTrace) {
      _gtfsByEndpoint[endpoint] = null;
      return DebugSourceResult<GtfsData>(
        value: null,
        source: DebugDataSource.gtfs,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<GtfsData?> loadGtfsForEndpoint(StopsEndpoint endpoint) async {
    return (await loadGtfsForEndpointResult(endpoint)).value;
  }

  Future<DebugSourceResult<VehiclePositionAggregationResult>>
  vehicleAggregationResult() async {
    final cached = _vehicleAggregation;
    if (cached != null) {
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: cached,
        source: DebugDataSource.realtime,
      );
    }
    try {
      final loaded =
          await _getVehicles() ??
          const VehiclePositionAggregationResult(
            vehicles: <VehiclePosition>[],
            breakdown: <String, int>{},
          );
      _vehicleAggregation = loaded;
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: loaded,
        source: DebugDataSource.realtime,
      );
    } catch (error, stackTrace) {
      const fallback = VehiclePositionAggregationResult(
        vehicles: <VehiclePosition>[],
        breakdown: <String, int>{},
      );
      _vehicleAggregation = fallback;
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: fallback,
        source: DebugDataSource.realtime,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<VehiclePositionAggregationResult> vehicleAggregation() async {
    return (await vehicleAggregationResult()).value ??
        const VehiclePositionAggregationResult(
          vehicles: <VehiclePosition>[],
          breakdown: <String, int>{},
        );
  }

  Future<DebugSourceResult<TripUpdateAggregationResult>>
  tripUpdateAggregationResult() async {
    final cached = _tripUpdateAggregation;
    if (cached != null) {
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: cached,
        source: DebugDataSource.realtime,
      );
    }
    try {
      final loaded =
          await _getTripUpdates() ??
          const TripUpdateAggregationResult(
            tripUpdates: <TripUpdate>[],
            breakdown: <String, int>{},
          );
      _tripUpdateAggregation = loaded;
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: loaded,
        source: DebugDataSource.realtime,
      );
    } catch (error, stackTrace) {
      const fallback = TripUpdateAggregationResult(
        tripUpdates: <TripUpdate>[],
        breakdown: <String, int>{},
      );
      _tripUpdateAggregation = fallback;
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: fallback,
        source: DebugDataSource.realtime,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<TripUpdateAggregationResult> tripUpdateAggregation() async {
    return (await tripUpdateAggregationResult()).value ??
        const TripUpdateAggregationResult(
          tripUpdates: <TripUpdate>[],
          breakdown: <String, int>{},
        );
  }

  Future<DebugSourceResult<List<db.Stop>>> lookupDbStopsResult(
    String stopId,
  ) async {
    if (_dbStopsById.containsKey(stopId)) {
      return DebugSourceResult<List<db.Stop>>(
        value: _dbStopsById[stopId],
        source: DebugDataSource.localDb,
      );
    }
    try {
      final rows = await _getDbStops(stopId);
      _dbStopsById[stopId] = rows;
      return DebugSourceResult<List<db.Stop>>(
        value: rows,
        source: DebugDataSource.localDb,
      );
    } catch (error, stackTrace) {
      _dbStopsById[stopId] = const <db.Stop>[];
      return DebugSourceResult<List<db.Stop>>(
        value: const <db.Stop>[],
        source: DebugDataSource.localDb,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<db.Stop>> lookupDbStops(String stopId) async {
    return (await lookupDbStopsResult(stopId)).value ?? const <db.Stop>[];
  }
}

class DebugEndpointResolver {
  final DebugEntityDataSource _dataSource;
  final DebugEndpointForMode _endpointsForMode;

  DebugEndpointResolver({
    required DebugEntityDataSource dataSource,
    required DebugEndpointForMode endpointsForMode,
  }) : _dataSource = dataSource,
       _endpointsForMode = endpointsForMode;

  StopsEndpoint? endpointForKey(String? endpointKey) {
    if (endpointKey == null) {
      return null;
    }
    return StopsEndpoint.values.firstWhereOrNull(
      (endpoint) => endpoint.key == endpointKey,
    );
  }

  Future<List<StopsEndpoint>> candidateRouteEndpoints({
    api.Leg? leg,
    api.TripJourney? trip,
    TransportMode? modeHint,
    StopsEndpoint? explicitEndpoint,
  }) async {
    final ordered = <StopsEndpoint>{};
    if (explicitEndpoint != null) {
      ordered.add(explicitEndpoint);
    }

    final stopIds = <String>{};
    if (leg != null) {
      stopIds
        ..add(leg.origin.id)
        ..add(leg.destination.id)
        ..addAll(
          (leg.stopSequence ?? const <api.Stop>[]).map((stop) => stop.id),
        );
    }
    if (trip != null && leg == null) {
      stopIds.addAll(
        DebugExtractors.collectStopsForTrip(trip).map((stop) => stop.id),
      );
    }

    for (final stopId in stopIds.where((id) => id.isNotEmpty)) {
      final rows = await _dataSource.lookupDbStops(stopId);
      for (final row in rows) {
        final endpoint = endpointForKey(row.endpoint);
        if (endpoint != null) {
          ordered.add(endpoint);
        }
      }
    }

    if (modeHint != null) {
      ordered.addAll(_endpointsForMode(modeHint));
    }
    return ordered.toList(growable: false);
  }
}

class DebugRealtimeMatcher {
  final DebugEntityDataSource _dataSource;

  const DebugRealtimeMatcher({required DebugEntityDataSource dataSource})
    : _dataSource = dataSource;

  Future<List<VehiclePosition>> matchVehicles({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) async {
    final aggregation = await _dataSource.vehicleAggregation();
    final matches = <VehiclePosition>[];
    for (final vehicle in aggregation.vehicles) {
      final tripId = vehicle.trip.hasTripId() ? vehicle.trip.tripId : '';
      final routeId = vehicle.trip.hasRouteId() ? vehicle.trip.routeId : '';
      if (tripIds.isNotEmpty) {
        if (tripId.isNotEmpty && tripIds.contains(tripId)) {
          matches.add(vehicle);
        }
        continue;
      }
      if (routeIds.isNotEmpty) {
        if (routeId.isNotEmpty && routeIds.contains(routeId)) {
          matches.add(vehicle);
        }
        continue;
      }
      matches.add(vehicle);
    }
    return matches;
  }

  Future<List<TripUpdate>> matchTripUpdates({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) async {
    final aggregation = await _dataSource.tripUpdateAggregation();
    final matches = <TripUpdate>[];
    for (final update in aggregation.tripUpdates) {
      final tripId = update.trip.hasTripId() ? update.trip.tripId : '';
      final routeId = update.trip.hasRouteId() ? update.trip.routeId : '';
      if (tripIds.isNotEmpty) {
        if (tripId.isNotEmpty && tripIds.contains(tripId)) {
          matches.add(update);
        }
        continue;
      }
      if (routeIds.isNotEmpty) {
        if (routeId.isNotEmpty && routeIds.contains(routeId)) {
          matches.add(update);
        }
        continue;
      }
      matches.add(update);
    }
    return matches;
  }

  Future<VehiclePosition?> resolveVehicle({
    VehiclePosition? preferredVehicle,
    String? vehicleId,
    String? tripId,
    String? routeId,
  }) async {
    if (preferredVehicle != null) {
      return preferredVehicle;
    }
    final aggregation = await _dataSource.vehicleAggregation();
    if (vehicleId != null && vehicleId.isNotEmpty) {
      final exact = aggregation.vehicles.firstWhereOrNull((vehicle) {
        final rawId = vehicle.vehicle.hasId() ? vehicle.vehicle.id : '';
        final extractedId = DebugExtractors.vehicleId(vehicle);
        return rawId == vehicleId || extractedId == vehicleId;
      });
      if (exact != null) {
        return exact;
      }
    }
    if (tripId != null && tripId.isNotEmpty) {
      final byTrip = aggregation.vehicles.firstWhereOrNull(
        (vehicle) => vehicle.trip.hasTripId() && vehicle.trip.tripId == tripId,
      );
      if (byTrip != null) {
        return byTrip;
      }
    }
    if (routeId != null && routeId.isNotEmpty) {
      final byRoute = aggregation.vehicles.firstWhereOrNull(
        (vehicle) =>
            vehicle.trip.hasRouteId() && vehicle.trip.routeId == routeId,
      );
      if (byRoute != null) {
        return byRoute;
      }
    }
    return null;
  }

  Future<DebugDerivedVehicleStops> deriveVehicleStops(
    VehiclePosition vehicle, {
    TripUpdate? preferredTripUpdate,
  }) async {
    final tripIds = <String>{
      if (vehicle.trip.hasTripId() && vehicle.trip.tripId.isNotEmpty)
        vehicle.trip.tripId,
    };
    final routeIds = <String>{
      if (tripIds.isEmpty &&
          vehicle.trip.hasRouteId() &&
          vehicle.trip.routeId.isNotEmpty)
        vehicle.trip.routeId,
    };
    final candidates = await matchTripUpdates(
      tripIds: tripIds,
      routeIds: routeIds,
    );
    final orderedCandidates = <TripUpdate>[
      if (preferredTripUpdate != null) preferredTripUpdate,
      ...candidates.where(
        (candidate) => !identical(candidate, preferredTripUpdate),
      ),
    ];
    final matched = orderedCandidates.firstOrNull;
    if (matched == null) {
      return const DebugDerivedVehicleStops(
        reason:
            'No matching realtime trip updates were found for this vehicle.',
      );
    }

    TripUpdate_StopTimeUpdate? currentStop;
    TripUpdate_StopTimeUpdate? nextStop;
    final updates = matched.stopTimeUpdate.toList(growable: false);
    if (updates.isNotEmpty) {
      if (vehicle.hasCurrentStopSequence()) {
        final currentSequence = vehicle.currentStopSequence;
        final index = updates.indexWhere(
          (stop) =>
              stop.hasStopSequence() && stop.stopSequence == currentSequence,
        );
        if (index >= 0) {
          currentStop = updates.elementAtOrNull(index);
          nextStop = updates.elementAtOrNull(index + 1);
        }
      }
      currentStop ??= updates.firstOrNull;
      if (nextStop == null && updates.length > 1) {
        nextStop = updates.elementAtOrNull(1);
      }
    }

    return DebugDerivedVehicleStops(
      currentStop: currentStop,
      nextStop: nextStop,
      matchedTripUpdate: matched,
      candidateTripUpdates: orderedCandidates,
      reason: currentStop == null
          ? 'Trip update matched, but no stop-time updates were available.'
          : 'Derived from realtime trip updates.',
    );
  }
}

class DebugGtfsMatcher {
  final DebugEntityDataSource _dataSource;
  final DebugEndpointResolver _endpointResolver;

  const DebugGtfsMatcher({
    required DebugEntityDataSource dataSource,
    required DebugEndpointResolver endpointResolver,
  }) : _dataSource = dataSource,
       _endpointResolver = endpointResolver;

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
  }) async {
    if (explicitRoute != null) {
      return DebugResolvedGtfsRoute(
        route: explicitRoute,
        agency: explicitAgency,
        data: explicitData,
        endpoint: explicitEndpoint,
        matchReason: explicitMatchReason ?? 'explicit route context',
      );
    }

    if (explicitData != null) {
      final match = _matchGtfsRoute(
        routeId: routeId,
        transportation: transportation,
        routes: explicitData.routes,
      );
      if (match != null) {
        return DebugResolvedGtfsRoute(
          route: match.$1,
          agency: _matchAgencyForRoute(match.$1, explicitData.agencies),
          data: explicitData,
          endpoint: explicitEndpoint,
          matchReason: match.$2,
        );
      }
    }

    final endpoints = await _endpointResolver.candidateRouteEndpoints(
      leg: leg,
      trip: trip,
      modeHint:
          modeHint ??
          DebugExtractors.transportModeFromTransportation(transportation),
      explicitEndpoint: explicitEndpoint,
    );
    for (final endpoint in endpoints) {
      final data = await _dataSource.loadGtfsForEndpoint(endpoint);
      if (data == null) {
        continue;
      }
      final match = _matchGtfsRoute(
        routeId: routeId,
        transportation: transportation,
        routes: data.routes,
      );
      if (match != null) {
        return DebugResolvedGtfsRoute(
          route: match.$1,
          agency: _matchAgencyForRoute(match.$1, data.agencies),
          data: data,
          endpoint: endpoint,
          matchReason: match.$2,
        );
      }
    }
    return null;
  }

  Future<DebugResolvedGtfsStop?> resolveGtfsStop({
    required String stopId,
    GtfsData? explicitData,
    StopsEndpoint? explicitEndpoint,
    Iterable<StopsEndpoint> endpointHints = const <StopsEndpoint>[],
  }) async {
    if (explicitData != null) {
      final explicit = explicitData.stops.firstWhereOrNull(
        (stop) => stop.stopId == stopId,
      );
      if (explicit != null) {
        return DebugResolvedGtfsStop(
          stop: explicit,
          data: explicitData,
          endpoint: explicitEndpoint,
        );
      }
    }

    final orderedHints = <StopsEndpoint>{};
    if (explicitEndpoint != null) {
      orderedHints.add(explicitEndpoint);
    }
    orderedHints.addAll(endpointHints);
    final dbRows = await _dataSource.lookupDbStops(stopId);
    for (final row in dbRows) {
      final endpoint = _endpointResolver.endpointForKey(row.endpoint);
      if (endpoint != null) {
        orderedHints.add(endpoint);
      }
    }

    for (final endpoint in orderedHints) {
      final data = await _dataSource.loadGtfsForEndpoint(endpoint);
      if (data == null) {
        continue;
      }
      final stop = data.stops.firstWhereOrNull(
        (candidate) => candidate.stopId == stopId,
      );
      if (stop != null) {
        return DebugResolvedGtfsStop(
          stop: stop,
          data: data,
          endpoint: endpoint,
        );
      }
    }
    return null;
  }

  List<gtfs_trip.Trip> tripsForRoute(GtfsData? data, String routeId) {
    if (data == null) {
      return const <gtfs_trip.Trip>[];
    }
    return data.trips
        .where((trip) => trip.routeId == routeId)
        .toList(growable: false);
  }

  List<StopTime> stopTimesForTrips(GtfsData? data, Set<String> tripIds) {
    if (data == null || tripIds.isEmpty) {
      return const <StopTime>[];
    }
    return data.stopTimes
        .where((stopTime) => tripIds.contains(stopTime.tripId))
        .toList(growable: false);
  }

  (gtfs_route.Route, String)? _matchGtfsRoute({
    required String routeId,
    required api.Transportation? transportation,
    required List<gtfs_route.Route> routes,
  }) {
    final transportId = transportation?.id?.trim() ?? routeId.trim();
    final transportNumber = transportation?.number?.trim();
    final trimmedTransportName = transportation?.name?.trim();
    final trimmedDisassembledName = transportation?.disassembledName?.trim();
    final transportNames = <String>{
      if (trimmedTransportName != null && trimmedTransportName.isNotEmpty)
        trimmedTransportName,
      if (trimmedDisassembledName != null && trimmedDisassembledName.isNotEmpty)
        trimmedDisassembledName,
    };

    for (final route in routes) {
      if (transportId.isNotEmpty && route.routeId == transportId) {
        return (route, 'route_id == transportation.id');
      }
      if (routeId.isNotEmpty && route.routeId == routeId) {
        return (route, 'route_id == requested id');
      }
    }

    if (transportNumber != null && transportNumber.isNotEmpty) {
      for (final route in routes) {
        if (route.routeShortName == transportNumber) {
          return (route, 'route_short_name == transportation.number');
        }
      }
    }

    for (final name in transportNames) {
      for (final route in routes) {
        if (route.routeShortName == name) {
          return (route, 'route_short_name == transportation.name');
        }
        if (route.routeLongName == name) {
          return (route, 'route_long_name == transportation.name');
        }
      }
    }
    return null;
  }

  gtfs_agency.Agency? _matchAgencyForRoute(
    gtfs_route.Route route,
    List<gtfs_agency.Agency> agencies,
  ) {
    if (agencies.isEmpty) {
      return null;
    }
    final agencyId = route.agencyId;
    if (agencyId != null && agencyId.isNotEmpty) {
      for (final agency in agencies) {
        if (agency.agencyId == agencyId) {
          return agency;
        }
      }
    }
    return agencies.length == 1 ? agencies.first : null;
  }
}

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
    getDbStopsById: getDbStopsById ?? StopsService.database.getStopsById,
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
