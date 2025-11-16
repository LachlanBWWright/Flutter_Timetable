import '../constants/transport_modes.dart';
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
  /// Optional progress callback for UI updates
  static Future<List<Station>> loadStopsForMode(
    TransportMode mode, {
    Function(String message, int current, int total)? onProgress,
  }) async {
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
      await _loadStopsFromApi(endpoints, onProgress: onProgress);

      // Try loading from database again
      for (final endpoint in endpoints) {
        final stops = await StopsService.getStopsForEndpoint(endpoint);
        allStops.addAll(stops);
      }
    }

    return allStops.map((stop) {
      final String displayName = stop.stopName;

      return Station(
        name: displayName,
        id: stop.stopId,
        latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
        longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
      );
    }).toList();
  }

  /// Get the list of API endpoints for a transport mode
  static List<StopsEndpoint> _getEndpointsForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.train:
        return [StopsEndpoint.nswtrains, StopsEndpoint.sydneytrains];
      case TransportMode.metro:
        return [StopsEndpoint.metro];
      case TransportMode.lightrail:
        return [
          StopsEndpoint.lightrailInnerwest,
          StopsEndpoint.lightrailNewcastle,
          StopsEndpoint.lightrailCbdandsoutheast,
          StopsEndpoint.lightrailParramatta,
        ];
      case TransportMode.bus:
        return [
          StopsEndpoint.buses,
          StopsEndpoint.busesSbsc006,
          StopsEndpoint.busesGbsc001,
          StopsEndpoint.busesGsbc002,
          StopsEndpoint.busesGsbc003,
          StopsEndpoint.busesGsbc004,
          StopsEndpoint.busesGsbc007,
          StopsEndpoint.busesGsbc008,
          StopsEndpoint.busesGsbc009,
          StopsEndpoint.busesGsbc010,
          StopsEndpoint.busesGsbc014,
          StopsEndpoint.busesOsmbsc001,
          StopsEndpoint.busesOsmbsc002,
          StopsEndpoint.busesOsmbsc003,
          StopsEndpoint.busesOsmbsc004,
          StopsEndpoint.busesOmbsc006,
          StopsEndpoint.busesOmbsc007,
          StopsEndpoint.busesOsmbsc008,
          StopsEndpoint.busesOsmbsc009,
          StopsEndpoint.busesOsmbsc010,
          StopsEndpoint.busesOsmbsc011,
          StopsEndpoint.busesOsmbsc012,
          StopsEndpoint.busesNisc001,
          StopsEndpoint.busesReplacementBus,
        ];
      case TransportMode.ferry:
        return [StopsEndpoint.ferriesSydneyFerries, StopsEndpoint.ferriesMff];
    }
  }

  /// Load stops from API endpoints and store in database
  /// Optional progress callback for UI updates
  static Future<void> _loadStopsFromApi(
    List<StopsEndpoint> endpoints, {
    Function(String message, int current, int total)? onProgress,
  }) async {
    final total = endpoints.length;
    for (var i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      try {
        onProgress?.call(
          'Loading ${endpoint.key}...',
          i + 1,
          total,
        );

        // Get GTFS data from the appropriate endpoint
        final gtfsData = await fetchGtfsDataForEndpoint(endpoint);
        if (gtfsData != null && gtfsData.stops.isNotEmpty) {
          // Store the stops to database
          await StopsService.storeStopsToDatabase(gtfsData.stops, endpoint);
          onProgress?.call(
            'Loaded ${gtfsData.stops.length} stops from ${endpoint.key}',
            i + 1,
            total,
          );
        } else {
          onProgress?.call(
            'No data found for ${endpoint.key}',
            i + 1,
            total,
          );
        }
      } catch (e) {
        onProgress?.call(
          'Error loading ${endpoint.key}: $e',
          i + 1,
          total,
        );
      }
    }
  }

  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<GtfsData?> fetchGtfsDataForEndpoint(
      StopsEndpoint endpoint) async {
    switch (endpoint) {
      // Trains
      case StopsEndpoint.nswtrains:
        return await fetchNswTrainsGtfsData();
      case StopsEndpoint.sydneytrains:
        return await fetchSydneyTrainsGtfsData();

      // Light Rail
      case StopsEndpoint.lightrailInnerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrailNewcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrailCbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrailParramatta:
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case StopsEndpoint.buses:
        return await fetchBusesGtfsData();
      case StopsEndpoint.busesSbsc006:
        return await fetchBusesSBSC006GtfsData();
      case StopsEndpoint.busesGbsc001:
        return await fetchBusesGSBC001GtfsData();
      case StopsEndpoint.busesGsbc002:
        return await fetchBusesGSBC002GtfsData();
      case StopsEndpoint.busesGsbc003:
        return await fetchBusesGSBC003GtfsData();
      case StopsEndpoint.busesGsbc004:
        return await fetchBusesGSBC004GtfsData();
      case StopsEndpoint.busesGsbc007:
        return await fetchBusesGSBC007GtfsData();
      case StopsEndpoint.busesGsbc008:
        return await fetchBusesGSBC008GtfsData();
      case StopsEndpoint.busesGsbc009:
        return await fetchBusesGSBC009GtfsData();
      case StopsEndpoint.busesGsbc010:
        return await fetchBusesGSBC010GtfsData();
      case StopsEndpoint.busesGsbc014:
        return await fetchBusesGSBC014GtfsData();
      case StopsEndpoint.busesOsmbsc001:
        return await fetchBusesOSMBSC001GtfsData();
      case StopsEndpoint.busesOsmbsc002:
        return await fetchBusesOSMBSC002GtfsData();
      case StopsEndpoint.busesOsmbsc003:
        return await fetchBusesOSMBSC003GtfsData();
      case StopsEndpoint.busesOsmbsc004:
        return await fetchBusesOSMBSC004GtfsData();
      case StopsEndpoint.busesOmbsc006:
        return await fetchBusesOMBSC006GtfsData();
      case StopsEndpoint.busesOmbsc007:
        return await fetchBusesOMBSC007GtfsData();
      case StopsEndpoint.busesOsmbsc008:
        return await fetchBusesOSMBSC008GtfsData();
      case StopsEndpoint.busesOsmbsc009:
        return await fetchBusesOSMBSC009GtfsData();
      case StopsEndpoint.busesOsmbsc010:
        return await fetchBusesOSMBSC010GtfsData();
      case StopsEndpoint.busesOsmbsc011:
        return await fetchBusesOSMBSC011GtfsData();
      case StopsEndpoint.busesOsmbsc012:
        return await fetchBusesOSMBSC012GtfsData();
      case StopsEndpoint.busesNisc001:
        return await fetchBusesNISC001GtfsData();
      case StopsEndpoint.busesReplacementBus:
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case StopsEndpoint.ferriesSydneyFerries:
        return await fetchFerriesSydneyFerriesGtfsData();
      case StopsEndpoint.ferriesMff:
        return await fetchFerriesMFFGtfsData();

      default:
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
  static String getModeDisplayName(TransportMode mode) {
    return mode.displayName;
  }
}
