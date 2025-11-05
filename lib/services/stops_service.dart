import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../constants/transport_modes.dart';
import '../fetch_data/timetable_data.dart';
import '../gtfs/gtfs_data.dart';
import '../gtfs/stop.dart';
import '../logs/logger.dart';
import '../schema/database.dart' hide Stop;

/// Progress event emitted while updating stops from API
/// Enumerates all supported GTFS endpoints used by the app. The enum names
/// intentionally match the string keys used previously so we can use
/// `.name` to obtain the original key when interacting with the database or
/// external systems.
enum StopsEndpoint {
  buses,
  buses_SBSC006,
  buses_GSBC001,
  buses_GSBC002,
  buses_GSBC003,
  buses_GSBC004,
  buses_GSBC007,
  buses_GSBC008,
  buses_GSBC009,
  buses_GSBC010,
  buses_GSBC014,
  buses_OSMBSC001,
  buses_OSMBSC002,
  buses_OSMBSC003,
  buses_OSMBSC004,
  buses_OMBSC006,
  buses_OMBSC007,
  buses_OSMBSC008,
  buses_OSMBSC009,
  buses_OSMBSC010,
  buses_OSMBSC011,
  buses_OSMBSC012,
  buses_NISC001,
  buses_ReplacementBus,
  ferries_sydneyferries,
  ferries_MFF,
  lightrail_innerwest,
  lightrail_newcastle,
  lightrail_cbdandsoutheast,
  lightrail_parramatta,
  nswtrains,
  sydneytrains,
  metro,
  regionbuses_southeasttablelands,
  regionbuses_southeasttablelands2,
  regionbuses_northcoast,
  regionbuses_northcoast2,
  regionbuses_centralwestandorana,
  regionbuses_centralwestandorana2,
  regionbuses_riverinamurray,
  regionbuses_newenglandnorthwest,
  regionbuses_riverinamurray2,
  regionbuses_northcoast3,
  regionbuses_sydneysurrounds,
  regionbuses_newcastlehunter,
  regionbuses_farwest,
}

class StopsUpdateProgress {
  /// The endpoint associated with this progress event. Null for control
  /// events such as 'init' and 'complete'. Use `.name` to obtain the
  /// original string key when needed.
  final StopsEndpoint? endpoint;
  final int completed;
  final int total;
  final bool success;
  final String? message;
  StopsUpdateProgress({
    required this.endpoint,
    required this.completed,
    required this.total,
    required this.success,
    this.message,
  });

  @override
  String toString() =>
      'StopsUpdateProgress(endpoint: ${endpoint?.name}, completed: $completed/$total, success: $success, message: $message)';
}

/// Service for managing GTFS stops data - parsing from assets and API endpoints
class StopsService {
  static AppDatabase? _database;

