part of 'package:lbww_flutter/schema/database.dart';

class StaticCacheStatuses extends Table {
  TextColumn get endpoint => text()();
  DateTimeColumn get stopsUpdatedAt => dateTime().nullable()();
  DateTimeColumn get lineMembershipsUpdatedAt => dateTime().nullable()();
  DateTimeColumn get lastBuildStartedAt => dateTime().nullable()();
  DateTimeColumn get lastBuildFinishedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  BoolColumn get isBuilding => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {endpoint};
}
