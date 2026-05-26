part of 'package:lbww_flutter/schema/database.dart';

// Drift table for stops
class Stops extends SafeTable {
  TextColumn get stopId => safeTextColumn();

  TextColumn get stopName => safeTextColumn();

  TextColumn get stopCode => safeTextColumn(nullable: true);

  TextColumn get ttsStopName => safeTextColumn(nullable: true);

  TextColumn get stopDesc => safeTextColumn(nullable: true);

  TextColumn get zoneId => safeTextColumn(nullable: true);

  TextColumn get stopUrl => safeTextColumn(nullable: true);

  TextColumn get stopTimezone => safeTextColumn(nullable: true);

  TextColumn get levelId => safeTextColumn(nullable: true);

  RealColumn get stopLat => safeRealColumn(nullable: true);

  RealColumn get stopLon => safeRealColumn(nullable: true);

  IntColumn get locationType => safeIntColumn(nullable: true);

  TextColumn get parentStation => safeTextColumn(nullable: true);

  IntColumn get wheelchairBoarding => safeIntColumn(nullable: true);

  TextColumn get platformCode => safeTextColumn(nullable: true);

  TextColumn get endpoint => safeTextColumn();

  @override
  Set<Column> get primaryKey => {stopId, endpoint};
}
