import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      fail(
          'API_KEY not set in .env — integration tests require a valid API key.');
    }
  });

  // Test-local helper to log stop details for manual review.
  void logStop(Stop stop) {
    print('Reviewing stop: id=${stop.stopId}, name=${stop.stopName}, '
        'lat=${stop.stopLat}, lon=${stop.stopLon}, '
        'parent=${stop.parentStation}, platform=${stop.platformCode}');
  }

  group('Fetch modes integration', () {
    test('metro fetch returns stops', () async {
      final data = await fetchMetroGtfsData();
      expect(data, isNotNull);
      expect(data!.stops, isNotEmpty);
      // log a sample stop for review (test-local helper)
      void logStop(Stop stop) {
        print('Reviewing stop: id=${stop.stopId}, name=${stop.stopName}, '
            'lat=${stop.stopLat}, lon=${stop.stopLon}, '
            'parent=${stop.parentStation}, platform=${stop.platformCode}');
      }

      logStop(data.stops.first);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('trains fetch returns stops/agencies', () async {
      final data = await fetchNswTrainsGtfsData();
      expect(data, isNotNull);
      expect((data!.stops.isNotEmpty || data.agencies.isNotEmpty), isTrue);
      if (data.stops.isNotEmpty) logStop(data.stops.first);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('buses fetch returns stops', () async {
      final data = await fetchBusesGtfsData();
      expect(data, isNotNull);
      expect(data!.stops, isNotEmpty);
      logStop(data.stops.first);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('lightrail fetch returns stops', () async {
      final data = await fetchLightRailCbdAndSoutheastGtfsData();
      expect(data, isNotNull);
      expect(data!.stops, isNotEmpty);
      logStop(data.stops.first);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('ferries fetch returns stops', () async {
      final data = await fetchFerriesSydneyFerriesGtfsData();
      expect(data, isNotNull);
      expect(data!.stops, isNotEmpty);
      logStop(data.stops.first);
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
