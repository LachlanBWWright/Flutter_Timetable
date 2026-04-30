import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
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
      latitude: latitude,
      longitude: longitude,
      distance: distanceKm,
      lineId: lineId,
      lineName: lineName,
      isWithinLinePriorityRadius: isWithinAnchorRadius,
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
  }) : _gtfsLoader = gtfsLoader ?? NewTripService.fetchGtfsDataForEndpoint,
       _stopLookup = stopLookup ?? _lookupStopsFromDatabase;

  static final TripLineService instance = TripLineService();

  final TripLineGtfsLoader _gtfsLoader;
  final TripLineStopLookup _stopLookup;
  final Map<String, Future<_EndpointLineIndex?>> _endpointIndexCache = {};

  Future<List<StopLineMatch>> getLinesForStop(
    String stopId, {
    TransportMode? mode,
  }) async {
    final lookupStops = await _stopLookup(stopId);
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
      final index = await _getIndexForEndpointKey(endpointKey);
      if (index == null) {
        continue;
      }
      for (final line in index.stopToLines[stopId] ?? const <StopLineMatch>[]) {
        matches[line.lineId] = line;
      }
    }

    return matches.values.toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<StopLineMatch>> findSharedLines(
    String stopA,
    String stopB, {
    required TransportMode mode,
  }) async {
    final linesForA = await getLinesForStop(stopA, mode: mode);
    if (linesForA.isEmpty) {
      return const [];
    }

    final lineIdsForB = (await getLinesForStop(
      stopB,
      mode: mode,
    )).map((line) => line.lineId).toSet();

    return linesForA.where((line) => lineIdsForB.contains(line.lineId)).toList()
      ..sort((a, b) => a.lineName.compareTo(b.lineName));
  }

  Future<List<LineScopedStop>> getStopsForLine(
    String lineId,
    TransportMode mode,
  ) async {
    final endpointKey = _endpointKeyFromLineId(lineId);
    final index = await _getIndexForEndpointKey(endpointKey);
    if (index == null || index.mode != mode) {
      return const [];
    }
    return index.lineStops[lineId] ?? const [];
  }

  Future<List<LineScopedStop>> getNearbyLineStops({
    required String anchorStopId,
    required String lineId,
    required TransportMode mode,
    double radiusKm = 5,
  }) async {
    return rankStopsForLine(
      lineId: lineId,
      mode: mode,
      anchorStopIds: [anchorStopId],
      radiusKm: radiusKm,
    ).then(
      (stops) => stops.where((stop) => stop.isWithinAnchorRadius).toList(),
    );
  }

  Future<List<LineScopedStop>> rankStopsForLine({
    required String lineId,
    required TransportMode mode,
    Iterable<String> anchorStopIds = const [],
    Iterable<String> excludedStopIds = const [],
    double radiusKm = 5,
  }) async {
    final stops = await getStopsForLine(lineId, mode);
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

  Future<List<_StopCoordinate>> _loadAnchorCoordinates(
    Iterable<String> anchorStopIds,
  ) async {
    final anchors = <_StopCoordinate>[];
    for (final anchorStopId in anchorStopIds) {
      final lookupStops = await _stopLookup(anchorStopId);
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
    final endpoint = StopsEndpoint.values.where(
      (value) => value.key == endpointKey,
    );
    if (endpoint.isEmpty) {
      return null;
    }

    final mode = StopsService.modeForEndpointKey(endpointKey);
    if (mode == null) {
      return null;
    }

    final data = await _gtfsLoader(endpoint.first);
    if (data == null) {
      return null;
    }

    return _EndpointLineIndex.build(
      endpointKey: endpointKey,
      mode: mode,
      data: data,
    );
  }

  static Future<List<TripLineLookupStop>> _lookupStopsFromDatabase(
    String stopId,
  ) async {
    final rows = await StopsService.database.getStopsById(stopId);
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
      final routeId = routeIdByTripId[stopTime.tripId];
      if (routeId == null) {
        continue;
      }

      final route = routesById[routeId];
      if (route == null) {
        continue;
      }

      final stopId = stopTime.stopId.trim();
      if (stopId.isEmpty) {
        continue;
      }

      final normalizedStop = _NormalizedStop.fromGtfsStopId(stopId, stopsById);

      final lineId = '$endpointKey|${route.routeId}';
      final lineName = _resolveLineName(route);
      final lineMatch = StopLineMatch(
        mode: mode,
        lineId: lineId,
        lineName: lineName,
        endpointKey: endpointKey,
      );

      stopToLines.putIfAbsent(normalizedStop.stopId, () => {})[lineId] =
          lineMatch;

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
      final lineMatch = entry.value.isEmpty
          ? null
          : stopToLines[entry.value.keys.first]?[lineId];
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

      lineStops[lineId] = stops;
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
    final stop = stopsById[stopId];
    if (stop == null) {
      return _NormalizedStop(stopId: stopId, stopName: stopId);
    }

    final parentStationId = stop.parentStation?.trim();
    if (parentStationId != null && parentStationId.isNotEmpty) {
      final parent = stopsById[parentStationId];
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
