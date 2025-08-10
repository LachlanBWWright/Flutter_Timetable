import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/backends/BackendAuthManager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/realtime_updates.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    addBackendAuthToAll(dotenv.env['API_KEY'] ?? '');
  });

  group('Endpoint tests', () {
    test('fetchBusesUpdates returns a FeedMessage on success', () async {
      final feed = await fetchBusesUpdates();
      expect(feed, isNotNull,
          reason:
              'FeedMessage should not be null if API key and endpoint are valid');
      expect(feed, isA<FeedMessage>());
    });

    test('fetchAllFerries returns a list of FeedMessages', () async {
      final feeds = await fetchAllFerries();
      expect(feeds, isA<List<FeedMessage?>>());
      expect(feeds.length, 2);
      for (final feed in feeds) {
        expect(feed, anyOf([isNull, isA<FeedMessage>()]));
      }
    });

    test('fetchAllLightRail returns a list of FeedMessages', () async {
      final feeds = await fetchAllLightRail();
      expect(feeds, isA<List<FeedMessage?>>());
      expect(feeds.length, 4);
      for (final feed in feeds) {
        expect(feed, anyOf([isNull, isA<FeedMessage>()]));
      }
    });

    test('fetchAllRegionBuses returns a list of FeedMessages', () async {
      final feeds = await fetchAllRegionBuses();
      expect(feeds, isA<List<FeedMessage?>>());
      expect(feeds.length, 13);
      for (final feed in feeds) {
        expect(feed, anyOf([isNull, isA<FeedMessage>()]));
      }
    });

    test('fetchSydneyTrainsUpdates returns a FeedMessage on success', () async {
      final feed = await fetchSydneyTrainsUpdates();
      expect(feed, anyOf([isNull, isA<FeedMessage>()]));
    });

    test('fetchSydneyMetroUpdates returns a FeedMessage on success', () async {
      final feed = await fetchSydneyMetroUpdates();
      expect(feed, anyOf([isNull, isA<FeedMessage>()]));
    });
  });
}
