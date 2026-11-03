part of '../trip_leg_detail_screen.dart';

/// Resolves GTFS route and agency data for the active leg.
extension _RouteLookup on _TripLegDetailScreenState {
  Future<void> _ensureRouteDebugLoaded() async {
    final leg = _activeLeg;
    final generation = _requestGeneration;
    final transportId = _legRouteIdFor(leg);
    final mode = _getRealtimeModeFromClass(_transportClass(leg.transportation));
    if (transportId == null || transportId.isEmpty) {
      guardedSetState(() {
        _routeDebugError = 'No route id available for this leg';
      });
      return;
    }
    if (_isLoadingRouteDebug || _gtfsRoute?.routeId == transportId) {
      return;
    }

    final debugGeneration = ++_debugRequestGeneration;
    bool isCurrent() =>
        _isCurrentRequest(generation, leg) &&
        debugGeneration == _debugRequestGeneration;
    guardedSetState(() {
      _isLoadingRouteDebug = true;
      _routeDebugError = null;
      _gtfsRoute = null;
      _gtfsAgency = null;
      _gtfsRouteEndpointKey = null;
      _gtfsRouteMatchReason = null;
    });

    await runAsyncGuarded(
      () async {
        final endpoints = await _candidateRouteEndpoints(leg, mode);
        if (!isCurrent()) return;
        if (endpoints.isEmpty) {
          guardedSetState(() {
            _isLoadingRouteDebug = false;
            _routeDebugError =
                'No GTFS endpoint mapping found for this leg. Load stops data first or provide a transport mode.';
          });
          return;
        }

        final injectedGtfsLoader = widget.getGtfsDataForEndpoint;
        if (injectedGtfsLoader != null) {
          for (final endpoint in endpoints) {
            GtfsData? data;
            try {
              data = await injectedGtfsLoader.call(endpoint);
            } catch (_) {
              data = null;
            }
            if (!isCurrent()) return;
            if (data == null) {
              continue;
            }
            final match = _matchGtfsRoute(leg, data.routes);
            final route = match?.$1;
            if (route == null) {
              continue;
            }
            final agency = _matchAgencyForRoute(route, data.agencies);
            if (!isCurrent()) return;
            guardedSetState(() {
              _gtfsRoute = route;
              _gtfsAgency = agency;
              _gtfsRouteEndpointKey = endpoint.key;
              _gtfsRouteMatchReason = match?.$2;
              _isLoadingRouteDebug = false;
              _routeDebugError = null;
            });
            return;
          }
        } else {
          for (final endpoint in endpoints) {
            final routes = await _loadPersistedRoutesForEndpoint(endpoint);
            if (!isCurrent()) return;
            if (routes.isEmpty) {
              continue;
            }
            final match = _matchGtfsRoute(leg, routes);
            final route = match?.$1;
            if (route == null) {
              continue;
            }
            if (!isCurrent()) return;
            guardedSetState(() {
              _gtfsRoute = route;
              _gtfsAgency = null;
              _gtfsRouteEndpointKey = endpoint.key;
              _gtfsRouteMatchReason = '${match?.$2} (cached routes table)';
              _isLoadingRouteDebug = false;
              _routeDebugError = null;
            });
            return;
          }
        }

        if (!isCurrent()) return;
        guardedSetState(() {
          _isLoadingRouteDebug = false;
          _routeDebugError =
              'No GTFS route match found for route id $transportId';
        });
      },
      onError: (error, _) {
        if (!isCurrent()) return;
        safeLogInfo('Failed to load GTFS route debug data: $error');
        guardedSetState(() {
          _isLoadingRouteDebug = false;
          _routeDebugError = error.toString();
        });
      },
    );
  }

  Future<List<gtfs_route.Route>> _loadPersistedRoutesForEndpoint(
    StopsEndpoint endpoint,
  ) async {
    final rows = await StopsService.database.getRoutesForEndpoint(endpoint.key);
    return rows.map(_dbRouteToGtfsRoute).toList(growable: false);
  }

  gtfs_route.Route _dbRouteToGtfsRoute(db.Route route) {
    return gtfs_route.Route(
      routeId: route.routeId,
      routeShortName: route.routeShortName ?? '',
      routeLongName: route.routeLongName ?? '',
      routeDesc: route.routeDesc,
      routeType: route.routeType ?? '',
      routeColor: route.routeColor,
      routeTextColor: route.routeTextColor,
      routeSortOrder: route.routeSortOrder,
    );
  }

  Future<List<StopsEndpoint>> _candidateRouteEndpoints(
    Leg leg,
    TransportMode? mode,
  ) async {
    if (mode != null) {
      return NewTripService.getEndpointsForMode(mode);
    }

    final orderedKeys = <String>[];

    final stopIds = <String>{
      leg.origin.id,
      leg.destination.id,
      ...?leg.stopSequence?.map((stop) => stop.id),
    }.where((id) => id.isNotEmpty);

    for (final stopId in stopIds) {
      final rows = await runAsyncGuardedWithFallback(
        () => StopsService.database.getStopsById(stopId),
        const <db.Stop>[],
        onError: (error, _) {
          safeLogInfo(
            'Failed to resolve stop endpoint for route debug: $error',
          );
        },
      );
      for (final row in rows) {
        if (!orderedKeys.contains(row.endpoint)) {
          orderedKeys.add(row.endpoint);
        }
      }
    }

    return orderedKeys.map(_endpointForKey).whereType<StopsEndpoint>().toList();
  }

  (gtfs_route.Route, String)? _matchGtfsRoute(
    Leg leg,
    List<gtfs_route.Route> routes,
  ) {
    final transport = leg.transportation;
    final transportId = _legRouteIdFor(leg);
    final transportNumber = _transportNumber(transport);
    final trimmedTransportName = _trimmedOrNull(transport?.name);
    final trimmedDisassembledName = _transportDisassembledName(transport);
    final transportNames = <String>{
      if (trimmedTransportName != null && trimmedTransportName.isNotEmpty)
        trimmedTransportName,
      if (trimmedDisassembledName != null && trimmedDisassembledName.isNotEmpty)
        trimmedDisassembledName,
    };

    for (final route in routes) {
      if (transportId != null &&
          transportId.isNotEmpty &&
          route.routeId == transportId) {
        return (route, 'route_id == transportation.id');
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
