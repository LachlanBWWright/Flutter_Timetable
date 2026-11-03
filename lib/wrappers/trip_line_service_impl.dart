import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

part 'trip_line_service/models.dart';
part 'trip_line_service/endpoint_index.dart';
part 'trip_line_service/index_builder.dart';
part 'trip_line_service/persistence.dart';
part 'trip_line_service/static_import.dart';
part 'trip_line_service/stop_ranking.dart';

class TripLineService {
  TripLineService({
    TripLineGtfsLoader? gtfsLoader,
    TripLineStopLookup? stopLookup,
    bool readPersistedCache = true,
  }) : _gtfsLoader = gtfsLoader ?? NewTripService.fetchGtfsDataForEndpoint,
       _stopLookup = stopLookup ?? _lookupStopsFromDatabase,
       _readPersistedCache = readPersistedCache;

  static final TripLineService instance = TripLineService();

  final TripLineGtfsLoader _gtfsLoader;
  final TripLineStopLookup _stopLookup;
  final bool _readPersistedCache;
  final Map<String, Future<_EndpointLineIndex?>> _endpointIndexCache = {};

  static V? _mapValueOrNull<K, V>(Map<K, V> values, K key) {
    try {
      return values[key];
    } catch (_) {
      return null;
    }
  }

  static void _putValue<K, V>(Map<K, V> values, K key, V value) {
    try {
      values[key] = value;
    } catch (_) {}
  }

