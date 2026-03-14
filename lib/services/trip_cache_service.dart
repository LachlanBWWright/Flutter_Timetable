import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:option_result/option_result.dart';

/// A simple in-memory cache for trip responses with a 10-minute TTL.
///
/// Entries are keyed by `"$originId|$destinationId"`. After [_ttl] has
/// elapsed, the entry is considered stale and the next call will re-fetch
/// from the API.
///
/// **Memory note**: stale entries are not automatically evicted. For a typical
/// app with a small number of saved journeys this is not a concern, but callers
/// should use [invalidate] or [invalidateAll] if memory usage becomes an issue.
class TripCacheService {
  TripCacheService._();

  static const Duration _ttl = Duration(minutes: 10);

  static final Map<String, _CachedTrip> _cache = {};

  /// Returns a cache key for the given origin/destination pair.
  static String _key(String originId, String destinationId) =>
      '$originId|$destinationId';

  /// Returns true when a cache entry exists and is still fresh.
  static bool isCached(String originId, String destinationId) {
    final entry = _cache[_key(originId, destinationId)];
    if (entry == null) return false;
    return DateTime.now().difference(entry.fetchedAt) < _ttl;
  }

  /// Stores a response in the cache.
  static void _store(
    String originId,
    String destinationId,
    GetTripsResponse response,
  ) {
    _cache[_key(originId, destinationId)] = _CachedTrip(
      response: response,
      fetchedAt: DateTime.now(),
    );
  }

  /// Returns the cached response if it exists and is still fresh,
  /// otherwise fetches from the API, caches the result, and returns it.
  static Future<Result<GetTripsResponse, String>> getCachedOrFetch({
    required String originId,
    required String destinationId,
  }) async {
    final key = _key(originId, destinationId);
    final entry = _cache[key];
    if (entry != null && DateTime.now().difference(entry.fetchedAt) < _ttl) {
      logger.d('TripCacheService: cache hit for $key');
      return Ok(entry.response);
    }

    logger.d('TripCacheService: cache miss for $key — fetching from API');
    final result = await TransportApiService.getTrips(
      originId: originId,
      destinationId: destinationId,
    );
    if (result case Ok(:final v)) {
      _store(originId, destinationId, v);
    }
    return result;
  }

  /// Prefetch trips for the first [limit] journeys in [journeys] without
  /// blocking the caller.  Already-cached and non-stale entries are skipped.
  static void prefetch(List<db.Journey> journeys, {int limit = 10}) {
    final toFetch = journeys.take(limit).toList();
    for (final j in toFetch) {
      if (!isCached(j.originId, j.destinationId)) {
        // Fire and forget — errors are logged inside getCachedOrFetch
        getCachedOrFetch(
          originId: j.originId,
          destinationId: j.destinationId,
        ).ignore();
      }
    }
  }

  /// Invalidate a single cache entry (e.g. on manual refresh).
  static void invalidate(String originId, String destinationId) {
    _cache.remove(_key(originId, destinationId));
  }

  /// Invalidate all cache entries.
  static void invalidateAll() => _cache.clear();
}

class _CachedTrip {
  final GetTripsResponse response;
  final DateTime fetchedAt;

  const _CachedTrip({required this.response, required this.fetchedAt});
}
