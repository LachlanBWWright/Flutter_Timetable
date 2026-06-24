part of 'package:lbww_flutter/schema/database.dart';

class StopLineMemberships extends SafeTable {
  TextColumn get endpoint => safeTextColumn();

  TextColumn get stopId => safeTextColumn();

  TextColumn get stopName => safeTextColumn();

  TextColumn get lineId => safeTextColumn();

  TextColumn get lineName => safeTextColumn();

  TextColumn get mode => safeTextColumn();

  IntColumn get stopOrder => safeIntColumn();

  RealColumn get stopLat => safeRealColumn(nullable: true);

  RealColumn get stopLon => safeRealColumn(nullable: true);

  @override
  Set<Column> get primaryKey => {endpoint, stopId, lineId};
}
