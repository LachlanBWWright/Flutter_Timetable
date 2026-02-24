part of 'package:lbww_flutter/schema/database.dart';

// Drift table for journeys
class Journeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origin => text()();
  TextColumn get originId => text()();
  TextColumn get destination => text()();
  TextColumn get destinationId => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}
