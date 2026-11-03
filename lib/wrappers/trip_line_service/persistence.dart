part of '../trip_line_service_impl.dart';

extension _TripLinePersistence on TripLineService {
  Future<List<StopLineMatch>> _getPersistedLinesForStop(
    String stopId, {
    TransportMode? mode,
  }) async {
    List<db.StopLineMembership> rows = const <db.StopLineMembership>[];

    rows = await StopsService.database.getStopLineMembershipsForStop(stopId);

    final matches = <String, StopLineMatch>{};
    for (final row in rows) {
      final rowMode = _modeFromStoredValue(row.mode);
      if (rowMode == null || (mode != null && rowMode != mode)) {
        continue;
      }
      TripLineService._putValue(
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
    rows = await StopsService.database.getStopLineMembershipsForLine(lineId);
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

  TransportMode? _modeFromStoredValue(String value) {
    for (final mode in TransportMode.values) {
      if (mode.id == value) {
        return mode;
      }
    }
    return null;
  }

  Future<void> _cacheRoutesForEndpoint(StopsEndpoint endpoint, GtfsData data) =>
      StopsService.database.replaceRoutesForEndpoint(
        endpoint.key,
        _routeRowsForEndpoint(endpoint, data),
      );
}
