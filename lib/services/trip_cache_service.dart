import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
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
  static final Map<String, Future<Result<GetTripsResponse, String>>> _inflight =
      {};

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

    final inflight = _inflight[key];
    if (inflight != null) {
      return inflight;
    }

    logger.d('TripCacheService: cache miss for $key — fetching from API');
    final request = () async {
      try {
        final result = await TransportApiService.getTrips(
          originId: originId,
          destinationId: destinationId,
        );
        if (result case Ok(:final v)) {
          _store(originId, destinationId, v);
        }
        return result;
      } finally {
        _inflight.remove(key);
      }
    }();

    _inflight[key] = request;
    return request;
  }

  static void prefetchJourney(db.Journey journey) {
    if (journey.isManualMultiLeg) {
      return;
    }
    if (isCached(journey.originId, journey.destinationId)) {
      return;
    }
    getCachedOrFetch(
      originId: journey.originId,
      destinationId: journey.destinationId,
    ).ignore();
  }

  static void prefetchReverseJourney(db.Journey journey) {
    if (journey.isManualMultiLeg) {
      return;
    }
    if (isCached(journey.destinationId, journey.originId)) {
      return;
    }
    getCachedOrFetch(
      originId: journey.destinationId,
      destinationId: journey.originId,
    ).ignore();
  }

  /// Prefetch trips for the first [limit] journeys in [journeys] without
  /// blocking the caller.  Already-cached and non-stale entries are skipped.
  static void prefetch(List<db.Journey> journeys, {int limit = 10}) {
    final toFetch = journeys.take(limit).toList();
    for (final j in toFetch) {
      prefetchJourney(j);
    }
  }

  /// Invalidate a single cache entry (e.g. on manual refresh).
  static void invalidate(String originId, String destinationId) {
    final key = _key(originId, destinationId);
    _cache.remove(key);
    _inflight.remove(key);
  }

  /// Invalidate all cache entries.
  static void invalidateAll() {
    _cache.clear();
    _inflight.clear();
  }
}

class _CachedTrip {
  final GetTripsResponse response;
  final DateTime fetchedAt;

  const _CachedTrip({required this.response, required this.fetchedAt});
}