  Future<GtfsData?> _loadGtfsDataForEndpoint(StopsEndpoint endpoint) async {
    try {
      return await _gtfsLoader(endpoint);
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> _loadCachedOrBuildList<T>({
    required bool allowBuild,
    required Future<List<T>> Function() loadPersisted,
    required Future<List<T>> Function() build,
  }) async {
    if (_readPersistedCache) {
      final persisted = await _safeLoadList(loadPersisted);
      if (persisted.isNotEmpty || !allowBuild) {
        return persisted;
      }
    } else if (!allowBuild) {
      return <T>[];
    }

    return _safeLoadList(build);
  }

  Future<List<T>> _safeLoadList<T>(Future<List<T>> Function() loader) async {
    try {
      return await loader.call();
    } catch (_) {
      return <T>[];
    }
  }

  Future<List<TripLineLookupStop>> _safeLookupStops(String stopId) async {
    try {
      return await _stopLookup.call(stopId);
    } catch (_) {
      return const <TripLineLookupStop>[];
    }
  }

  Future<_EndpointLineIndex?> _safeGetIndexForEndpointKey(
    String endpointKey,
  ) async {
    return await _getIndexForEndpointKey(endpointKey);
  }

  Future<List<StopLineMatch>> getLinesForStop(
    String stopId, {
    TransportMode? mode,
    bool allowBuild = false,
  }) async {
    return _loadCachedOrBuildList(
      allowBuild: allowBuild,
      loadPersisted: () => _getPersistedLinesForStop(stopId, mode: mode),
      build: () => _buildLinesForStop(stopId, mode: mode),
    );
  }

  Future<List<StopLineMatch>> _buildLinesForStop(
    String stopId, {
    TransportMode? mode,
  }) async {
    final lookupStops = await _safeLookupStops(stopId);
    final endpointKeys = lookupStops.map((stop) => stop.endpointKey).where((
      endpointKey,
    ) {
      if (mode == null) {
        return true;
      }
      return StopsService.modeForEndpointKey(endpointKey) == mode;
    }).toSet();

    final matches = <String, StopLineMatch>{};
    for (final endpointKey in endpointKeys) {
      final index = await _safeGetIndexForEndpointKey(endpointKey);
      if (index == null) {
        continue;
      }
      final stopLines = _mapValueOrNull(index.stopToLines, stopId);
      if (stopLines != null) {
        for (final line in stopLines) {
          _putValue(matches, line.lineId, line);
        }
      }
    }

    return matches.values.toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<StopLineMatch>> findSharedLines(
    String stopA,
    String stopB, {
    required TransportMode mode,
    bool allowBuild = false,
  }) async {
    final linesForA = await getLinesForStop(
      stopA,
      mode: mode,
      allowBuild: allowBuild,
    );
    if (linesForA.isEmpty) {
      return const [];
    }

    final lineIdsForB = (await getLinesForStop(
      stopB,
      mode: mode,
      allowBuild: allowBuild,
    )).map((line) => line.lineId).toSet();

    return linesForA.where((line) => lineIdsForB.contains(line.lineId)).toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<LineScopedStop>> getStopsForLine(
    String lineId,
    TransportMode mode, {
    bool allowBuild = false,
  }) async {
    return _loadCachedOrBuildList(
      allowBuild: allowBuild,
      loadPersisted: () => _getPersistedStopsForLine(lineId, mode),
      build: () => _buildStopsForLine(lineId, mode),
    );
  }

  Future<List<LineScopedStop>> _buildStopsForLine(
    String lineId,
    TransportMode mode,
  ) async {
    final endpointKey = _endpointKeyFromLineId(lineId);
    final index = await _safeGetIndexForEndpointKey(endpointKey);
    if (index == null || index.mode != mode) {
      return const [];
    }
    final stops = _mapValueOrNull(index.lineStops, lineId);
    return stops ?? const [];
  }

  Future<List<LineScopedStop>> getNearbyLineStops({
    required String anchorStopId,
    required String lineId,
    required TransportMode mode,
    double radiusKm = 5,
  }) async {
    final stops = await rankStopsForLine(
      lineId: lineId,
      mode: mode,
      anchorStopIds: [anchorStopId],
      radiusKm: radiusKm,
      allowBuild: false,
    );
    return stops.where((stop) => stop.isWithinAnchorRadius).toList();
  }

  Future<List<LineScopedStop>> rankStopsForLine({
    required String lineId,
    required TransportMode mode,
    Iterable<String> anchorStopIds = const [],
    Iterable<String> excludedStopIds = const [],
    double radiusKm = 5,
    bool allowBuild = false,
  }) async {
    final stops = await getStopsForLine(lineId, mode, allowBuild: allowBuild);
    if (stops.isEmpty) {
      return const [];
    }

    final excludedIds = excludedStopIds.toSet();
    final anchorCoordinates = await _loadAnchorCoordinates(anchorStopIds);

    final ranked = stops
        .where((stop) => !excludedIds.contains(stop.stopId))
        .map((stop) {
          final distanceKm = _distanceToNearestAnchor(stop, anchorCoordinates);
          return stop.copyWith(
            distanceKm: distanceKm,
            isWithinAnchorRadius: distanceKm != null && distanceKm <= radiusKm,
          );
        })
        .toList();

    ranked.sort((a, b) {
      if (a.isWithinAnchorRadius != b.isWithinAnchorRadius) {
        return a.isWithinAnchorRadius ? -1 : 1;
      }

      final distanceA = a.distanceKm;
      final distanceB = b.distanceKm;
      if (distanceA != null && distanceB != null) {
        final byDistance = distanceA.compareTo(distanceB);
        if (byDistance != 0) {
          return byDistance;
        }
      } else if (distanceA != null) {
        return -1;
      } else if (distanceB != null) {
        return 1;
      }

      final byName = a.stopName.compareTo(b.stopName);
      if (byName != 0) {
        return byName;
      }

      return a.stopOrder.compareTo(b.stopOrder);
    });

    return ranked;
  }

  void clearCache() {
    _endpointIndexCache.clear();
  }

  Future<void> prefetchIndexesForEndpoints(
    Iterable<StopsEndpoint> endpoints,
  ) async {
    await Future.wait(
      endpoints.map((endpoint) async {
        try {
          final persistedCount = await StopsService.database
              .getStopLineMembershipCountForEndpoint(endpoint.key);
          if (persistedCount > 0) {
            return;
          }
          await _getIndexForEndpointKey(endpoint.key);
        } catch (_) {
          // Swallow error
        }
      }),
    );
  }

  Future<void> cacheGtfsDataForEndpoint(
    StopsEndpoint endpoint,
    GtfsData data,
  ) => publishStaticDataForEndpoint(endpoint, data);

  Future<void> cacheRoutesForEndpoint(
    StopsEndpoint endpoint,
    GtfsData data,
  ) async {
    final release = await EndpointStaticUpdateQueue.acquire(endpoint);
    try {
      await _cacheRoutesForEndpoint(endpoint, data);
    } finally {
      release();
    }
  }

  static Future<List<TripLineLookupStop>> _lookupStopsFromDatabase(
    String stopId,
  ) async {
    List<db.Stop> rows = const <db.Stop>[];
    try {
      rows = await StopsService.database.getStopsById(stopId);
    } catch (_) {}
    return rows
        .map(
          (row) => TripLineLookupStop(
            stopId: row.stopId,
            stopName: row.stopName,
            endpointKey: row.endpoint,
            latitude: row.stopLat == 0.0 ? null : row.stopLat,
            longitude: row.stopLon == 0.0 ? null : row.stopLon,
          ),
        )
        .toList();
  }

  static String _endpointKeyFromLineId(String lineId) {
    final separatorIndex = lineId.indexOf('|');
    if (separatorIndex == -1) {
      return '';
    }
    return lineId.substring(0, separatorIndex);
  }
}
