import '../../constants/transport_modes.dart';
import '../fetch_data/realtime_positions.dart' as positions;
import '../fetch_data/realtime_updates.dart' as updates;
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'realtime_service/snapshot_cache.dart';

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
  /// Retry expired feeds while retaining the last successful fallback.
  static void invalidateRealtimeCache() {
    _RealtimeFeedCache.cache.invalidate();
    _lastAggregatePrefetchAt = null;
  }

  static RealtimeSnapshotMetadata metadataForVehicleModes(
    Iterable<TransportMode> modes,
  ) {
    final builder = _SnapshotMetadataBuilder();
    for (final mode in modes) {
      builder.addCached('positions:${mode.id}');
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
  getVehiclePositionsForModeSafe(TransportMode mode) =>
      _LegFeedAggregation.getVehiclePositionsForModeSafe(mode);

  /// Load only the aggregate sources belonging to one transport mode.
  static Future<TripUpdateAggregationResult> getTripUpdatesForModeSafe(
    TransportMode mode,
  ) => _LegFeedAggregation.getTripUpdatesForModeSafe(mode);

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
    TransportMode mode,
  ) async {
    return _RealtimeFeedCache.getFeed('positions:${mode.id}', () async {
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
    return _RealtimeFeedCache.getFeed('updates:${mode.id}', () async {
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
    return _RealtimeFeedCache.getFeedList(
      'positions:region_buses',
      positions.getAllRegionBuses,
    );
  }

  /// Get region bus updates
  static Future<List<FeedMessage?>> getRegionBusUpdates() async {
    return _RealtimeFeedCache.getFeedList(
      'updates:region_buses',
      updates.fetchAllRegionBuses,
    );
  }

  /// Get all ferry positions
  static Future<List<FeedMessage?>> getAllFerryPositions() async {
    return _RealtimeFeedCache.getFeedList(
      'positions:ferries',
      positions.getAllFerries,
    );
  }

  /// Get all ferry updates
  static Future<List<FeedMessage?>> getAllFerryUpdates() async {
    return _RealtimeFeedCache.getFeedList(
      'updates:ferries',
      updates.fetchAllFerries,
    );
  }

  /// Get all light rail positions
  static Future<List<FeedMessage?>> getAllLightRailPositions() async {
    return _RealtimeFeedCache.getFeedList(
      'positions:lightrail_all',
      positions.getAllLightRail,
    );
  }

  /// Get all light rail updates
  static Future<List<FeedMessage?>> getAllLightRailUpdates() async {
    return _RealtimeFeedCache.getFeedList(
      'updates:lightrail_all',
      updates.fetchAllLightRail,
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
