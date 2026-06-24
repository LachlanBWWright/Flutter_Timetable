import '../constants/transport_modes.dart';
import '../fetch_data/realtime_positions.dart' as positions;
import '../fetch_data/realtime_updates.dart' as updates;
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

class TripUpdateAggregationResult {
  final List<TripUpdate> tripUpdates;
  final Map<String, int> breakdown;

  const TripUpdateAggregationResult({
    required this.tripUpdates,
    required this.breakdown,
  });
}

class VehiclePositionAggregationResult {
  final List<VehiclePosition> vehicles;
  final Map<String, int> breakdown;

  const VehiclePositionAggregationResult({
    required this.vehicles,
    required this.breakdown,
  });
}

/// Service for managing realtime transport data
class RealtimeService {
  static const Duration _aggregatePrefetchCooldown = Duration(seconds: 30);
  static const Duration _feedTtl = Duration(seconds: 30);
  static DateTime? _lastAggregatePrefetchAt;
  static Future<void>? _inflightAggregatePrefetch;
  static final Map<String, _RealtimeFeedCacheEntry<FeedMessage?>> _feedCache =
      {};
  static final Map<String, Future<FeedMessage?>> _inflightFeeds = {};
  static final Map<String, _RealtimeFeedCacheEntry<List<FeedMessage?>>>
  _feedListCache = {};
  static final Map<String, Future<List<FeedMessage?>>> _inflightFeedLists = {};

  static V? _mapValueOrNull<K, V>(Map<K, V> map, K key) {
    try {
      for (final entry in map.entries) {
        if (entry.key == key) {
          return entry.value;
        }
      }
    } catch (_) {}
    return null;
  }

  static void _putValue<K, V>(Map<K, V> map, K key, V value) {
    try {
      map.remove(key);
      map.addAll({key: value});
    } catch (_) {}
  }

  static void _incrementCount(Map<String, int> counts, String key, int delta) {
    final previousCount = _mapValueOrNull(counts, key) ?? 0;
    _putValue(counts, key, previousCount + delta);
  }

  static Future<T> _loadOrFallback<T>(
    Future<T> Function() loader,
    T fallback,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  static Future<FeedMessage?> _invokeFeedLoader(
    Future<FeedMessage?> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return null;
    }
  }

