import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// Drift table for journeys
class Journeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origin => text()();
  TextColumn get originId => text()();
  TextColumn get destination => text()();
  TextColumn get destinationId => text()();
}

@DriftDatabase(tables: [Journeys])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Insert a journey
  Future<int> insertJourney(JourneysCompanion journey) =>
      into(journeys).insert(journey);

  // Get all journeys
  Future<List<Journey>> getAllJourneys() => select(journeys).get();

  // Delete a journey by id
  Future<int> deleteJourney(int id) =>
      (delete(journeys)..where((tbl) => tbl.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/trip_database.db');
    return NativeDatabase(file);
  });
}
