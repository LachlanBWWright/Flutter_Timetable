// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
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

  group('Fetch modes integration', () {
    test('metro fetch returns stops', () async {
      final data = await fetchMetroGtfsData();
      expect(data, isNotNull);
      expect(data?.stops, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test(
      'trains fetch returns stops/agencies',
      () async {
        final data = await fetchNswTrainsGtfsData();
        expect(data, isNotNull);
        expect(
          ((data?.stops.isNotEmpty ?? false) ||
              (data?.agencies.isNotEmpty ?? false)),
          isTrue,
        );
        // if (data.stops.isNotEmpty) logStop(data.stops.first);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test('buses fetch returns stops', () async {
      final data = await fetchBusesGtfsData();
      expect(data, isNotNull);
      expect(data?.stops, isNotEmpty);
      // logStop(data.stops.first);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test(
      'lightrail fetch returns stops',
      () async {
        final data = await fetchLightRailCbdAndSoutheastGtfsData();
        expect(data, isNotNull);
        expect(data?.stops, isNotEmpty);
        // logStop(data.stops.first);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test('ferries fetch returns stops', () async {
      final data = await fetchFerriesSydneyFerriesGtfsData();
      expect(data, isNotNull);
      expect(data?.stops, isNotEmpty);
      // logStop(data.stops.first);
    }, timeout: const Timeout(Duration(seconds: 60)));
  }, skip: 'Requires live API key');
}
