part of '../debug_entity_list_loader.dart';

extension _DebugRouteList on DebugEntityListLoader {
  Future<DebugEntityListPageData> _loadRouteList() async {
    final catalog = <String, _RouteListEntry>{};
    final persistedRoutes = await _loadDbRoutes();

    for (final persistedRoute in persistedRoutes) {
      final entry = catalog.putIfAbsent(
        persistedRoute.lineId,
        () => _RouteListEntry(routeId: persistedRoute.routeId),
      );
      entry.route ??= gtfs_route.Route(
        routeId: persistedRoute.routeId,
        routeShortName: persistedRoute.routeShortName ?? '',
        routeLongName: persistedRoute.routeLongName ?? '',
        routeDesc: persistedRoute.routeDesc,
        routeType: persistedRoute.routeType ?? '',
        routeColor: persistedRoute.routeColor,
        routeTextColor: persistedRoute.routeTextColor,
        routeSortOrder: persistedRoute.routeSortOrder,
      );
      final endpoint = _endpointForKey(persistedRoute.endpoint);
      if (endpoint != null) {
        entry.endpoints.add(endpoint);
      }
      entry.modes.add(_modeNameForEndpointKey(persistedRoute.endpoint));
      entry.sources.add(DebugDataSource.localDb);
    }

    final vehicleAggregation = await resolver.vehicleAggregation();
    for (final vehicle in vehicleAggregation.vehicles) {
      if (!vehicle.trip.hasRouteId() || vehicle.trip.routeId.isEmpty) {
        continue;
      }
      final entry = _routeEntryForRealtime(catalog, vehicle.trip.routeId);
      entry.sources.add(DebugDataSource.realtime);
      entry.activeVehicles += 1;
      if (vehicle.hasTimestamp()) {
        final timestamp = timestampFromUnixSeconds(vehicle.timestamp.toInt());
        final latestRealtime = entry.latestRealtime;
        if (latestRealtime == null ||
            (timestamp != null && timestamp.isAfter(latestRealtime))) {
          entry.latestRealtime = timestamp;
        }
      }
    }

    final tripUpdates = await resolver.tripUpdateAggregation();
    for (final update in tripUpdates.tripUpdates) {
      if (!update.trip.hasRouteId() || update.trip.routeId.isEmpty) {
        continue;
      }
      final entry = _routeEntryForRealtime(catalog, update.trip.routeId);
      entry.sources.add(DebugDataSource.realtime);
      entry.activeTrips += 1;
      if (update.hasTimestamp()) {
        final timestamp = timestampFromUnixSeconds(update.timestamp.toInt());
        final latestRealtime = entry.latestRealtime;
        if (latestRealtime == null ||
            (timestamp != null && timestamp.isAfter(latestRealtime))) {
          entry.latestRealtime = timestamp;
        }
      }
    }

    final items = catalog.values
        .map((entry) {
          final route = entry.route;
          final endpoints =
              entry.endpoints.map((endpoint) => endpoint.key).toList()..sort();
          final modes = entry.modes.toList()..sort();
          final filterValues = <String, List<String>>{};
          _putFilterValues(filterValues, 'mode', modes);
          _putFilterValues(filterValues, 'endpoint', endpoints);
          _putFilterValues(filterValues, 'activity', [
            routeActivity(
              hasGtfs:
                  entry.sources.contains(DebugDataSource.gtfs) ||
                  entry.sources.contains(DebugDataSource.localDb),
              hasRealtime: entry.sources.contains(DebugDataSource.realtime),
              activeTrips: entry.activeTrips,
              activeVehicles: entry.activeVehicles,
            ),
          ]);
          _putFilterValues(
            filterValues,
            'source',
            entry.sources.map((source) => source.label).toList()..sort(),
          );

          return DebugEntityListItem(
            entityType: DebugEntityType.route,
            entityId: entry.routeId,
            title: bestRouteTitle(route, entry.routeId),
            subtitle: bestRouteSubtitle(route, endpoints),
            description: routeDescription(
              agency: null,
              route: route,
              activeTrips: entry.activeTrips,
              activeVehicles: entry.activeVehicles,
            ),
            sources: sortedSources(entry.sources),
            filterValues: filterValues,
            searchTerms: [
              entry.routeId,
              if (route?.routeShortName case final shortName?) shortName,
              if (route?.routeLongName case final longName?) longName,
              if (route?.routeDesc case final routeDesc?) routeDesc,
              ...endpoints,
              ...modes,
            ],
            timestamp: entry.latestRealtime,
            request: DebugEntityRequest(
              entityType: DebugEntityType.route,
              entityId: entry.routeId,
              context: DebugEntityContext(
                gtfsEndpoint: entry.endpoints.isEmpty
                    ? null
                    : entry.endpoints.first,
              ),
            ),
          );
        })
        .toList(growable: false);

    return DebugEntityListPageData(
      entityType: DebugEntityType.route,
      title: 'Route Debug Browser',
      description:
          'Browse cached scheduled GTFS routes, enriched with any active realtime route activity.',
      emptyMessage:
          'No cached route data is available. Update static transport data from Settings before browsing scheduled routes.',
      items: items,
      sourceBadges: const [DebugDataSource.localDb, DebugDataSource.realtime],
      filterGroups: _buildFilterGroups(items, const {
        'source': 'Source',
        'mode': 'Mode',
        'endpoint': 'Endpoint',
        'activity': 'Activity',
      }),
      sortOptions: const [
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.titleDesc,
        DebugEntityListSort.idAsc,
        DebugEntityListSort.recentFirst,
      ],
      defaultSort: DebugEntityListSort.titleAsc,
      banners: items.isEmpty
          ? const [
              DebugStatusBannerData(
                tone: DebugStatusTone.warning,
                title: 'No route catalog available',
                message:
                    'The route browser loads cached route metadata and merges active realtime route IDs when available.',
                sources: [DebugDataSource.localDb, DebugDataSource.realtime],
              ),
            ]
          : const [],
    );
  }

  String _modeNameForEndpointKey(String endpoint) {
    return StopsService.modeForEndpointKey(endpoint)?.name ?? 'unknown';
  }

  StopsEndpoint? _endpointForKey(String endpointKey) {
    for (final endpoint in StopsEndpoint.values) {
      if (endpoint.key == endpointKey) {
        return endpoint;
      }
    }
    return null;
  }

  _RouteListEntry _routeEntryForRealtime(
    Map<String, _RouteListEntry> catalog,
    String routeId,
  ) {
    for (final entry in catalog.values) {
      if (entry.routeId == routeId) {
        return entry;
      }
    }
    return catalog.putIfAbsent(
      routeId,
      () => _RouteListEntry(routeId: routeId),
    );
  }
}

class _RouteListEntry {
  final String routeId;
  gtfs_route.Route? route;
  final Set<StopsEndpoint> endpoints = <StopsEndpoint>{};
  final Set<String> modes = <String>{};
  final Set<DebugDataSource> sources = <DebugDataSource>{};
  int activeTrips = 0;
  int activeVehicles = 0;
  DateTime? latestRealtime;

  _RouteListEntry({required this.routeId});
}
