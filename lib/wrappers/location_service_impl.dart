import 'package:geolocator/geolocator.dart';
import '../schema/database.dart';
import '../services/app_preferences.dart';

enum LocationLookupFailureReason {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  timeout,
  unavailable,
}

extension LocationLookupFailureReasonX on LocationLookupFailureReason {
  String get message {
    switch (this) {
      case LocationLookupFailureReason.permissionDenied:
        return 'Location permission denied.';
      case LocationLookupFailureReason.permissionDeniedForever:
        return 'Location permission permanently denied. Please enable it from device settings.';
      case LocationLookupFailureReason.serviceDisabled:
        return 'Location services are disabled on this device.';
      case LocationLookupFailureReason.timeout:
        return 'Location request timed out.';
      case LocationLookupFailureReason.unavailable:
        return 'Location unavailable.';
    }
  }
}

class LocationLookupResult {
  const LocationLookupResult.success(Position this.position) : failure = null;

  const LocationLookupResult.failure(LocationLookupFailureReason this.failure)
    : position = null;

  final Position? position;
  final LocationLookupFailureReason? failure;
}

class LocationService {
  static const String _sortingPreferenceKey = 'journey_sorting_preference';
  static const String _sortByDistance = 'distance';
  static const String _sortAlphabetically = 'alphabetical';

  static double? _coordValueAt(List<double> coords, int index) {
    if (index < 0 || index >= coords.length) {
      return null;
    }
    try {
      return coords[index];
    } catch (_) {
      return null;
    }
  }

  static Future<LocationLookupFailureReason?> _ensureLocationAccess() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationLookupFailureReason.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationLookupFailureReason.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationLookupFailureReason.permissionDeniedForever;
      }

      return null;
    } catch (_) {
      return LocationLookupFailureReason.unavailable;
    }
  }

  static Future<LocationLookupResult> getCurrentLocationResult() async {
    final accessFailure = await _ensureLocationAccess();
    if (accessFailure != null) {
      return LocationLookupResult.failure(accessFailure);
    }

    try {
      final position = await Geolocator.getCurrentPosition()
          .then<Position?>((value) => value)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (position == null) {
        return const LocationLookupResult.failure(
          LocationLookupFailureReason.timeout,
        );
      }
      return LocationLookupResult.success(position);
    } catch (_) {
      return const LocationLookupResult.failure(
        LocationLookupFailureReason.unavailable,
      );
    }
  }

  /// Get current location if permission is granted
  static Future<Position?> getCurrentLocation() async {
    final result = await getCurrentLocationResult();
    return result.position;
  }

  /// Check and request location availability and permissions.
  /// Returns null when location services and permissions are available.
  /// Otherwise returns a human-friendly error message describing the problem.
  static Future<String?> checkAndRequestLocationAvailability() async {
    final failure = await _ensureLocationAccess();
    return failure?.message;
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  /// Get the closest stop coordinates for a journey using the provided database
  static Future<List<double>?> getClosestStopCoordinates(
    Journey journey,
    AppDatabase database,
  ) async {
    try {
      // First try to get origin coordinates
      final originStops = await database.searchStops(journey.origin, limit: 1);
      if (originStops.isNotEmpty) {
        final lat = originStops.first.stopLat;
        final lon = originStops.first.stopLon;
        if (lat != null && lon != null) {
          return [lat, lon];
        }
      }

      // If origin not found, try destination
      final destStops = await database.searchStops(
        journey.destination,
        limit: 1,
      );
      if (destStops.isNotEmpty) {
        final lat = destStops.first.stopLat;
        final lon = destStops.first.stopLon;
        if (lat != null && lon != null) {
          return [lat, lon];
        }
      }

      return null;
    } catch (e) {
      // Error getting stop coordinates
      return null;
    }
  }

  /// Sort journeys by closest station or alphabetically based on user preference
  static Future<List<Journey>> sortJourneys(List<Journey> journeys) async {
    final sortingPreference =
        await AppPreferences.getString(_sortingPreferenceKey) ??
        _sortAlphabetically;

    if (sortingPreference == _sortAlphabetically) {
      // Sort alphabetically by origin name
      journeys.sort((a, b) => a.origin.compareTo(b.origin));
      return journeys;
    }

    // Sort by distance
    final currentPosition = await getCurrentLocation();
    if (currentPosition == null) {
      // Fallback to alphabetical if location not available
      journeys.sort((a, b) => a.origin.compareTo(b.origin));
      return journeys;
    }

    // Calculate distances and sort — reuse a single database instance
    final database = AppDatabase();
    final journeysWithDistance = <MapEntry<Journey, double>>[];

    for (final journey in journeys) {
      final stopCoords = await getClosestStopCoordinates(journey, database);
      final lat = stopCoords == null ? null : _coordValueAt(stopCoords, 0);
      final lon = stopCoords == null ? null : _coordValueAt(stopCoords, 1);
      if (lat != null && lon != null) {
        final distance = calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          lat,
          lon,
        );
        journeysWithDistance.add(MapEntry(journey, distance));
      } else {
        // If no coordinates found, assign a high distance value
        journeysWithDistance.add(MapEntry(journey, double.infinity));
      }
    }

    // Sort by distance
    journeysWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return journeysWithDistance.map((entry) => entry.key).toList();
  }

  /// Get current sorting preference
  static Future<bool> isAlphabeticalSorting() async {
    final preference =
        await AppPreferences.getString(_sortingPreferenceKey) ??
        _sortAlphabetically;
    return preference == _sortAlphabetically;
  }

  /// Set sorting preference
  static Future<void> setSortingPreference(bool isAlphabetical) async {
    await AppPreferences.setString(
      _sortingPreferenceKey,
      isAlphabetical ? _sortAlphabetically : _sortByDistance,
    );
  }
}
