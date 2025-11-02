import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';

void main() {
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
  });

  test('fetchFerriesSydneyFerriesGtfsData returns a GtfsData object', () async {
    final data = await fetchFerriesSydneyFerriesGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.routes, isA<List>());
  });

  test('fetchLightRailInnerWestGtfsData returns a GtfsData object', () async {
    final data = await fetchLightRailInnerWestGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.trips, isA<List>());
  });

  test('fetchNswTrainsGtfsData returns a GtfsData object', () async {
    final data = await fetchNswTrainsGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.agencies, isA<List>());
  });

  test('fetchSydneyTrainsGtfsData returns a GtfsData object and logs a station',
      () async {
    final data = await fetchSydneyTrainsGtfsData();
    expect(data, isNotNull);
    expect(data, isA<GtfsData>());
    expect(data!.stops, isA<List>());
    if (data.stops.isNotEmpty) {
      // Print the parentStation for up to the first 100 stops so it's visible in test output / logs
      final count = data.stops.length < 100 ? data.stops.length : 100;
      for (var i = 0; i < count; i++) {
        final parent = data.stops[i].parentStation;
        print('Stop ${i + 1} ${data.stops[i]}');
      }
    } else {
      print('No stops returned for SydneyTrains feed');
    }
  });
}
