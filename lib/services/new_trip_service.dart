import '../fetch_data/timetable_data.dart';
import '../gtfs/gtfs_data.dart';
import '../gtfs/stop.dart';
// logger removed
import '../services/location_service.dart';
import '../services/stops_service.dart';
import '../widgets/station_widgets.dart';

/// Service for managing stops data in the New Trip screen
class NewTripService {
  /// Load stops for a specific transport mode from database or API
  static Future<List<Station>> loadStopsForMode(String mode) async {
    final endpoints = _getEndpointsForMode(mode);
    final List<Stop> allStops = [];

    // Check if we have any stops for this mode in the database
    bool hasStops = false;
    for (final endpoint in endpoints) {
      final existingStops = await StopsService.getStopsForEndpoint(endpoint);
      if (existingStops.isNotEmpty) {
        hasStops = true;
        allStops.addAll(existingStops);
      }
    }

    // If no stops found in database, try to load from API
    if (!hasStops) {
      await _loadStopsFromApi(endpoints);

      // Try loading from database again
      for (final endpoint in endpoints) {
        final stops = await StopsService.getStopsForEndpoint(endpoint);
        allStops.addAll(stops);
      }
    }

    // Convert Stop objects to Station objects for the UI
    // Helper to detect suspect stop names (numeric or equal to the id)
    bool isSuspectName(String name, String id) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return true;
      if (trimmed == id) return true;
      // If name is numeric-only, treat as suspect
      if (RegExp(r'^\d+\$').hasMatch(trimmed)) return true;
      return false;
    }

