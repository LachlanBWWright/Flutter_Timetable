import 'dart:async';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../constants/transport_modes.dart';
import '../fetch_data/timetable_data.dart';
import '../gtfs/stop.dart';
import '../logs/logger.dart';
import '../schema/database.dart' hide Stop;

/// Progress event emitted while updating stops from API
/// Enumerates all supported GTFS endpoints used by the app. The enum names
/// intentionally match the string keys used previously so we can use
/// `.key` to obtain the original key when interacting with the database or
/// external systems.
enum StopsEndpoint {
  buses('buses', '/buses'),
  busesSbsc006('busesSbsc006', '/buses/SBSC006'),
  busesGbsc001('busesGbsc001', '/buses/GSBC001'),
  busesGsbc002('buses_GSBC002', '/buses/GSBC002'),
  busesGsbc003('buses_GSBC003', '/buses/GSBC003'),
  busesGsbc004('buses_GSBC004', '/buses/GSBC004'),
  busesGsbc007('buses_GSBC007', '/buses/GSBC007'),
  busesGsbc008('buses_GSBC008', '/buses/GSBC008'),
  busesGsbc009('buses_GSBC009', '/buses/GSBC009'),
  busesGsbc010('buses_GSBC010', '/buses/GSBC010'),
  busesGsbc014('buses_GSBC014', '/buses/GSBC014'),
  busesOsmbsc001('buses_OSMBSC001', '/buses/OSMBSC001'),
  busesOsmbsc002('buses_OSMBSC002', '/buses/OSMBSC002'),
  busesOsmbsc003('buses_OSMBSC003', '/buses/OSMBSC003'),
  busesOsmbsc004('buses_OSMBSC004', '/buses/OSMBSC004'),
  busesOmbsc006('buses_OMBSC006', '/buses/OMBSC006'),
  busesOmbsc007('buses_OMBSC007', '/buses/OMBSC007'),
  busesOsmbsc008('buses_OSMBSC008', '/buses/OSMBSC008'),
  busesOsmbsc009('buses_OSMBSC009', '/buses/OSMBSC009'),
  busesOsmbsc010('buses_OSMBSC010', '/buses/OSMBSC010'),
  busesOsmbsc011('buses_OSMBSC011', '/buses/OSMBSC011'),
  busesOsmbsc012('buses_OSMBSC012', '/buses/OSMBSC012'),
  busesNisc001('buses_NISC001', '/buses/NISC001'),
  busesReplacementBus('buses_ReplacementBus', '/buses/ReplacementBus'),
  ferriesSydneyFerries('ferries_sydneyferries', '/ferries/sydneyferries'),
  ferriesMff('ferries_MFF', '/ferries/MFF'),
  lightrailInnerwest('lightrail_innerwest', '/lightrail/innerwest'),
  lightrailNewcastle('lightrail_newcastle', '/lightrail/newcastle'),
  lightrailCbdandsoutheast(
    'lightrail_cbdandsoutheast',
    '/lightrail/cbdandsoutheast',
  ),
  lightrailParramatta('lightrail_parramatta', '/lightrail/parramatta'),
  nswtrains('nswtrains', '/nswtrains'),
  sydneytrains('sydneytrains', '/sydneytrains'),
  metro('metro', '/metro', isV2: true),
  regionbusesSoutheastTablelands(
    'regionbuses_southeasttablelands',
    '/regionbuses/southeasttablelands',
  ),
  regionbusesSoutheastTablelands2(
    'regionbuses_southeasttablelands2',
    '/regionbuses/southeasttablelands2',
  ),
  regionbusesNorthCoast('regionbuses_northcoast', '/regionbuses/northcoast'),
  regionbusesNorthCoast2('regionbuses_northcoast2', '/regionbuses/northcoast2'),
  regionbusesCentralWestAndOrana(
    'regionbuses_centralwestandorana',
    '/regionbuses/centralwestandorana',
  ),
  regionbusesCentralWestAndOrana2(
    'regionbuses_centralwestandorana2',
    '/regionbuses/centralwestandorana2',
  ),
  regionbusesRiverinaMurray(
    'regionbuses_riverinamurray',
    '/regionbuses/riverinamurray',
  ),
  regionbusesNewEnglandNorthWest(
    'regionbuses_newenglandnorthwest',
    '/regionbuses/newenglandnorthwest',
  ),
  regionbusesRiverinaMurray2(
    'regionbuses_riverinamurray2',
    '/regionbuses/riverinamurray2',
  ),
  regionbusesNorthCoast3('regionbuses_northcoast3', '/regionbuses/northcoast3'),
  regionbusesSydneySurrounds(
    'regionbuses_sydneysurrounds',
    '/regionbuses/sydneysurrounds',
  ),
  regionbusesNewcastleHunter(
    'regionbuses_newcastlehunter',
    '/regionbuses/newcastlehunter',
  ),
  regionbusesFarWest('regionbuses_farwest', '/regionbuses/farwest');

