part of 'package:lbww_flutter/schema/database.dart';

class TripPlannerCache extends Table {
  TextColumn get originId => text()();
  TextColumn get destinationId => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get responseJson => text().nullable()();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {originId, destinationId};
}
