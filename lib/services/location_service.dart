import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../schema/database.dart';

class LocationService {
  static const String _sortingPreferenceKey = 'journey_sorting_preference';
  static const String _sortByDistance = 'distance';
  static const String _sortAlphabetically = 'alphabetical';

  /// Get current location if permission is granted
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  /// Get the closest stop coordinates for a journey
  static Future<List<double>?> getClosestStopCoordinates(Journey journey) async {
    try {
      final database = AppDatabase();
      
      // First try to get origin coordinates
      final originStops = await database.searchStops(journey.origin, limit: 1);
      if (originStops.isNotEmpty && 
          originStops.first.stopLat != null && 
          originStops.first.stopLon != null) {
        return [originStops.first.stopLat!, originStops.first.stopLon!];
      }

      // If origin not found, try destination
      final destStops = await database.searchStops(journey.destination, limit: 1);
      if (destStops.isNotEmpty && 
          destStops.first.stopLat != null && 
          destStops.first.stopLon != null) {
        return [destStops.first.stopLat!, destStops.first.stopLon!];
      }

      return null;
    } catch (e) {
      print('Error getting stop coordinates: $e');
      return null;
    }
  }

  /// Sort journeys by closest station or alphabetically based on user preference
  static Future<List<Journey>> sortJourneys(List<Journey> journeys) async {
    final prefs = await SharedPreferences.getInstance();
    final sortingPreference = prefs.getString(_sortingPreferenceKey) ?? _sortByDistance;

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

    // Calculate distances and sort
    final journeysWithDistance = <MapEntry<Journey, double>>[];
    
    for (final journey in journeys) {
      final stopCoords = await getClosestStopCoordinates(journey);
      if (stopCoords != null) {
        final distance = calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          stopCoords[0],
          stopCoords[1],
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
    final prefs = await SharedPreferences.getInstance();
    final preference = prefs.getString(_sortingPreferenceKey) ?? _sortByDistance;
    return preference == _sortAlphabetically;
  }

  /// Set sorting preference
  static Future<void> setSortingPreference(bool isAlphabetical) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sortingPreferenceKey,
      isAlphabetical ? _sortAlphabetically : _sortByDistance,
    );
  }
}