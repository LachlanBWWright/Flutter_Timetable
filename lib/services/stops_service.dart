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
/// `.key` to obtain the original key when interacting with the database or
/// external systems.
enum StopsEndpoint {
  buses('buses'),
  busesSbsc006('busesSbsc006'),
  busesGbsc001('busesGbsc001'),
  busesGsbc002('buses_GSBC002'),
  busesGsbc003('buses_GSBC003'),
  busesGsbc004('buses_GSBC004'),
  busesGsbc007('buses_GSBC007'),
  busesGsbc008('buses_GSBC008'),
  busesGsbc009('buses_GSBC009'),
  busesGsbc010('buses_GSBC010'),
  busesGsbc014('buses_GSBC014'),
  busesOsmbsc001('buses_OSMBSC001'),
  busesOsmbsc002('buses_OSMBSC002'),
  busesOsmbsc003('buses_OSMBSC003'),
  busesOsmbsc004('buses_OSMBSC004'),
  busesOmbsc006('buses_OMBSC006'),
  busesOmbsc007('buses_OMBSC007'),
  busesOsmbsc008('buses_OSMBSC008'),
  busesOsmbsc009('buses_OSMBSC009'),
  busesOsmbsc010('buses_OSMBSC010'),
  busesOsmbsc011('buses_OSMBSC011'),
  busesOsmbsc012('buses_OSMBSC012'),
  busesNisc001('buses_NISC001'),
  busesReplacementBus('buses_ReplacementBus'),
  ferriesSydneyFerries('ferries_sydneyferries'),
  ferriesMff('ferries_MFF'),
  lightrailInnerwest('lightrail_innerwest'),
  lightrailNewcastle('lightrail_newcastle'),
  lightrailCbdandsoutheast('lightrail_cbdandsoutheast'),
  lightrailParramatta('lightrail_parramatta'),
  nswtrains('nswtrains'),
  sydneytrains('sydneytrains'),
  metro('metro'),
  regionbusesSoutheastTablelands('regionbuses_southeasttablelands'),
  regionbusesSoutheastTablelands2('regionbuses_southeasttablelands2'),
  regionbusesNorthCoast('regionbuses_northcoast'),
  regionbusesNorthCoast2('regionbuses_northcoast2'),
  regionbusesCentralWestAndOrana('regionbuses_centralwestandorana'),
  regionbusesCentralWestAndOrana2('regionbuses_centralwestandorana2'),
  regionbusesRiverinaMurray('regionbuses_riverinamurray'),
  regionbusesNewEnglandNorthWest('regionbuses_newenglandnorthwest'),
  regionbusesRiverinaMurray2('regionbuses_riverinamurray2'),
  regionbusesNorthCoast3('regionbuses_northcoast3'),
  regionbusesSydneySurrounds('regionbuses_sydneysurrounds'),
  regionbusesNewcastleHunter('regionbuses_newcastlehunter'),
  regionbusesFarWest('regionbuses_farwest');

  /// The original string key used for disk / DB storage & service endpoints
  final String key;

  const StopsEndpoint(this.key);
}

class StopsUpdateProgress {
  /// The endpoint associated with this progress event. Null for control
  /// events such as 'init' and 'complete'. Use `.key` to obtain the
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
      'StopsUpdateProgress(endpoint: ${endpoint?.key}, completed: $completed/$total, success: $success, message: $message)';
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
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(
      csvString,
    );

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

  static Future<void> storeStopsToDatabase(
    List<Stop> stops,
    StopsEndpoint endpoint,
  ) async {
    final db = database;

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
      'Storing ${stations.length} stops (from ${stops.length} total, skipped $missingIdCount missing-id rows) for endpoint ${endpoint.key}',
    );

