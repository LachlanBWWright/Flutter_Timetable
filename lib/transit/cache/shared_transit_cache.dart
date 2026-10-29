import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'provider_sources.dart';
import 'realtime_query.dart';

/// Optional HTTP interface to the Firebase backend. Existing repositories own
/// loaded domain data; this module additionally deduplicates remote lookups.
/// No provider credentials are ever forwarded to the shared backend.
class SharedTransitCache {
  SharedTransitCache({
    required this.endpoint,
    Set<String>? hosts,
    DateTime Function()? clock,
    this.timeout = const Duration(seconds: 4),
  }) : hosts = hosts ?? defaultHosts,
       _clock = clock ?? DateTime.now;

  static final defaultHosts = <String>{
    'api.transport.nsw.gov.au',
    'timetableapi.ptv.vic.gov.au',
    ...sharedProviderSources.keys.map((url) => Uri.parse(url).host),
  };

  static final instance = SharedTransitCache.fromEnvironment();

  factory SharedTransitCache.fromEnvironment() {
    String setting(String name, String compiled) {
      if (compiled.isNotEmpty) return compiled;
      return dotenv.isInitialized ? dotenv.env[name] ?? '' : '';
    }

    final configured = setting(
      'FIREBASE_CACHE_URL',
      const String.fromEnvironment('FIREBASE_CACHE_URL'),
    );
    final rawHosts = setting(
      'FIREBASE_CACHE_HOSTS',
      const String.fromEnvironment('FIREBASE_CACHE_HOSTS'),
    );
    final uri = Uri.tryParse(configured);
    final valid =
        uri != null &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        (uri.scheme == 'https' ||
            (uri.scheme == 'http' &&
                const {
                  'localhost',
                  '127.0.0.1',
                  '10.0.2.2',
                }.contains(uri.host)));
    return SharedTransitCache(
      endpoint: valid ? uri : null,
      hosts: rawHosts.isEmpty
          ? defaultHosts
          : rawHosts
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toSet(),
    );
  }

  final Uri? endpoint;
  final Set<String> hosts;
  final DateTime Function() _clock;
  final Duration timeout;
  final _loaded = <String, ({http.Response response, DateTime expires})>{};
  final _inflight = <String, Future<http.Response?>>{};
  int _generation = 0;
  DateTime? _retryAfter;
  bool get isConfigured => endpoint != null;

  static bool isPtvResource(Uri uri) =>
      uri.host == 'timetableapi.ptv.vic.gov.au' &&
      RegExp(
        r'^/v3/(search/[^/]+|stops/\d+/route_type/[0-4]|departures/route_type/[0-4]/stop/\d+|disruptions(/stop/\d+)?)$',
      ).hasMatch(uri.path);

  static Uri cacheUri(Uri uri) {
    if (!isPtvResource(uri)) return uri;
    final parameters = Map<String, dynamic>.from(uri.queryParametersAll)
      ..removeWhere(
        (key, _) => const {'signature', 'devid'}.contains(key.toLowerCase()),
      );
    return uri.replace(queryParameters: parameters);
  }

  bool supports(Uri uri) =>
      isConfigured &&
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      hosts.contains(uri.host) &&
      uri != endpoint &&
      !uri.queryParameters.keys.any(
        (k) => RegExp(
          r'key|token|signature|authorization|callback',
          caseSensitive: false,
        ).hasMatch(k),
      );

  void invalidate() {
    _generation++;
    _loaded.clear();
    _inflight.clear();
    _retryAfter = null;
  }

  /// Null means use the original provider path. Missing configuration performs
  /// no I/O. Timeouts, unsupported sources and invalid cache data fail open.
  Future<http.Response?> lookup(
    Uri uri, {
    RealtimeQuery? query,
    http.Client? client,
  }) async {
    uri = cacheUri(uri);
    if (!supports(uri)) return null;
    uri = uri.replace(
      queryParameters: uri.hasQuery
          ? SplayTreeMap<String, dynamic>.from(uri.queryParametersAll)
          : null,
    );
    final key = jsonEncode([uri.toString(), query?.toJson() ?? {}]);
    final loaded = _loaded[key];
    if (loaded != null && _clock().isBefore(loaded.expires)) {
      return loaded.response;
    }
    _loaded.remove(key);
    if (_retryAfter != null && _clock().isBefore(_retryAfter!)) return null;
    final pending = _inflight[key];
    if (pending != null) return pending;
    final generation = _generation;
    final future = _lookup(uri, query, key, generation, client);
    _inflight[key] = future;
    try {
      return await future;
    } finally {
      if (identical(_inflight[key], future)) _inflight.remove(key);
    }
  }

