import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lbww_flutter/fetch_data/realtime_positions.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart'
    show FeedMessage;

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  test('fetchSydneyTrainsPositions returns valid FeedMessage or null',
      () async {
    final feed = await fetchSydneyTrainsPositions();
    if (feed == null) {
      logger.d('Sydney Trains: No data or API error');
    } else {
      logger.d(
          'Sydney Trains: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchSydneyMetroPositions returns valid FeedMessage or null', () async {
    final feed = await fetchSydneyMetroPositions();
    if (feed == null) {
      logger.d('Sydney Metro: No data or API error');
    } else {
      logger.d(
          'Sydney Metro: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchBusesPositions returns valid FeedMessage or null', () async {
    final feed = await fetchBusesPositions();
    if (feed == null) {
      logger.d('Buses: No data or API error');
    } else {
      logger.d(
          'Buses: ${feed.header.gtfsRealtimeVersion}, entities: ${feed.entity.length}');
      expect(feed.header.hasGtfsRealtimeVersion(), true);
      expect(feed.entity.isNotEmpty, true);
    }
  });

  test('fetchNswTrainsPositions returns valid FeedMessage or null', () async {
    final feed = await fetchNswTrainsPositions();
    if (feed == null) {
      logger.d('NSW Trains: No data or API error');
    } else {
      logger.d(
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
        logger.d('Region Buses: No data or API error');
      } else {
        logger.d(
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
        logger.d('All Ferries: No data or API error');
      } else {
        logger.d(
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
        logger.d('All Light Rail: No data or API error');
      } else {
        logger.d(
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
        logger.d('All Region Buses: No data or API error');
      } else {
        logger.d(
            'All Region Buses: \\${feed.header.gtfsRealtimeVersion}, entities: \\${feed.entity.length}');
        expect(feed.header.hasGtfsRealtimeVersion(), true);
        expect(feed.entity.isNotEmpty, true);
      }
    }
  });
}
