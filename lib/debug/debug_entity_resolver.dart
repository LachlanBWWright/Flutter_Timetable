import 'dart:collection';

import 'package:lbww_flutter/constants/transport_modes.dart';
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

class DebugResolvedGtfsRoute {
  final gtfs_route.Route route;
  final gtfs_agency.Agency? agency;
  final GtfsData? data;
  final StopsEndpoint? endpoint;
  final String matchReason;

  const DebugResolvedGtfsRoute({
    required this.route,
    required this.matchReason,
    this.agency,
    this.data,
    this.endpoint,
  });
}

class DebugResolvedGtfsStop {
  final gtfs_stop.Stop stop;
  final GtfsData? data;
  final StopsEndpoint? endpoint;

  const DebugResolvedGtfsStop({required this.stop, this.data, this.endpoint});
}

class DebugDerivedVehicleStops {
  final TripUpdate? matchedTripUpdate;
  final List<TripUpdate> candidateTripUpdates;
  final TripUpdate_StopTimeUpdate? currentStop;
  final TripUpdate_StopTimeUpdate? nextStop;
  final String reason;

  const DebugDerivedVehicleStops({
    required this.reason,
    this.matchedTripUpdate,
    this.candidateTripUpdates = const [],
    this.currentStop,
    this.nextStop,
  });
}

class DebugEntityResolver {
  final Future<GtfsData?> Function(StopsEndpoint endpoint) _getGtfsData;
  final Future<VehiclePositionAggregationResult> Function() _getVehicles;
  final Future<TripUpdateAggregationResult> Function() _getTripUpdates;
  final Future<List<db.Stop>> Function(String stopId) _getDbStops;

  final Map<StopsEndpoint, Future<GtfsData?>> _gtfsCache = {};
  final Map<String, Future<List<db.Stop>>> _dbStopsCache = {};
  Future<VehiclePositionAggregationResult>? _vehiclesCache;
  Future<TripUpdateAggregationResult>? _tripUpdatesCache;

  DebugEntityResolver({
    Future<GtfsData?> Function(StopsEndpoint endpoint)? getGtfsDataForEndpoint,
    Future<VehiclePositionAggregationResult> Function()?
    getAllVehiclesAggregated,
    Future<TripUpdateAggregationResult> Function()? getAllTripUpdatesAggregated,
    Future<List<db.Stop>> Function(String stopId)? getDbStopsById,
  }) : _getGtfsData =
           getGtfsDataForEndpoint ?? NewTripService.fetchGtfsDataForEndpoint,
       _getVehicles =
           getAllVehiclesAggregated ??
           RealtimeService.getAllVehiclePositionsAggregated,
       _getTripUpdates =
           getAllTripUpdatesAggregated ??
           RealtimeService.getAllTripUpdatesAggregated,
       _getDbStops = getDbStopsById ?? StopsService.database.getStopsById;

  Future<List<db.Stop>> lookupDbStops(String stopId) {
    return _dbStopsCache.putIfAbsent(stopId, () => _getDbStops(stopId));
  }

  Future<VehiclePositionAggregationResult> vehicleAggregation() {
    return _vehiclesCache ??= _getVehicles();
  }

  Future<TripUpdateAggregationResult> tripUpdateAggregation() {
    return _tripUpdatesCache ??= _getTripUpdates();
  }

  Future<GtfsData?> loadGtfsForEndpoint(StopsEndpoint endpoint) {
    return _gtfsCache.putIfAbsent(endpoint, () => _getGtfsData(endpoint));
  }

  Future<List<VehiclePosition>> matchVehicles({
    Set<String> tripIds = const {},
    Set<String> routeIds = const {},
  }) async {
    if (tripIds.isEmpty && routeIds.isEmpty) {
      return const <VehiclePosition>[];
    }

    final aggregation = await vehicleAggregation();
    final vehicles = aggregation.vehicles;
    if (tripIds.isNotEmpty) {
      return vehicles
          .where(
            (vehicle) =>
                vehicle.trip.hasTripId() &&
                tripIds.contains(vehicle.trip.tripId),
          )
          .toList(growable: false);
    }

    return vehicles
        .where(
          (vehicle) =>
              vehicle.trip.hasRouteId() &&
              routeIds.contains(vehicle.trip.routeId),
        )
        .toList(growable: false);
  }

