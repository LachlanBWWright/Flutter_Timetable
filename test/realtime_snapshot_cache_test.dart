import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/wrappers/realtime_service/snapshot_cache.dart';

void main() {
  test(
    'failed refresh preserves source values and their original timestamps',
    () async {
      var now = DateTime.utc(2026, 1, 1);
      final cache = RealtimeSnapshotCache<String>(clock: () => now);
      await cache.load('feed', () async => ['first', 'second']);
      final firstAt = now;
      now = now.add(const Duration(seconds: 31));
      final partial = await cache.load('feed', () async => ['new', null]);
      expect(partial.map((s) => s.value), ['new', 'second']);
      expect(partial[0].fetchedAt, now);
      expect(partial[1].fetchedAt, firstAt);
      expect(partial[1].isStale, isTrue);
      cache.invalidate();
      final failed = await cache.load(
        'feed',
        () async => throw StateError('offline'),
      );
      expect(failed.map((s) => s.value), ['new', 'second']);
      expect(failed.every((s) => s.isStale), isTrue);
    },
  );

  test('missing trailing slots preserve previous successful shards', () async {
    final cache = RealtimeSnapshotCache<String>();
    await cache.load('feed', () async => ['first', 'second']);
    cache.invalidate();
    final shortened = await cache.load('feed', () async => ['new']);
    expect(shortened.map((source) => source.value), ['new', 'second']);
    expect(shortened.last.isStale, isTrue);
  });

  test(
    'empty payload is successful but no returned sources is unavailable',
    () async {
      final cache = RealtimeSnapshotCache<List<String>>();
      final empty = await cache.load('feed', () async => [<String>[]]);
      expect(empty.single.failed, isFalse);
      expect(empty.single.fetchedAt, isNotNull);
      cache.invalidate();
      final missing = await cache.load('feed', () async => []);
      expect(missing.single.isStale, isTrue);
      expect(missing.single.value, isEmpty);
    },
  );

  test(
    'invalidation retains fallback and simultaneous retries share loader',
    () async {
      final cache = RealtimeSnapshotCache<String>();
      await cache.load('feed', () async => ['old']);
      cache.invalidate();
      final completer = Completer<List<String?>>();
      var requests = 0;
      Future<List<String?>> loader() {
        requests++;
        return completer.future;
      }

      final first = cache.load('feed', loader);
      final second = cache.load('feed', loader);
      expect(cache.sources('feed').single.value, 'old');
      expect(requests, 1);
      completer.complete([null]);
      expect((await first).single.value, 'old');
      expect((await second).single.isStale, isTrue);
    },
  );

  test(
    'success uses TTL while retry invalidation bypasses failure backoff',
    () async {
      var now = DateTime.utc(2026, 1, 1);
      final cache = RealtimeSnapshotCache<String>(clock: () => now);
      var calls = 0;
      Future<List<String?>> success() async {
        calls++;
        return ['ok'];
      }

      await cache.load('feed', success);
      await cache.load('feed', success);
      expect(calls, 1);
      now = now.add(const Duration(seconds: 30));
      await cache.load('feed', success);
      expect(calls, 2);
      final unavailable = await cache.load('missing', () async => [null]);
      expect(unavailable.single.fetchedAt, isNull);
      expect(unavailable.single.failed, isTrue);
      cache.invalidate();
      final recovered = await cache.load('missing', success);
      expect(recovered.single.failed, isFalse);
    },
  );

  for (final oldCompletesFirst in [false, true]) {
    test('invalidation isolates old completion from the new request '
        '(old completes first: $oldCompletesFirst)', () async {
      final cache = RealtimeSnapshotCache<String>();
      await cache.load('feed', () async => ['seed']);
      cache.invalidate();
      final old = Completer<List<String?>>();
      final current = Completer<List<String?>>();
      final staleRequest = cache.load('feed', () => old.future);
      cache.invalidate();
      var currentRequests = 0;
      Future<List<String?>> loader() {
        currentRequests++;
        return current.future;
      }

      final freshRequest = cache.load('feed', loader);
      expect(currentRequests, 1);
      expect(cache.sources('feed').single.value, 'seed');
      if (oldCompletesFirst) {
        old.complete(['obsolete']);
        await staleRequest;
        expect(cache.sources('feed').single.value, 'seed');
      }
      final sharedRequest = cache.load('feed', loader);
      expect(currentRequests, 1);
      current.complete(['fresh']);
      expect((await freshRequest).single.value, 'fresh');
      expect((await sharedRequest).single.value, 'fresh');
      if (!oldCompletesFirst) {
        // A late failure must not mark the fresh snapshot stale or replace it.
        old.complete([null]);
        await staleRequest;
      }
      expect(cache.sources('feed').single.value, 'fresh');
      expect(cache.sources('feed').single.failed, isFalse);
      await cache.load('feed', loader);
      expect(currentRequests, 1);
    });
  }
}