    return allStops.map((stop) {
      String displayName = stop.stopName;

      if (isSuspectName(displayName, stop.stopId)) {
        // Try to find a parent station's name in the fetched stops
        if (stop.parentStation != null && stop.parentStation!.isNotEmpty) {
          final parentMatches = allStops
              .where((s) => s.stopId == stop.parentStation)
              .toList();
          if (parentMatches.isNotEmpty) {
            final parentName = parentMatches.first.stopName;
            if (!isSuspectName(parentName, parentMatches.first.stopId)) {
              displayName = parentName;
            }
          }
        }
      }

      // Fallback: if still suspect, use stopId so the user at least sees an identifier
      if (isSuspectName(displayName, stop.stopId)) {
        displayName = stop.stopId;
      }

      return Station(
        name: displayName,
        id: stop.stopId,
        latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
        longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
      );
    }).toList();
  }

  /// Get the list of API endpoints for a transport mode
  static List<String> _getEndpointsForMode(String mode) {
    switch (mode) {
      case 'train':
        return ['nswtrains', 'sydneytrains'];
      case 'metro':
        return ['metro'];
      case 'lightrail':
        return [
          'lightrail_innerwest',
          'lightrail_newcastle',
          'lightrail_cbdandsoutheast',
          'lightrail_parramatta'
        ];
      case 'bus':
        return [
          'buses',
          'buses_SBSC006',
          'buses_GSBC001',
          'buses_GSBC002',
          'buses_GSBC003',
          'buses_GSBC004',
          'buses_GSBC007',
          'buses_GSBC008',
          'buses_GSBC009',
          'buses_GSBC010',
          'buses_GSBC014',
          'buses_OSMBSC001',
          'buses_OSMBSC002',
          'buses_OSMBSC003',
          'buses_OSMBSC004',
          'buses_OMBSC006',
          'buses_OMBSC007',
          'buses_OSMBSC008',
          'buses_OSMBSC009',
          'buses_OSMBSC010',
          'buses_OSMBSC011',
          'buses_OSMBSC012',
          'buses_NISC001',
          'buses_ReplacementBus',
        ];
      case 'ferry':
        return ['ferries_sydneyferries', 'ferries_MFF'];
      default:
        return [];
    }
  }

  /// Load stops from API endpoints and store in database
  static Future<void> _loadStopsFromApi(List<String> endpoints) async {
    for (final endpoint in endpoints) {
      try {
        // Loading stops from API for endpoint: $endpoint

        // Get GTFS data from the appropriate endpoint
        final gtfsData = await fetchGtfsDataForEndpoint(endpoint);
        if (gtfsData != null && gtfsData.stops.isNotEmpty) {
          // Store the stops to database
          await StopsService.storeStopsToDatabase(gtfsData.stops, endpoint);
          // Loaded ${gtfsData.stops.length} stops for $endpoint
        } else {
          // No GTFS data found for $endpoint
        }
      } catch (e) {
        // Error loading stops from endpoint $endpoint
      }
    }
  }

  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<GtfsData?> fetchGtfsDataForEndpoint(String endpoint) async {
    switch (endpoint) {
      // Trains
      case 'nswtrains':
        return await fetchNswTrainsGtfsData();
      case 'sydneytrains':
        return await fetchSydneyTrainsGtfsData();

      // Light Rail
      case 'lightrail_innerwest':
        return await fetchLightRailInnerWestGtfsData();
      case 'lightrail_newcastle':
        return await fetchLightRailNewcastleGtfsData();
      case 'lightrail_cbdandsoutheast':
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case 'lightrail_parramatta':
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case 'buses':
        return await fetchBusesGtfsData();
      case 'buses_SBSC006':
        return await fetchBusesSBSC006GtfsData();
      case 'buses_GSBC001':
        return await fetchBusesGSBC001GtfsData();
      case 'buses_GSBC002':
        return await fetchBusesGSBC002GtfsData();
      case 'buses_GSBC003':
        return await fetchBusesGSBC003GtfsData();
      case 'buses_GSBC004':
        return await fetchBusesGSBC004GtfsData();
      case 'buses_GSBC007':
        return await fetchBusesGSBC007GtfsData();
      case 'buses_GSBC008':
        return await fetchBusesGSBC008GtfsData();
      case 'buses_GSBC009':
        return await fetchBusesGSBC009GtfsData();
      case 'buses_GSBC010':
        return await fetchBusesGSBC010GtfsData();
      case 'buses_GSBC014':
        return await fetchBusesGSBC014GtfsData();
      case 'buses_OSMBSC001':
        return await fetchBusesOSMBSC001GtfsData();
      case 'buses_OSMBSC002':
        return await fetchBusesOSMBSC002GtfsData();
      case 'buses_OSMBSC003':
        return await fetchBusesOSMBSC003GtfsData();
      case 'buses_OSMBSC004':
        return await fetchBusesOSMBSC004GtfsData();
      case 'buses_OMBSC006':
        return await fetchBusesOMBSC006GtfsData();
      case 'buses_OMBSC007':
        return await fetchBusesOMBSC007GtfsData();
      case 'buses_OSMBSC008':
        return await fetchBusesOSMBSC008GtfsData();
      case 'buses_OSMBSC009':
        return await fetchBusesOSMBSC009GtfsData();
      case 'buses_OSMBSC010':
        return await fetchBusesOSMBSC010GtfsData();
      case 'buses_OSMBSC011':
        return await fetchBusesOSMBSC011GtfsData();
      case 'buses_OSMBSC012':
        return await fetchBusesOSMBSC012GtfsData();
      case 'buses_NISC001':
        return await fetchBusesNISC001GtfsData();
      case 'buses_ReplacementBus':
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case 'ferries_sydneyferries':
        return await fetchFerriesSydneyFerriesGtfsData();
      case 'ferries_MFF':
        return await fetchFerriesMFFGtfsData();

      default:
        // Unknown endpoint: $endpoint
        return null;
    }
  }

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
            (station) => station.latitude != null && station.longitude != null)
        .toList();

    if (stationsWithCoords.isEmpty) {
      return sortAlphabetically(stations);
    }

    try {
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        return sortAlphabetically(stations);
      }

      // Calculate distances and create new Station objects with distance data
      final stationsWithDistance = stationsWithCoords.map((station) {
        final distance = LocationService.calculateDistance(
          position.latitude,
          position.longitude,
          station.latitude!,
          station.longitude!,
        );
        return station.copyWith(distance: distance);
      }).toList();

      stationsWithDistance.sort((a, b) => a.distance!.compareTo(b.distance!));

      // Add stations without coordinates at the end (sorted alphabetically)
      final stationsWithoutCoords = stations
          .where((station) =>
              station.latitude == null || station.longitude == null)
          .toList();
      stationsWithoutCoords.sort((a, b) => a.name.compareTo(b.name));

      return [
        ...stationsWithDistance,
        ...stationsWithoutCoords,
      ];
    } catch (e) {
      // Error sorting by distance
      return sortAlphabetically(stations);
    }
  }

  /// Get display name for transport mode
  static String getModeDisplayName(String mode) {
    switch (mode) {
      case 'train':
        return 'Train';
      case 'metro':
        return 'Metro';
      case 'lightrail':
        return 'Light Rail';
      case 'bus':
        return 'Bus';
      case 'ferry':
        return 'Ferry';
      default:
        return mode;
    }
  }
}