  Future<List<TripUpdate>> matchTripUpdates({
    Set<String> tripIds = const {},
    Set<String> routeIds = const {},
  }) async {
    if (tripIds.isEmpty && routeIds.isEmpty) {
      return const <TripUpdate>[];
    }

    final aggregation = await tripUpdateAggregation();
    final updates = aggregation.tripUpdates;
    if (tripIds.isNotEmpty) {
      return updates
          .where(
            (update) =>
                update.trip.hasTripId() && tripIds.contains(update.trip.tripId),
          )
          .toList(growable: false);
    }

    return updates
        .where(
          (update) =>
              update.trip.hasRouteId() &&
              routeIds.contains(update.trip.routeId),
        )
        .toList(growable: false);
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

    final aggregation = await vehicleAggregation();
    for (final vehicle in aggregation.vehicles) {
      if (vehicleId != null &&
          DebugExtractors.vehicleId(vehicle) == vehicleId) {
        return vehicle;
      }
      if (tripId != null &&
          vehicle.trip.hasTripId() &&
          vehicle.trip.tripId == tripId) {
        return vehicle;
      }
      if (routeId != null &&
          vehicle.trip.hasRouteId() &&
          vehicle.trip.routeId == routeId) {
        return vehicle;
      }
    }
    return null;
  }

  Future<DebugDerivedVehicleStops> deriveVehicleStops(
    VehiclePosition vehicle, {
    TripUpdate? preferredTripUpdate,
  }) async {
    final tripId = vehicle.trip.hasTripId() ? vehicle.trip.tripId : null;
    final routeId = vehicle.trip.hasRouteId() ? vehicle.trip.routeId : null;

    final candidates = preferredTripUpdate != null
        ? <TripUpdate>[preferredTripUpdate]
        : await matchTripUpdates(
            tripIds: tripId == null || tripId.isEmpty ? const {} : {tripId},
            routeIds: tripId == null || tripId.isEmpty
                ? routeId == null || routeId.isEmpty
                      ? const {}
                      : {routeId}
                : const {},
          );

    if (candidates.isEmpty) {
      return const DebugDerivedVehicleStops(
        reason: 'No matching realtime trip updates found for this vehicle.',
      );
    }

    final matched = candidates.firstWhere(
      (candidate) =>
          tripId != null &&
          candidate.trip.hasTripId() &&
          candidate.trip.tripId == tripId,
      orElse: () => candidates.first,
    );

    final updates = matched.stopTimeUpdate.toList()
      ..sort((left, right) => left.stopSequence.compareTo(right.stopSequence));
    if (updates.isEmpty) {
      return DebugDerivedVehicleStops(
        matchedTripUpdate: matched,
        candidateTripUpdates: candidates,
        reason: 'Matched realtime trip update does not include stop-time rows.',
      );
    }

    TripUpdate_StopTimeUpdate? currentStop;
    TripUpdate_StopTimeUpdate? nextStop;
    final currentSequence = vehicle.hasCurrentStopSequence()
        ? vehicle.currentStopSequence
        : null;

    if (currentSequence != null) {
      for (final stop in updates) {
        if (stop.stopSequence == currentSequence) {
          currentStop = stop;
        } else if (stop.stopSequence > currentSequence) {
          nextStop ??= stop;
        }
      }
    }

    currentStop ??= updates.first;
    nextStop ??= updates.length > 1 ? updates[1] : null;

    final reason = tripId != null && tripId.isNotEmpty
        ? 'Matched by realtime tripId.'
        : routeId != null && routeId.isNotEmpty
        ? 'Matched by realtime routeId.'
        : 'Matched by fallback candidate ordering.';

    return DebugDerivedVehicleStops(
      matchedTripUpdate: matched,
      candidateTripUpdates: candidates,
      currentStop: currentStop,
      nextStop: nextStop,
      reason: reason,
    );
  }

  Future<DebugResolvedGtfsRoute?> resolveGtfsRoute({
    required String routeId,
    api.Leg? leg,
    api.TripJourney? trip,
    api.Transportation? transportation,
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
        agency:
            explicitAgency ??
            _matchAgencyForRoute(
              explicitRoute,
              explicitData?.agencies ?? const [],
            ),
        data: explicitData,
        endpoint: explicitEndpoint,
        matchReason: explicitMatchReason ?? 'provided by context',
      );
    }

    final transport = DebugExtractors.bestTransportationFromContext(
      routeId,
      preferredTransportation: transportation,
      leg: leg,
      trip: trip,
    );