  static Future<List<FeedMessage?>> _invokeFeedListLoader(
    Future<List<FeedMessage?>> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return const [];
    }
  }

  /// Warm critical realtime datasets before the user opens detail actions.
  ///
  /// This is intentionally throttled because feeds are network-heavy.
  static Future<void> prefetchAggregates({
    bool includeVehicles = true,
    bool includeTripUpdates = true,
  }) async {
    final now = DateTime.now();
    final lastAggregatePrefetchAt = _lastAggregatePrefetchAt;
    if (lastAggregatePrefetchAt != null &&
        now.difference(lastAggregatePrefetchAt) < _aggregatePrefetchCooldown) {
      return;
    }

    final inflight = _inflightAggregatePrefetch;
    if (inflight != null) {
      return inflight;
    }

    Future<void> requestBody() async {
      try {
        final futures = <Future<Object?>>[];
        if (includeVehicles) {
          futures.add(getAllVehiclePositionsAggregated());
        }
        if (includeTripUpdates) {
          futures.add(getAllTripUpdatesAggregated());
        }
        await Future.wait<void>(
          futures.map((future) async {
            try {
              await future;
            } catch (_) {}
          }),
        );
        _lastAggregatePrefetchAt = DateTime.now();
      } finally {
        _inflightAggregatePrefetch = null;
      }
    }

    final request = requestBody();

    _inflightAggregatePrefetch = request;
    return request;
  }

  /// Get realtime positions for all broad transport modes.
  ///
  /// Returns a map keyed by [TransportMode] (the broad mode) with the
  /// corresponding canonical feed [FeedMessage] where available. This
  /// intentionally uses the enum as the key instead of string feed keys so
  /// callers can rely on typed mode values.
  static Future<Map<TransportMode, FeedMessage?>>
  getAllRealtimePositions() async {
    final results = <TransportMode, FeedMessage?>{};
    final modes = <TransportMode>[
      TransportMode.train,
      TransportMode.metro,
      TransportMode.bus,
      TransportMode.lightrail,
      TransportMode.ferry,
    ];

    for (final mode in modes) {
      final feed = await _loadOrFallback<FeedMessage?>(
        () => getPositionsForTransportMode(mode),
        null,
      );
      _putValue(results, mode, feed);
    }

    return results;
  }

  static Future<VehiclePositionAggregationResult>
  getAllVehiclePositionsAggregatedSafe({
    Future<Map<TransportMode, FeedMessage?>> Function()?
    getAllPositionsOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) async {
    try {
      return await getAllVehiclePositionsAggregated(
        getAllPositionsOverride: getAllPositionsOverride,
        getRegionBusesOverride: getRegionBusesOverride,
        getAllFerriesOverride: getAllFerriesOverride,
        getAllLightRailOverride: getAllLightRailOverride,
      );
    } catch (_) {
      return const VehiclePositionAggregationResult(
        vehicles: <VehiclePosition>[],
        breakdown: <String, int>{},
      );
    }
  }

  static Future<TripUpdateAggregationResult> getAllTripUpdatesAggregatedSafe({
    Future<Map<TransportMode, FeedMessage?>> Function()? getAllUpdatesOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) async {
    try {
      return await getAllTripUpdatesAggregated(
        getAllUpdatesOverride: getAllUpdatesOverride,
        getRegionBusesOverride: getRegionBusesOverride,
        getAllFerriesOverride: getAllFerriesOverride,
        getAllLightRailOverride: getAllLightRailOverride,
      );
    } catch (_) {
      return const TripUpdateAggregationResult(
        tripUpdates: <TripUpdate>[],
        breakdown: <String, int>{},
      );
    }
  }

  /// Get realtime trip updates for all broad transport modes.
  ///
  /// Returns a map keyed by [TransportMode] with the canonical feed
  /// [FeedMessage] for each broad mode.
  static Future<Map<TransportMode, FeedMessage?>>
  getAllRealtimeUpdates() async {
    final results = <TransportMode, FeedMessage?>{};
    final modes = <TransportMode>[
      TransportMode.train,
      TransportMode.metro,
      TransportMode.bus,
      TransportMode.lightrail,
      TransportMode.ferry,
    ];

    for (final mode in modes) {
      final feed = await _loadOrFallback<FeedMessage?>(
        () => getUpdatesForTransportMode(mode),
        null,
      );
      _putValue(results, mode, feed);
    }

    return results;
  }

  /// Typed wrapper: get positions for a broad TransportMode. This maps the
  /// enum to a sensible canonical feed key and delegates to the existing
  /// string-based API to preserve existing feed selection logic.
  static Future<FeedMessage?> getPositionsForTransportMode(
    TransportMode mode,
  ) async {
    return _cachedFeed('positions:${mode.id}', () async {
      switch (mode) {
        case TransportMode.train:
          return await positions.fetchSydneyTrainsPositions();
        case TransportMode.metro:
          return await positions.fetchSydneyMetroPositions();
        case TransportMode.bus:
          return await positions.fetchBusesPositions();
        case TransportMode.lightrail:
          return await positions.fetchLightRailCbdAndSoutheastPositions();
        case TransportMode.ferry:
          return await positions.fetchFerriesSydneyFerriesPositions();
      }
    });
  }

  /// Typed wrapper: get trip updates for a broad TransportMode.
  static Future<FeedMessage?> getUpdatesForTransportMode(
    TransportMode mode,
  ) async {
    return _cachedFeed('updates:${mode.id}', () async {
      switch (mode) {
        case TransportMode.train:
          return await updates.fetchSydneyTrainsUpdates();
        case TransportMode.metro:
          return await updates.fetchSydneyMetroUpdates();
        case TransportMode.bus:
          return await updates.fetchBusesUpdates();
        case TransportMode.lightrail:
          return await updates.fetchLightRailCbdAndSoutheastUpdates();
        case TransportMode.ferry:
          return await updates.fetchFerriesSydneyFerriesUpdates();
      }
    });
  }

  /// Get region bus positions
  static Future<List<FeedMessage?>> getRegionBusPositions() async {
    return _cachedFeedList(
      'positions:region_buses',
      positions.getAllRegionBuses,
    );
  }

  /// Get region bus updates
  static Future<List<FeedMessage?>> getRegionBusUpdates() async {
    return _cachedFeedList('updates:region_buses', updates.fetchAllRegionBuses);
  }

  /// Get all ferry positions
  static Future<List<FeedMessage?>> getAllFerryPositions() async {
    return _cachedFeedList('positions:ferries', positions.getAllFerries);
  }

  /// Get all ferry updates
  static Future<List<FeedMessage?>> getAllFerryUpdates() async {
    return _cachedFeedList('updates:ferries', updates.fetchAllFerries);
  }

  /// Get all light rail positions
  static Future<List<FeedMessage?>> getAllLightRailPositions() async {
    return _cachedFeedList('positions:lightrail', positions.getAllLightRail);
  }

  /// Get all light rail updates
  static Future<List<FeedMessage?>> getAllLightRailUpdates() async {
    return _cachedFeedList('updates:lightrail', updates.fetchAllLightRail);
  }

  static Future<FeedMessage?> _cachedFeed(
    String key,
    Future<FeedMessage?> Function() loader,
  ) async {
    final cached = _mapValueOrNull(_feedCache, key);
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _feedTtl) {
      return cached.value;
    }

    final inflight = _mapValueOrNull(_inflightFeeds, key);
    if (inflight != null) {
      return inflight;
    }

    Future<FeedMessage?> requestBody() async {
      try {
        final FeedMessage? value = await _invokeFeedLoader(loader);
        _putValue(
          _feedCache,
          key,
          _RealtimeFeedCacheEntry(value, DateTime.now()),
        );
        return value;
      } finally {
        _inflightFeeds.remove(key);
      }
    }

    final request = requestBody();
    _putValue(_inflightFeeds, key, request);
    return request;
  }

  static Future<List<FeedMessage?>> _cachedFeedList(
    String key,
    Future<List<FeedMessage?>> Function() loader,
  ) async {
    final cached = _mapValueOrNull(_feedListCache, key);
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _feedTtl) {
      return cached.value;
    }

    final inflight = _mapValueOrNull(_inflightFeedLists, key);
    if (inflight != null) {
      return inflight;
    }

    Future<List<FeedMessage?>> requestBody() async {
      try {
        final List<FeedMessage?> value = await _invokeFeedListLoader(loader);
        _putValue(
          _feedListCache,
          key,
          _RealtimeFeedCacheEntry(value, DateTime.now()),
        );
        return value;
      } finally {
        _inflightFeedLists.remove(key);
      }
    }

    final request = requestBody();
    _putValue(_inflightFeedLists, key, request);
    return request;
  }

  /// Extract vehicle positions from feed message
  static List<VehiclePosition> extractVehiclePositions(FeedMessage? feed) {
    if (feed == null) return [];

    return feed.entity
        .where((entity) => entity.hasVehicle())
        .map((entity) => entity.vehicle)
        .toList();
  }

  /// Extract trip updates from feed message
  static List<TripUpdate> extractTripUpdates(FeedMessage? feed) {
    if (feed == null) return [];

    return feed.entity
        .where((entity) => entity.hasTripUpdate())
        .map((entity) => entity.tripUpdate)
        .toList();
  }

  /// Aggregate all vehicle positions across all feeds and return a deduplicated
  /// list along with a breakdown of counts per feed group to aid debugging.
  static Future<VehiclePositionAggregationResult>
  getAllVehiclePositionsAggregated({
    Future<Map<TransportMode, FeedMessage?>> Function()?
    getAllPositionsOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) async {
    final vehicles = <VehiclePosition>[];
    final breakdown = <String, int>{};

    final Map<TransportMode, FeedMessage?> all = getAllPositionsOverride != null
        ? await _loadOrFallback(
            getAllPositionsOverride,
            <TransportMode, FeedMessage?>{},
          )
        : await _loadOrFallback(
            getAllRealtimePositions,
            <TransportMode, FeedMessage?>{},
          );
    for (final entry in all.entries) {
      final pack = extractVehiclePositions(entry.value);
      vehicles.addAll(pack);
      _incrementCount(breakdown, '${entry.key}', pack.length);
    }

    final List<FeedMessage?> regionBuses = getRegionBusesOverride != null
        ? await _loadOrFallback(getRegionBusesOverride, <FeedMessage?>[])
        : await _loadOrFallback(getRegionBusPositions, <FeedMessage?>[]);
    var regionCount = 0;
    for (final feed in regionBuses) {
      final pack = extractVehiclePositions(feed);
      regionCount += pack.length;
      vehicles.addAll(pack);
    }
    _putValue(breakdown, 'regionBuses', regionCount);

    final List<FeedMessage?> allFerries = getAllFerriesOverride != null
        ? await _loadOrFallback(getAllFerriesOverride, <FeedMessage?>[])
        : await _loadOrFallback(getAllFerryPositions, <FeedMessage?>[]);
    var ferryCount = 0;
    for (final feed in allFerries) {
      final pack = extractVehiclePositions(feed);
      ferryCount += pack.length;
      vehicles.addAll(pack);
    }
    _putValue(breakdown, 'ferries', ferryCount);

    final List<FeedMessage?> allLightRail = getAllLightRailOverride != null
        ? await _loadOrFallback(getAllLightRailOverride, <FeedMessage?>[])
        : await _loadOrFallback(getAllLightRailPositions, <FeedMessage?>[]);
    var lightrailCount = 0;
    for (final feed in allLightRail) {
      final pack = extractVehiclePositions(feed);
      lightrailCount += pack.length;
      vehicles.addAll(pack);
    }
    _putValue(breakdown, 'lightrail', lightrailCount);

    // Deduplicate using vehicle.id > tripId > position+timestamp
    final unique = <String, VehiclePosition>{};
    for (final v in vehicles) {
      var key = 'unknown';
      if (v.vehicle.hasId()) {
        key = 'vid:${v.vehicle.id}';
      } else if (v.trip.hasTripId()) {
        key = 'trip:${v.trip.tripId}';
      } else if (v.hasPosition() &&
          v.position.hasLatitude() &&
          v.position.hasLongitude()) {
        final lat = v.position.latitude.toStringAsFixed(6);
        final lng = v.position.longitude.toStringAsFixed(6);
        final ts = v.hasTimestamp() ? v.timestamp.toString() : 'nots';
        key = 'pos:$lat:$lng:$ts';
      }
      if (!unique.containsKey(key)) {
        _putValue(unique, key, v);
      }
    }

    return VehiclePositionAggregationResult(
      vehicles: unique.values.toList(),
      breakdown: breakdown,
    );
  }

  /// Aggregate realtime trip updates across all feeds and return a
  /// deduplicated list plus a breakdown of counts per feed group.
  static Future<TripUpdateAggregationResult> getAllTripUpdatesAggregated({
    Future<Map<TransportMode, FeedMessage?>> Function()? getAllUpdatesOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) async {
    final tripUpdates = <TripUpdate>[];
    final breakdown = <String, int>{};

    final Map<TransportMode, FeedMessage?> all = getAllUpdatesOverride != null
        ? await _loadOrFallback(
            getAllUpdatesOverride,
            <TransportMode, FeedMessage?>{},
          )
        : await _loadOrFallback(
            getAllRealtimeUpdates,
            <TransportMode, FeedMessage?>{},
          );
    for (final entry in all.entries) {
      final pack = extractTripUpdates(entry.value);
      tripUpdates.addAll(pack);
      _incrementCount(breakdown, '${entry.key}', pack.length);
    }

    final List<FeedMessage?> regionBuses = getRegionBusesOverride != null
        ? await _loadOrFallback(getRegionBusesOverride, <FeedMessage?>[])
        : await _loadOrFallback(getRegionBusUpdates, <FeedMessage?>[]);
    var regionCount = 0;
    for (final feed in regionBuses) {
      final pack = extractTripUpdates(feed);
      regionCount += pack.length;
      tripUpdates.addAll(pack);
    }
    _putValue(breakdown, 'regionBuses', regionCount);

    final List<FeedMessage?> allFerries = getAllFerriesOverride != null
        ? await _loadOrFallback(getAllFerriesOverride, <FeedMessage?>[])
        : await _loadOrFallback(getAllFerryUpdates, <FeedMessage?>[]);
    var ferryCount = 0;
    for (final feed in allFerries) {
      final pack = extractTripUpdates(feed);
      ferryCount += pack.length;
      tripUpdates.addAll(pack);
    }
    _putValue(breakdown, 'ferries', ferryCount);

    final List<FeedMessage?> allLightRail = getAllLightRailOverride != null
        ? await _loadOrFallback(getAllLightRailOverride, <FeedMessage?>[])
        : await _loadOrFallback(getAllLightRailUpdates, <FeedMessage?>[]);
    var lightrailCount = 0;
    for (final feed in allLightRail) {
      final pack = extractTripUpdates(feed);
      lightrailCount += pack.length;
      tripUpdates.addAll(pack);
    }
    _putValue(breakdown, 'lightrail', lightrailCount);

    final unique = <String, TripUpdate>{};
    for (final u in tripUpdates) {
      final tripId = u.trip.hasTripId() ? u.trip.tripId : '';
      final routeId = u.trip.hasRouteId() ? u.trip.routeId : '';
      final startDate = u.trip.hasStartDate() ? u.trip.startDate : '';
      final key = tripId.isNotEmpty
          ? 'trip:$tripId'
          : routeId.isNotEmpty
          ? 'route:$routeId:$startDate'
          : 'unknown:${unique.length}';
      if (!unique.containsKey(key)) {
        _putValue(unique, key, u);
      }
    }

    return TripUpdateAggregationResult(
      tripUpdates: unique.values.toList(),
      breakdown: breakdown,
    );
  }

  /// Get realtime status summary
  static Future<Map<TransportMode, Map<String, Object?>>>
  getRealtimeStatusSummary() async {
    // Build summary by fetching positions and updates for each broad TransportMode
    final modes = <TransportMode>[
      TransportMode.train,
      TransportMode.metro,
      TransportMode.bus,
      TransportMode.lightrail,
      TransportMode.ferry,
    ];

    final summary = <TransportMode, Map<String, Object?>>{};

    for (final mode in modes) {
      final errors = <String>[];
      FeedMessage? posFeed;
      FeedMessage? updFeed;

      try {
        posFeed = await getPositionsForTransportMode(mode);
        if (posFeed == null) {
          errors.add('Positions: no data returned');
        }
      } catch (e) {
        errors.add('Positions: ${e.toString()}');
      }

      try {
        updFeed = await getUpdatesForTransportMode(mode);
        if (updFeed == null) {
          errors.add('Updates: no data returned');
        }
      } catch (e) {
        errors.add('Updates: ${e.toString()}');
      }

      final positionCount = extractVehiclePositions(posFeed).length;
      final updateCount = extractTripUpdates(updFeed).length;

      _putValue(summary, mode, {
        'vehicles': positionCount,
        'updates': updateCount,
        'last_updated': DateTime.now().toIso8601String(),
        'errors': errors,
      });
    }

    return summary;
  }
}

class _RealtimeFeedCacheEntry<T> {
  const _RealtimeFeedCacheEntry(this.value, this.fetchedAt);

  final T value;
  final DateTime fetchedAt;
}
