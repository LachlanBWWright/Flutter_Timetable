import 'package:collection/collection.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_list_utils.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/stops_service.dart';

class DebugEntityListLoader {
  final DebugEntityResolver resolver;
  final List<db.Stop>? _preloadedDbStops;
  final List<db.Route>? _preloadedDbRoutes;

  DebugEntityListLoader({
    required this.resolver,
    List<db.Stop>? preloadedDbStops,
    List<db.Route>? preloadedDbRoutes,
  }) : _preloadedDbStops = preloadedDbStops,
       _preloadedDbRoutes = preloadedDbRoutes;

  Future<DebugEntityListPageData> load(DebugEntityType entityType) {
    switch (entityType) {
      case DebugEntityType.stop:
        return _loadStopList();
      case DebugEntityType.route:
        return _loadRouteList();
      case DebugEntityType.trip:
        return _loadTripList();
      case DebugEntityType.vehicle:
        return _loadVehicleList();
    }
  }

  Future<List<db.Stop>> _loadDbStops() async {
    final preloadedStops = _preloadedDbStops;
    if (preloadedStops != null) {
      return preloadedStops;
    }
    return StopsService.database.getAllStops();
  }

  Future<List<db.Route>> _loadDbRoutes() async {
    final preloadedRoutes = _preloadedDbRoutes;
    if (preloadedRoutes != null) {
      return preloadedRoutes;
    }
    return StopsService.database.getAllRoutes();
  }

