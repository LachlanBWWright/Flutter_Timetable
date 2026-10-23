import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';

void main() {
  test('trip IDs on different service dates remain distinct', () async {
    final updates = await _aggregateUpdates([
      _trip(date: '20261015'),
      _trip(date: '20261016'),
    ]);
    expect(updates, hasLength(2));
    expect(
      updates.map((update) => update.trip.startDate),
      unorderedEquals(['20261015', '20261016']),
    );
  });

  test(
    'missing trip IDs retain separate departures on the same route',
    () async {
      final updates = await _aggregateUpdates([
        _trip(id: '', time: '08:00:00'),
        _trip(id: '', time: '09:00:00'),
        _trip(id: '', time: '08:00:00', timestamp: 200),
      ]);
      expect(updates, hasLength(2));
      expect(
        updates.map((update) => update.trip.startTime),
        unorderedEquals(['08:00:00', '09:00:00']),
      );
      expect(
        updates
            .singleWhere((update) => update.trip.startTime == '08:00:00')
            .timestamp,
        Int64(200),
      );
    },
  );

  test('exact service instances deduplicate to the newest update', () async {
    final updates = await _aggregateUpdates([
      _trip(timestamp: 200),
      _trip(timestamp: 100),
    ]);
    expect(updates, hasLength(1));
    expect(updates.single.timestamp, Int64(200));
  });

  test('incomplete missing-ID descriptors are not collapsed', () async {
    final updates = await _aggregateUpdates([
      _trip(id: '', time: ''),
      _trip(id: '', time: ''),
    ]);
    expect(updates, hasLength(2));
  });

  test('vehicles without IDs retain separate service instances', () async {
    final feed = FeedMessage(
      header: FeedHeader(gtfsRealtimeVersion: '2.0'),
      entity: [
        for (final (index, trip) in [
          _trip(date: '20261015'),
          _trip(date: '20261016'),
          _trip(date: '20261016', time: '09:00:00'),
        ].indexed)
          FeedEntity(
            id: 'vehicle-$index',
            vehicle: VehiclePosition(trip: trip.trip),
          ),
      ],
    );
    final result = await RealtimeService.getAllVehiclePositionsAggregated(
      getAllPositionsOverride: () async => {TransportMode.train: feed},
      getRegionBusesOverride: () async => [],
      getAllFerriesOverride: () async => [],
      getAllLightRailOverride: () async => [],
    );
    expect(result.vehicles, hasLength(3));
    expect(
      result.vehicles.map(
        (vehicle) => (vehicle.trip.startDate, vehicle.trip.startTime),
      ),
      unorderedEquals([
        ('20261015', '08:00:00'),
        ('20261016', '08:00:00'),
        ('20261016', '09:00:00'),
      ]),
    );
  });
}

TripUpdate _trip({
  String id = 'trip-1',
  String date = '20261015',
  String time = '08:00:00',
  int timestamp = 100,
}) => TripUpdate(
  trip: TripDescriptor(
    tripId: id,
    routeId: 'route-1',
    startDate: date,
    startTime: time,
  ),
  timestamp: Int64(timestamp),
);

Future<List<TripUpdate>> _aggregateUpdates(List<TripUpdate> updates) async {
  final result = await RealtimeService.getAllTripUpdatesAggregated(
    getAllUpdatesOverride: () async => {
      TransportMode.train: FeedMessage(
        header: FeedHeader(gtfsRealtimeVersion: '2.0'),
        entity: [
          for (final (index, update) in updates.indexed)
            FeedEntity(id: 'update-$index', tripUpdate: update),
        ],
      ),
    },
    getRegionBusesOverride: () async => [],
    getAllFerriesOverride: () async => [],
    getAllLightRailOverride: () async => [],
  );
  return result.tripUpdates;
}
