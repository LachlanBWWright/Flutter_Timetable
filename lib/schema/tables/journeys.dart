part of 'package:lbww_flutter/schema/database.dart';

// Drift table for journeys
class Journeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origin => text()();
  TextColumn get originId => text()();
  TextColumn get destination => text()();
  TextColumn get destinationId => text()();
  TextColumn get tripType => text().withDefault(const Constant('direct'))();
  TextColumn get mode => text().nullable()();
  TextColumn get lineId => text().nullable()();
  TextColumn get lineName => text().nullable()();
  TextColumn get legsJson => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}
