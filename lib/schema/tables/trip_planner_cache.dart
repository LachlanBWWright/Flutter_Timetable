part of 'package:lbww_flutter/schema/database.dart';

class TripPlannerCache extends SafeTable {
  TextColumn get originId => safeTextColumn();

  TextColumn get destinationId => safeTextColumn();

  DateTimeColumn get fetchedAt => safeDateTimeColumn();

  TextColumn get responseJson => safeTextColumn(nullable: true);

  TextColumn get error => safeTextColumn(nullable: true);

  @override
  Set<Column> get primaryKey => {originId, destinationId};
}
