part of 'package:lbww_flutter/schema/database.dart';

class StaticCacheStatuses extends SafeTable {
  TextColumn get endpoint => safeTextColumn();

  DateTimeColumn get stopsUpdatedAt => safeDateTimeColumn(nullable: true);

  DateTimeColumn get lineMembershipsUpdatedAt =>
      safeDateTimeColumn(nullable: true);

  DateTimeColumn get lastBuildStartedAt => safeDateTimeColumn(nullable: true);

  DateTimeColumn get lastBuildFinishedAt => safeDateTimeColumn(nullable: true);

  TextColumn get lastError => safeTextColumn(nullable: true);

  BoolColumn get isBuilding => safeBoolColumn(defaultValue: false);

  @override
  Set<Column> get primaryKey => {endpoint};
}
