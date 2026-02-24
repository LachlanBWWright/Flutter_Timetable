part of 'package:lbww_flutter/schema/database.dart';

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
