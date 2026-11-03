import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/vehicle_finder/provider.dart';

import 'fixtures.dart';

VehiclePosition report({
  bool timestamp = true,
  bool coordinates = true,
  bool identity = true,
  bool motion = true,
}) => VehiclePosition(
  vehicle: identity ? VehicleDescriptor(id: 'set-1', label: 'Train 1') : null,
  trip: TripDescriptor(
    tripId: 'trip',
    startDate: '20261020',
    startTime: '12:00:00',
    routeId: 'T1',
  ),
  timestamp: timestamp ? Int64(epoch.millisecondsSinceEpoch ~/ 1000) : null,
  position: coordinates
      ? Position(
          latitude: -33.86,
          longitude: 151.2,
          speed: motion ? 10 : null,
          bearing: motion ? 90 : null,
        )
      : null,
);

void main() {
  test(
    'preserves actual observation time and missing optional motion fields',
    () {
      final snapshot = VehiclePositionAggregationResult(
        vehicles: [report(motion: false)],
        breakdown: const {},
        metadata: RealtimeSnapshotMetadata(fetchedAt: instant(30)),
      );
      final result = finderVehiclesFromSnapshot(
        TransportMode.train,
        snapshot,
      ).single;
      expect(result.observedAt, epoch);
      expect(result.speed, isNull);
      expect(result.heading, isNull);
      expect(result.id, 'set-1');
      expect(result.label, 'Train 1');
      expect(result.tripKey, contains('20261020'));
      expect(result.route, 'T1');
      expect(result.service!.tripId, 'trip');
      expect(result.service!.startDate, '20261020');
      expect(result.service!.startTime, '12:00:00');
      expect(result.service!.source, 'tfnsw:train');
    },
  );

  test(
    'ignores reports without timestamps, coordinates or vehicle identity',
    () {
      final snapshot = VehiclePositionAggregationResult(
        vehicles: [
          report(timestamp: false),
          report(coordinates: false),
          report(identity: false),
          report(),
        ],
        breakdown: const {},
      );
      expect(
        finderVehiclesFromSnapshot(TransportMode.train, snapshot),
        hasLength(1),
      );
    },
  );

  test('explains when a nonempty feed has no usable observations', () {
    expect(
      () => finderVehiclesFromSnapshot(
        TransportMode.train,
        VehiclePositionAggregationResult(
          vehicles: [report(timestamp: false)],
          breakdown: const {},
        ),
      ),
      throwsA(
        isA<VehicleFinderException>().having(
          (e) => e.message,
          'message',
          contains('no usable'),
        ),
      ),
    );
  });

  test('rejects stale fallback data and unavailable source snapshots', () {
    for (final metadata in [
      const RealtimeSnapshotMetadata(staleSources: {'trains'}),
      const RealtimeSnapshotMetadata(failedSources: {'trains'}),
    ]) {
      expect(
        () => finderVehiclesFromSnapshot(
          TransportMode.train,
          VehiclePositionAggregationResult(
            vehicles: [report()],
            breakdown: const {},
            metadata: metadata,
          ),
        ),
        throwsA(isA<VehicleFinderException>()),
      );
    }
  });
}