  /// The original string key used for disk / DB storage & service endpoints
  final String key;

  /// The API path segment used to construct the GTFS schedule URL
  final String path;

  /// Whether this endpoint uses the v2 schedule API surface (default: v1)
  final bool isV2;

  const StopsEndpoint(this.key, this.path, {this.isV2 = false});
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
    final db = _database ??= AppDatabase();
    return db;
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

  /// Fetch only stops.txt from the GTFS ZIP for [endpoint] and update the DB.
  ///
  /// Key improvements over the old approach:
  /// - Only parses stops.txt — skips stop_times.txt, trips.txt, shapes.txt
  ///   etc. which can be orders of magnitude larger.
  /// - ZIP decompression and CSV parsing run in a background isolate via
  ///   [compute], keeping the UI thread free.
  static Future<void> updateStopsFromEndpoint(StopsEndpoint endpoint) async {
    try {
      final stops = await _fetchStopsOnly(endpoint);
      if (stops == null) return;
      await storeStopsToDatabase(stops, endpoint);
      logger.i('Updated ${stops.length} stops for ${endpoint.key} from API');
    } catch (e) {
      logger.e('Error updating stops from endpoint ${endpoint.key}: $e');
    }
  }

  /// HTTP-fetch the GTFS ZIP for [endpoint] and parse only stops.txt in a
  /// background isolate. Returns null on any network or parse failure.
  static Future<List<Stop>?> _fetchStopsOnly(StopsEndpoint endpoint) async {
    final versionPath = endpoint.isV2 ? 'v2' : 'v1';
    final url = Uri.parse(
      'https://api.transport.nsw.gov.au/$versionPath/gtfs/schedule${endpoint.path}',
    );
    try {
      final response = await http.get(url, headers: getHeaders());
      if (response.statusCode != 200) {
        logger.e(
          'Failed to fetch GTFS for ${endpoint.key}: ${response.statusCode}',
        );
        return null;
      }
      // Offload ZIP decode + CSV parse to a background isolate so the UI
      // thread is not blocked by the CPU-intensive work.
      return await compute(parseStopsOnlyFromZipBytes, response.bodyBytes);
    } catch (e) {
      logger.e('Network error fetching ${endpoint.key}: $e');
      return null;
    }
  }

  /// Update all endpoints from API (manual function - not called automatically).
  ///
  /// Emits [StopsUpdateProgress] events as each endpoint is processed.
  /// Endpoints are processed in parallel batches of [_batchSize] to reduce
  /// total wall-clock time while avoiding excessive memory and connection usage.
  static const int _batchSize = 5;

  static Stream<StopsUpdateProgress> updateAllStopsFromApi() {
    final endpoints = StopsEndpoint.values;
    final total = endpoints.length;
    final controller = StreamController<StopsUpdateProgress>();

    () async {
      controller.add(
        StopsUpdateProgress(
          endpoint: null,
          completed: 0,
          total: total,
          success: true,
          message: 'Starting update of $total endpoints',
        ),
      );

      var completed = 0;

      for (var i = 0; i < endpoints.length; i += _batchSize) {
        final batch = endpoints.skip(i).take(_batchSize).toList();

        await Future.wait(
          batch.map((endpoint) async {
            controller.add(
              StopsUpdateProgress(
                endpoint: endpoint,
                completed: completed,
                total: total,
                success: true,
                message: 'Starting ${endpoint.key}',
              ),
            );
            try {
              await updateStopsFromEndpoint(endpoint);
              completed += 1;
              controller.add(
                StopsUpdateProgress(
                  endpoint: endpoint,
                  completed: completed,
                  total: total,
                  success: true,
                  message: 'Completed ${endpoint.key}',
                ),
              );
            } catch (e) {
              logger.w('Failed to update ${endpoint.key}: $e');
              controller.add(
                StopsUpdateProgress(
                  endpoint: endpoint,
                  completed: completed,
                  total: total,
                  success: false,
                  message: 'Failed ${endpoint.key}: $e',
                ),
              );
            }
          }),
        );
      }

      controller.add(
        StopsUpdateProgress(
          endpoint: null,
          completed: completed,
          total: total,
          success: true,
          message: 'Finished updating stops ($completed/$total)',
        ),
      );
      await controller.close();
    }();

    return controller.stream;
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
      grouped[modeKey]?[endpoint] = count;
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
