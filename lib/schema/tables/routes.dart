part of 'package:lbww_flutter/schema/database.dart';

class Routes extends Table {
  TextColumn get endpoint => text()();
  TextColumn get routeId => text()();
  TextColumn get lineId => text()();
  TextColumn get routeShortName => text().nullable()();
  TextColumn get routeLongName => text().nullable()();
  TextColumn get routeDesc => text().nullable()();
  TextColumn get routeType => text().nullable()();
  TextColumn get routeColor => text().nullable()();
  TextColumn get routeTextColor => text().nullable()();
  TextColumn get routeSortOrder => text().nullable()();

  @override
  Set<Column> get primaryKey => {endpoint, routeId};
}
