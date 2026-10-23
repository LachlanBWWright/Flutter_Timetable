import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../constants/transport_modes.dart';
import '../../gtfs/stop.dart';
import '../../logs/logger.dart';
import '../../schema/database.dart' hide Stop;
import '../fetch_data/timetable_data.dart';
import 'stop_mode_cache.dart';

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

/// Service for managing GTFS stops data - parsing from assets and API endpoints
class StopsService {
  static final _stopModeCache = StopModeCache();
  static ValueListenable<int> get modeChanges => _stopModeCache.changes;

  /// Invalidate pending lookups as well as cached modes when stops change.
  static void clearModeCache() {
    _stopModeCache.clear();
  }

  static void _putGroupedCount(
    Map<TransportMode?, Map<String, int>> grouped,
    TransportMode? modeKey,
    String endpoint,
    int count,
  ) {
    grouped.putIfAbsent(modeKey, () => {})[endpoint] = count;
  }

  static TransportMode? modeForEndpointKey(String endpoint) {
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
  }

  /// Resolve the current application database for each operation.
  static AppDatabase get database => AppDatabase();

  /// Parse CSV file from assets and return list of Stop objects
  static Future<List<Stop>> parseStopsFromAsset(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      return await compute(parseStopsCsv, csvString);
    } catch (e) {
      safeLogWarning('Error loading stops from asset $assetPath: $e');
      return [];
    }
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

    safeLogInfo(
      'Storing ${stations.length} stops (from ${stops.length} total, skipped $missingIdCount missing-id rows) for endpoint ${endpoint.key}',
    );

    final stopsCompanions = <StopsCompanion>[];
    for (final stop in stations) {
      final trimmedId = stop.stopId.trim();
      stopsCompanions.add(
        StopsCompanion.insert(
          stopId: trimmedId,
          stopName: stop.stopName,
          stopCode: Value(stop.stopCode),
          ttsStopName: Value(stop.ttsStopName),
          stopDesc: Value(stop.stopDesc),
          zoneId: Value(stop.zoneId),
          stopUrl: Value(stop.stopUrl),
          stopTimezone: Value(stop.stopTimezone),
          levelId: Value(stop.levelId),
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
    clearModeCache();
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
            stopCode: dbStop.stopCode,
            ttsStopName: dbStop.ttsStopName,
            stopName: dbStop.stopName,
            stopDesc: dbStop.stopDesc,
            stopLat: dbStop.stopLat ?? 0.0,
            stopLon: dbStop.stopLon ?? 0.0,
            zoneId: dbStop.zoneId,
            stopUrl: dbStop.stopUrl,
            stopTimezone: dbStop.stopTimezone,
            locationType: dbStop.locationType ?? 0,
            parentStation: dbStop.parentStation,
            wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
            levelId: dbStop.levelId,
            platformCode: dbStop.platformCode,
          ),
        )
        .toList();
  }

  static Future<List<Stop>> getStopsForEndpoints(
    Iterable<StopsEndpoint> endpoints,
  ) async {
    final dbStops = await database.getAllStopsForEndpoints(
      endpoints.map((endpoint) => endpoint.key),
    );
    return dbStops
        .map(
          (dbStop) => Stop(
            stopId: dbStop.stopId,
            stopCode: dbStop.stopCode,
            ttsStopName: dbStop.ttsStopName,
            stopName: dbStop.stopName,
            stopDesc: dbStop.stopDesc,
            stopLat: dbStop.stopLat ?? 0.0,
            stopLon: dbStop.stopLon ?? 0.0,
            zoneId: dbStop.zoneId,
            stopUrl: dbStop.stopUrl,
            stopTimezone: dbStop.stopTimezone,
            locationType: dbStop.locationType ?? 0,
            parentStation: dbStop.parentStation,
            wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
            levelId: dbStop.levelId,
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
            stopCode: dbStop.stopCode,
            ttsStopName: dbStop.ttsStopName,
            stopName: dbStop.stopName,
            stopDesc: dbStop.stopDesc,
            stopLat: dbStop.stopLat ?? 0.0,
            stopLon: dbStop.stopLon ?? 0.0,
            zoneId: dbStop.zoneId,
            stopUrl: dbStop.stopUrl,
            stopTimezone: dbStop.stopTimezone,
            locationType: dbStop.locationType ?? 0,
            parentStation: dbStop.parentStation,
            wheelchairBoarding: dbStop.wheelchairBoarding ?? 0,
            levelId: dbStop.levelId,
            platformCode: dbStop.platformCode,
          ),
        )
        .toList();
  }

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
      final modeKey = modeForEndpointKey(endpoint);

      _putGroupedCount(grouped, modeKey, endpoint, count);
    }

    return grouped;
  }

  /// Infer the transport mode for a given stopId by looking up the DB
  /// and mapping the stored endpoint to a TransportMode. Returns null if
  /// no mapping can be inferred.
  static Future<TransportMode?> resolveModeForStopId(
    String stopId, {
    TransportMode? preferredMode,
  }) async {
    if (preferredMode != null) {
      return preferredMode;
    }
    return getModeForStopId(stopId);
  }

  static Future<TransportMode?> getModeForStopId(String stopId) async {
    final cachedMode = _stopModeCache.lookup(stopId);
    if (cachedMode != null) return cachedMode;

    final generation = _stopModeCache.generation;
    final mode = await _readModeForStopId(stopId);
    if (generation == _stopModeCache.generation) {
      _stopModeCache.store(stopId, mode);
    }
    return mode;
  }

  static Future<TransportMode?> _readModeForStopId(String stopId) async {
    final db = database;
    try {
      final rows = await db.getStopsById(stopId);
      if (rows.isEmpty) return null;

      // Use the first matching row's endpoint to infer mode
      final endpoint = rows.first.endpoint;

      return modeForEndpointKey(endpoint);
    } on Exception {
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
    clearModeCache();
  }
}
