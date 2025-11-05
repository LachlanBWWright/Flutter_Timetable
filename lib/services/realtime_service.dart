import '../constants/transport_modes.dart';
import '../fetch_data/realtime_positions.dart' as positions;
import '../fetch_data/realtime_updates.dart' as updates;
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

/// Service for managing realtime transport data
class RealtimeService {
  /// Get realtime positions for all broad transport modes.
  ///
  /// Returns a map keyed by [TransportMode] (the broad mode) with the
  /// corresponding canonical feed [FeedMessage] where available. This
  /// intentionally uses the enum as the key instead of string feed keys so
  /// callers can rely on typed mode values.
  static Future<Map<TransportMode, FeedMessage?>>
      getAllRealtimePositions() async {
    final results = <TransportMode, FeedMessage?>{};

    // Use the typed wrappers which map a broad TransportMode to a
    // canonical feed key and fetch function.
    results[TransportMode.train] =
        await getPositionsForTransportMode(TransportMode.train);
    results[TransportMode.metro] =
        await getPositionsForTransportMode(TransportMode.metro);
    results[TransportMode.bus] =
        await getPositionsForTransportMode(TransportMode.bus);
    results[TransportMode.lightrail] =
        await getPositionsForTransportMode(TransportMode.lightrail);
    results[TransportMode.ferry] =
        await getPositionsForTransportMode(TransportMode.ferry);

    return results;
  }

  /// Get realtime trip updates for all broad transport modes.
  ///
  /// Returns a map keyed by [TransportMode] with the canonical feed
  /// [FeedMessage] for each broad mode.
  static Future<Map<TransportMode, FeedMessage?>>
      getAllRealtimeUpdates() async {
    final results = <TransportMode, FeedMessage?>{};

    results[TransportMode.train] =
        await getUpdatesForTransportMode(TransportMode.train);
    results[TransportMode.metro] =
        await getUpdatesForTransportMode(TransportMode.metro);
    results[TransportMode.bus] =
        await getUpdatesForTransportMode(TransportMode.bus);
    results[TransportMode.lightrail] =
        await getUpdatesForTransportMode(TransportMode.lightrail);
    results[TransportMode.ferry] =
        await getUpdatesForTransportMode(TransportMode.ferry);

    return results;
  }

  /// Typed wrapper: get positions for a broad TransportMode. This maps the
  /// enum to a sensible canonical feed key and delegates to the existing
  /// string-based API to preserve existing feed selection logic.
  static Future<FeedMessage?> getPositionsForTransportMode(
      TransportMode mode) async {
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
  }

  /// Typed wrapper: get trip updates for a broad TransportMode.
  static Future<FeedMessage?> getUpdatesForTransportMode(
      TransportMode mode) async {
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
  }

  /// Get region bus positions
  static Future<List<FeedMessage?>> getRegionBusPositions() async {
    return await positions.getAllRegionBuses();
  }

  /// Get region bus updates
  static Future<List<FeedMessage?>> getRegionBusUpdates() async {
    return await updates.fetchAllRegionBuses();
  }

  /// Get all ferry positions
  static Future<List<FeedMessage?>> getAllFerryPositions() async {
    return await positions.getAllFerries();
  }

  /// Get all ferry updates
  static Future<List<FeedMessage?>> getAllFerryUpdates() async {
    return await updates.fetchAllFerries();
  }

  /// Get all light rail positions
  static Future<List<FeedMessage?>> getAllLightRailPositions() async {
    return await positions.getAllLightRail();
  }

  /// Get all light rail updates
  static Future<List<FeedMessage?>> getAllLightRailUpdates() async {
    return await updates.fetchAllLightRail();
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

  /// Get realtime status summary
  static Future<Map<TransportMode, Map<String, dynamic>>>
      getRealtimeStatusSummary() async {
    // Build summary by fetching positions and updates for each broad TransportMode
    final modes = <TransportMode>[
      TransportMode.train,
      TransportMode.metro,
      TransportMode.bus,
      TransportMode.lightrail,
      TransportMode.ferry,
    ];

    final summary = <TransportMode, Map<String, dynamic>>{};

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

      summary[mode] = {
        'vehicles': positionCount,
        'updates': updateCount,
        'last_updated': DateTime.now().toIso8601String(),
        'errors': errors,
      };
    }

    return summary;
  }
}