  Future<http.Response?> _lookup(
    Uri uri,
    RealtimeQuery? query,
    String key,
    int generation,
    http.Client? supplied,
  ) async {
    final client = supplied ?? http.Client();
    final abort = Completer<void>();
    try {
      final request =
          http.AbortableRequest('POST', endpoint!, abortTrigger: abort.future)
            ..headers['content-type'] = 'application/json'
            ..body = jsonEncode({
              'version': 1,
              'url': uri.toString(),
              'filter': query?.toJson() ?? {},
            });
      var result =
          await (() async => http.Response.fromStream(
            await client.send(request),
          ))().timeout(
            timeout,
            onTimeout: () {
              if (!abort.isCompleted) abort.complete();
              throw TimeoutException('Shared cache deadline exceeded');
            },
          );
      if (generation == _generation &&
          (result.statusCode >= 500 || result.statusCode == 429)) {
        _retryAfter = _clock().add(const Duration(seconds: 15));
      }
      if (result.statusCode != 200 ||
          result.headers['x-transit-version'] != '1') {
        return null;
      }
      final download = result.headers['x-transit-download-url'];
      if (download != null) {
        // Large static archives travel directly from Storage, rather than
        // through the function's response-size limit. Only the trusted backend
        // can supply this public-dataset token; device credentials are absent.
        var target = Uri.tryParse(download);
        const loopback = {'localhost', '127.0.0.1', '10.0.2.2'};
        final emulator =
            endpoint!.scheme == 'http' &&
            loopback.contains(endpoint!.host) &&
            target?.scheme == 'http' &&
            loopback.contains(target!.host);
        if (emulator && endpoint!.host == '10.0.2.2') {
          target = target.replace(host: '10.0.2.2');
        }
        if (sharedProviderSources[uri.toString()] != 'static' ||
            target == null ||
            (!emulator &&
                (target.scheme != 'https' ||
                    target.host != 'firebasestorage.googleapis.com')) ||
            target.userInfo.isNotEmpty ||
            !target.path.startsWith('/v0/b/')) {
          return null;
        }
        final storageRequest = http.AbortableRequest(
          'GET',
          target,
          abortTrigger: abort.future,
        );
        final archive =
            await (() async => http.Response.fromStream(
              await client.send(storageRequest),
            ))().timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                if (!abort.isCompleted) abort.complete();
                throw TimeoutException('Shared archive deadline exceeded');
              },
            );
        if (archive.statusCode != 200) return null;
        result = http.Response.bytes(
          archive.bodyBytes,
          200,
          headers: result.headers,
        );
      }
      // Validate before installing transport data; malformed shared responses
      // must not block the normal provider request or poison loaded data.
      final kind = sharedProviderSources[uri.toString()];
      if (kind == 'static') {
        final bytes = result.bodyBytes;
        if (bytes.length < 22 ||
            bytes[0] != 0x50 ||
            bytes[1] != 0x4b ||
            bytes[2] != 3 ||
            bytes[3] != 4) {
          return null;
        }
      } else if (kind == 'realtime' ||
          (uri.path.contains('/gtfs/') && !uri.path.contains('/schedule'))) {
        final feed = FeedMessage.fromBuffer(result.bodyBytes);
        if (!feed.hasHeader() || !feed.header.hasGtfsRealtimeVersion()) {
          return null;
        }
      } else {
        final body = jsonDecode(result.body);
        if (body is! Map<String, dynamic>) return null;
        if (uri.path.endsWith('/stop_finder') && body['locations'] is! List) {
          return null;
        }
        if (uri.path.endsWith('/trip') && body['journeys'] is! List) {
          return null;
        }
        if (isPtvResource(uri)) {
          final field = uri.path.startsWith('/v3/search/')
              ? 'stops'
              : uri.path.startsWith('/v3/stops/')
              ? 'stop'
              : uri.path.startsWith('/v3/departures/')
              ? 'departures'
              : 'disruptions';
          if (field == 'stops' || field == 'departures') {
            if (body[field] is! List) return null;
          } else if (body[field] is! Map<String, dynamic>) {
            return null;
          }
        }
      }
      final fetched = DateTime.tryParse(
        result.headers['x-transit-fetched-at'] ?? '',
      );
      final expires = DateTime.tryParse(
        result.headers['x-transit-expires-at'] ?? '',
      );
      if (fetched == null ||
          expires == null ||
          fetched.isAfter(_clock().add(const Duration(seconds: 5))) ||
          !expires.isAfter(fetched) ||
          !_clock().isBefore(expires)) {
        return null;
      }
      // Do not keep large static archives or unbounded lists in transport memory.
      if (generation == _generation && result.bodyBytes.length <= 1024 * 1024) {
        if (_loaded.length >= 64) _loaded.remove(_loaded.keys.first);
        _loaded[key] = (response: result, expires: expires);
      }
      return result;
    } catch (_) {
      if (generation == _generation) {
        _retryAfter = _clock().add(const Duration(seconds: 15));
      }
      return null;
    } finally {
      if (supplied == null) client.close();
    }
  }
}