    final stopsCompanions = <StopsCompanion>[];
    for (final stop in stations) {
      final trimmedId = stop.stopId.trim();
      stopsCompanions.add(
        StopsCompanion.insert(
          stopId: trimmedId,
          stopName: stop.stopName,
          stopLat: Value(stop.stopLat),
          stopLon: Value(stop.stopLon),
          locationType: Value(stop.locationType),
          parentStation: Value(stop.parentStation),
          wheelchairBoarding: Value(stop.wheelchairBoarding),
          platformCode: Value(stop.platformCode),
          endpoint: endpoint.key,
        ),
      );
    }

    try {
      for (var i = 0; i < stations.length && i < 5; i++) {
        final s = stations[i];
        logger.d(
          'Inserting sample stop for ${endpoint.key}: id="${s.stopId}", name="${s.stopName}", location_type=${s.locationType}',
        );
      }
    } catch (_) {}

    // store under the canonical key value (original string key preserved in `key`)
    await db.insertStopsForEndpoint(stopsCompanions, endpoint.key);
  }

  /// Get all stops for a specific endpoint from database
  static Future<List<Stop>> getStopsForEndpoint(StopsEndpoint endpoint) async {
    final db = database;
    final dbStops = await db.getAllStopsForEndpoint(endpoint.key);

    // Convert Drift Stop objects back to our Stop objects
    return dbStops
        .map(
          (dbStop) => Stop(
            stopId: dbStop.stopId,
            stopName: dbStop.stopName,
            stopLat: dbStop.stopLat ?? 0.0,
            stopLon: dbStop.stopLon ?? 0.0,
            locationType: dbStop.locationType ?? 0,
            parentStation: dbStop.parentStation,
            wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
            platformCode: dbStop.platformCode,
          ),
        )
        .toList();
  }

  /// Search stops by name across all endpoints
  static Future<List<Stop>> searchStops(String query) async {
    final db = database;
    final dbStops = await db.searchStops(query);

    // Convert Drift Stop objects back to our Stop objects
    return dbStops
        .map(
          (dbStop) => Stop(
            stopId: dbStop.stopId,
            stopName: dbStop.stopName,
            stopLat: dbStop.stopLat ?? 0.0,
            stopLon: dbStop.stopLon ?? 0.0,
            locationType: dbStop.locationType ?? 0,
            parentStation: dbStop.parentStation,
            wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
            platformCode: dbStop.platformCode,
          ),
        )
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
          'Updated ${gtfsData.stops.length} stops for ${endpoint.key} from API',
        );
      } catch (e, st) {
        logger.e(
          'Database error while storing stops for ${endpoint.key}: $e\n$st',
        );
      }
    } catch (e) {
      logger.e('Error updating stops from endpoint ${endpoint.key}: $e');
    }
  }

  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<GtfsData?> _fetchGtfsDataForEndpoint(
    StopsEndpoint endpoint,
  ) async {
    switch (endpoint) {
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

      // Light Rail
      case StopsEndpoint.lightrailInnerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrailNewcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrailCbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrailParramatta:
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
      case StopsEndpoint.regionbusesSoutheastTablelands:
        return await fetchRegionBusesSouthEastTablelandsGtfsData();
      case StopsEndpoint.regionbusesSoutheastTablelands2:
        return await fetchRegionBusesSouthEastTablelands2GtfsData();
      case StopsEndpoint.regionbusesNorthCoast:
        return await fetchRegionBusesNorthCoastGtfsData();
      case StopsEndpoint.regionbusesNorthCoast2:
        return await fetchRegionBusesNorthCoast2GtfsData();
      case StopsEndpoint.regionbusesCentralWestAndOrana:
        return await fetchRegionBusesCentralWestAndOranaGtfsData();
      case StopsEndpoint.regionbusesCentralWestAndOrana2:
        return await fetchRegionBusesCentralWestAndOrana2GtfsData();
      case StopsEndpoint.regionbusesRiverinaMurray:
        return await fetchRegionBusesRiverinaMurrayGtfsData();
      case StopsEndpoint.regionbusesNewEnglandNorthWest:
        return await fetchRegionBusesNewEnglandNorthWestGtfsData();
      case StopsEndpoint.regionbusesRiverinaMurray2:
        return await fetchRegionBusesRiverinaMurray2GtfsData();
      case StopsEndpoint.regionbusesNorthCoast3:
        return await fetchRegionBusesNorthCoast3GtfsData();
      case StopsEndpoint.regionbusesSydneySurrounds:
        return await fetchRegionBusesSydneySurroundsGtfsData();
      case StopsEndpoint.regionbusesNewcastleHunter:
        return await fetchRegionBusesNewcastleHunterGtfsData();
      case StopsEndpoint.regionbusesFarWest:
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
      StopsEndpoint.ferriesSydneyFerries,
      StopsEndpoint.ferriesMff,
      StopsEndpoint.lightrailInnerwest,
      StopsEndpoint.lightrailNewcastle,
      StopsEndpoint.lightrailCbdandsoutheast,
      StopsEndpoint.lightrailParramatta,
      StopsEndpoint.nswtrains,
      StopsEndpoint.sydneytrains,
      StopsEndpoint.metro,
      StopsEndpoint.regionbusesSoutheastTablelands,
      StopsEndpoint.regionbusesSoutheastTablelands2,
      StopsEndpoint.regionbusesNorthCoast,
      StopsEndpoint.regionbusesNorthCoast2,
      StopsEndpoint.regionbusesCentralWestAndOrana,
      StopsEndpoint.regionbusesCentralWestAndOrana2,
      StopsEndpoint.regionbusesRiverinaMurray,
      StopsEndpoint.regionbusesNewEnglandNorthWest,
      StopsEndpoint.regionbusesRiverinaMurray2,
      StopsEndpoint.regionbusesNorthCoast3,
      StopsEndpoint.regionbusesSydneySurrounds,
      StopsEndpoint.regionbusesNewcastleHunter,
      StopsEndpoint.regionbusesFarWest,
    ];

    final total = endpoints.length;

    // Emit initial event
    yield StopsUpdateProgress(
      endpoint: null,
      completed: 0,
      total: total,
      success: true,
      message: 'Starting update of $total endpoints',
    );

    var completed = 0;

    for (final endpoint in endpoints) {
      // Emit event that we're starting this endpoint
      yield StopsUpdateProgress(
        endpoint: endpoint,
        completed: completed,
        total: total,
        success: true,
        message: 'Starting ${endpoint.key}',
      );

      try {
        await updateStopsFromEndpoint(endpoint);
        completed += 1;
        yield StopsUpdateProgress(
          endpoint: endpoint,
          completed: completed,
          total: total,
          success: true,
          message: 'Completed ${endpoint.key}',
        );
      } catch (e) {
        logger.w('Failed to update ${endpoint.key}: $e');
        yield StopsUpdateProgress(
          endpoint: endpoint,
          completed: completed,
          total: total,
          success: false,
          message: 'Failed ${endpoint.key}: $e',
        );
      }
    }

    // Final completion event
    yield StopsUpdateProgress(
      endpoint: null,
      completed: completed,
      total: total,
      success: true,
      message: 'Finished updating stops ($completed/$total)',
    );
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

  /// Infer the transport mode for a given stopId by looking up the DB
  /// and mapping the stored endpoint to a TransportMode. Returns null if
  /// no mapping can be inferred.
  static Future<TransportMode?> getModeForStopId(String stopId) async {
    final db = database;
    try {
      final rows = await db.getStopsById(stopId);
      if (rows.isEmpty) return null;

      // Use the first matching row's endpoint to infer mode
      final endpoint = rows.first.endpoint;

      if (endpoint.startsWith('buses') || endpoint.startsWith('regionbuses')) {
        return TransportMode.bus;
      }
      if (endpoint.startsWith('ferries')) {
        return TransportMode.ferry;
      }
      if (endpoint.startsWith('lightrail')) {
        return TransportMode.lightrail;
      }
      if (endpoint.contains('trains')) {
        return TransportMode.train;
      }
      if (endpoint == 'metro') {
        return TransportMode.metro;
      }

      return null;
    } catch (_) {
      return null;
    }
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