    if (explicitData != null) {
      final match = _matchGtfsRoute(
        routeId: routeId,
        transportation: transport,
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

    final endpoints = await candidateRouteEndpoints(
      leg: leg,
      trip: trip,
      modeHint:
          modeHint ??
          DebugExtractors.transportModeFromTransportation(transport),
      explicitEndpoint: explicitEndpoint,
    );
    for (final endpoint in endpoints) {
      final data = await loadGtfsForEndpoint(endpoint);
      if (data == null) {
        continue;
      }

      final match = _matchGtfsRoute(
        routeId: routeId,
        transportation: transport,
        routes: data.routes,
      );
      if (match == null) {
        continue;
      }

      return DebugResolvedGtfsRoute(
        route: match.$1,
        agency: _matchAgencyForRoute(match.$1, data.agencies),
        data: data,
        endpoint: endpoint,
        matchReason: match.$2,
      );
    }

    return null;
  }

  Future<DebugResolvedGtfsStop?> resolveGtfsStop({
    required String stopId,
    GtfsData? explicitData,
    StopsEndpoint? explicitEndpoint,
    Iterable<StopsEndpoint> endpointHints = const [],
  }) async {
    if (explicitData != null) {
      for (final stop in explicitData.stops) {
        if (stop.stopId == stopId) {
          return DebugResolvedGtfsStop(
            stop: stop,
            data: explicitData,
            endpoint: explicitEndpoint,
          );
        }
      }
    }

    final orderedHints = LinkedHashSet<StopsEndpoint>();
    if (explicitEndpoint != null) {
      orderedHints.add(explicitEndpoint);
    }
    orderedHints.addAll(endpointHints);

    final dbRows = await lookupDbStops(stopId);
    final endpointByKey = {
      for (final endpoint in StopsEndpoint.values) endpoint.key: endpoint,
    };
    for (final row in dbRows) {
      final endpoint = endpointByKey[row.endpoint];
      if (endpoint != null) {
        orderedHints.add(endpoint);
      }
    }

    for (final endpoint in orderedHints) {
      final data = await loadGtfsForEndpoint(endpoint);
      if (data == null) {
        continue;
      }
      for (final stop in data.stops) {
        if (stop.stopId == stopId) {
          return DebugResolvedGtfsStop(
            stop: stop,
            data: data,
            endpoint: endpoint,
          );
        }
      }
    }

    return null;
  }

  Future<List<StopsEndpoint>> candidateRouteEndpoints({
    api.Leg? leg,
    api.TripJourney? trip,
    TransportMode? modeHint,
    StopsEndpoint? explicitEndpoint,
  }) async {
    final ordered = LinkedHashSet<StopsEndpoint>();
    if (explicitEndpoint != null) {
      ordered.add(explicitEndpoint);
    }

    final stopIds = LinkedHashSet<String>();
    if (leg != null) {
      stopIds.add(leg.origin.id);
      stopIds.add(leg.destination.id);
      stopIds.addAll(
        (leg.stopSequence ?? const <api.Stop>[]).map((stop) => stop.id),
      );
    }
    if (trip != null && leg == null) {
      stopIds.addAll(
        DebugExtractors.collectStopsForTrip(trip).map((stop) => stop.id),
      );
    }

    final endpointByKey = {
      for (final endpoint in StopsEndpoint.values) endpoint.key: endpoint,
    };
    for (final stopId in stopIds.where((stopId) => stopId.isNotEmpty)) {
      final rows = await lookupDbStops(stopId);
      for (final row in rows) {
        final endpoint = endpointByKey[row.endpoint];
        if (endpoint != null) {
          ordered.add(endpoint);
        }
      }
    }

    if (modeHint != null) {
      ordered.addAll(NewTripService.getEndpointsForMode(modeHint));
    }

    return ordered.toList(growable: false);
  }

  (gtfs_route.Route, String)? _matchGtfsRoute({
    required String routeId,
    required api.Transportation? transportation,
    required List<gtfs_route.Route> routes,
  }) {
    final transportId = transportation?.id?.trim() ?? routeId.trim();
    final transportNumber = transportation?.number?.trim();
    final transportNames = <String>{
      if (transportation?.name != null &&
          transportation!.name!.trim().isNotEmpty)
        transportation.name!.trim(),
      if (transportation?.disassembledName != null &&
          transportation!.disassembledName!.trim().isNotEmpty)
        transportation.disassembledName!.trim(),
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
    if (route.agencyId != null && route.agencyId!.isNotEmpty) {
      for (final agency in agencies) {
        if (agency.agencyId == route.agencyId) {
          return agency;
        }
      }
    }
    return agencies.length == 1 ? agencies.first : null;
  }

  List<gtfs_trip.Trip> tripsForRoute(GtfsData? data, String routeId) {
    if (data == null) {
      return const [];
    }
    return data.trips
        .where((trip) => trip.routeId == routeId)
        .toList(growable: false);
  }

  List<StopTime> stopTimesForTrips(GtfsData? data, Set<String> tripIds) {
    if (data == null || tripIds.isEmpty) {
      return const [];
    }
    return data.stopTimes
        .where((stopTime) => tripIds.contains(stopTime.tripId))
        .toList(growable: false);
  }
}
