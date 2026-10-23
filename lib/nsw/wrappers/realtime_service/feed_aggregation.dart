part of '../realtime_service_impl.dart';

class _RealtimeFeedAggregation {
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
    final vehicles = <_RealtimeRecord<VehiclePosition>>[];
    final breakdown = <String, int>{};
    final metadata = _SnapshotMetadataBuilder();

    final allRequest = _loadModes(
      getAllPositionsOverride ?? RealtimeService.getAllRealtimePositions,
      metadata,
      'positions',
      custom: getAllPositionsOverride != null,
    );
    final regionRequest = _loadGroup(
      getRegionBusesOverride ?? RealtimeService.getRegionBusPositions,
      metadata,
      'positions:region_buses',
      custom: getRegionBusesOverride != null,
    );
    final ferryRequest = _loadGroup(
      getAllFerriesOverride ?? RealtimeService.getAllFerryPositions,
      metadata,
      'positions:ferries',
      custom: getAllFerriesOverride != null,
    );
    final lightRailRequest = _loadGroup(
      getAllLightRailOverride ?? RealtimeService.getAllLightRailPositions,
      metadata,
      'positions:lightrail_all',
      custom: getAllLightRailOverride != null,
    );
    final all = await allRequest;
    for (final entry in all.entries) {
      final pack = RealtimeService.extractVehiclePositions(entry.value.feed);
      vehicles.addAll(pack.map((value) => entry.value.vehicleRecord(value)));
      _incrementCount(breakdown, '${entry.key}', pack.length);
    }

    final regionBuses = await regionRequest;
    var regionCount = 0;
    for (final feed in regionBuses) {
      final pack = RealtimeService.extractVehiclePositions(feed.feed);
      regionCount += pack.length;
      vehicles.addAll(pack.map(feed.vehicleRecord));
    }
    _putValue(breakdown, 'regionBuses', regionCount);

    final allFerries = await ferryRequest;
    var ferryCount = 0;
    for (final feed in allFerries) {
      final pack = RealtimeService.extractVehiclePositions(feed.feed);
      ferryCount += pack.length;
      vehicles.addAll(pack.map(feed.vehicleRecord));
    }
    _putValue(breakdown, 'ferries', ferryCount);

    final allLightRail = await lightRailRequest;
    var lightrailCount = 0;
    for (final feed in allLightRail) {
      final pack = RealtimeService.extractVehiclePositions(feed.feed);
      lightrailCount += pack.length;
      vehicles.addAll(pack.map(feed.vehicleRecord));
    }
    _putValue(breakdown, 'lightrail', lightrailCount);

    // Deduplicate using vehicle.id > tripId > position+timestamp
    final unique = <String, _RealtimeRecord<VehiclePosition>>{};
    for (final record in vehicles) {
      final key = _vehicleRecordKey(record, unique.length);
      final existing = unique[key];
      if (existing == null || record.isNewerThan(existing)) {
        _putValue(unique, key, record);
      }
    }

