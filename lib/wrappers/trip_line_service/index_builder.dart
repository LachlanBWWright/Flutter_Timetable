part of '../trip_line_service_impl.dart';

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

      final normalizedStop = _NormalizedStop.fromGtfsStopId(stopId, stopsById);

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
  return _EndpointLineIndex.build(
    endpointKey: request.endpointKey,
    mode: request.mode,
    data: request.data,
  );
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
