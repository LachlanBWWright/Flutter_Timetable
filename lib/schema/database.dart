import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Drift table for journeys
class Journeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origin => text()();
  TextColumn get originId => text()();
  TextColumn get destination => text()();
  TextColumn get destinationId => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}

// Drift table for stops
class Stops extends Table {
  TextColumn get stopId => text()();
  TextColumn get stopName => text()();
  RealColumn get stopLat => real().nullable()();
  RealColumn get stopLon => real().nullable()();
  IntColumn get locationType => integer().nullable()();
  TextColumn get parentStation => text().nullable()();
  IntColumn get wheelchairBoarding => integer().nullable()();
  TextColumn get platformCode => text().nullable()();
  TextColumn get endpoint => text()();

  @override
  Set<Column> get primaryKey => {stopId, endpoint};
}

@DriftDatabase(tables: [Journeys, Stops])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            // Add isPinned column to journeys table
            await m.addColumn(journeys, journeys.isPinned);
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
      (update(journeys)..where((tbl) => tbl.id.equals(id)))
          .write(JourneysCompanion(isPinned: Value(isPinned)));

  Future<int> deleteJourney(int id) =>
      (delete(journeys)..where((tbl) => tbl.id.equals(id))).go();

  // Stop operations
  Future<int> insertStop(StopsCompanion stop) =>
      into(stops).insert(stop, mode: InsertMode.replace);

  Future<List<Stop>> getAllStopsForEndpoint(String endpoint) => (select(stops)
        ..where((tbl) => tbl.endpoint.equals(endpoint))
        ..orderBy([(t) => OrderingTerm(expression: t.stopName)]))
      .get();

  Future<List<Stop>> searchStops(String query, {int limit = 50}) =>
      (select(stops)
            ..where((tbl) => tbl.stopName.like('%$query%'))
            ..orderBy([(t) => OrderingTerm(expression: t.stopName)])
            ..limit(limit))
          .get();

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
    return Map.fromEntries(results.map((row) => MapEntry(
          row.read(stops.endpoint)!,
          row.read(countExp) ?? 0,
        )));
  }

  // Batch insert stops with transaction
  Future<void> insertStopsForEndpoint(
      List<StopsCompanion> stopsList, String endpoint) async {
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

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
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
