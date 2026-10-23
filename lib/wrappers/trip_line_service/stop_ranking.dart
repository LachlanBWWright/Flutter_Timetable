part of '../trip_line_service_impl.dart';

extension _TripLineStopRanking on TripLineService {
  Future<List<_StopCoordinate>> _loadAnchorCoordinates(
    Iterable<String> anchorStopIds,
  ) async {
    final anchors = <_StopCoordinate>[];
    for (final anchorStopId in anchorStopIds) {
      final lookupStops = await _safeLookupStops(anchorStopId);
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
}
