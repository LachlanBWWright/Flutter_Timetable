// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      fail(
        'API_KEY not set in .env — integration tests require a valid API key.',
      );
    }
  });

  test(
    'fetchBusesGtfsData calls live API and parses GTFS',
    () async {
      final GtfsData? data = await fetchBusesGtfsData();
      expect(data, isNotNull);
      // The feed should contain at least stops or routes
      expect(
        ((data?.stops.isNotEmpty ?? false) ||
            (data?.routes.isNotEmpty ?? false)),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
    skip: 'Requires live API key',
  );
}
