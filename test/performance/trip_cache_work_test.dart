import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:option_result/option_result.dart';

import '../../integration_test/support/performance_fixtures.dart';

void main() {
  test(
    '100 simultaneous callers share one fetch and persistence write',
    () async {
      final pending = Completer<Result<GetTripsResponse, String>>();
      var reads = 0;
      var fetches = 0;
      var writes = 0;
      final repository = TripCacheRepository(
        readCache: (_, _) async {
          reads++;
          return null;
        },
        fetchTrips: (_, _) {
          fetches++;
          return pending.future;
        },
        writeCache: (_, _, _) async => writes++,
      );
      final requests = List.generate(
        100,
        (_) => repository.getSnapshotOrFetch(
          originId: 'central',
          destinationId: 'town-hall',
        ),
      );
      // Keep transport blocked until every caller has joined the request.
      await Future<void>.delayed(Duration.zero);
      expect(reads, 1);
      expect(fetches, 1);
      expect(writes, 0);
      pending.complete(Ok(journeyResponse(DateTime.now())));
      final results = await Future.wait(requests);
      expect(
        results,
        everyElement(predicate<TripCacheSnapshot>((s) => s.isFresh)),
      );
      expect(writes, 1);
    },
  );

  test(
    '1000 warm cache reads perform no extra transport or disk work',
    () async {
      final cache = PerformanceCache();
      await cache.repository.getSnapshotOrFetch(
        originId: 'central',
        destinationId: 'town-hall',
      );
      for (var index = 0; index < 1000; index++) {
        final snapshot = await cache.repository.getSnapshotOrFetch(
          originId: 'central',
          destinationId: 'town-hall',
        );
        expect(snapshot.isFresh, isTrue);
        expect(
          cache.repository.peekSnapshot('central', 'town-hall')?.response,
          isNotNull,
        );
      }
      expect(cache.fetches, 1);
      expect(cache.reads, 1);
      expect(cache.writes, 1);
    },
  );

  test('loading 100 route pairs retains only 50 responses in memory', () async {
    final cache = PerformanceCache();
    for (var index = 0; index < 100; index++) {
      await cache.repository.getSnapshotOrFetch(
        originId: 'origin-$index',
        destinationId: 'destination',
      );
    }
    final retained = [
      for (var index = 0; index < 100; index++)
        if (cache.repository.peekSnapshot('origin-$index', 'destination') !=
            null)
          index,
    ];
    expect(retained, List.generate(50, (index) => index + 50));
    expect(cache.fetches, 100);
    expect(cache.writes, 100);
  });

  test(
    '100 invalidations publish one notification per synchronous burst',
    () async {
      final cache = PerformanceCache();
      var notifications = 0;
      void onChange() => notifications++;
      cache.repository.changes.addListener(onChange);
      addTearDown(() => cache.repository.changes.removeListener(onChange));
      for (var index = 0; index < 100; index++) {
        cache.repository.invalidate('origin-$index', 'destination');
      }
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
      // A later change must still reach consumers after the burst has flushed.
      cache.repository.invalidate('another-origin', 'destination');
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 2);
    },
  );
}