  /// Get or create database instance
  static AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Parse CSV file from assets and return list of Stop objects
  static Future<List<Stop>> parseStopsFromAsset(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      return _parseStopsFromCsv(csvString);
    } catch (e) {
      logger.w('Error loading stops from asset $assetPath: $e');
      return [];
    }
  }

  /// Parse CSV string and return list of Stop objects
  static List<Stop> _parseStopsFromCsv(String csvString) {
    final List<List<dynamic>> csvData =
        const CsvToListConverter().convert(csvString);

    if (csvData.isEmpty || csvData.length < 2) return [];

    // Get header row
    final header = csvData[0].map((e) => e.toString()).toList();

    // Parse data rows using header-based parsing
    final stops = <Stop>[];
    for (var i = 1; i < csvData.length; i++) {
      try {
        final row = csvData[i].map((e) => e.toString()).toList();
        stops.add(Stop.fromCsv(header, row));
      } catch (e) {
        logger.w('Error parsing stop row ${i + 1}: $e');
      }
    }

    return stops;
  }

  /// Store stops to database for a specific endpoint
  /// Store stops to database for a specific endpoint.
  ///
  /// NOTE: previously this filtered to only store stations (location_type=1).
  /// That caused many feeds to have very few stored stops because most
  /// physical stops are marked with location_type=0. For now we store all
  /// stops regardless of their `location_type` so no stops are discarded.
  static Future<void> storeStopsToDatabase(
      List<Stop> stops, StopsEndpoint endpoint) async {
    final db = database;
    // Store all provided stop records (no filtering by location_type).
    // However, skip any records that don't have a valid stopId because the
    // table primary key includes stopId; empty IDs will cause replacements
    // and may result in a single saved row. Also deduplicate by stopId.
    final cleaned = <String, Stop>{};
    var missingIdCount = 0;
    for (final s in stops) {
      final id = s.stopId.trim();
      if (id.isEmpty) {
        missingIdCount += 1;
        continue;
      }
      // keep first occurrence for a given stopId
      cleaned.putIfAbsent(id, () => s);
    }
    final stations = cleaned.values.toList();

    logger.i(
        'Storing ${stations.length} stops (from ${stops.length} total, skipped $missingIdCount missing-id rows) for endpoint ${endpoint.name}');

    // Convert Stop objects to StopsCompanion objects for Drift
    // Normalize IDs (trim) when creating DB companions to avoid accidental
    // duplicates caused by trailing/leading whitespace. Also log a small
    // sample to help diagnose feeds that produce few stored rows.
    final stopsCompanions = <StopsCompanion>[];
    for (final stop in stations) {
      final trimmedId = stop.stopId.trim();
      stopsCompanions.add(StopsCompanion.insert(
        stopId: trimmedId,
        stopName: stop.stopName,
        stopLat: Value(stop.stopLat),
        stopLon: Value(stop.stopLon),
        locationType: Value(stop.locationType),
        parentStation: Value(stop.parentStation),
        wheelchairBoarding: Value(stop.wheelchairBoarding),
        platformCode: Value(stop.platformCode),
        endpoint: endpoint.name,
      ));
    }

    try {
      for (var i = 0; i < stations.length && i < 5; i++) {
        final s = stations[i];
        logger.d(
            'Inserting sample stop for $endpoint: id="${s.stopId}", name="${s.stopName}", location_type=${s.locationType}');
      }
    } catch (_) {}

    await db.insertStopsForEndpoint(stopsCompanions, endpoint.name);
  }

  /// Get all stops for a specific endpoint from database
  static Future<List<Stop>> getStopsForEndpoint(StopsEndpoint endpoint) async {
    final db = database;
    final dbStops = await db.getAllStopsForEndpoint(endpoint.name);

    // Convert Drift Stop objects back to our Stop objects
    return dbStops
        .map((dbStop) => Stop(
              stopId: dbStop.stopId,
              stopName: dbStop.stopName,
              stopLat: dbStop.stopLat ?? 0.0,
              stopLon: dbStop.stopLon ?? 0.0,
              locationType: dbStop.locationType ?? 0,
              parentStation: dbStop.parentStation,
              wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
              platformCode: dbStop.platformCode,
            ))
        .toList();
  }

  /// Search stops by name across all endpoints
  static Future<List<Stop>> searchStops(String query) async {
    final db = database;
    final dbStops = await db.searchStops(query);

    // Convert Drift Stop objects back to our Stop objects
    return dbStops
        .map((dbStop) => Stop(
              stopId: dbStop.stopId,
              stopName: dbStop.stopName,
              stopLat: dbStop.stopLat ?? 0.0,
              stopLon: dbStop.stopLon ?? 0.0,
              locationType: dbStop.locationType ?? 0,
              parentStation: dbStop.parentStation,
              wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
              platformCode: dbStop.platformCode,
            ))
        .toList();
  }

  /// Fetch stops from API endpoint and update database (manual update function)
  static Future<void> updateStopsFromEndpoint(StopsEndpoint endpoint) async {
    try {
      // Fetching stops from API for endpoint: $endpoint

      // Get GTFS data from the appropriate endpoint
      final gtfsData = await _fetchGtfsDataForEndpoint(endpoint);
      if (gtfsData == null) {
        // Failed to fetch GTFS data for $endpoint: no data returned from API.
        return;
      }

      // Store the stops to database
      try {
        await storeStopsToDatabase(gtfsData.stops, endpoint);
        logger.i(
            'Updated ${gtfsData.stops.length} stops for ${endpoint.name} from API');
      } catch (e, st) {
        logger.e('Database error while storing stops for $endpoint: $e\n$st');
      }
    } catch (e) {
      logger.e('Error updating stops from endpoint ${endpoint.name}: $e');
    }
  }

  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<GtfsData?> _fetchGtfsDataForEndpoint(
      StopsEndpoint endpoint) async {
    switch (endpoint) {
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

      // Light Rail
      case StopsEndpoint.lightrail_innerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrail_newcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrail_cbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrail_parramatta:
        return await fetchLightRailParramattaGtfsData();

      // Trains
      case StopsEndpoint.nswtrains:
        return await fetchNswTrainsGtfsData();
      case StopsEndpoint.sydneytrains:
        return await fetchSydneyTrainsGtfsData();

      // Metro
      case StopsEndpoint.metro:
        return await fetchMetroGtfsData();

      // Regional Buses
      case StopsEndpoint.regionbuses_southeasttablelands:
        return await fetchRegionBusesSouthEastTablelandsGtfsData();
      case StopsEndpoint.regionbuses_southeasttablelands2:
        return await fetchRegionBusesSouthEastTablelands2GtfsData();
      case StopsEndpoint.regionbuses_northcoast:
        return await fetchRegionBusesNorthCoastGtfsData();
      case StopsEndpoint.regionbuses_northcoast2:
        return await fetchRegionBusesNorthCoast2GtfsData();
      case StopsEndpoint.regionbuses_centralwestandorana:
        return await fetchRegionBusesCentralWestAndOranaGtfsData();
      case StopsEndpoint.regionbuses_centralwestandorana2:
        return await fetchRegionBusesCentralWestAndOrana2GtfsData();
      case StopsEndpoint.regionbuses_riverinamurray:
        return await fetchRegionBusesRiverinaMurrayGtfsData();
      case StopsEndpoint.regionbuses_newenglandnorthwest:
        return await fetchRegionBusesNewEnglandNorthWestGtfsData();
      case StopsEndpoint.regionbuses_riverinamurray2:
        return await fetchRegionBusesRiverinaMurray2GtfsData();
      case StopsEndpoint.regionbuses_northcoast3:
        return await fetchRegionBusesNorthCoast3GtfsData();
      case StopsEndpoint.regionbuses_sydneysurrounds:
        return await fetchRegionBusesSydneySurroundsGtfsData();
      case StopsEndpoint.regionbuses_newcastlehunter:
        return await fetchRegionBusesNewcastleHunterGtfsData();
      case StopsEndpoint.regionbuses_farwest:
        return await fetchRegionBusesFarWestGtfsData();
    }
  }

  /// Update all endpoints from API (manual function - not called automatically)
  /// Progress event emitted while updating stops
  ///
  /// - endpoint: the endpoint being processed (or 'init'/'complete')
  /// - completed: number of endpoints completed so far
  /// - total: total number of endpoints to process
  /// - success: whether the last operation succeeded
  /// - message: optional human-readable message
  /// Convert this method to an async generator (Stream) that yields
  /// `StopsUpdateProgress` events during the update process.
  static Stream<StopsUpdateProgress> updateAllStopsFromApi() async* {
    final endpoints = [
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
      StopsEndpoint.ferries_sydneyferries,
      StopsEndpoint.ferries_MFF,
      StopsEndpoint.lightrail_innerwest,
      StopsEndpoint.lightrail_newcastle,
      StopsEndpoint.lightrail_cbdandsoutheast,
      StopsEndpoint.lightrail_parramatta,
      StopsEndpoint.nswtrains,
      StopsEndpoint.sydneytrains,
      StopsEndpoint.metro,
      StopsEndpoint.regionbuses_southeasttablelands,
      StopsEndpoint.regionbuses_southeasttablelands2,
      StopsEndpoint.regionbuses_northcoast,
      StopsEndpoint.regionbuses_northcoast2,
      StopsEndpoint.regionbuses_centralwestandorana,
      StopsEndpoint.regionbuses_centralwestandorana2,
      StopsEndpoint.regionbuses_riverinamurray,
      StopsEndpoint.regionbuses_newenglandnorthwest,
      StopsEndpoint.regionbuses_riverinamurray2,
      StopsEndpoint.regionbuses_northcoast3,
      StopsEndpoint.regionbuses_sydneysurrounds,
      StopsEndpoint.regionbuses_newcastlehunter,
      StopsEndpoint.regionbuses_farwest,
    ];

    final total = endpoints.length;

    // Emit initial event
    yield StopsUpdateProgress(
        endpoint: null,
        completed: 0,
        total: total,
        success: true,
        message: 'Starting update of $total endpoints');

    var completed = 0;

    for (final endpoint in endpoints) {
      // Emit event that we're starting this endpoint
      yield StopsUpdateProgress(
          endpoint: endpoint,
          completed: completed,
          total: total,
          success: true,
          message: 'Starting ${endpoint.name}');

      try {
        await updateStopsFromEndpoint(endpoint);
        completed += 1;
        yield StopsUpdateProgress(
            endpoint: endpoint,
            completed: completed,
            total: total,
            success: true,
            message: 'Completed ${endpoint.name}');
      } catch (e) {
        logger.w('Failed to update ${endpoint.name}: $e');
        yield StopsUpdateProgress(
            endpoint: endpoint,
            completed: completed,
            total: total,
            success: false,
            message: 'Failed ${endpoint.name}: $e');
      }
    }

    // Final completion event
    yield StopsUpdateProgress(
        endpoint: null,
        completed: completed,
        total: total,
        success: true,
        message: 'Finished updating stops ($completed/$total)');
  }

  /// Get total number of stops in database
  static Future<int> getTotalStopsCount() async {
    final db = database;
    return await db.getTotalStopsCount();
  }

  /// Get stops count grouped by transport mode.
  ///
  /// Returns a map keyed by `TransportMode?` where `null` represents
  /// endpoints that couldn't be mapped to a known transport mode. Each
  /// value is a map of endpoint string -> count as returned by the DB.
  static Future<Map<TransportMode?, Map<String, int>>>
      getStopsCountByEndpoint() async {
    final db = database;
    final raw = await db.getStopsCountByEndpoint();

    // Group endpoints by inferred TransportMode (null for unknown)
    final Map<TransportMode?, Map<String, int>> grouped = {};

    for (final entry in raw.entries) {
      final endpoint = entry.key;
      final count = entry.value;

      // Try to map common endpoint prefixes to TransportMode
      TransportMode? modeKey;
      if (endpoint.startsWith('buses')) {
        modeKey = TransportMode.bus;
      } else if (endpoint.startsWith('regionbuses')) {
        modeKey = TransportMode.bus;
      } else if (endpoint.startsWith('ferries')) {
        modeKey = TransportMode.ferry;
      } else if (endpoint.startsWith('lightrail')) {
        modeKey = TransportMode.lightrail;
      } else if (endpoint.contains('trains')) {
        modeKey = TransportMode.train;
      } else if (endpoint == 'metro') {
        modeKey = TransportMode.metro;
      } else {
        modeKey = null;
      }

      grouped.putIfAbsent(modeKey, () => {});
      grouped[modeKey]![endpoint] = count;
    }

    return grouped;
  }

  /// Wipe all stops data from the database
  static Future<void> wipeAllStopsData() async {
    final db = database;

    // Get all unique endpoints
    final stopsCount = await db.getStopsCountByEndpoint();

    // Delete stops for each endpoint
    for (final endpoint in stopsCount.keys) {
      await db.deleteStopsForEndpoint(endpoint);
    }
  }
}
