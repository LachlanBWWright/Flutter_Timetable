import '../gtfs/stop.dart';

/// Small grid index for retrieving stops close to a map viewport.
class StopsSpatialIndex {
  StopsSpatialIndex(Iterable<Stop> stops) : _stops = List.unmodifiable(stops) {
    for (final stop in _stops) {
      if (!_hasValidCoordinates(stop)) continue;
      _cells
          .putIfAbsent(_keyFor(stop.stopLat, stop.stopLon), () => [])
          .add(stop);
    }
  }

  static const double _cellSizeDegrees = 0.15;
  static const int _longitudeCellCount = 2401;

  final List<Stop> _stops;
  final Map<int, List<Stop>> _cells = {};

  List<Stop> query({
    required double south,
    required double north,
    required double west,
    required double east,
  }) {
    south = south.clamp(-90.0, 90.0).toDouble();
    north = north.clamp(-90.0, 90.0).toDouble();
    if (north < south) return const [];
    var longitudeWidth = east - west;
    if (longitudeWidth < 0) {
      longitudeWidth = (longitudeWidth % 360 + 360) % 360;
    }
    final List<(double, double)> intervals;
    if (longitudeWidth >= 360) {
      intervals = [(-180, 180)];
    } else {
      final normalizedWest = _normalizeLongitude(west);
      final normalizedEast = normalizedWest + longitudeWidth;
      intervals = normalizedEast <= 180
          ? [(normalizedWest, normalizedEast)]
          : [(normalizedWest, 180), (-180, normalizedEast - 360)];
    }
    final minLatCell = _latCell(south);
    final maxLatCell = _latCell(north);
    final results = <Stop>[];
    final seen = <Stop>{};

    for (final interval in intervals) {
      final minLonCell = _lonCell(interval.$1);
      final maxLonCell = _lonCell(interval.$2);
      final cellCount =
          (maxLatCell - minLatCell + 1) * (maxLonCell - minLonCell + 1);
      if (cellCount > _cells.length * 4) {
        for (final stop in _stops) {
          if (_isWithin(stop, south, north, interval.$1, interval.$2) &&
              seen.add(stop)) {
            results.add(stop);
          }
        }
        continue;
      }

      for (var latCell = minLatCell; latCell <= maxLatCell; latCell++) {
        for (var lonCell = minLonCell; lonCell <= maxLonCell; lonCell++) {
          for (final stop in _cells[_cellKey(latCell, lonCell)] ?? const []) {
            if (_isWithin(stop, south, north, interval.$1, interval.$2) &&
                seen.add(stop)) {
              results.add(stop);
            }
          }
        }
      }
    }
    return results;
  }

  static bool _isWithin(
    Stop stop,
    double south,
    double north,
    double west,
    double east,
  ) =>
      stop.stopLat >= south &&
      stop.stopLat <= north &&
      stop.stopLon >= west &&
      stop.stopLon <= east;

  static bool _hasValidCoordinates(Stop stop) =>
      stop.stopLat.isFinite &&
      stop.stopLon.isFinite &&
      stop.stopLat >= -90 &&
      stop.stopLat <= 90 &&
      stop.stopLon >= -180 &&
      stop.stopLon <= 180;

  static int _latCell(double latitude) =>
      ((latitude + 90) / _cellSizeDegrees).floor();

  static double _normalizeLongitude(double longitude) {
    final wrapped = (longitude + 180) % 360;
    return (wrapped < 0 ? wrapped + 360 : wrapped) - 180;
  }

  static int _lonCell(double longitude) =>
      ((longitude + 180) / _cellSizeDegrees).floor();

  static int _keyFor(double latitude, double longitude) =>
      _cellKey(_latCell(latitude), _lonCell(longitude));

  static int _cellKey(int latCell, int lonCell) =>
      latCell * _longitudeCellCount + lonCell;
}
