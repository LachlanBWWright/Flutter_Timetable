import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/stops_service.dart';

class DebugEntityListLoader {
  final DebugEntityResolver resolver;
  final Future<List<db.Stop>> Function() _getAllDbStops;
  final Future<Map<TransportMode?, Map<String, int>>> Function()
  _getStopsCountByEndpoint;

  DebugEntityListLoader({
    required this.resolver,
    Future<List<db.Stop>> Function()? getAllDbStops,
    Future<Map<TransportMode?, Map<String, int>>> Function()?
    getStopsCountByEndpoint,
  }) : _getAllDbStops =
           getAllDbStops ?? (() => StopsService.database.getAllStops()),
       _getStopsCountByEndpoint =
           getStopsCountByEndpoint ?? StopsService.getStopsCountByEndpoint;

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

  Future<DebugEntityListPageData> _loadStopList() async {
    final rows = await _getAllDbStops();
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
          final localities = _sortedStrings(
            stopRows.map((row) => row.stopDesc),
          );
          final parentStations = _sortedStrings(
            stopRows.map((row) => row.parentStation),
          );
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
          };
          if (localities.isNotEmpty) {
            filterValues['locality'] = localities;
          }
          if (parentStations.isNotEmpty) {
            filterValues['parent'] = parentStations;
          }

