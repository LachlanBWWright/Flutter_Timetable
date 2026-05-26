part of 'package:lbww_flutter/schema/database.dart';

// Drift table for journeys
class Journeys extends SafeTable {
  IntColumn get id => safeIntColumn(autoIncrement: true);

  TextColumn get origin => safeTextColumn();

  TextColumn get originId => safeTextColumn();

  TextColumn get destination => safeTextColumn();

  TextColumn get destinationId => safeTextColumn();

  TextColumn get tripType => safeTextColumn(defaultValue: 'direct');

  TextColumn get mode => safeTextColumn(nullable: true);

  TextColumn get lineId => safeTextColumn(nullable: true);

  TextColumn get lineName => safeTextColumn(nullable: true);

  TextColumn get legsJson => safeTextColumn(nullable: true);

  BoolColumn get isPinned => safeBoolColumn(defaultValue: false);
}
