import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/transit/cache/realtime_query.dart';
import 'package:lbww_flutter/transit/cache/shared_transit_cache.dart';
import 'package:lbww_flutter/wrappers/app_http_client_impl.dart';

void main() {
  final provider = Uri.parse(
    'https://api.transport.nsw.gov.au/v1/tp/stop_finder?outputFormat=rapidJSON',
  );
  final endpoint = Uri.parse('https://cache.example/transitCache');
  final initial = DateTime.utc(2026, 10, 28);
  http.Response cached(DateTime fetched, {String body = '{"locations":[]}'}) =>
      http.Response(
        body,
        200,
        headers: {
          'content-type': 'application/json',
          'x-transit-version': '1',
          'x-transit-fetched-at': fetched.toIso8601String(),
          'x-transit-expires-at': fetched
              .add(const Duration(seconds: 30))
              .toIso8601String(),
        },
      );

  test('unconfigured app performs only its normal provider request', () async {
    final seen = <Uri>[];
    final client = MockClient((r) async {
      seen.add(r.url);
      return http.Response('normal', 200);
    });
    final result = await AppHttpClient.get(
      provider,
      client: client,
      sharedCache: SharedTransitCache(endpoint: null),
    );
    expect(result!.body, 'normal');
    expect(seen, [provider]);
  });

  test('Firebase hit avoids upstream; loaded hit avoids Firebase', () async {
    var calls = 0;
    final cache = SharedTransitCache(endpoint: endpoint, clock: () => initial);
    final client = MockClient((r) async {
      calls++;
      expect(r.url, endpoint);
      expect(r.headers.containsKey('authorization'), isFalse);
      expect((jsonDecode(r.body) as Map<String, dynamic>)['version'], 1);
      return cached(initial);
    });
    for (var i = 0; i < 2; i++) {
      final result = await AppHttpClient.get(
        provider,
        headers: {'Authorization': 'apikey private'},
        client: client,
        sharedCache: cache,
      );
      expect(result!.body, '{"locations":[]}');
    }
    expect(calls, 1);
  });

  test(
    'outage, malformed, expired and incompatible cache responses fall back',
    () async {
      for (final response in [
        http.Response('offline', 503),
        cached(initial, body: 'invalid'),
        cached(initial.subtract(const Duration(minutes: 1))),
        http.Response('{}', 200),
      ]) {
        final cache = SharedTransitCache(
          endpoint: endpoint,
          clock: () => initial,
        );
        final seen = <Uri>[];
        final client = MockClient((r) async {
          seen.add(r.url);
          return r.url == endpoint ? response : http.Response('provider', 200);
        });
        final result = await AppHttpClient.get(
          provider,
          client: client,
          sharedCache: cache,
        );
        expect(result!.body, 'provider');
        expect(seen, [endpoint, provider]);
      }
    },
  );

  test(
    'generated clients also retain direct fallback when cache fails',
    () async {
      final seen = <Uri>[];
      final client = BoundedHttpClient(
        sharedCache: SharedTransitCache(
          endpoint: endpoint,
          clock: () => initial,
        ),
        inner: MockClient((r) async {
          seen.add(r.url);
          return http.Response(
            r.url == endpoint ? 'unavailable' : 'normal',
            r.url == endpoint ? 503 : 200,
          );
        }),
      );
      expect((await client.get(provider)).body, 'normal');
      expect(seen, [endpoint, provider]);
      client.close();
    },
  );

  test('loaded expiry does not restart when data changes tiers', () async {
    var now = initial;
    var calls = 0;
    final cache = SharedTransitCache(endpoint: endpoint, clock: () => now);
    final client = MockClient((r) async {
      calls++;
      return cached(now);
    });
    await cache.lookup(provider, client: client);
    now = now.add(const Duration(seconds: 29));
    await cache.lookup(provider, client: client);
    expect(calls, 1);
    now = now.add(const Duration(seconds: 2));
    await cache.lookup(provider, client: client);
    expect(calls, 2);
  });

  test(
    'concurrent equivalent queries deduplicate; scopes remain separate',
    () async {
      final completer = Completer<http.Response>();
      var calls = 0;
      final cache = SharedTransitCache(
        endpoint: endpoint,
        clock: () => initial,
      );
      final client = MockClient((r) {
        calls++;
        return completer.future;
      });
      final a = cache.lookup(provider, client: client);
      final b = cache.lookup(provider, client: client);
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      completer.complete(cached(initial));
      await Future.wait([a, b]);
      await cache.lookup(
        provider,
        client: client,
        query: RealtimeQuery(tripIds: ['other']),
      );
      expect(calls, 2);
    },
  );

  test('invalidation prevents pending work reinstalling loaded data', () async {
    final completer = Completer<http.Response>();
    var calls = 0;
    final cache = SharedTransitCache(endpoint: endpoint, clock: () => initial);
    final client = MockClient((r) {
      calls++;
      return completer.future;
    });
    final first = cache.lookup(provider, client: client);
    cache.invalidate();
    completer.complete(cached(initial));
    await first;
    await cache.lookup(provider, client: client);
    expect(calls, 2);
  });

  test(
    'timeout aborts shared lookup and still requests normal provider',
    () async {
      final cache = SharedTransitCache(
        endpoint: endpoint,
        clock: () => initial,
        timeout: const Duration(milliseconds: 5),
      );
      final seen = <Uri>[];
      final client = MockClient((r) {
        seen.add(r.url);
        return r.url == endpoint
            ? Completer<http.Response>().future
            : Future.value(http.Response('normal', 200));
      });
      expect(
        (await AppHttpClient.get(
          provider,
          client: client,
          sharedCache: cache,
        ))!.body,
        'normal',
      );
      expect(seen, [endpoint, provider]);
    },
  );

  test(
    'credential-bearing and unsupported URLs never leave the device',
    () async {
      final cache = SharedTransitCache(endpoint: endpoint);
      final client = MockClient(
        (_) async => throw StateError('must not request'),
      );
      expect(
        await cache.lookup(
          Uri.parse('https://other.example/feed'),
          client: client,
        ),
        isNull,
      );
      expect(
        await cache.lookup(
          provider.replace(queryParameters: {'api_key': 'private'}),
          client: client,
        ),
        isNull,
      );
    },
  );
}
