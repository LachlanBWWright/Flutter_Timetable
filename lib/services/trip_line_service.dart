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
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

typedef TripLineStopLookup =
    Future<List<TripLineLookupStop>> Function(String stopId);

typedef TripLineGtfsLoader = Future<GtfsData?> Function(StopsEndpoint endpoint);

class TripLineLookupStop {
  const TripLineLookupStop({
    required this.stopId,
    required this.stopName,
    required this.endpointKey,
    this.latitude,
    this.longitude,
  });

  final String stopId;
  final String stopName;
  final String endpointKey;
  final double? latitude;
  final double? longitude;
}

class StopLineMatch {
  const StopLineMatch({
    required this.mode,
    required this.lineId,
    required this.lineName,
    required this.endpointKey,
  });

  final TransportMode mode;
  final String lineId;
  final String lineName;
  final String endpointKey;
}

class LineScopedStop {
  const LineScopedStop({
    required this.stopId,
    required this.stopName,
    required this.mode,
    required this.lineId,
    required this.lineName,
    required this.endpointKey,
    required this.stopOrder,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isWithinAnchorRadius = false,
  });

  final String stopId;
  final String stopName;
  final TransportMode mode;
  final String lineId;
  final String lineName;
  final String endpointKey;
  final int stopOrder;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isWithinAnchorRadius;

  Station toStation() {
    return Station(
      name: stopName,
      id: stopId,
      mode: mode,
      latitude: latitude,
      longitude: longitude,
      distance: distanceKm,
      lineId: lineId,
      lineName: lineName,
      isPreferredNearby: isWithinAnchorRadius,
      lineStopOrder: stopOrder,
    );
  }

