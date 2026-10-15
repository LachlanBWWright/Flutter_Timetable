import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart' as gtfs_trip;
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

import 'endpoint_resolver.dart';
import 'entity_data_source.dart';
import 'resolver_models.dart';

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
