import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import '../models/manual_trip_models.dart';
import '../schema/database.dart' as db;
import '../services/prefetch_scheduler.dart';
import '../services/transport_api_service.dart' hide logger;
import '../transit/domain/transit_types.dart';
import '../transit/registry/region_feature_flags.dart';
import 'trip_cache_service/repository.dart';
import 'trip_cache_service/trip_cache_snapshot.dart';

export 'trip_cache_service/repository.dart';
export 'trip_cache_service/trip_cache_snapshot.dart';

/// Compatibility facade over the explicit journey cache policy.
class TripCacheService {
  TripCacheService._();
  static TripCacheRepository _repository = TripCacheRepository();
  static String _key(String originId, String destinationId) =>
      '$originId|$destinationId';

  @visibleForTesting
  static void configureForTesting(TripCacheRepository repository) =>
      _repository = repository;

  @visibleForTesting
  static void resetForTesting() => _repository = TripCacheRepository();

  static Listenable get changes => _repository.changes;

  static bool canLoadJourney(db.Journey journey) =>
      !journey.isManualMultiLeg &&
      _tfnswStopId(journey.originId) != null &&
      _tfnswStopId(journey.destinationId) != null;

  /// Returns current cached data without starting another request.
  static TripCacheSnapshot? peekSnapshot(
    String originId,
    String destinationId,
  ) {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    return origin == null || destination == null
        ? null
        : _repository.peekSnapshot(origin, destination);
  }

  static String? _tfnswStopId(String value) {
    if (!RegionFeatureFlags.nsw) return null;
    if (value.trim().isEmpty) return null;
    if (!value.contains('|')) return value;
    final reference = TransitStopRef.tryParse(value);
    return reference?.region == TransitRegion.nsw &&
            reference?.provider == TransitProviderId.tfnsw
        ? reference!.stopId
        : null;
  }

  static bool isCached(String originId, String destinationId) {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    return origin != null &&
        destination != null &&
        _repository.isCached(origin, destination);
  }

  static Future<TripCacheSnapshot> getSnapshotOrFetch({
    required String originId,
    required String destinationId,
    bool forceRefresh = false,
  }) {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    if (origin == null || destination == null) {
      return Future.value(
        const TripCacheSnapshot(
          error: 'Journeys for this region cannot be loaded here.',
        ),
      );
    }
    return _repository.getSnapshotOrFetch(
      originId: origin,
      destinationId: destination,
      forceRefresh: forceRefresh,
    );
  }

  static Future<TripCacheSnapshot?> getRetainedSnapshot(
    String originId,
    String destinationId,
  ) async {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    if (origin == null || destination == null) return null;
    return _repository.getRetainedSnapshot(origin, destination);
  }

  /// Legacy callers still receive only usable, non-expired journey results.
  static Future<Result<GetTripsResponse, String>> getCachedOrFetch({
    required String originId,
    required String destinationId,
  }) async {
    final snapshot = await getSnapshotOrFetch(
      originId: originId,
      destinationId: destinationId,
    );
    final response = snapshot.response;
    if (response != null) return Ok(response);
    return Err(
      snapshot.error ??
          'Saved journeys have expired. Refresh to load current departures.',
    );
  }

  static void prefetchJourney(db.Journey journey) {
    if (journey.isManualMultiLeg) return;
    _prefetchStops(journey.originId, journey.destinationId);
  }

  static void prefetchReverseJourney(db.Journey journey) {
    if (journey.isManualMultiLeg) return;
    _prefetchStops(journey.destinationId, journey.originId);
  }

  static void _prefetchStops(String originId, String destinationId) {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    if (origin == null ||
        destination == null ||
        isCached(origin, destination)) {
      return;
    }
    PrefetchScheduler.instance.enqueueTripPlanner(
      key: _key(origin, destination),
      job: () async {
        await getCachedOrFetch(originId: origin, destinationId: destination);
      },
    );
  }

  /// Prefetch trips for the first [limit] journeys in [journeys] without
  /// blocking the caller.  Already-cached and non-stale entries are skipped.
  static void prefetch(List<db.Journey> journeys, {int limit = 10}) {
    final toFetch = journeys.take(limit).toList();
    for (final j in toFetch) {
      prefetchJourney(j);
    }
  }

  static void invalidate(String originId, String destinationId) {
    final origin = _tfnswStopId(originId);
    final destination = _tfnswStopId(destinationId);
    if (origin != null && destination != null) {
      _repository.invalidate(origin, destination);
    }
  }

  static void invalidateAll() => _repository.invalidateAll();

  /// Clear cached journeys without starting persistence work.
  static Future<void> clearMemoryCache() => _repository.clearMemoryCache();
}
