import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:lbww_flutter/models/manual_trip_models.dart';

part 'tables/journeys.dart';
part 'tables/stops.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Journeys, Stops])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static AppDatabase? _instance;

  // Single QueryExecutor reused across the app to avoid multiple database
  // instances. Uses drift_flutter which picks the right backend per platform
  // (NativeDatabase on mobile/desktop, IndexedDB on web).
  static final QueryExecutor _sharedExecutor = driftDatabase(
    name: 'trip_database',
  );

  AppDatabase._internal() : super(_sharedExecutor);

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  /// Create an AppDatabase backed by the provided [QueryExecutor].
  /// Useful for tests where an in-memory or temporary file database is required.
  AppDatabase.connect(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
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
    },
  );

  // Journey operations
  Future<int> insertJourney(JourneysCompanion journey) =>
      into(journeys).insert(journey);

  Future<List<Journey>> getAllJourneys() => select(journeys).get();

  Future<List<Journey>> getPinnedJourneys() =>
      (select(journeys)..where((tbl) => tbl.isPinned.equals(true))).get();

  Future<List<Journey>> getUnpinnedJourneys() =>
      (select(journeys)..where((tbl) => tbl.isPinned.equals(false))).get();

  Future<int> toggleJourneyPin(int id, bool isPinned) =>
      (update(journeys)..where((tbl) => tbl.id.equals(id))).write(
        JourneysCompanion(isPinned: Value(isPinned)),
      );

  Future<int> deleteJourney(int id) =>
      (delete(journeys)..where((tbl) => tbl.id.equals(id))).go();

  // Stop operations
  Future<int> insertStop(StopsCompanion stop) =>
      into(stops).insert(stop, mode: InsertMode.replace);

  Future<List<Stop>> getAllStopsForEndpoint(String endpoint) =>
      (select(stops)
            ..where((tbl) => tbl.endpoint.equals(endpoint))
            ..orderBy([(t) => OrderingTerm(expression: t.stopName)]))
          .get();

  Future<List<Stop>> getAllStops({int? limit}) {
    final query = select(stops)
      ..orderBy([(t) => OrderingTerm(expression: t.stopName)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Stop>> searchStops(String query, {int limit = 50}) =>
      (select(stops)
            ..where((tbl) => tbl.stopName.like('%$query%'))
            ..orderBy([(t) => OrderingTerm(expression: t.stopName)])
            ..limit(limit))
          .get();

  /// Get all stop rows matching the provided stopId across endpoints
  Future<List<Stop>> getStopsById(String stopId) =>
      (select(stops)..where((tbl) => tbl.stopId.equals(stopId))).get();

  Future<int> deleteStopsForEndpoint(String endpoint) =>
      (delete(stops)..where((tbl) => tbl.endpoint.equals(endpoint))).go();

  Future<int> getTotalStopsCount() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<Map<String, int>> getStopsCountByEndpoint() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)
      ..addColumns([stops.endpoint, countExp])
      ..groupBy([stops.endpoint])
      ..orderBy([OrderingTerm(expression: stops.endpoint)]);

    final results = await query.get();
    return Map.fromEntries(
      results.expand((row) {
        final endpoint = row.read(stops.endpoint);
        if (endpoint == null) return const <MapEntry<String, int>>[];
        return [MapEntry(endpoint, row.read(countExp) ?? 0)];
      }),
    );
  }

  // Batch insert stops with transaction
  Future<void> insertStopsForEndpoint(
    List<StopsCompanion> stopsList,
    String endpoint,
  ) async {
    await transaction(() async {
      // Clear existing stops for this endpoint
      await deleteStopsForEndpoint(endpoint);

      // Insert new stops in batches
      await batch((batch) {
        for (final stop in stopsList) {
          batch.insert(stops, stop, mode: InsertMode.replace);
        }
      });
    });
  }

  // No extra connection helpers are exposed; use the AppDatabase() singleton.

  /// Close, delete and recreate the underlying database file.
  ///
  /// This is intended for development/testing only. It will close the current
  /// instance (if any), delete the database file from the application's
  /// documents directory and create a fresh DB instance.
  static Future<void> resetDatabase() async {
    // Close existing instance if open
    try {
      await _instance?.close();
    } catch (_) {
      // ignore errors during close
    }

    _instance = null;

    // Create a fresh instance backed by a new executor.
    _instance = AppDatabase.connect(driftDatabase(name: 'trip_database'));
  }
}

/* LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/trip_database.db');
    return NativeDatabase(file);
  });
}
 */
