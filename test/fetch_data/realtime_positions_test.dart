import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/realtime_positions.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  test('fetchSydneyTrainsPositions returns valid FeedMessage or null',
      () async {
    final feed = await fetchSydneyTrainsPositions();
    if (feed == null) {
      print('Sydney Trains: No data or API error');
    } else {
      print(
          'Sydney Trains: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchSydneyMetroPositions returns valid FeedMessage or null', () async {
    final feed = await fetchSydneyMetroPositions();
    if (feed == null) {
      print('Sydney Metro: No data or API error');
    } else {
      print(
          'Sydney Metro: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchBusesPositions returns valid FeedMessage or null', () async {
    final feed = await fetchBusesPositions();
    if (feed == null) {
      print('Buses: No data or API error');
    } else {
      print(
          'Buses: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchNswTrainsPositions returns valid FeedMessage or null', () async {
    final feed = await fetchNswTrainsPositions();
    if (feed == null) {
      print('NSW Trains: No data or API error');
    } else {
      print(
          'NSW Trains: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchRegionBusesPositions returns valid FeedMessage or null', () async {
    final feed = await fetchRegionBusesPositions();
    if (feed == null) {
      print('Region Buses: No data or API error');
    } else {
      print(
          'Region Buses: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('getAllFerries returns list with valid FeedMessage or null', () async {
    final feeds = await getAllFerries();
    expect(feeds.length, 1);
    if (feeds[0] == null) {
      print('All Ferries: No data or API error');
    } else {
      print(
          'All Ferries: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.header.hasGtfsRealtimeVersion(), true);
      expect(feeds[0]!.entity.isNotEmpty, true);
    }
  });

  test('getAllLightRail returns list with valid FeedMessage or null', () async {
    final feeds = await getAllLightRail();
    expect(feeds.length, 1);
    if (feeds[0] == null) {
      print('All Light Rail: No data or API error');
    } else {
      print(
          'All Light Rail: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.header.hasGtfsRealtimeVersion(), true);
      expect(feeds[0]!.entity.isNotEmpty, true);
    }
  });

  test('getAllRegionBuses returns list with valid FeedMessage or null',
      () async {
    final feeds = await getAllRegionBuses();
    expect(feeds.length, 1);
    if (feeds[0] == null) {
      print('All Region Buses: No data or API error');
    } else {
      print(
          'All Region Buses: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.header.hasGtfsRealtimeVersion(), true);
      expect(feeds[0]!.entity.isNotEmpty, true);
    }
  });
}
