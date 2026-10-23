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

part 'list_loader/stop_list.dart';
part 'list_loader/route_list.dart';
part 'list_loader/realtime_lists.dart';

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
