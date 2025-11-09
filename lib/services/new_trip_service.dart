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
          StopsEndpoint.lightrail_innerwest,
          StopsEndpoint.lightrail_newcastle,
          StopsEndpoint.lightrail_cbdandsoutheast,
          StopsEndpoint.lightrail_parramatta,
        ];
      case TransportMode.bus:
        return [
          StopsEndpoint.buses,
          StopsEndpoint.buses_SBSC006,
          StopsEndpoint.buses_GSBC001,
          StopsEndpoint.buses_GSBC002,
          StopsEndpoint.buses_GSBC003,
          StopsEndpoint.buses_GSBC004,
          StopsEndpoint.buses_GSBC007,
          StopsEndpoint.buses_GSBC008,
          StopsEndpoint.buses_GSBC009,
          StopsEndpoint.buses_GSBC010,
          StopsEndpoint.buses_GSBC014,
          StopsEndpoint.buses_OSMBSC001,
          StopsEndpoint.buses_OSMBSC002,
          StopsEndpoint.buses_OSMBSC003,
          StopsEndpoint.buses_OSMBSC004,
          StopsEndpoint.buses_OMBSC006,
          StopsEndpoint.buses_OMBSC007,
          StopsEndpoint.buses_OSMBSC008,
          StopsEndpoint.buses_OSMBSC009,
          StopsEndpoint.buses_OSMBSC010,
          StopsEndpoint.buses_OSMBSC011,
          StopsEndpoint.buses_OSMBSC012,
          StopsEndpoint.buses_NISC001,
          StopsEndpoint.buses_ReplacementBus,
        ];
      case TransportMode.ferry:
        return [StopsEndpoint.ferries_sydneyferries, StopsEndpoint.ferries_MFF];
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
          'Loading ${endpoint.name}...',
          i + 1,
          total,
        );

        // Get GTFS data from the appropriate endpoint
        final gtfsData = await fetchGtfsDataForEndpoint(endpoint);
        if (gtfsData != null && gtfsData.stops.isNotEmpty) {
          // Store the stops to database
          await StopsService.storeStopsToDatabase(gtfsData.stops, endpoint);
          onProgress?.call(
            'Loaded ${gtfsData.stops.length} stops from ${endpoint.name}',
            i + 1,
            total,
          );
        } else {
          onProgress?.call(
            'No data found for ${endpoint.name}',
            i + 1,
            total,
          );
        }
      } catch (e) {
        onProgress?.call(
          'Error loading ${endpoint.name}: $e',
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
      case StopsEndpoint.lightrail_innerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrail_newcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrail_cbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrail_parramatta:
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case StopsEndpoint.buses:
        return await fetchBusesGtfsData();
      case StopsEndpoint.buses_SBSC006:
        return await fetchBusesSBSC006GtfsData();
      case StopsEndpoint.buses_GSBC001:
        return await fetchBusesGSBC001GtfsData();
      case StopsEndpoint.buses_GSBC002:
        return await fetchBusesGSBC002GtfsData();
      case StopsEndpoint.buses_GSBC003:
        return await fetchBusesGSBC003GtfsData();
      case StopsEndpoint.buses_GSBC004:
        return await fetchBusesGSBC004GtfsData();
      case StopsEndpoint.buses_GSBC007:
        return await fetchBusesGSBC007GtfsData();
      case StopsEndpoint.buses_GSBC008:
        return await fetchBusesGSBC008GtfsData();
      case StopsEndpoint.buses_GSBC009:
        return await fetchBusesGSBC009GtfsData();
      case StopsEndpoint.buses_GSBC010:
        return await fetchBusesGSBC010GtfsData();
      case StopsEndpoint.buses_GSBC014:
        return await fetchBusesGSBC014GtfsData();
      case StopsEndpoint.buses_OSMBSC001:
        return await fetchBusesOSMBSC001GtfsData();
      case StopsEndpoint.buses_OSMBSC002:
        return await fetchBusesOSMBSC002GtfsData();
      case StopsEndpoint.buses_OSMBSC003:
        return await fetchBusesOSMBSC003GtfsData();
      case StopsEndpoint.buses_OSMBSC004:
        return await fetchBusesOSMBSC004GtfsData();
      case StopsEndpoint.buses_OMBSC006:
        return await fetchBusesOMBSC006GtfsData();
      case StopsEndpoint.buses_OMBSC007:
        return await fetchBusesOMBSC007GtfsData();
      case StopsEndpoint.buses_OSMBSC008:
        return await fetchBusesOSMBSC008GtfsData();
      case StopsEndpoint.buses_OSMBSC009:
        return await fetchBusesOSMBSC009GtfsData();
      case StopsEndpoint.buses_OSMBSC010:
        return await fetchBusesOSMBSC010GtfsData();
      case StopsEndpoint.buses_OSMBSC011:
        return await fetchBusesOSMBSC011GtfsData();
      case StopsEndpoint.buses_OSMBSC012:
        return await fetchBusesOSMBSC012GtfsData();
      case StopsEndpoint.buses_NISC001:
        return await fetchBusesNISC001GtfsData();
      case StopsEndpoint.buses_ReplacementBus:
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case StopsEndpoint.ferries_sydneyferries:
        return await fetchFerriesSydneyFerriesGtfsData();
      case StopsEndpoint.ferries_MFF:
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
