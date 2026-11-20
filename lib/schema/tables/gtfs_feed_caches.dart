part of 'package:lbww_flutter/schema/database.dart';

class GtfsFeedCaches extends Table {
  TextColumn get source => text()();
  BlobColumn get archive => blob()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get stopModes => text().withDefault(const Constant('{}'))();
  @override
  Set<Column> get primaryKey => {source};
}
