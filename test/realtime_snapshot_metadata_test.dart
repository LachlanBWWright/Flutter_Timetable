import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/nsw/wrappers/realtime_service_impl.dart';

void main() {
  test(
    'valid empty feeds remain available with a successful timestamp',
    () async {
      final result = await RealtimeService.getAllVehiclePositionsAggregated(
        getAllPositionsOverride: () async => {TransportMode.bus: FeedMessage()},
        getRegionBusesOverride: () async => [],
        getAllFerriesOverride: () async => [],
        getAllLightRailOverride: () async => [],
      );
      expect(result.vehicles, isEmpty);
      expect(result.metadata.fetchedAt, isNotNull);
      expect(result.metadata.isUnavailable, isFalse);
      expect(result.metadata.failedSources, isEmpty);
    },
  );

  test(
    'failed sources distinguish unavailable and partial live results',
    () async {
      Future<List<FeedMessage?>> failedGroup() async =>
          throw StateError('offline');
      final unavailable = await RealtimeService.getAllTripUpdatesAggregated(
        getAllUpdatesOverride: () async => throw StateError('offline'),
        getRegionBusesOverride: failedGroup,
        getAllFerriesOverride: failedGroup,
        getAllLightRailOverride: failedGroup,
      );
      expect(unavailable.metadata.isUnavailable, isTrue);
      expect(unavailable.metadata.isPartial, isFalse);
      expect(unavailable.metadata.fetchedAt, isNull);
      final partial = await RealtimeService.getAllTripUpdatesAggregated(
        getAllUpdatesOverride: () async => {TransportMode.train: FeedMessage()},
        getRegionBusesOverride: failedGroup,
        getAllFerriesOverride: failedGroup,
        getAllLightRailOverride: failedGroup,
      );
      expect(partial.metadata.isPartial, isTrue);
      expect(partial.metadata.failedSources.length, 3);
      expect(partial.metadata.isUnavailable, isFalse);
    },
  );
}
