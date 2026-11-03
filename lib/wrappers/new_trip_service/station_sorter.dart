part of '../new_trip_service_impl.dart';

class _StationSorter {
  /// Sort stations alphabetically by name
  static List<Station> sortAlphabetically(List<Station> stations) {
    final sorted = List<Station>.from(stations);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sort stations by distance from user's current location
  static Future<List<Station>> sortByDistance(List<Station> stations) async {
    final stationsWithCoords = stations
        .where(
          (station) => station.latitude != null && station.longitude != null,
        )
        .toList();

    if (stationsWithCoords.isEmpty) {
      return sortAlphabetically(stations);
    }

    late final Position? position;
    try {
      position = await LocationService.getCurrentLocation();
    } catch (_) {
      return sortAlphabetically(stations);
    }
    final currentPosition = position;
    if (currentPosition == null) {
      return sortAlphabetically(stations);
    }

    // Calculate distances and create new Station objects with distance data
    final stationsWithDistance = stationsWithCoords.map((station) {
      final lat = station.latitude;
      final lon = station.longitude;
      final double distance = lat != null && lon != null
          ? LocationService.calculateDistance(
              currentPosition.latitude,
              currentPosition.longitude,
              lat,
              lon,
            )
          : 0.0;
      return station.copyWith(distance: distance);
    }).toList();

    stationsWithDistance.sort((a, b) {
      final distA = a.distance;
      final distB = b.distance;
      if (distA == null && distB == null) return 0;
      if (distA == null) return 1;
      if (distB == null) return -1;
      return distA.compareTo(distB);
    });

    // Add stations without coordinates at the end (sorted alphabetically)
    final stationsWithoutCoords = stations
        .where(
          (station) => station.latitude == null || station.longitude == null,
        )
        .toList();
    stationsWithoutCoords.sort((a, b) => a.name.compareTo(b.name));

    return [...stationsWithDistance, ...stationsWithoutCoords];
  }
}
