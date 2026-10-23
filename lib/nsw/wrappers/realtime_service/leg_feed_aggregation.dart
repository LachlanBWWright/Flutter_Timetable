part of '../realtime_service_impl.dart';

/// Builds trip-leg snapshots from only the selected mode's feeds.
class _LegFeedAggregation {
  static Future<VehiclePositionAggregationResult>
  getVehiclePositionsForModeSafe(TransportMode mode) async {
    try {
      final metadata = _SnapshotMetadataBuilder();
      final breakdown = <String, int>{};
      final records = <_RealtimeRecord<VehiclePosition>>[];
      final baseRequest = _RealtimeFeedAggregation._loadModes(
        () async => {
          mode: await RealtimeService.getPositionsForTransportMode(mode),
        },
        metadata,
        'positions',
        custom: false,
      );
      final groupRequest = _loadPositionGroup(mode, metadata);
      final base = await baseRequest;
      for (final entry in base.entries) {
        final values = RealtimeService.extractVehiclePositions(
          entry.value.feed,
        );
        records.addAll(values.map(entry.value.vehicleRecord));
        _incrementCount(breakdown, '${entry.key}', values.length);
      }
      var groupCount = 0;
      for (final feed in await groupRequest) {
        final values = RealtimeService.extractVehiclePositions(feed.feed);
        groupCount += values.length;
        records.addAll(values.map(feed.vehicleRecord));
      }
      if (mode == TransportMode.bus) {
        _putValue(breakdown, 'regionBuses', groupCount);
      }
      if (mode == TransportMode.ferry) {
        _putValue(breakdown, 'ferries', groupCount);
      }
      if (mode == TransportMode.lightrail) {
        _putValue(breakdown, 'lightrail', groupCount);
      }
      final unique = <String, _RealtimeRecord<VehiclePosition>>{};
      for (final record in records) {
        final key = _vehicleRecordKey(record, unique.length);
        final previous = unique[key];
        if (previous == null || record.isNewerThan(previous)) {
          _putValue(unique, key, record);
        }
      }
      return VehiclePositionAggregationResult(
        vehicles: unique.values.map((record) => record.value).toList(),
        breakdown: breakdown,
        metadata: metadata.build(),
      );
    } catch (_) {
      return const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {},
        metadata: RealtimeSnapshotMetadata(failedSources: {'realtime'}),
      );
    }
  }

  static Future<TripUpdateAggregationResult> getTripUpdatesForModeSafe(
    TransportMode mode,
  ) async {
    try {
      final metadata = _SnapshotMetadataBuilder();
      final breakdown = <String, int>{};
      final records = <_RealtimeRecord<TripUpdate>>[];
      final baseRequest = _RealtimeFeedAggregation._loadModes(
        () async => {
          mode: await RealtimeService.getUpdatesForTransportMode(mode),
        },
        metadata,
        'updates',
        custom: false,
      );
      final groupRequest = _loadUpdateGroup(mode, metadata);
      final base = await baseRequest;
      for (final entry in base.entries) {
        final values = RealtimeService.extractTripUpdates(entry.value.feed);
        records.addAll(values.map(entry.value.tripRecord));
        _incrementCount(breakdown, '${entry.key}', values.length);
      }
      var groupCount = 0;
      for (final feed in await groupRequest) {
        final values = RealtimeService.extractTripUpdates(feed.feed);
        groupCount += values.length;
        records.addAll(values.map(feed.tripRecord));
      }
      if (mode == TransportMode.bus) {
        _putValue(breakdown, 'regionBuses', groupCount);
      }
      if (mode == TransportMode.ferry) {
        _putValue(breakdown, 'ferries', groupCount);
      }
      if (mode == TransportMode.lightrail) {
        _putValue(breakdown, 'lightrail', groupCount);
      }
      final unique = <String, _RealtimeRecord<TripUpdate>>{};
      for (final record in records) {
        final key = _tripRecordKey(record, unique.length);
        final previous = unique[key];
        if (previous == null || record.isNewerThan(previous)) {
          _putValue(unique, key, record);
        }
      }
      return TripUpdateAggregationResult(
        tripUpdates: unique.values.map((record) => record.value).toList(),
        breakdown: breakdown,
        metadata: metadata.build(),
      );
    } catch (_) {
      return const TripUpdateAggregationResult(
        tripUpdates: [],
        breakdown: {},
        metadata: RealtimeSnapshotMetadata(failedSources: {'realtime'}),
      );
    }
  }

  static Future<List<_LoadedRealtimeFeed>> _loadPositionGroup(
    TransportMode mode,
    _SnapshotMetadataBuilder metadata,
  ) {
    switch (mode) {
      case TransportMode.bus:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getRegionBusPositions,
          metadata,
          'positions:region_buses',
          custom: false,
        );
      case TransportMode.ferry:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getAllFerryPositions,
          metadata,
          'positions:ferries',
          custom: false,
        );
      case TransportMode.lightrail:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getAllLightRailPositions,
          metadata,
          'positions:lightrail_all',
          custom: false,
        );
      case TransportMode.train:
      case TransportMode.metro:
        return Future.value(const <_LoadedRealtimeFeed>[]);
    }
  }

  static Future<List<_LoadedRealtimeFeed>> _loadUpdateGroup(
    TransportMode mode,
    _SnapshotMetadataBuilder metadata,
  ) {
    switch (mode) {
      case TransportMode.bus:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getRegionBusUpdates,
          metadata,
          'updates:region_buses',
          custom: false,
        );
      case TransportMode.ferry:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getAllFerryUpdates,
          metadata,
          'updates:ferries',
          custom: false,
        );
      case TransportMode.lightrail:
        return _RealtimeFeedAggregation._loadGroup(
          RealtimeService.getAllLightRailUpdates,
          metadata,
          'updates:lightrail_all',
          custom: false,
        );
      case TransportMode.train:
      case TransportMode.metro:
        return Future.value(const <_LoadedRealtimeFeed>[]);
    }
  }
}
