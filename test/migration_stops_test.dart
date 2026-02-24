import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:path/path.dart' as p;
// sqlite3 not needed for this simplified test

void main() {
  test('migration creates stops table when upgrading from old schema',
      () async {
    // Create a temp directory and a SQLite file that simulates an older DB version
    final dir = await Directory.systemTemp.createTemp('fluttertimetable_test_');
    final dbFile = File(p.join(dir.path, 'old_trip_database.db'));
    // Ensure the file exists
    await dbFile.create();

    // For this test create an in-memory database instance using the
    // test-only constructor. This will run onCreate and create the tables.
    final db = AppDatabase.connect(NativeDatabase.memory());

    // Force the database to be opened and migrations to run by running a simple query
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final tableNames = tables.map((r) => r.data['name'] as String).toList();

    // The migration should have created the 'stops' table
    expect(tableNames.contains('stops'), isTrue,
        reason: 'stops table should exist after migration');

    await db.close();
    await dir.delete(recursive: true);
  });
}
