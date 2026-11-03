import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';

void main() {
  test('upgrades a version 4 database and preserves saved journeys', () async {
    final database = AppDatabase.connect(
      NativeDatabase.memory(
        setup: (connection) {
          connection.execute('''
            CREATE TABLE journeys (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              origin TEXT NOT NULL,
              origin_id TEXT NOT NULL,
              destination TEXT NOT NULL,
              destination_id TEXT NOT NULL,
              is_pinned INTEGER NOT NULL DEFAULT 0
            )
          ''');
          connection.execute('''
            CREATE TABLE stops (
              stop_id TEXT NOT NULL,
              stop_code TEXT,
              tts_stop_name TEXT,
              stop_desc TEXT,
              zone_id TEXT,
              stop_url TEXT,
              stop_timezone TEXT,
              level_id TEXT,
              stop_name TEXT NOT NULL,
              stop_lat REAL,
              stop_lon REAL,
              location_type INTEGER,
              parent_station TEXT,
              wheelchair_boarding INTEGER,
              platform_code TEXT,
              endpoint TEXT NOT NULL,
              PRIMARY KEY (stop_id, endpoint)
            )
          ''');
          connection.execute('''
            INSERT INTO journeys (
              origin, origin_id, destination, destination_id, is_pinned
            ) VALUES ('Central', 'central', 'Redfern', 'redfern', 1)
          ''');
          connection.execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(database.close);

    final journeys = await database.getAllJourneys();
    final tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final tableNames = tables.map((row) => row.data['name']).toSet();

    expect(journeys, hasLength(1));
    expect(journeys.single.origin, 'Central');
    expect(journeys.single.destination, 'Redfern');
    expect(journeys.single.isPinned, isTrue);
    expect(journeys.single.tripType, 'direct');
    expect(journeys.single.mode, isNull);
    expect(
      tableNames,
      containsAll(<String>{
        'journeys',
        'stops',
        'stop_line_memberships',
        'static_cache_statuses',
        'trip_planner_cache',
        'routes',
      }),
    );
  });
}
