import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/realtime_positions.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });
  group('Endpoint tests', () {
    test('fetchBusesPositions returns valid FeedMessage or null', () async {
      final feed = await fetchBusesPositions();
      expect(feed, isNotNull, reason: 'Buses: No data or API error');
      final f = feed!;
      // logger.d(
      //     'Buses: ${f.header.gtfsRealtimeVersion}, entities: ${f.entity.length}');
      expect(f.header.hasGtfsRealtimeVersion(), true);
      expect(f.entity.isNotEmpty, true);
    }, skip: 'Requires live API key');

    test('fetchNswTrainsPositions returns valid FeedMessage or null', () async {
      final feed = await fetchNswTrainsPositions();
      expect(feed, isNotNull, reason: 'NSW Trains: No data or API error');
      final f = feed!;
      // logger.d(
      //     'NSW Trains: ${f.header.gtfsRealtimeVersion}, entities: ${f.entity.length}');
      expect(f.header.hasGtfsRealtimeVersion(), true);
      expect(f.entity.isNotEmpty, true);
    }, skip: 'Requires live API key');

    //next three tests might fail because of the time of day

    test('getAllFerries returns list with valid FeedMessage or null', () async {
      final feeds = await getAllFerries();
      expect(feeds.length, 2);
      expect(feeds[0], isNotNull, reason: 'All Ferries: No data or API error');
      final f0 = feeds[0]!;
      // logger.d(
      //     'All Ferries: ${f0.header.gtfsRealtimeVersion}, entities: ${f0.entity.length}');
      expect(f0.entity.isNotEmpty, true);
    }, skip: 'Requires live API key');

    test(
      'getAllLightRail returns list with valid FeedMessage or null',
      () async {
        final feeds = await getAllLightRail();
        expect(feeds.length, 4);
        expect(
          feeds[0],
          isNotNull,
          reason: 'All Light Rail: No data or API error',
        );
        final f0 = feeds[0]!;
        // logger.d(
        //     'All Light Rail: ${f0.header.gtfsRealtimeVersion}, entities: ${f0.entity.length}');
        expect(f0.entity.isNotEmpty, true);
      },
      skip: 'Requires live API key',
    );

    test(
      'getAllRegionBuses returns list with valid FeedMessage or null',
      () async {
        final feeds = await getAllRegionBuses();
        expect(feeds.length, 13);
        expect(
          feeds[0],
          isNotNull,
          reason: 'All Region Buses: No data or API error',
        );
        final f0 = feeds[0]!;
        // logger.d(
        //     'All Region Buses: ${f0.header.gtfsRealtimeVersion}, entities: ${f0.entity.length}');
        expect(f0.entity.isNotEmpty, true);
      },
      skip: 'Requires live API key',
    );

    test(
      'Sydney Metro GTFS-realtime endpoint returns valid FeedMessage',
      () async {
        final feed = await fetchSydneyMetroPositions();
        expect(
          feed,
          isNotNull,
          reason: 'FeedMessage was null (API error or bad response)',
        );
        final f = feed!;
        // logger.d('GTFS version: ${f.header.gtfsRealtimeVersion}');
        // logger.d('Number of entities: ${f.entity.length}');
        // for (var i = 0; i < f.entity.length; i++) {
        //   logger.d('Entity #$i: ${f.entity[i].toString()}');
        // }
        expect(f.header.hasGtfsRealtimeVersion(), true);
        expect(f.entity.isNotEmpty, true);
      },
      skip: 'Requires live API key',
    );

    test(
      'Sydney Trains GTFS-realtime endpoint returns valid FeedMessage',
      () async {
        final feed = await fetchSydneyTrainsPositions();
        expect(
          feed,
          isNotNull,
          reason: 'FeedMessage was null (API error or bad response)',
        );
        final f = feed!;
        // logger.d('GTFS version: ${f.header.gtfsRealtimeVersion}');
        // logger.d('Number of entities: ${f.entity.length}');
        // for (var i = 0; i < f.entity.length; i++) {
        //   logger.d('Entity #$i: ${f.entity[i].toString()}');
        // }
        expect(f.header.hasGtfsRealtimeVersion(), true);
        expect(f.entity.isNotEmpty, true);
      },
      skip: 'Requires live API key',
    );
  });
}
