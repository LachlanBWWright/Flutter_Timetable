import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/wrappers/new_trip_service/endpoint_stop_cache.dart';

final _now = DateTime.utc(2026, 10, 13, 10);
const _first = StopsEndpoint.ferriesSydneyFerries;
const _second = StopsEndpoint.ferriesMff;

Stop _stop(String id) => Stop(
  stopId: id,
  stopName: id,
  stopLat: -33.8,
  stopLon: 151.2,
  locationType: 0,
  wheelchairBoarding: 0,
);

EndpointStopCacheSnapshot _snapshot(
  String id, {
  DateTime? updatedAt,
  bool complete = true,
}) => EndpointStopCacheSnapshot(
  stops: [_stop(id)],
  stopsUpdatedAt: updatedAt ?? _now,
  lineMembershipsUpdatedAt: complete ? updatedAt ?? _now : null,
  membershipCount: complete ? 1 : 0,
);

EndpointStopCacheSnapshot _empty() => const EndpointStopCacheSnapshot(
  stops: [],
  stopsUpdatedAt: null,
  lineMembershipsUpdatedAt: null,
  membershipCount: 0,
);

void main() {
  test('cached feed stays usable while missing feed refreshes', () async {
    final snapshots = {_first: _snapshot('cached'), _second: _empty()};
    final refreshed = <StopsEndpoint>[];
    final started = Completer<void>();
    final release = Completer<void>();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (endpoint) async => snapshots[endpoint]!,
      refreshEndpoint: (endpoint) async {
        refreshed.add(endpoint);
        started.complete();
        await release.future;
        snapshots[endpoint] = _snapshot('downloaded');
      },
    );

    final cached = await loader.load([_first, _second]);
    expect(cached.map((stop) => stop.stopId), ['cached']);
    await started.future;
    expect(refreshed, [_second]);
    release.complete();
    await Future<void>.delayed(Duration.zero);
    final complete = await loader.load([_first, _second]);
    expect(complete.map((stop) => stop.stopId), ['cached', 'downloaded']);
    expect(refreshed, [_second]);
  });

  test('empty cache waits for downloads before returning', () async {
    var snapshot = _empty();
    final started = Completer<void>();
    final release = Completer<void>();
    var returned = false;
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (_) async => snapshot,
      refreshEndpoint: (_) async {
        started.complete();
        await release.future;
        snapshot = _snapshot('new');
      },
    );

    final loading = loader.load([_first]).then((stops) {
      returned = true;
      return stops;
    });
    await started.future;
    expect(returned, isFalse);
    release.complete();
    expect((await loading).single.stopId, 'new');
  });

  test('stale feed returns immediately and refreshes in background', () async {
    var snapshot = _snapshot(
      'old',
      updatedAt: _now.subtract(const Duration(days: 2)),
    );
    final started = Completer<void>();
    final release = Completer<void>();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (_) async => snapshot,
      refreshEndpoint: (_) async {
        started.complete();
        await release.future;
        snapshot = _snapshot('current');
      },
    );

    expect((await loader.load([_first])).single.stopId, 'old');
    await started.future;
    release.complete();
    await Future<void>.delayed(Duration.zero);
    expect((await loader.load([_first])).single.stopId, 'current');
  });

  test('failed missing feed refresh preserves existing stops', () async {
    final attempted = Completer<void>();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (endpoint) async =>
          endpoint == _first ? _snapshot('usable') : _empty(),
      refreshEndpoint: (_) async {
        attempted.complete();
        throw StateError('offline');
      },
    );

    expect((await loader.load([_first, _second])).single.stopId, 'usable');
    await attempted.future;
    await Future<void>.delayed(Duration.zero);
  });

  test('complete fresh feeds skip downloads', () async {
    final downloaded = <StopsEndpoint>[];
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (endpoint) async => _snapshot(endpoint.key),
      refreshEndpoint: (endpoint) async => downloaded.add(endpoint),
    );

    expect(await loader.load([_first, _second]), hasLength(2));
    await Future<void>.delayed(Duration.zero);
    expect(downloaded, isEmpty);
  });

  test('fresh stops with missing memberships still refresh', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (_) async => _snapshot('usable', complete: false),
      refreshEndpoint: (_) async {
        started.complete();
        await release.future;
      },
    );

    expect((await loader.load([_first])).single.stopId, 'usable');
    await started.future;
    release.complete();
    await Future<void>.delayed(Duration.zero);
  });

  test('overlapping loads share each active endpoint refresh', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    var refreshes = 0;
    var snapshot = _empty();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (_) async => snapshot,
      refreshEndpoint: (_) async {
        refreshes++;
        started.complete();
        await release.future;
        snapshot = _snapshot('loaded');
      },
    );

    final first = loader.load([_first]);
    await started.future;
    final second = loader.load([_first]);
    await Future<void>.delayed(Duration.zero);
    expect(refreshes, 1);
    release.complete();
    expect((await first).single.stopId, 'loaded');
    expect((await second).single.stopId, 'loaded');
    expect(refreshes, 1);
  });

  test('failed first download returns empty without throwing', () async {
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (_) async => _empty(),
      refreshEndpoint: (_) async => throw StateError('offline'),
    );

    expect(await loader.load([_first, _second]), isEmpty);
  });

  test(
    'duplicate endpoint selection does not repeat stops or refresh',
    () async {
      final downloaded = <StopsEndpoint>[];
      final loader = EndpointStopCacheLoader(
        now: () => _now,
        readEndpoint: (_) async => _snapshot('one-stop'),
        refreshEndpoint: (endpoint) async => downloaded.add(endpoint),
      );

      expect((await loader.load([_first, _first])).single.stopId, 'one-stop');
      expect(downloaded, isEmpty);
    },
  );

  test('queued feed skips refresh when another updater publishes it', () async {
    final old = _now.subtract(const Duration(days: 2));
    final snapshots = {
      _first: _snapshot('first-old', updatedAt: old),
      _second: _snapshot('second-old', updatedAt: old),
    };
    final started = Completer<void>();
    final release = Completer<void>();
    final downloaded = <StopsEndpoint>[];
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (endpoint) async => snapshots[endpoint]!,
      refreshEndpoint: (endpoint) async {
        downloaded.add(endpoint);
        started.complete();
        await release.future;
        snapshots[endpoint] = _snapshot('first-new');
      },
    );

    expect(await loader.load([_first, _second]), hasLength(2));
    await started.future;
    expect(downloaded, [_first]);
    snapshots[_second] = _snapshot('published-elsewhere');
    release.complete();
    await Future<void>.delayed(Duration.zero);
    expect(downloaded, [_first]);
    expect((await loader.load([_first, _second])).map((stop) => stop.stopId), [
      'first-new',
      'published-elsewhere',
    ]);
  });

  test('one endpoint read failure retains another endpoint cache', () async {
    final errors = <StopsEndpoint>[];
    final refreshed = Completer<void>();
    final loader = EndpointStopCacheLoader(
      now: () => _now,
      readEndpoint: (endpoint) async {
        if (endpoint == _second) throw StateError('database unavailable');
        return _snapshot('available');
      },
      refreshEndpoint: (_) async => refreshed.complete(),
      onError: (endpoint, _) => errors.add(endpoint),
    );

    expect((await loader.load([_first, _second])).single.stopId, 'available');
    await refreshed.future;
    expect(errors, everyElement(_second));
    expect(errors, isNotEmpty);
  });

  test(
    'failed refresh can retry and does not block queued endpoints',
    () async {
      final snapshots = {_first: _empty(), _second: _empty()};
      final attempts = <StopsEndpoint, int>{};
      final loader = EndpointStopCacheLoader(
        now: () => _now,
        readEndpoint: (endpoint) async => snapshots[endpoint]!,
        refreshEndpoint: (endpoint) async {
          final count = attempts.update(
            endpoint,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          if (endpoint == _first && count == 1) throw StateError('offline');
          snapshots[endpoint] = _snapshot(endpoint.key);
        },
      );

      expect((await loader.load([_first, _second])).single.stopId, _second.key);
      expect((await loader.load([_first])).single.stopId, _first.key);
      expect(attempts, {_first: 2, _second: 1});
    },
  );

  test(
    'throwing error observer cannot poison background refresh queue',
    () async {
      final snapshots = {_first: _empty(), _second: _empty()};
      var firstRead = true;
      final loader = EndpointStopCacheLoader(
        now: () => _now,
        readEndpoint: (endpoint) async {
          if (firstRead) {
            firstRead = false;
            throw StateError('temporary read failure');
          }
          return snapshots[endpoint]!;
        },
        refreshEndpoint: (endpoint) async {
          if (endpoint == _first) throw StateError('offline');
          snapshots[endpoint] = _snapshot('downloaded');
        },
        onError: (_, _) => throw StateError('observer failure'),
      );

      expect(
        (await loader.load([_first, _second])).single.stopId,
        'downloaded',
      );
      expect(
        (await loader.load([_first, _second])).single.stopId,
        'downloaded',
      );
    },
  );

  test('freshness requires both endpoint import components', () {
    expect(_snapshot('fresh').isFresh(_now), isTrue);
    expect(_snapshot('incomplete', complete: false).isFresh(_now), isFalse);
    expect(_empty().isFresh(_now), isFalse);
    expect(
      _snapshot(
        'expired',
        updatedAt: _now.subtract(const Duration(hours: 24)),
      ).isFresh(_now),
      isFalse,
    );
    expect(
      EndpointStopCacheSnapshot(
        stops: [_stop('stale-memberships')],
        stopsUpdatedAt: _now,
        lineMembershipsUpdatedAt: _now.subtract(const Duration(days: 2)),
        membershipCount: 1,
      ).isFresh(_now),
      isFalse,
    );
  });
}
