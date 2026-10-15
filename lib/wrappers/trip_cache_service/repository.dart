import 'package:option_result/option_result.dart';
import '../../logs/logger.dart';
import '../../schema/database.dart' as db;
import '../../services/transport_api_service.dart' hide logger;
import 'persistence.dart';
import 'trip_cache_snapshot.dart';

typedef TripCacheFetch =
    Future<Result<GetTripsResponse, String>> Function(
      String origin,
      String destination,
    );
typedef TripCacheRead =
    Future<TripCacheEntry?> Function(String origin, String destination);
typedef TripCacheWrite =
    Future<void> Function(
      String origin,
      String destination,
      TripCacheEntry entry,
    );
typedef TripCacheError =
    Future<void> Function(String origin, String destination, String error);

/// Clock, transport and persistence are injectable without global database mocks.
class TripCacheRepository {
  TripCacheRepository({
    DateTime Function()? clock,
    TripCacheFetch? fetchTrips,
    TripCacheRead? readCache,
    TripCacheWrite? writeCache,
    TripCacheError? markError,
    Future<void> Function(String, String)? deleteCache,
    Future<void> Function()? deleteAll,
  }) : clock = clock ?? DateTime.now,
       fetchTrips =
           fetchTrips ??
           ((o, d) =>
               TransportApiService.getTrips(originId: o, destinationId: d)),
       readCache = readCache ?? readTripCache,
       writeCache = writeCache ?? writeTripCache,
       markError = markError ?? markTripCacheError,
       deleteCache =
           deleteCache ??
           ((o, d) async {
             await db.AppDatabase().deleteTripPlannerCache(o, d);
           }),
       deleteAll =
           deleteAll ??
           (() async {
             await db.AppDatabase().deleteAllTripPlannerCache();
           });

  static const freshFor = Duration(minutes: 10);
  static const renderableFor = Duration(hours: 24);
  final DateTime Function() clock;
  final TripCacheFetch fetchTrips;
  final TripCacheRead readCache;
  final TripCacheWrite writeCache;
  final TripCacheError markError;
  final Future<void> Function(String, String) deleteCache;
  final Future<void> Function() deleteAll;
  final _memory = <String, TripCacheEntry>{};
  final _inflight = <String, Future<TripCacheSnapshot>>{};
  final _generations = <String, int>{};
  final _activeRequests = <String, int>{};
  int _generation = 0;
  Future<void>? _persistence;

  // Ordering deletes and writes also protects invalidateAll across endpoints.
  Future<void> _mutate(Future<void> Function() operation) {
    final tail = _persistence;
    final mutation = tail == null
        ? Future<void>.sync(operation)
        : tail.then((_) => operation());
    late final Future<void> settled;
    settled = mutation.then<void>(
      (_) {
        if (identical(_persistence, settled)) _persistence = null;
      },
      onError: (Object error, StackTrace stack) {
        safeLogWarning('Trip cache persistence failed: $error');
        if (identical(_persistence, settled)) _persistence = null;
      },
    );
    _persistence = settled;
    return mutation;
  }

  bool isCached(String origin, String destination) {
    final entry = _memory['$origin|$destination'];
    return entry != null && _fresh(entry) && _hasUpcoming(entry.response);
  }

  bool _fresh(TripCacheEntry entry) {
    final age = clock().difference(entry.fetchedAt);
    return entry.error == null && !age.isNegative && age < freshFor;
  }

  Future<TripCacheSnapshot> getSnapshotOrFetch({
    required String originId,
    required String destinationId,
    bool forceRefresh = false,
  }) {
    final key = '$originId|$destinationId';
    final pending = _inflight[key];
    if (pending != null) return pending;
    final generation = _generation;
    final keyGeneration = _generations[key] ?? 0;
    _activeRequests[key] = (_activeRequests[key] ?? 0) + 1;
    late final Future<TripCacheSnapshot> request;
    request =
        _load(
          originId,
          destinationId,
          forceRefresh,
          () =>
              generation == _generation &&
              keyGeneration == (_generations[key] ?? 0),
        ).whenComplete(() {
          if (identical(_inflight[key], request)) _inflight.remove(key);
          _releaseRequestKey(key);
        });
    _inflight[key] = request;
    return request;
  }

