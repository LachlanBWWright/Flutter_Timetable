import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';

void main() {
  // Helper to print first N stops and a frequency map of locationType values
  void logStopsSummary(GtfsData data, String name, int showCount) {
    final stops = data.stops;
    print(
        '\n--- $name feed: ${stops.length} stops (showing up to $showCount) ---');
    final count = stops.length < showCount ? stops.length : showCount;
    for (var i = 0; i < count; i++) {
      final s = stops[i];
      print(
          '$name Stop ${i + 1}: id=${s.stopId}, name=${s.stopName}, locationType=${s.locationType}, parentStation=${s.parentStation}');
    }

    // Frequency map of locationType
    final freq = <int, int>{};
    for (final s in stops) {
      freq[s.locationType] = (freq[s.locationType] ?? 0) + 1;
    }
    if (freq.isEmpty) {
      print('LocationType counts for $name: (none)');
    } else {
      final summary = freq.entries.map((e) => '${e.key}:${e.value}').join(', ');
      print('LocationType counts for $name: $summary');
    }
  }

  // NOTE: removed fetch-with-timeout helper per request; tests call fetchers directly.

  setUpAll(() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey.toLowerCase() == 'your_api_key_here' ||
        apiKey.toLowerCase() == 'your_api_key') {
      fail(
          'API_KEY not set in .env. Please create a .env file in the project root with a valid NSW Transport API key, e.g.:\n\nAPI_KEY=your_real_api_key_here');
    }
  });

  test('fetchBusesGtfsData returns a GtfsData object', () async {
    final data = await fetchBusesGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.stops, isA<List>());
    expect(data.stops.length, greaterThanOrEqualTo(5),
        reason: 'Expected at least 5 stops for buses feed');
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'buses', 10);
    } else {
      print('\n--- buses feed returned 0 stops ---');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('fetchFerriesSydneyFerriesGtfsData returns a GtfsData object', () async {
    final data = await fetchFerriesSydneyFerriesGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.routes, isA<List>());
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'ferries', 10);
    } else {
      print('\n--- ferries feed returned 0 stops ---');
    }
  });

  test('fetchMetroGtfsData returns a GtfsData object and logs stops', () async {
    final data = await fetchMetroGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.stops, isA<List>());
    expect(data.stops.length, greaterThanOrEqualTo(5),
        reason: 'Expected at least 5 stops for metro feed');
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'metro', 50);
    } else {
      print('No stops returned for Metro feed');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('fetchLightRailInnerWestGtfsData returns a GtfsData object', () async {
    final data = await fetchLightRailInnerWestGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.trips, isA<List>());
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'lightrail', 10);
    } else {
      print('\n--- lightrail feed returned 0 stops ---');
    }
  });

/*   test('fetchNswTrainsGtfsData returns a GtfsData object', () async {
    final data = await fetchNswTrainsGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.agencies, isA<List>());
    // Require at least 5 stops for this feed to be considered valid
    expect(data.stops.length, greaterThanOrEqualTo(5),
        reason: 'Expected at least 5 stops for nswtrains feed');
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'nswtrains', 10);
    } else {
      print('\n--- nswtrains feed returned 0 stops ---');
    }
  }, timeout: const Timeout(Duration(minutes: 2))); */

  test('fetchSydneyTrainsGtfsData returns a GtfsData object and logs a station',
      () async {
    final data = await fetchSydneyTrainsGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.stops, isA<List>());
    expect(data.stops.length, greaterThanOrEqualTo(5),
        reason: 'Expected at least 5 stops for sydneytrains feed');
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'sydneytrains', 100);
    } else {
      print('No stops returned for SydneyTrains feed');
    }
  });

  test('fetchMetroGtfsData returns a GtfsData object (v2 endpoint)', () async {
    // Metro is exposed under the v2 schedule surface — use the v2 fetcher
    final data = await fetchMetroGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.stops, isA<List>());
    if (data.stops.isNotEmpty) {
      logStopsSummary(data, 'metro', 100);
    } else {
      print('No stops returned for Metro feed');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
