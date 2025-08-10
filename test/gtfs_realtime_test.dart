import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/backends/BackendAuthManager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/realtime_positions.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    addBackendAuthToAll(dotenv.env['API_KEY'] ?? '');
  });
  group('Endpoint tests', () {
    test('fetchBusesPositions returns valid FeedMessage or null', () async {
      final feed = await fetchBusesPositions();
      expect(feed, isNotNull, reason: 'Buses: No data or API error');
      print(
          'Buses: ${feed!.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    });

    test('fetchNswTrainsPositions returns valid FeedMessage or null', () async {
      final feed = await fetchNswTrainsPositions();
      expect(feed, isNotNull, reason: 'NSW Trains: No data or API error');
      print(
          'NSW Trains: ${feed!.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    });

    //next three tests might fail because of the time of day

    test('getAllFerries returns list with valid FeedMessage or null', () async {
      final feeds = await getAllFerries();
      expect(feeds.length, 2);
      expect(feeds[0], isNotNull, reason: 'All Ferries: No data or API error');
      print(
          'All Ferries: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.entity.isNotEmpty, true);
    });

    test('getAllLightRail returns list with valid FeedMessage or null',
        () async {
      final feeds = await getAllLightRail();
      expect(feeds.length, 4);
      expect(feeds[0], isNotNull,
          reason: 'All Light Rail: No data or API error');
      print(
          'All Light Rail: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.entity.isNotEmpty, true);
    });

    test('getAllRegionBuses returns list with valid FeedMessage or null',
        () async {
      final feeds = await getAllRegionBuses();
      expect(feeds.length, 13);
      expect(feeds[0], isNotNull,
          reason: 'All Region Buses: No data or API error');
      print(
          'All Region Buses: ${feeds[0]!.header.gtfsRealtimeVersion}, entities: ${feeds[0]!.entity.length}');
      expect(feeds[0]!.entity.isNotEmpty, true);
    });

    test('Sydney Metro GTFS-realtime endpoint returns valid FeedMessage',
        () async {
      final feed = await fetchSydneyMetroPositions();
      expect(feed, isNotNull,
          reason: 'FeedMessage was null (API error or bad response)');
      print('GTFS version: ${feed!.header.gtfsRealtimeVersion}');
      print('Number of entities: ${feed.entity.length}');
      for (var i = 0; i < feed.entity.length; i++) {
        print('Entity #$i: ${feed.entity[i].toString()}');
      }
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    });

    test('Sydney Trains GTFS-realtime endpoint returns valid FeedMessage',
        () async {
      final feed = await fetchSydneyTrainsPositions();
      expect(feed, isNotNull,
          reason: 'FeedMessage was null (API error or bad response)');
      print('GTFS version: ${feed!.header.gtfsRealtimeVersion}');
      print('Number of entities: ${feed.entity.length}');
      for (var i = 0; i < feed.entity.length; i++) {
        print('Entity #$i: ${feed.entity[i].toString()}');
      }
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    });
  });
}