  Future<TripCacheSnapshot> _load(
    String origin,
    String destination,
    bool force,
    bool Function() current,
  ) async {
    final key = '$origin|$destination';
    var entry = _memory[key];
    if (entry == null) {
      try {
        final pendingMutation = _persistence;
        if (pendingMutation != null) await pendingMutation;
        entry = await readCache(origin, destination);
      } catch (error) {
        safeLogWarning('Trip cache read failed: $error');
      }
      if (entry != null && current()) _remember(key, entry);
    }
    if (!force &&
        entry != null &&
        _fresh(entry) &&
        _hasUpcoming(entry.response)) {
      return _snapshot(entry);
    }
    Result<GetTripsResponse, String> result;
    try {
      result = await fetchTrips(origin, destination);
    } catch (error) {
      result = Err('Unable to refresh journeys: $error');
    }
    switch (result) {
      case Ok(:final v):
        final updated = TripCacheEntry(response: v, fetchedAt: clock());
        if (current()) {
          _remember(key, updated);
          try {
            await _mutate(() async {
              if (current()) await writeCache(origin, destination, updated);
            });
          } catch (error) {
            safeLogWarning('Trip cache write failed: $error');
          }
        }
        return _snapshot(updated);
      case Err(:final e):
        if (current() && entry != null) {
          _remember(
            key,
            TripCacheEntry(
              response: entry.response,
              fetchedAt: entry.fetchedAt,
              error: e,
            ),
          );
          try {
            await _mutate(() async {
              if (current()) await markError(origin, destination, e);
            });
          } catch (error) {
            safeLogWarning('Trip cache error write failed: $error');
          }
        }
        return entry == null
            ? TripCacheSnapshot(error: e)
            : _snapshot(entry, error: e);
    }
  }

  TripCacheSnapshot _snapshot(TripCacheEntry entry, {String? error}) {
    final age = clock().difference(entry.fetchedAt);
    final expired = age.isNegative || age >= renderableFor;
    final refreshError = error ?? entry.error;
    return TripCacheSnapshot(
      response: expired ? null : _upcoming(entry.response),
      fetchedAt: entry.fetchedAt,
      error: refreshError,
      isFresh: !expired && age < freshFor && refreshError == null,
      isStale: !expired && (age >= freshFor || refreshError != null),
      isExpired: expired,
      // A provider failure does not establish that the device is offline.
      isOffline: false,
    );
  }

  bool _hasUpcoming(GetTripsResponse response) =>
      response.tripJourneys.isEmpty ||
      response.tripJourneys.any(_upcomingJourney);

  bool _upcomingJourney(TripJourney journey) {
    if (journey.legs.isEmpty) return false;
    final stop = journey.legs.first.origin;
    final departure =
        DateTime.tryParse(stop.departureTimeEstimated ?? '') ??
        DateTime.tryParse(stop.departureTimePlanned ?? '');
    // Undated cached journeys cannot safely be presented as current departures.
    return departure != null && !departure.isBefore(clock());
  }

  GetTripsResponse _upcoming(GetTripsResponse response) => GetTripsResponse(
    tripJourneys: response.tripJourneys
        .where(_upcomingJourney)
        .toList(growable: false),
    systemMessages: response.systemMessages,
    version: response.version,
    rawJson: response.rawJson,
  );

  void _remember(String key, TripCacheEntry entry) {
    _memory.remove(key);
    _memory[key] = entry;
    while (_memory.length > 50) {
      _memory.remove(_memory.keys.first);
    }
  }

  void _releaseRequestKey(String key) {
    final active = _activeRequests[key] ?? 0;
    if (active <= 1) {
      _activeRequests.remove(key);
      _generations.remove(key);
    } else {
      _activeRequests[key] = active - 1;
    }
  }

  void invalidate(String origin, String destination) {
    final key = '$origin|$destination';
    if ((_activeRequests[key] ?? 0) > 0) {
      _generations[key] = (_generations[key] ?? 0) + 1;
    } else {
      _generations.remove(key);
    }
    _memory.remove(key);
    _inflight.remove(key);
    _mutate(() => deleteCache(origin, destination)).ignore();
  }

  /// Clear in-memory entries and invalidate inflight work without issuing DB
  /// writes. Wait for writes already accepted before returning so callers can
  /// safely clear persistent state immediately afterward.
  Future<void> clearMemoryCache() async {
    _clearMemoryEntries();
    final pendingPersistence = _persistence;
    if (pendingPersistence != null) await pendingPersistence;
  }

  void _clearMemoryEntries() {
    _generation++;
    _memory.clear();
    _generations.clear();
    _inflight.clear();
  }

  void invalidateAll() {
    _clearMemoryEntries();
    _mutate(deleteAll).ignore();
  }
}
