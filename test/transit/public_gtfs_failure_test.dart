import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

const _config = PublicGtfsProviderConfig(
  region: TransitRegion.queensland,
  provider: TransitProviderId.translink,
  attributionName: 'Test',
  attributionUrl: 'https://example.com',
  feeds: [
    PublicGtfsFeedConfig(
      sourceId: plannerSource,
      label: 'Test feed',
      url: 'https://example.com/feed.zip',
    ),
  ],
);

void main() {
  test('unknown source fails before fetching', () async {
    var fetched = false;
    final repository = PublicGtfsDepartureRepository(
      config: _config,
      fetcher: (_) async {
        fetched = true;
        return http.Response('', 200);
      },
    );
    await expectLater(
      repository.loadFeed(const TransitSourceId('unknown')),
      throwsA(isA<InvalidJourneyRequest>()),
    );
    expect(fetched, isFalse);
  });

  test('HTTP failure is a provider failure, not an empty feed', () async {
    final repository = PublicGtfsDepartureRepository(
      config: _config,
      fetcher: (_) async => http.Response('Unavailable', 503),
    );
    await expectLater(
      repository.loadFeed(plannerSource),
      throwsA(isA<ProviderUnavailable>()),
    );
  });

  test('corrupt successful response is an invalid feed', () async {
    final repository = PublicGtfsDepartureRepository(
      config: _config,
      fetcher: (_) async => http.Response('not a zip', 200),
    );
    await expectLater(
      repository.loadFeed(plannerSource),
      throwsA(isA<InvalidProviderResponse>()),
    );
  });

  test('typed download failures propagate unchanged', () async {
    const failure = NetworkUnavailable(message: 'Offline');
    final repository = PublicGtfsDepartureRepository(
      config: _config,
      fetcher: (_) async => throw failure,
    );
    await expectLater(
      repository.loadFeed(plannerSource),
      throwsA(same(failure)),
    );
  });

  test(
    'failed downloads are retried instead of cached as empty feeds',
    () async {
      var calls = 0;
      final repository = PublicGtfsDepartureRepository(
        config: _config,
        fetcher: (_) async {
          calls++;
          return http.Response('Unavailable', 503);
        },
      );
      for (var attempt = 0; attempt < 2; attempt++) {
        await expectLater(
          repository.loadFeed(plannerSource),
          throwsA(isA<ProviderUnavailable>()),
        );
      }
      expect(calls, 2);
    },
  );
}
