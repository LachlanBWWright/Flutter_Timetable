import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';

import 'database_errors.dart';

part 'tables/journeys.dart';
part 'tables/routes.dart';
part 'tables/static_cache_statuses.dart';
part 'tables/stop_line_memberships.dart';
part 'tables/stops.dart';
part 'tables/trip_planner_cache.dart';

part 'database.g.dart';
part 'database/safe_table.dart';
part 'database/operations.dart';
part 'database/stops.dart';
part 'database/cache.dart';
part 'database/routes.dart';
part 'database/static_import.dart';

QueryExecutor _openAppDatabase() => driftDatabase(
  name: 'trip_database',
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  ),
);

@DriftDatabase(
  tables: [
    Journeys,
    Routes,
    Stops,
    StopLineMemberships,
    StaticCacheStatuses,
    TripPlannerCache,
  ],
)
class AppDatabase extends _$AppDatabase
    with
        _DatabaseOperations,
        _StopQueries,
        _CacheQueries,
        _RouteQueries,
        _StaticImportQueries {
  // Singleton instance
  static AppDatabase? _instance;
  static Future<void>? _resetInFlight;
  @override
  bool _isClosed = false;

  // Single QueryExecutor reused across the app to avoid multiple database
  // instances. Uses drift_flutter which picks the right backend per platform.
  static QueryExecutor _sharedExecutor = _openAppDatabase();

  AppDatabase._internal() : super(_sharedExecutor);

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  /// Create an AppDatabase backed by the provided [QueryExecutor].
  /// Useful for tests where an in-memory or temporary file database is required.
  AppDatabase.connect(super.executor);

  @override
  Future<void> close() async {
    _isClosed = true;
    try {
      await super.close();
    } finally {
      if (identical(_instance, this)) {
        _instance = null;
        _sharedExecutor = _openAppDatabase();
      }
    }
  }

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await _createAllSafe(m);
      await customStatement(
        'CREATE INDEX IF NOT EXISTS stops_endpoint_stop_name '
        'ON stops (endpoint, stop_name)',
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Add new stop columns introduced in schemaVersion 4. Drift will
      // skip columns that already exist when upgrading.
      if (from < 4) {
        await m.addColumn(stops, stops.stopCode);
        await m.addColumn(stops, stops.ttsStopName);
        await m.addColumn(stops, stops.stopDesc);
        await m.addColumn(stops, stops.zoneId);
        await m.addColumn(stops, stops.stopUrl);
        await m.addColumn(stops, stops.stopTimezone);
        await m.addColumn(stops, stops.levelId);
      }

      if (from < 5) {
        await m.addColumn(journeys, journeys.tripType);
        await m.addColumn(journeys, journeys.mode);
        await m.addColumn(journeys, journeys.lineId);
        await m.addColumn(journeys, journeys.lineName);
        await m.addColumn(journeys, journeys.legsJson);
        await customStatement(
          "UPDATE journeys SET trip_type = '${SavedTripType.direct.storageValue}' WHERE trip_type IS NULL OR trip_type = ''",
        );
      }

      if (from < 6) {
        await m.createTable(stopLineMemberships);
      }

      if (from < 7) {
        await m.createTable(staticCacheStatuses);
        await m.createTable(tripPlannerCache);
      }

      if (from < 8) {
        await m.createTable(routes);
      }

      if (from < 9) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS stops_endpoint_stop_name '
          'ON stops (endpoint, stop_name)',
        );
      }
    },
  );

  // Journey operations
  Future<int> insertJourney(JourneysCompanion journey) => _runDatabaseOperation(
    'insertJourney',
    () => into(journeys).insert(journey),
  );

  Future<List<Journey>> getAllJourneys() =>
      _runDatabaseRead('getAllJourneys', () => select(journeys).get());

  Future<List<Journey>> getPinnedJourneys() => _runDatabaseRead(
    'getPinnedJourneys',
    () => (select(journeys)..where((tbl) => tbl.isPinned.equals(true))).get(),
  );

  Future<List<Journey>> getUnpinnedJourneys() => _runDatabaseRead(
    'getUnpinnedJourneys',
    () => (select(journeys)..where((tbl) => tbl.isPinned.equals(false))).get(),
  );

  Future<int> toggleJourneyPin(int id, bool isPinned) => _runDatabaseOperation(
    'toggleJourneyPin',
    () => (update(journeys)..where((tbl) => tbl.id.equals(id))).write(
      JourneysCompanion(isPinned: Value(isPinned)),
    ),
  );

  Future<int> deleteJourney(int id) => _runDatabaseOperation(
    'deleteJourney',
    () => (delete(journeys)..where((tbl) => tbl.id.equals(id))).go(),
  );

  // No extra connection helpers are exposed; use the AppDatabase() singleton.

  /// Clear all persisted application data while retaining live references.
  ///
  /// This is intended for development/testing only. The schema and migrations
  /// remain in place while every app table is cleared transactionally.
  static Future<void> resetDatabase() => _resetInFlight ??=
      _clearPersistedData().whenComplete(() => _resetInFlight = null);

  static Future<void> _clearPersistedData() async {
    // Clear through Drift so this works with both native and web executors.
    // The transaction keeps the previous data intact if any delete fails.
    final existing = _instance;
    late final AppDatabase database;
    if (existing == null) {
      database = AppDatabase._internal();
    } else if (existing._isClosed) {
      _instance = null;
      _sharedExecutor = _openAppDatabase();
      database = AppDatabase._internal();
    } else {
      database = existing;
    }
    _instance = database;

    // Drift opens the executor and applies migrations on the first query.
    // Do that before setting the operation gate, since onCreate runs wrapped
    // database operations of its own.
    await database._runDatabaseOperation<void>(
      'prepareDatabaseReset',
      () async {
        await database.customSelect('SELECT 1').getSingle();
      },
    );

    try {
      await database._runDatabaseOperation<void>('resetDatabase', () async {
        // Keep new SafeTable-wrapped work from queuing behind the reset and
        // the transaction window.
        database._isClosed = true;
        await database.transaction(() async {
          await database.delete(database.journeys).go();
          await database.delete(database.routes).go();
          await database.delete(database.stopLineMemberships).go();
          await database.delete(database.stops).go();
          await database.delete(database.staticCacheStatuses).go();
          await database.delete(database.tripPlannerCache).go();
          await database.customStatement(
            'DELETE FROM sqlite_sequence WHERE name = ?',
            ['journeys'],
          );
        });
      });
    } finally {
      // Keep the same connection and singleton. Screens and injected services
      // may retain this object, so closing it would strand those references.
      // Restore access on success and after transaction rollback alike.
      database._isClosed = false;
    }
  }
}
