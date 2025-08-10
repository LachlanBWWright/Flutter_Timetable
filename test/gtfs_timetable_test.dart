import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/backends/BackendAuthManager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    addBackendAuthToAll(dotenv.env['API_KEY'] ?? '');
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
}