  Future<DebugEntityListPageData> _loadStopList() async {
    final rows = await _loadDbStops();
    final grouped = <String, List<db.Stop>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.stopId, () => <db.Stop>[]).add(row);
    }

    final items = grouped.entries
        .map((entry) {
          final stopId = entry.key;
          final stopRows = entry.value;
          final primary = stopRows.first;
          final endpoints = stopRows.map((row) => row.endpoint).toSet().toList()
            ..sort();
          final modes =
              stopRows
                  .map(
                    (row) =>
                        StopsService.modeForEndpointKey(row.endpoint)?.name ??
                        'unknown',
                  )
                  .toSet()
                  .toList()
                ..sort();
          final localities = sortedStrings(stopRows.map((row) => row.stopDesc));
          final parentStations = sortedStrings(
            stopRows.map((row) => row.parentStation),
          );
          final parentStatus = parentStations.isEmpty
              ? 'no_parent'
              : 'has_parent';
          final coverage = endpoints.length > 1
              ? 'multi_endpoint'
              : 'single_endpoint';
          final searchTerms = <String>{
            primary.stopName,
            primary.stopCode ?? '',
            primary.stopDesc ?? '',
            primary.parentStation ?? '',
            ...endpoints,
            ...localities,
            ...parentStations,
          }..removeWhere((term) => term.isEmpty);

          final filterValues = <String, List<String>>{
            'mode': modes,
            'endpoint': endpoints,
            'coverage': [coverage],
            'parent_status': [parentStatus],
          };
          _putFilterValues(filterValues, 'locality', localities);
          _putFilterValues(filterValues, 'parent', parentStations);

          return DebugEntityListItem(
            entityType: DebugEntityType.stop,
            entityId: stopId,
            title: primary.stopName,
            subtitle: listSubtitleForEntity(
              DebugEntityType.stop,
              stopId,
              endpoints.length,
            ),
            description: primary.stopDesc,
            sources: const [DebugDataSource.localDb],
            filterValues: filterValues,
            searchTerms: searchTerms.toList()..sort(),
            request: DebugEntityRequest(
              entityType: DebugEntityType.stop,
              entityId: stopId,
              context: DebugEntityContext(dbStops: stopRows),
            ),
          );
        })
        .toList(growable: false);

    return DebugEntityListPageData(
      entityType: DebugEntityType.stop,
      title: 'Stop Debug Browser',
      description:
          'Browse locally managed stop records and open the standalone stop debug page for any stop ID.',
      emptyMessage:
          'No local stop data is available. Load stops data from Settings before browsing stop debug pages.',
      items: items,
      sourceBadges: const [DebugDataSource.localDb],
      filterGroups: _buildFilterGroups(items, const {
        'mode': 'Mode',
        'endpoint': 'Endpoint',
        'coverage': 'Coverage',
        'parent_status': 'Parent status',
        'locality': 'Locality',
        'parent': 'Parent stop',
      }),
      sortOptions: const [
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.titleDesc,
        DebugEntityListSort.idAsc,
        DebugEntityListSort.idDesc,
      ],
      defaultSort: DebugEntityListSort.titleAsc,
      banners: items.isEmpty
          ? const [
              DebugStatusBannerData(
                tone: DebugStatusTone.warning,
                title: 'No managed stops',
                message:
                    'The stop browser uses the local stops database. Use the stops management tools to load data first.',
                sources: [DebugDataSource.localDb],
              ),
            ]
          : const [],
    );
  }

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

  Future<DebugEntityListPageData> _loadTripList() async {
    final tripUpdates = await resolver.tripUpdateAggregation();
    final vehicleAggregation = await resolver.vehicleAggregation();
    final vehiclesByTripId = <String, VehiclePosition>{};
    for (final vehicle in vehicleAggregation.vehicles) {
      if (vehicle.trip.hasTripId() && vehicle.trip.tripId.isNotEmpty) {
        vehiclesByTripId.putIfAbsent(vehicle.trip.tripId, () => vehicle);
      }
    }

    final items = <DebugEntityListItem>[];
    final seenTripIds = <String>{};
    for (final update in tripUpdates.tripUpdates) {
      if (!update.trip.hasTripId() || update.trip.tripId.isEmpty) {
        continue;
      }
      final tripId = update.trip.tripId;
      if (!seenTripIds.add(tripId)) {
        continue;
      }
      final routeId = update.trip.hasRouteId()
          ? update.trip.routeId
          : 'unknown';
      final timestamp = update.hasTimestamp()
          ? timestampFromUnixSeconds(update.timestamp.toInt())
          : null;
      final matchedVehicle = _mapValue(vehiclesByTripId, tripId);
      final stopIds =
          update.stopTimeUpdate
              .where(
                (stopUpdate) =>
                    stopUpdate.hasStopId() && stopUpdate.stopId.isNotEmpty,
              )
              .map((stopUpdate) => stopUpdate.stopId)
              .toSet()
              .toList()
            ..sort();
      final filterValues = <String, List<String>>{
        'route': [routeId],
        'source': [
          DebugDataSource.realtime.label,
          DebugDataSource.derived.label,
        ],
        'vehicle': [
          matchedVehicle == null ? 'no_vehicle_match' : 'matched_vehicle',
        ],
      };
      if (update.trip.hasStartDate()) {
        _putFilterValues(filterValues, 'service_date', [update.trip.startDate]);
      }
      _putFilterValues(filterValues, 'stop', stopIds);

      items.add(
        DebugEntityListItem(
          entityType: DebugEntityType.trip,
          entityId: tripId,
          title: tripId,
          subtitle: 'Route: $routeId',
          description: tripDescription(
            serviceDate: update.trip.hasStartDate()
                ? update.trip.startDate
                : null,
            stopCount: stopIds.length,
            matchedVehicleId: matchedVehicle == null
                ? null
                : DebugExtractors.vehicleDisplayId(matchedVehicle),
          ),
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          filterValues: filterValues,
          searchTerms: [
            tripId,
            routeId,
            if (update.trip.hasStartDate()) update.trip.startDate,
            ...stopIds,
            if (matchedVehicle != null)
              DebugExtractors.vehicleDisplayId(matchedVehicle),
          ],
          timestamp: timestamp,
          request: DebugEntityRequest(
            entityType: DebugEntityType.trip,
            entityId: tripId,
            context: DebugEntityContext(
              tripUpdate: update,
              vehiclePosition: matchedVehicle,
            ),
          ),
        ),
      );
    }

    return DebugEntityListPageData(
      entityType: DebugEntityType.trip,
      title: 'Trip Debug Browser',
      description:
          'Browse active realtime trips. Each entry opens the standalone trip debug page with realtime context attached.',
      emptyMessage:
          'No active realtime trips are currently available for debugging.',
      items: items,
      sourceBadges: const [DebugDataSource.realtime, DebugDataSource.derived],
      filterGroups: _buildFilterGroups(items, const {
        'route': 'Route',
        'source': 'Source',
        'service_date': 'Service date',
        'vehicle': 'Vehicle match',
        'stop': 'Stop',
      }),
      sortOptions: const [
        DebugEntityListSort.recentFirst,
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.idAsc,
      ],
      defaultSort: DebugEntityListSort.recentFirst,
      banners: const [
        DebugStatusBannerData(
          tone: DebugStatusTone.info,
          title: 'Realtime trip catalog',
          message:
              'Trip browser results come from active realtime trip updates, so only currently published trips appear here.',
          sources: [DebugDataSource.realtime, DebugDataSource.derived],
        ),
      ],
    );
  }

  Future<DebugEntityListPageData> _loadVehicleList() async {
    final aggregation = await resolver.vehicleAggregation();
    final items = aggregation.vehicles
        .map((vehicle) {
          final vehicleId =
              DebugExtractors.vehicleId(vehicle) ??
              DebugExtractors.vehicleDisplayId(vehicle);
          final routeId = DebugExtractors.vehicleRouteId(vehicle) ?? 'unknown';
          final tripId = DebugExtractors.vehicleTripId(vehicle) ?? 'unknown';
          final occupancy = vehicle.hasOccupancyStatus()
              ? vehicle.occupancyStatus.name
              : 'unknown';
          final timestamp = vehicle.hasTimestamp()
              ? timestampFromUnixSeconds(vehicle.timestamp.toInt())
              : null;

          final filterValues = <String, List<String>>{
            'route': [routeId],
            'trip': [tripId],
            'status': [
              vehicle.hasCurrentStatus()
                  ? vehicle.currentStatus.name
                  : 'unknown',
            ],
          };
          if (occupancy != 'unknown') {
            _putFilterValues(filterValues, 'occupancy', [occupancy]);
          }

          return DebugEntityListItem(
            entityType: DebugEntityType.vehicle,
            entityId: vehicleId,
            title: DebugExtractors.vehicleDisplayId(vehicle),
            subtitle: 'Trip: $tripId • Route: $routeId',
            description: vehicle.hasCurrentStatus()
                ? 'Status: ${vehicle.currentStatus.name}'
                : 'Realtime vehicle position',
            sources: const [DebugDataSource.realtime],
            filterValues: filterValues,
            searchTerms: [
              vehicleId,
              DebugExtractors.vehicleDisplayId(vehicle),
              tripId,
              routeId,
              if (vehicle.vehicle.hasLicensePlate())
                vehicle.vehicle.licensePlate,
              if (occupancy != 'unknown') occupancy,
            ],
            timestamp: timestamp,
            request: DebugEntityRequest(
              entityType: DebugEntityType.vehicle,
              entityId: vehicleId,
              context: DebugEntityContext(vehiclePosition: vehicle),
            ),
          );
        })
        .toList(growable: false);

    return DebugEntityListPageData(
      entityType: DebugEntityType.vehicle,
      title: 'Vehicle Debug Browser',
      description:
          'Browse active realtime vehicles and open their standalone debug pages with live position context.',
      emptyMessage:
          'No active realtime vehicles are currently available for debugging.',
      items: items,
      sourceBadges: const [DebugDataSource.realtime],
      filterGroups: _buildFilterGroups(items, const {
        'route': 'Route',
        'trip': 'Trip',
        'status': 'Status',
        'occupancy': 'Occupancy',
      }),
      sortOptions: const [
        DebugEntityListSort.recentFirst,
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.idAsc,
      ],
      defaultSort: DebugEntityListSort.recentFirst,
    );
  }

  List<DebugEntityListFilterGroup> _buildFilterGroups(
    List<DebugEntityListItem> items,
    Map<String, String> labels,
  ) {
    final groups = <DebugEntityListFilterGroup>[];
    for (final entry in labels.entries) {
      final counts = <String, int>{};
      for (final item in items) {
        final values = _filterValuesForItem(item, entry.key);
        for (final value in values) {
          if (value.isEmpty || value == 'unknown') {
            continue;
          }
          _incrementCount(counts, value);
        }
      }
      if (counts.isEmpty) {
        continue;
      }
      final options =
          counts.entries
              .map(
                (option) => DebugEntityListFilterOption(
                  id: option.key,
                  label: filterLabel(option.key),
                  count: option.value,
                ),
              )
              .toList(growable: false)
            ..sort((left, right) => left.label.compareTo(right.label));
      groups.add(
        DebugEntityListFilterGroup(
          key: entry.key,
          label: entry.value,
          options: options,
        ),
      );
    }
    return groups;
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

  void _putFilterValues(
    Map<String, List<String>> filterValues,
    String key,
    List<String> values,
  ) {
    if (values.isEmpty) {
      return;
    }
    filterValues.addAll({key: values});
  }

  List<String> _filterValuesForItem(DebugEntityListItem item, String key) {
    return item.filterValues.entries
            .firstWhereOrNull((entry) => entry.key == key)
            ?.value ??
        const <String>[];
  }

  T? _mapValue<K, T>(Map<K, T> values, K key) {
    return values.entries.firstWhereOrNull((entry) => entry.key == key)?.value;
  }

  void _incrementCount(Map<String, int> counts, String value) {
    final current = _mapValue(counts, value) ?? 0;
    counts.addAll({value: current + 1});
  }
}

DebugEntityListPageLoader buildDebugEntityListLoader({
  DebugGtfsLoader? getGtfsDataForEndpoint,
  DebugVehicleAggregationLoader? getAllVehiclesAggregated,
  DebugTripUpdateAggregationLoader? getAllTripUpdatesAggregated,
  DebugDbStopLoader? getDbStopsById,
}) {
  final resolver = buildDebugEntityResolver(
    getGtfsDataForEndpoint: getGtfsDataForEndpoint,
    getAllVehiclesAggregated: getAllVehiclesAggregated,
    getAllTripUpdatesAggregated: getAllTripUpdatesAggregated,
    getDbStopsById: getDbStopsById,
  );
  final loader = DebugEntityListLoader(resolver: resolver);
  return loader.load;
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