    return VehiclePositionAggregationResult(
      vehicles: unique.values.map((record) => record.value).toList(),
      breakdown: breakdown,
      metadata: metadata.build(),
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
    final tripUpdates = <_RealtimeRecord<TripUpdate>>[];
    final breakdown = <String, int>{};
    final metadata = _SnapshotMetadataBuilder();

    final allRequest = _loadModes(
      getAllUpdatesOverride ?? RealtimeService.getAllRealtimeUpdates,
      metadata,
      'updates',
      custom: getAllUpdatesOverride != null,
    );
    final regionRequest = _loadGroup(
      getRegionBusesOverride ?? RealtimeService.getRegionBusUpdates,
      metadata,
      'updates:region_buses',
      custom: getRegionBusesOverride != null,
    );
    final ferryRequest = _loadGroup(
      getAllFerriesOverride ?? RealtimeService.getAllFerryUpdates,
      metadata,
      'updates:ferries',
      custom: getAllFerriesOverride != null,
    );
    final lightRailRequest = _loadGroup(
      getAllLightRailOverride ?? RealtimeService.getAllLightRailUpdates,
      metadata,
      'updates:lightrail_all',
      custom: getAllLightRailOverride != null,
    );
    final all = await allRequest;
    for (final entry in all.entries) {
      final pack = RealtimeService.extractTripUpdates(entry.value.feed);
      tripUpdates.addAll(pack.map((value) => entry.value.tripRecord(value)));
      _incrementCount(breakdown, '${entry.key}', pack.length);
    }

    final regionBuses = await regionRequest;
    var regionCount = 0;
    for (final feed in regionBuses) {
      final pack = RealtimeService.extractTripUpdates(feed.feed);
      regionCount += pack.length;
      tripUpdates.addAll(pack.map(feed.tripRecord));
    }
    _putValue(breakdown, 'regionBuses', regionCount);

    final allFerries = await ferryRequest;
    var ferryCount = 0;
    for (final feed in allFerries) {
      final pack = RealtimeService.extractTripUpdates(feed.feed);
      ferryCount += pack.length;
      tripUpdates.addAll(pack.map(feed.tripRecord));
    }
    _putValue(breakdown, 'ferries', ferryCount);

    final allLightRail = await lightRailRequest;
    var lightrailCount = 0;
    for (final feed in allLightRail) {
      final pack = RealtimeService.extractTripUpdates(feed.feed);
      lightrailCount += pack.length;
      tripUpdates.addAll(pack.map(feed.tripRecord));
    }
    _putValue(breakdown, 'lightrail', lightrailCount);

    final unique = <String, _RealtimeRecord<TripUpdate>>{};
    for (final record in tripUpdates) {
      final key = _tripRecordKey(record, unique.length);
      final existing = unique[key];
      if (existing == null || record.isNewerThan(existing)) {
        _putValue(unique, key, record);
      }
    }

    return TripUpdateAggregationResult(
      tripUpdates: unique.values.map((record) => record.value).toList(),
      breakdown: breakdown,
      metadata: metadata.build(),
    );
  }

  static Future<Map<TransportMode, _LoadedRealtimeFeed>> _loadModes(
    Future<Map<TransportMode, FeedMessage?>> Function() loader,
    _SnapshotMetadataBuilder metadata,
    String prefix, {
    required bool custom,
  }) async {
    try {
      final feeds = await loader();
      if (feeds.isEmpty) metadata.add(prefix, failed: true);
      for (final entry in feeds.entries) {
        final key = '$prefix:${entry.key.id}';
        if (custom) {
          metadata.add(
            key,
            fetchedAt: entry.value == null ? null : DateTime.now(),
            failed: entry.value == null,
          );
        } else {
          metadata.addCached(key);
        }
      }
      return feeds.map(
        (mode, feed) => MapEntry(
          mode,
          _LoadedRealtimeFeed.fromSource(feed, '$prefix:${mode.id}', 0, custom),
        ),
      );
    } catch (_) {
      metadata.add(prefix, failed: true);
      return {};
    }
  }

  static Future<List<_LoadedRealtimeFeed>> _loadGroup(
    Future<List<FeedMessage?>> Function() loader,
    _SnapshotMetadataBuilder metadata,
    String key, {
    required bool custom,
  }) async {
    try {
      final feeds = await loader();
      if (custom) {
        // Empty explicit overrides represent a successful empty group.
        if (feeds.isEmpty) metadata.add(key, fetchedAt: DateTime.now());
        for (var i = 0; i < feeds.length; i++) {
          metadata.add(
            '$key:$i',
            fetchedAt: feeds[i] == null ? null : DateTime.now(),
            failed: feeds[i] == null,
          );
        }
      } else {
        metadata.addCached(key);
      }
      return [
        for (var i = 0; i < feeds.length; i++)
          _LoadedRealtimeFeed.fromSource(feeds[i], key, i, custom),
      ];
    } catch (_) {
      metadata.add(key, failed: true);
      return [];
    }
  }
}