          return DebugEntityListItem(
            entityType: DebugEntityType.stop,
            entityId: stopId,
            title: primary.stopName,
            subtitle:
                '$stopId • ${endpoints.length} endpoint${endpoints.length == 1 ? '' : 's'}',
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
    final managedEndpoints = await _managedEndpoints();

    for (final endpoint in managedEndpoints) {
      final data = await resolver.loadGtfsForEndpoint(endpoint);
      if (data == null) {
        continue;
      }
      final agenciesById = {
        for (final agency in data.agencies)
          if (agency.agencyId != null) agency.agencyId!: agency,
      };
      for (final route in data.routes) {
        final entry = catalog.putIfAbsent(
          route.routeId,
          () => _RouteListEntry(routeId: route.routeId),
        );
        entry.route ??= route;
        entry.agency ??= route.agencyId == null
            ? null
            : agenciesById[route.agencyId!];
        entry.endpoints.add(endpoint);
        entry.modes.add(_modeNameForEndpoint(endpoint));
        entry.sources.add(DebugDataSource.gtfs);
      }
    }

    final vehicleAggregation = await resolver.vehicleAggregation();
    for (final vehicle in vehicleAggregation.vehicles) {
      if (!vehicle.trip.hasRouteId() || vehicle.trip.routeId.isEmpty) {
        continue;
      }
      final entry = catalog.putIfAbsent(
        vehicle.trip.routeId,
        () => _RouteListEntry(routeId: vehicle.trip.routeId),
      );
      entry.sources.add(DebugDataSource.realtime);
      entry.activeVehicles += 1;
      if (vehicle.hasTimestamp()) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          vehicle.timestamp.toInt() * 1000,
        );
        if (entry.latestRealtime == null ||
            timestamp.isAfter(entry.latestRealtime!)) {
          entry.latestRealtime = timestamp;
        }
      }
    }

    final tripUpdates = await resolver.tripUpdateAggregation();
    for (final update in tripUpdates.tripUpdates) {
      if (!update.trip.hasRouteId() || update.trip.routeId.isEmpty) {
        continue;
      }
      final entry = catalog.putIfAbsent(
        update.trip.routeId,
        () => _RouteListEntry(routeId: update.trip.routeId),
      );
      entry.sources.add(DebugDataSource.realtime);
      entry.activeTrips += 1;
      if (update.hasTimestamp()) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          update.timestamp.toInt() * 1000,
        );
        if (entry.latestRealtime == null ||
            timestamp.isAfter(entry.latestRealtime!)) {
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
          if (modes.isNotEmpty) {
            filterValues['mode'] = modes;
          }
          if (endpoints.isNotEmpty) {
            filterValues['endpoint'] = endpoints;
          }
          final agencyName = entry.agency?.agencyName;
          if (agencyName != null && agencyName.isNotEmpty) {
            filterValues['agency'] = [agencyName];
          }
          filterValues['activity'] = [_routeActivity(entry)];
          filterValues['source'] =
              entry.sources.map((source) => source.label).toList()..sort();

          return DebugEntityListItem(
            entityType: DebugEntityType.route,
            entityId: entry.routeId,
            title: _bestRouteTitle(route, entry.routeId),
            subtitle: _bestRouteSubtitle(route, endpoints),
            description: _routeDescription(entry),
            sources: entry.sources.toList()
              ..sort((left, right) => left.label.compareTo(right.label)),
            filterValues: filterValues,
            searchTerms: [
              entry.routeId,
              if (route?.routeShortName case final shortName?) shortName,
              if (route?.routeLongName case final longName?) longName,
              if (route?.routeDesc case final routeDesc?) routeDesc,
              if (entry.agency?.agencyName case final agencyName?) agencyName,
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
          'Browse scheduled GTFS routes for managed endpoints, enriched with any active realtime route activity.',
      emptyMessage:
          'No route data could be loaded. Ensure you have a valid API key and managed stops data for at least one endpoint.',
      items: items,
      sourceBadges: const [DebugDataSource.gtfs, DebugDataSource.realtime],
      filterGroups: _buildFilterGroups(items, const {
        'source': 'Source',
        'mode': 'Mode',
        'endpoint': 'Endpoint',
        'agency': 'Agency',
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
                    'The route browser loads GTFS routes for locally managed endpoints and merges active realtime route IDs when available.',
                sources: [DebugDataSource.gtfs, DebugDataSource.realtime],
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
          ? DateTime.fromMillisecondsSinceEpoch(update.timestamp.toInt() * 1000)
          : null;
      final matchedVehicle = vehiclesByTripId[tripId];
      final stopIds = update.stopTimeUpdate
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
        filterValues['service_date'] = [update.trip.startDate];
      }
      if (stopIds.isNotEmpty) {
        filterValues['stop'] = stopIds;
      }

      items.add(
        DebugEntityListItem(
          entityType: DebugEntityType.trip,
          entityId: tripId,
          title: tripId,
          subtitle: 'Route: $routeId',
          description: _tripDescription(
            update,
            matchedVehicle: matchedVehicle,
            stopCount: stopIds.length,
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
              ? DateTime.fromMillisecondsSinceEpoch(
                  vehicle.timestamp.toInt() * 1000,
                )
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
            filterValues['occupancy'] = [occupancy];
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

  Future<List<StopsEndpoint>> _managedEndpoints() async {
    final grouped = await _getStopsCountByEndpoint();
    final endpointByKey = {
      for (final endpoint in StopsEndpoint.values) endpoint.key: endpoint,
    };
    final endpoints = <StopsEndpoint>{};
    for (final entry in grouped.values) {
      for (final endpointKey in entry.keys) {
        final endpoint = endpointByKey[endpointKey];
        if (endpoint != null) {
          endpoints.add(endpoint);
        }
      }
    }
    final result = endpoints.toList(growable: false)
      ..sort((left, right) => left.key.compareTo(right.key));
    return result;
  }

  List<DebugEntityListFilterGroup> _buildFilterGroups(
    List<DebugEntityListItem> items,
    Map<String, String> labels,
  ) {
    final groups = <DebugEntityListFilterGroup>[];
    for (final entry in labels.entries) {
      final counts = <String, int>{};
      for (final item in items) {
        final values = item.filterValues[entry.key] ?? const <String>[];
        for (final value in values) {
          if (value.isEmpty || value == 'unknown') {
            continue;
          }
          counts[value] = (counts[value] ?? 0) + 1;
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
                  label: _filterLabel(option.key),
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

  String _bestRouteTitle(gtfs_route.Route? route, String routeId) {
    if (route == null) {
      return routeId;
    }
    final longName = route.routeLongName;
    if (longName.isNotEmpty) {
      return longName;
    }
    final shortName = route.routeShortName;
    if (shortName.isNotEmpty) {
      return shortName;
    }
    return routeId;
  }

  String _bestRouteSubtitle(gtfs_route.Route? route, List<String> endpoints) {
    final parts = <String>[];
    final shortName = route?.routeShortName;
    if (shortName != null && shortName.isNotEmpty) {
      parts.add(shortName);
    }
    if (endpoints.isNotEmpty) {
      parts.add(endpoints.join(', '));
    }
    return parts.isEmpty ? 'No GTFS metadata' : parts.join(' • ');
  }

  String _routeDescription(_RouteListEntry entry) {
    final parts = <String>[];
    if (entry.agency?.agencyName case final agencyName?) {
      parts.add(agencyName);
    }
    if (entry.activeTrips > 0) {
      parts.add(
        '${entry.activeTrips} active trip${entry.activeTrips == 1 ? '' : 's'}',
      );
    }
    if (entry.activeVehicles > 0) {
      parts.add(
        '${entry.activeVehicles} active vehicle${entry.activeVehicles == 1 ? '' : 's'}',
      );
    }
    if (entry.route?.routeDesc case final routeDesc?) {
      parts.add(routeDesc);
    }
    return parts.join(' • ');
  }

  String _routeActivity(_RouteListEntry entry) {
    final hasGtfs = entry.sources.contains(DebugDataSource.gtfs);
    final hasRealtime = entry.sources.contains(DebugDataSource.realtime);
    if (!hasGtfs && hasRealtime) {
      return 'realtime_only';
    }
    if (entry.activeTrips > 0 && entry.activeVehicles > 0) {
      return 'active_trips_and_vehicles';
    }
    if (entry.activeTrips > 0) {
      return 'active_trips';
    }
    if (entry.activeVehicles > 0) {
      return 'active_vehicles';
    }
    return 'catalog_only';
  }

  String _tripDescription(
    TripUpdate update, {
    required VehiclePosition? matchedVehicle,
    required int stopCount,
  }) {
    final parts = <String>[];
    if (update.trip.hasStartDate()) {
      parts.add('Service date: ${update.trip.startDate}');
    }
    parts.add(
      '$stopCount stop update${stopCount == 1 ? '' : 's'}',
    );
    if (matchedVehicle != null) {
      parts.add('Vehicle: ${DebugExtractors.vehicleDisplayId(matchedVehicle)}');
    }
    return parts.join(' • ');
  }

  String _modeNameForEndpoint(StopsEndpoint endpoint) {
    return StopsService.modeForEndpointKey(endpoint.key)?.name ?? 'unknown';
  }

  List<String> _sortedStrings(Iterable<String?> values) {
    final result = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
    return result;
  }

  String _filterLabel(String value) {
    final normalized = value.replaceAll('_', ' ');
    if (normalized.isEmpty) {
      return value;
    }
    return normalized
        .split(' ')
        .map((segment) {
          if (segment.isEmpty) {
            return segment;
          }
          return '${segment[0].toUpperCase()}${segment.substring(1)}';
        })
        .join(' ');
  }
}

class _RouteListEntry {
  final String routeId;
  gtfs_route.Route? route;
  gtfs_agency.Agency? agency;
  final Set<StopsEndpoint> endpoints = <StopsEndpoint>{};
  final Set<String> modes = <String>{};
  final Set<DebugDataSource> sources = <DebugDataSource>{};
  int activeTrips = 0;
  int activeVehicles = 0;
  DateTime? latestRealtime;

  _RouteListEntry({required this.routeId});
}
