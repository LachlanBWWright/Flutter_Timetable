import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/backends/BackendAuthManager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lbww_flutter/fetch_data/realtime_positions.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart'
    show FeedMessage;

void main() {
  setUpAll(() async {
    await dotenv.load();
    addBackendAuthToAll(dotenv.env['API_KEY'] ?? '');
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
    final feeds = await fetchRegionBusesPositions();
    expect(feeds.isNotEmpty, true);
    for (final feed in feeds) {
      if (feed == null) {
        print('Region Buses: No data or API error');
      } else {
        print(
            'Region Buses: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
        expect(feed.header.hasGtfsRealtimeVersion(), true);
        expect(feed.entity.isNotEmpty, true);
      }
    }
  });

  test('getAllFerries returns list with valid FeedMessage or null', () async {
    final feeds = await getAllFerries();
    expect(feeds.isNotEmpty, true);
    for (final feed in feeds) {
      if (feed == null) {
        print('All Ferries: No data or API error');
      } else {
        print(
            'All Ferries: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
        expect(feed.header.hasGtfsRealtimeVersion(), true);
        expect(feed.entity.isNotEmpty, true);
      }
    }
  });

  test('getAllLightRail returns list with valid FeedMessage or null', () async {
    final feeds = await getAllLightRail();
    expect(feeds.isNotEmpty, true);
    for (final feed in feeds) {
      if (feed == null) {
        print('All Light Rail: No data or API error');
      } else {
        print(
            'All Light Rail: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
        expect(feed.header.hasGtfsRealtimeVersion(), true);
        expect(feed.entity.isNotEmpty, true);
      }
    }
  });

  test('getAllRegionBuses returns list with valid FeedMessage or null',
      () async {
    final regionBusesFeeds = await getAllRegionBuses();
    expect(regionBusesFeeds.isNotEmpty, true);
    // Flatten if any element is a list
    final flatFeeds = regionBusesFeeds
        .expand((e) => e is List ? e as List<FeedMessage?> : [e])
        .cast<FeedMessage?>();
    for (final feed in flatFeeds) {
      if (feed == null) {
        print('All Region Buses: No data or API error');
      } else {
        print(
            'All Region Buses: \\${feed.header.gtfsRealtimeVersion}, entities: \\${feed.entity.length}');
        expect(feed.header.hasGtfsRealtimeVersion(), true);
        expect(feed.entity.isNotEmpty, true);
      }
    }
  });
}
