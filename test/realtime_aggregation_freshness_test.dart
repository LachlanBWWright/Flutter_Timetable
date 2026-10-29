import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/nsw/wrappers/realtime_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('vehicle duplicates prefer the newer provider timestamp', () async {
    final result = await RealtimeService.getAllVehiclePositionsAggregated(
      getAllPositionsOverride: () async => {
        TransportMode.ferry: _feed('ferry', 'old', timestamp: 100),
      },
      getRegionBusesOverride: () async => [],
      getAllFerriesOverride: () async => [
        _feed('ferry', 'new', timestamp: 200),
      ],
      getAllLightRailOverride: () async => [],
    );
    expect(result.vehicles.single.trip.routeId, 'new');
  });

  test(
    'trip duplicates preserve a newer canonical provider timestamp',
    () async {
      final result = await RealtimeService.getAllTripUpdatesAggregated(
        getAllUpdatesOverride: () async => {
          TransportMode.ferry: _feed('ferry', 'new', timestamp: 200),
        },
        getRegionBusesOverride: () async => [],
        getAllFerriesOverride: () async => [
          _feed('ferry', 'old', timestamp: 100),
        ],
        getAllLightRailOverride: () async => [],
      );
      expect(result.tripUpdates.single.trip.routeId, 'new');
    },
  );

  test(
    'fresh grouped ferry replaces stale canonical without timestamps',
    () async {
      RealtimeService.invalidateRealtimeCache();
      var sydneyFerryRequests = 0;
      await http.runWithClient(
        () async {
          await RealtimeService.getPositionsForTransportMode(
            TransportMode.ferry,
          );
          RealtimeService.invalidateRealtimeCache();
          final result = await RealtimeService.getAllVehiclePositionsAggregated(
            getRegionBusesOverride: () async => [],
            getAllLightRailOverride: () async => [],
          );
          final ferry = result.vehicles.singleWhere(
            (v) => v.vehicle.id == 'ferry',
          );
          expect(ferry.trip.routeId, 'new');
          expect(result.metadata.isStale, isTrue);
        },
        () => MockClient((request) async {
          final isSydneyFerry = request.url.path.endsWith(
            '/ferries/sydneyferries',
          );
          if (isSydneyFerry) sydneyFerryRequests++;
          // The primed canonical feed fails its refresh; the independent ferry
          // group then succeeds for the same vehicle.
          if (isSydneyFerry && sydneyFerryRequests == 2) {
            return http.Response('', 401);
          }
          final feed = isSydneyFerry
              ? _feed('ferry', sydneyFerryRequests == 1 ? 'old' : 'new')
              : _feed(request.url.path, 'other');
          return http.Response.bytes(feed.writeToBuffer(), 200);
        }),
      );
    },
  );
}

FeedMessage _feed(String id, String version, {int? timestamp}) => FeedMessage(
  header: FeedHeader(gtfsRealtimeVersion: '2.0'),
  entity: [
    FeedEntity(
      id: id,
      vehicle: VehiclePosition(
        vehicle: VehicleDescriptor(id: id),
        trip: TripDescriptor(tripId: id, routeId: version),
        timestamp: timestamp == null ? null : Int64(timestamp),
      ),
      tripUpdate: TripUpdate(
        trip: TripDescriptor(tripId: id, routeId: version),
        timestamp: timestamp == null ? null : Int64(timestamp),
      ),
    ),
  ],
);
