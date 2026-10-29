import '../../constants/transport_modes.dart';
import '../../transit/cache/realtime_query.dart';
import '../../transit/cache/shared_transit_cache.dart';
import '../fetch_data/realtime_feed_fetcher.dart' show sharedFeedFetchedAt;
import '../fetch_data/realtime_positions.dart' as positions;
import '../fetch_data/realtime_updates.dart' as updates;
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'realtime_service/snapshot_cache.dart';

export '../../transit/cache/realtime_query.dart';

part 'realtime_service/aggregation_results.dart';
part 'realtime_service/feed_aggregation.dart';
part 'realtime_service/leg_feed_aggregation.dart';
part 'realtime_service/record_freshness.dart';
part 'realtime_service/record_identity.dart';
part 'realtime_service/feed_cache.dart';
part 'realtime_service/safe_collections.dart';
part 'realtime_service/snapshot_metadata.dart';

/// Service for managing realtime transport data
class RealtimeService {
  static bool get usesSharedCache => SharedTransitCache.instance.isConfigured;

  /// Retry expired feeds while retaining the last successful fallback.
  static void invalidateRealtimeCache() {
    _RealtimeFeedCache.cache.invalidate();
    SharedTransitCache.instance.invalidate();
    _lastAggregatePrefetchAt = null;
  }

  static RealtimeSnapshotMetadata metadataForVehicleModes(
    Iterable<TransportMode> modes, {
    RealtimeQuery? query,
  }) {
    final builder = _SnapshotMetadataBuilder();
    for (final mode in modes) {
      builder.addCached(_RealtimeFeedCache.key('positions:${mode.id}', query));
    }
    return builder.build();
  }

  static const Duration _aggregatePrefetchCooldown = Duration(seconds: 30);
  static DateTime? _lastAggregatePrefetchAt;
  static Future<void>? _inflightAggregatePrefetch;