  LineScopedStop copyWith({double? distanceKm, bool? isWithinAnchorRadius}) {
    return LineScopedStop(
      stopId: stopId,
      stopName: stopName,
      mode: mode,
      lineId: lineId,
      lineName: lineName,
      endpointKey: endpointKey,
      stopOrder: stopOrder,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      isWithinAnchorRadius: isWithinAnchorRadius ?? this.isWithinAnchorRadius,
    );
  }
}

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

  Future<List<StopLineMatch>> getLinesForStop(
    String stopId, {
    TransportMode? mode,
    bool allowBuild = false,
  }) async {
    if (_readPersistedCache) {
      List<StopLineMatch> persisted = const [];
      try {
        persisted = await _getPersistedLinesForStop(stopId, mode: mode);
      } catch (_) {
        // Swallow and fallback to build
      }
      if (persisted.isNotEmpty || !allowBuild) {
        return persisted;
      }
    } else if (!allowBuild) {
      return const [];
    }

    List<TripLineLookupStop> lookupStops = const [];
    try {
      lookupStops = await _stopLookup(stopId);
    } catch (_) {
      // fallback to empty
    }
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
      _EndpointLineIndex? index;
      try {
        index = await _getIndexForEndpointKey(endpointKey);
      } catch (_) {
        continue;
      }
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
    List<StopLineMatch> linesForA = const [];
    try {
      linesForA = await getLinesForStop(
        stopA,
        mode: mode,
        allowBuild: allowBuild,
      );
    } catch (_) {}
    if (linesForA.isEmpty) {
      return const [];
    }

    Set<String> lineIdsForB = const {};
    try {
      lineIdsForB = (await getLinesForStop(
        stopB,
        mode: mode,
        allowBuild: allowBuild,
      )).map((line) => line.lineId).toSet();
    } catch (_) {}

    return linesForA.where((line) => lineIdsForB.contains(line.lineId)).toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<LineScopedStop>> getStopsForLine(
    String lineId,
    TransportMode mode, {
    bool allowBuild = false,
  }) async {
    if (_readPersistedCache) {
      List<LineScopedStop> persisted = const [];
      try {
        persisted = await _getPersistedStopsForLine(lineId, mode);
      } catch (_) {}
      if (persisted.isNotEmpty || !allowBuild) {
        return persisted;
      }
    } else if (!allowBuild) {
      return const [];
    }

    final endpointKey = _endpointKeyFromLineId(lineId);
    _EndpointLineIndex? index;
    try {
      index = await _getIndexForEndpointKey(endpointKey);
    } catch (_) {
      return const [];
    }
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
    try {
      final stops = await rankStopsForLine(
        lineId: lineId,
        mode: mode,
        anchorStopIds: [anchorStopId],
        radiusKm: radiusKm,
        allowBuild: false,
      );
      return stops.where((stop) => stop.isWithinAnchorRadius).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<LineScopedStop>> rankStopsForLine({
    required String lineId,
    required TransportMode mode,
    Iterable<String> anchorStopIds = const [],
    Iterable<String> excludedStopIds = const [],
    double radiusKm = 5,
    bool allowBuild = false,
  }) async {
    List<LineScopedStop> stops = const [];
    try {
      stops = await getStopsForLine(lineId, mode, allowBuild: allowBuild);
    } catch (_) {
      return const [];
    }
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
  ) async {
    final mode = StopsService.modeForEndpointKey(endpoint.key);
    if (mode == null) {
      return;
    }
    final index = await _buildEndpointLineIndexInBackground(
      endpointKey: endpoint.key,
      mode: mode,
      data: data,
    );
    await _storeIndexForEndpoint(endpoint.key, index);
    await cacheRoutesForEndpoint(endpoint, data);
  }

  Future<void> cacheRoutesForEndpoint(
    StopsEndpoint endpoint,
    GtfsData data,
  ) async {
    final routeRows = data.routes
        .where((route) => route.routeId.trim().isNotEmpty)
        .map(
          (route) => db.RoutesCompanion.insert(
            endpoint: endpoint.key,
            routeId: route.routeId.trim(),
            lineId: '${endpoint.key}|${route.routeId.trim()}',
            routeShortName: drift.Value(route.routeShortName),
            routeLongName: drift.Value(route.routeLongName),
            routeDesc: drift.Value(route.routeDesc),
            routeType: drift.Value(route.routeType),
            routeColor: drift.Value(route.routeColor),
            routeTextColor: drift.Value(route.routeTextColor),
            routeSortOrder: drift.Value(route.routeSortOrder),
          ),
        )
        .toList(growable: false);
    await StopsService.database.replaceRoutesForEndpoint(
      endpoint.key,
      routeRows,
    );
  }

  Future<List<_StopCoordinate>> _loadAnchorCoordinates(
    Iterable<String> anchorStopIds,
  ) async {
    final anchors = <_StopCoordinate>[];
    for (final anchorStopId in anchorStopIds) {
      List<TripLineLookupStop> lookupStops = const [];
      try {
        lookupStops = await _stopLookup(anchorStopId);
      } catch (_) {}
      for (final stop in lookupStops) {
        final latitude = stop.latitude;
        final longitude = stop.longitude;
        if (latitude != null && longitude != null) {
          anchors.add(
            _StopCoordinate(latitude: latitude, longitude: longitude),
          );
        }
      }
    }
    return anchors;
  }

  double? _distanceToNearestAnchor(
    LineScopedStop stop,
    List<_StopCoordinate> anchors,
  ) {
    final latitude = stop.latitude;
    final longitude = stop.longitude;
    if (latitude == null || longitude == null || anchors.isEmpty) {
      return null;
    }

    double? bestDistance;
    for (final anchor in anchors) {
      final distance = LocationService.calculateDistance(
        anchor.latitude,
        anchor.longitude,
        latitude,
        longitude,
      );
      if (bestDistance == null || distance < bestDistance) {
        bestDistance = distance;
      }
    }
    return bestDistance;
  }

  Future<_EndpointLineIndex?> _getIndexForEndpointKey(
    String endpointKey,
  ) async {
    final future = _endpointIndexCache.putIfAbsent(
      endpointKey,
      () => _buildIndexForEndpointKey(endpointKey),
    );
    return future;
  }

  Future<_EndpointLineIndex?> _buildIndexForEndpointKey(
    String endpointKey,
  ) async {
    final endpoint = StopsEndpoint.values
        .where((value) => value.key == endpointKey)
        .firstOrNull;
    if (endpoint == null) {
      return null;
    }

    final mode = StopsService.modeForEndpointKey(endpointKey);
    if (mode == null) {
      return null;
    }

    final data = await _loadGtfsDataForEndpoint(endpoint);
    if (data == null) {
      return null;
    }

    final index = await _buildEndpointLineIndexInBackground(
      endpointKey: endpointKey,
      mode: mode,
      data: data,
    );
    if (_readPersistedCache) {
      await _storeIndexForEndpoint(endpointKey, index);
      await cacheRoutesForEndpoint(endpoint, data);
    }
    return index;
  }

  Future<_EndpointLineIndex> _buildEndpointLineIndexInBackground({
    required String endpointKey,
    required TransportMode mode,
    required GtfsData data,
  }) {
    return compute(
      _buildEndpointLineIndex,
      _EndpointLineIndexBuildRequest(
        endpointKey: endpointKey,
        mode: mode,
        data: data,
      ),
    );
  }

  Future<List<StopLineMatch>> _getPersistedLinesForStop(
    String stopId, {
    TransportMode? mode,
  }) async {
    List<db.StopLineMembership> rows = const <db.StopLineMembership>[];
    try {
      rows = await StopsService.database.getStopLineMembershipsForStop(stopId);
    } catch (_) {}
    final matches = <String, StopLineMatch>{};
    for (final row in rows) {
      final rowMode = _modeFromStoredValue(row.mode);
      if (rowMode == null || (mode != null && rowMode != mode)) {
        continue;
      }
      _putValue(
        matches,
        row.lineId,
        StopLineMatch(
          mode: rowMode,
          lineId: row.lineId,
          lineName: row.lineName,
          endpointKey: row.endpoint,
        ),
      );
    }
    return matches.values.toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<LineScopedStop>> _getPersistedStopsForLine(
    String lineId,
    TransportMode mode,
  ) async {
    List<db.StopLineMembership> rows = const <db.StopLineMembership>[];
    try {
      rows = await StopsService.database.getStopLineMembershipsForLine(lineId);
    } catch (_) {}
    return rows
        .where((row) => _modeFromStoredValue(row.mode) == mode)
        .map(
          (row) => LineScopedStop(
            stopId: row.stopId,
            stopName: row.stopName,
            mode: mode,
            lineId: row.lineId,
            lineName: row.lineName,
            endpointKey: row.endpoint,
            stopOrder: row.stopOrder,
            latitude: row.stopLat,
            longitude: row.stopLon,
          ),
        )
        .toList();
  }

  Future<void> _storeIndexForEndpoint(
    String endpointKey,
    _EndpointLineIndex index,
  ) async {
    final memberships = <db.StopLineMembershipsCompanion>[];
    for (final stops in index.lineStops.values) {
      for (final stop in stops) {
        memberships.add(
          db.StopLineMembershipsCompanion.insert(
            endpoint: endpointKey,
            stopId: stop.stopId,
            stopName: stop.stopName,
            lineId: stop.lineId,
            lineName: stop.lineName,
            mode: stop.mode.id,
            stopOrder: stop.stopOrder,
            stopLat: drift.Value(stop.latitude),
            stopLon: drift.Value(stop.longitude),
          ),
        );
      }
    }
    await StopsService.database.replaceStopLineMembershipsForEndpoint(
      endpointKey,
      memberships,
    );
  }

  TransportMode? _modeFromStoredValue(String value) {
    for (final mode in TransportMode.values) {
      if (mode.id == value) {
        return mode;
      }
    }
    return null;
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

class _EndpointLineIndex {
  const _EndpointLineIndex({
    required this.mode,
    required this.stopToLines,
    required this.lineStops,
  });

  final TransportMode mode;
  final Map<String, List<StopLineMatch>> stopToLines;
  final Map<String, List<LineScopedStop>> lineStops;

  static _EndpointLineIndex build({
    required String endpointKey,
    required TransportMode mode,
    required GtfsData data,
  }) {
    final routesById = <String, gtfs_route.Route>{
      for (final route in data.routes) route.routeId: route,
    };
    final routeIdByTripId = <String, String>{
      for (final trip in data.trips) trip.tripId: trip.routeId,
    };
    final stopsById = <String, gtfs_stop.Stop>{
      for (final stop in data.stops) stop.stopId: stop,
    };

    final stopToLines = <String, Map<String, StopLineMatch>>{};
    final lineStopsAccumulators = <String, Map<String, _LineStopAccumulator>>{};

    for (final stopTime in data.stopTimes) {
      final routeId = TripLineService._mapValueOrNull(
        routeIdByTripId,
        stopTime.tripId,
      );
      if (routeId == null) {
        continue;
      }

      final route = TripLineService._mapValueOrNull(routesById, routeId);
      if (route == null) {
        continue;
      }

      final stopId = stopTime.stopId.trim();
      if (stopId.isEmpty) {
        continue;
      }

      _NormalizedStop normalizedStop;
      try {
        normalizedStop = _NormalizedStop.fromGtfsStopId(stopId, stopsById);
      } catch (_) {
        continue;
      }

      final lineId = '$endpointKey|${route.routeId}';
      final lineName = _resolveLineName(route);
      final lineMatch = StopLineMatch(
        mode: mode,
        lineId: lineId,
        lineName: lineName,
        endpointKey: endpointKey,
      );

      final stopLines = stopToLines.putIfAbsent(
        normalizedStop.stopId,
        () => {},
      );
      TripLineService._putValue(stopLines, lineId, lineMatch);

      final order = int.tryParse(stopTime.stopSequence) ?? 0;
      final accumulatorsForLine = lineStopsAccumulators.putIfAbsent(
        lineId,
        () => {},
      );
      accumulatorsForLine.update(
        normalizedStop.stopId,
        (existing) => existing.addOrder(order),
        ifAbsent: () => _LineStopAccumulator(
          stopId: normalizedStop.stopId,
          stopOrder: order,
          stopName: normalizedStop.stopName,
          latitude: normalizedStop.latitude,
          longitude: normalizedStop.longitude,
        ),
      );
    }

    final lineStops = <String, List<LineScopedStop>>{};
    for (final entry in lineStopsAccumulators.entries) {
      final lineId = entry.key;
      final firstKey = entry.value.keys.firstOrNull;
      final firstStopLines = firstKey == null
          ? null
          : TripLineService._mapValueOrNull(stopToLines, firstKey);
      final lineMatch = firstStopLines == null
          ? null
          : TripLineService._mapValueOrNull(firstStopLines, lineId);
      if (lineMatch == null) {
        continue;
      }

      final stops =
          entry.value.values.map((accumulator) {
            return LineScopedStop(
              stopId: accumulator.stopId,
              stopName: accumulator.stopName,
              mode: mode,
              lineId: lineId,
              lineName: lineMatch.lineName,
              endpointKey: endpointKey,
              stopOrder: accumulator.stopOrder,
              latitude: accumulator.latitude,
              longitude: accumulator.longitude,
            );
          }).toList()..sort((a, b) {
            final byOrder = a.stopOrder.compareTo(b.stopOrder);
            if (byOrder != 0) {
              return byOrder;
            }
            return a.stopName.compareTo(b.stopName);
          });

      TripLineService._putValue(lineStops, lineId, stops);
    }

    return _EndpointLineIndex(
      mode: mode,
      stopToLines: {
        for (final entry in stopToLines.entries)
          entry.key: entry.value.values.toList()
            ..sort((a, b) => a.lineName.compareTo(b.lineName)),
      },
      lineStops: lineStops,
    );
  }

  static String _resolveLineName(gtfs_route.Route route) {
    if (route.routeShortName.isNotEmpty) {
      return route.routeShortName;
    }
    if (route.routeLongName.isNotEmpty) {
      return route.routeLongName;
    }
    return route.routeId;
  }
}

class _EndpointLineIndexBuildRequest {
  const _EndpointLineIndexBuildRequest({
    required this.endpointKey,
    required this.mode,
    required this.data,
  });

  final String endpointKey;
  final TransportMode mode;
  final GtfsData data;
}

_EndpointLineIndex _buildEndpointLineIndex(
  _EndpointLineIndexBuildRequest request,
) {
  try {
    return _EndpointLineIndex.build(
      endpointKey: request.endpointKey,
      mode: request.mode,
      data: request.data,
    );
  } catch (_) {
    return _EndpointLineIndex(
      mode: request.mode,
      stopToLines: const {},
      lineStops: const {},
    );
  }
}

class _LineStopAccumulator {
  const _LineStopAccumulator({
    required this.stopId,
    required this.stopOrder,
    required this.stopName,
    this.latitude,
    this.longitude,
  });

  final String stopId;
  final int stopOrder;
  final String stopName;
  final double? latitude;
  final double? longitude;

  _LineStopAccumulator addOrder(int order) {
    return _LineStopAccumulator(
      stopId: stopId,
      stopOrder: order < stopOrder ? order : stopOrder,
      stopName: stopName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class _NormalizedStop {
  const _NormalizedStop({
    required this.stopId,
    required this.stopName,
    this.latitude,
    this.longitude,
  });

  final String stopId;
  final String stopName;
  final double? latitude;
  final double? longitude;

  static _NormalizedStop fromGtfsStopId(
    String stopId,
    Map<String, gtfs_stop.Stop> stopsById,
  ) {
    final stop = TripLineService._mapValueOrNull(stopsById, stopId);
    if (stop == null) {
      return _NormalizedStop(stopId: stopId, stopName: stopId);
    }

    final parentStationId = stop.parentStation?.trim();
    if (parentStationId != null && parentStationId.isNotEmpty) {
      final parent = TripLineService._mapValueOrNull(
        stopsById,
        parentStationId,
      );
      if (parent != null) {
        return _NormalizedStop(
          stopId: parent.stopId,
          stopName: parent.stopName,
          latitude: parent.stopLat != 0.0
              ? parent.stopLat
              : (stop.stopLat != 0.0 ? stop.stopLat : null),
          longitude: parent.stopLon != 0.0
              ? parent.stopLon
              : (stop.stopLon != 0.0 ? stop.stopLon : null),
        );
      }
    }

    return _NormalizedStop(
      stopId: stop.stopId,
      stopName: stop.stopName,
      latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
      longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
    );
  }
}

class _StopCoordinate {
  const _StopCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
