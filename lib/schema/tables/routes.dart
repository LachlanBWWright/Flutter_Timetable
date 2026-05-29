part of 'package:lbww_flutter/schema/database.dart';

class Routes extends SafeTable {
  TextColumn get endpoint => safeTextColumn();

  TextColumn get routeId => safeTextColumn();

  TextColumn get lineId => safeTextColumn();

  TextColumn get routeShortName => safeTextColumn(nullable: true);

  TextColumn get routeLongName => safeTextColumn(nullable: true);

  TextColumn get routeDesc => safeTextColumn(nullable: true);

  TextColumn get routeType => safeTextColumn(nullable: true);

  TextColumn get routeColor => safeTextColumn(nullable: true);

  TextColumn get routeTextColor => safeTextColumn(nullable: true);

  TextColumn get routeSortOrder => safeTextColumn(nullable: true);

  @override
  Set<Column> get primaryKey => {endpoint, routeId};
}