  /// Warm critical realtime datasets before the user opens detail actions.
  ///
  /// This is intentionally throttled because feeds are network-heavy.
  static Future<void> prefetchAggregates({
    bool includeVehicles = true,
    bool includeTripUpdates = true,
  }) async {
    if (SharedTransitCache.instance.isConfigured) return;
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

    await Future.wait(
      modes.map((mode) async {
        final feed = await _loadOrFallback<FeedMessage?>(
          () => getPositionsForTransportMode(mode),
          null,
        );
        _putValue(results, mode, feed);
      }),
    );

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
        metadata: RealtimeSnapshotMetadata(failedSources: {'realtime'}),
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
        metadata: RealtimeSnapshotMetadata(failedSources: {'realtime'}),
      );
    }
  }

  /// Load only the aggregate sources belonging to one transport mode.
  static Future<VehiclePositionAggregationResult>
  getVehiclePositionsForModeSafe(TransportMode mode, {RealtimeQuery? query}) =>
      _LegFeedAggregation.getVehiclePositionsForModeSafe(mode, query: query);

  /// Load only the aggregate sources belonging to one transport mode.
  static Future<TripUpdateAggregationResult> getTripUpdatesForModeSafe(
    TransportMode mode, {
    RealtimeQuery? query,
  }) => _LegFeedAggregation.getTripUpdatesForModeSafe(mode, query: query);

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

    await Future.wait(
      modes.map((mode) async {
        final feed = await _loadOrFallback<FeedMessage?>(
          () => getUpdatesForTransportMode(mode),
          null,
        );
        _putValue(results, mode, feed);
      }),
    );

    return results;
  }

  /// Typed wrapper: get positions for a broad TransportMode. This maps the
  /// enum to a sensible canonical feed key and delegates to the existing
  /// string-based API to preserve existing feed selection logic.
  static Future<FeedMessage?> getPositionsForTransportMode(
    TransportMode mode, {
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeed(
      _RealtimeFeedCache.key('positions:${mode.id}', query),
      () async {
        switch (mode) {
          case TransportMode.train:
            return await positions.fetchSydneyTrainsPositions(query: query);
          case TransportMode.metro:
            return await positions.fetchSydneyMetroPositions(query: query);
          case TransportMode.bus:
            return await positions.fetchBusesPositions(query: query);
          case TransportMode.lightrail:
            return await positions.fetchLightRailCbdAndSoutheastPositions(
              query: query,
            );
          case TransportMode.ferry:
            return await positions.fetchFerriesSydneyFerriesPositions(
              query: query,
            );
        }
      },
    );
  }

  /// Typed wrapper: get trip updates for a broad TransportMode.
  static Future<FeedMessage?> getUpdatesForTransportMode(
    TransportMode mode, {
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeed(
      _RealtimeFeedCache.key('updates:${mode.id}', query),
      () async {
        switch (mode) {
          case TransportMode.train:
            return await updates.fetchSydneyTrainsUpdates(query: query);
          case TransportMode.metro:
            return await updates.fetchSydneyMetroUpdates(query: query);
          case TransportMode.bus:
            return await updates.fetchBusesUpdates(query: query);
          case TransportMode.lightrail:
            return await updates.fetchLightRailCbdAndSoutheastUpdates(
              query: query,
            );
          case TransportMode.ferry:
            return await updates.fetchFerriesSydneyFerriesUpdates(query: query);
        }
      },
    );
  }

  /// Get region bus positions
  static Future<List<FeedMessage?>> getRegionBusPositions({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('positions:region_buses', query),
      () => positions.getAllRegionBuses(query: query),
    );
  }

  /// Get region bus updates
  static Future<List<FeedMessage?>> getRegionBusUpdates({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('updates:region_buses', query),
      () => updates.fetchAllRegionBuses(query: query),
    );
  }

  /// Get all ferry positions
  static Future<List<FeedMessage?>> getAllFerryPositions({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('positions:ferries', query),
      () => positions.getAllFerries(query: query),
    );
  }

  /// Get all ferry updates
  static Future<List<FeedMessage?>> getAllFerryUpdates({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('updates:ferries', query),
      () => updates.fetchAllFerries(query: query),
    );
  }

  /// Get all light rail positions
  static Future<List<FeedMessage?>> getAllLightRailPositions({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('positions:lightrail_all', query),
      () => positions.getAllLightRail(query: query),
    );
  }

  /// Get all light rail updates
  static Future<List<FeedMessage?>> getAllLightRailUpdates({
    RealtimeQuery? query,
  }) async {
    return _RealtimeFeedCache.getFeedList(
      _RealtimeFeedCache.key('updates:lightrail_all', query),
      () => updates.fetchAllLightRail(query: query),
    );
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

  /// Aggregate vehicle feeds while preserving source counts and deduplication.
  static Future<VehiclePositionAggregationResult>
  getAllVehiclePositionsAggregated({
    Future<Map<TransportMode, FeedMessage?>> Function()?
    getAllPositionsOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) => _RealtimeFeedAggregation.getAllVehiclePositionsAggregated(
    getAllPositionsOverride: getAllPositionsOverride,
    getRegionBusesOverride: getRegionBusesOverride,
    getAllFerriesOverride: getAllFerriesOverride,
    getAllLightRailOverride: getAllLightRailOverride,
  );

  /// Aggregate trip update feeds while preserving source counts and deduplication.
  static Future<TripUpdateAggregationResult> getAllTripUpdatesAggregated({
    Future<Map<TransportMode, FeedMessage?>> Function()? getAllUpdatesOverride,
    Future<List<FeedMessage?>> Function()? getRegionBusesOverride,
    Future<List<FeedMessage?>> Function()? getAllFerriesOverride,
    Future<List<FeedMessage?>> Function()? getAllLightRailOverride,
  }) => _RealtimeFeedAggregation.getAllTripUpdatesAggregated(
    getAllUpdatesOverride: getAllUpdatesOverride,
    getRegionBusesOverride: getRegionBusesOverride,
    getAllFerriesOverride: getAllFerriesOverride,
    getAllLightRailOverride: getAllLightRailOverride,
  );

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

      final metadataBuilder = _SnapshotMetadataBuilder()
        ..addCached('positions:${mode.id}')
        ..addCached('updates:${mode.id}');
      final metadata = metadataBuilder.build();
      if (metadata.failedSources.isNotEmpty) {
        errors.add('Some live feeds could not be refreshed');
      }
      _putValue(summary, mode, {
        'vehicles': positionCount,
        'updates': updateCount,
        'last_updated': metadata.fetchedAt?.toIso8601String(),
        'is_stale': metadata.isStale,
        'is_unavailable': metadata.isUnavailable,
        'errors': errors,
      });
    }

    return summary;
  }
}
