part of 'package:lbww_flutter/schema/database.dart';

class StopLineMemberships extends Table {
  TextColumn get endpoint => text()();
  TextColumn get stopId => text()();
  TextColumn get stopName => text()();
  TextColumn get lineId => text()();
  TextColumn get lineName => text()();
  TextColumn get mode => text()();
  IntColumn get stopOrder => integer()();
  RealColumn get stopLat => real().nullable()();
  RealColumn get stopLon => real().nullable()();

  @override
  Set<Column> get primaryKey => {endpoint, stopId, lineId};
}
