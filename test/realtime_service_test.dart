import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';

void main() {
  test('getAllVehiclePositionsAggregated deduplicates across feeds', () async {
    // Build FeedMessage for bus with vehicle id V1
    final feedBus = FeedMessage();
    final eBus = FeedEntity();
    final vpBus = VehiclePosition();
    final vehicleBus = VehicleDescriptor();
    vehicleBus.id = 'V1';
    vpBus.vehicle = vehicleBus;
    final tripBus = TripDescriptor();
    tripBus.routeId = 'R1';
    vpBus.trip = tripBus;
    final p = Position();
    p.latitude = -33.86;
    p.longitude = 151.20;
    vpBus.position = p;
    eBus.vehicle = vpBus;
    feedBus.entity.add(eBus);

    // Build FeedMessage for region buses with same vehicle id V1
    final feedRegion = FeedMessage();
    final eReg = FeedEntity();
    final vpReg = VehiclePosition();
    final vehicleReg = VehicleDescriptor();
    vehicleReg.id = 'V1';
    vpReg.vehicle = vehicleReg;
    final tripReg = TripDescriptor();
    tripReg.routeId = 'R1';
    vpReg.trip = tripReg;
    final p2 = Position();
    p2.latitude = -33.860001;
    p2.longitude = 151.20005;
    vpReg.position = p2;
    eReg.vehicle = vpReg;
    feedRegion.entity.add(eReg);

    // Build an independent vehicle V2
    final feedOther = FeedMessage();
    final eO = FeedEntity();
    final vpO = VehiclePosition();
    final vehicleO = VehicleDescriptor();
    vehicleO.id = 'V2';
    vpO.vehicle = vehicleO;
    final tripO = TripDescriptor();
    tripO.routeId = 'R2';
    vpO.trip = tripO;
    final p3 = Position();
    p3.latitude = -33.86;
    p3.longitude = 151.21;
    vpO.position = p3;
    eO.vehicle = vpO;
    feedOther.entity.add(eO);

    Future<Map<TransportMode, FeedMessage?>> getAllPositionsOverride() async =>
        {TransportMode.bus: feedBus};
    Future<List<FeedMessage?>> getRegionBusesOverride() async =>
        [feedRegion, null];
    Future<List<FeedMessage?>> getAllFerriesOverride() async => <FeedMessage?>[];
    Future<List<FeedMessage?>> getAllLightRailOverride() async =>
        <FeedMessage?>[feedOther];

    final result = await RealtimeService.getAllVehiclePositionsAggregated(
      getAllPositionsOverride: getAllPositionsOverride,
      getRegionBusesOverride: getRegionBusesOverride,
      getAllFerriesOverride: getAllFerriesOverride,
      getAllLightRailOverride: getAllLightRailOverride,
    );

    final vehicles = result.vehicles;
    final breakdown = result.breakdown;

    // Vehicles should include V1 once (deduped) and V2
    final ids = vehicles
        .map((v) => v.vehicle.hasId() ? v.vehicle.id : null)
        .whereType<String>()
        .toList();
    expect(ids, contains('V1'));
    expect(ids, contains('V2'));
    expect(ids.length, 2);

    // Breakdown should include bus (1), regionBuses (1), lightrail or similar depending on our inputs
    expect(breakdown['TransportMode.bus'] ?? breakdown['TransportMode.bus'], 1);
    expect(breakdown['regionBuses'], 1);
    expect(breakdown['lightrail'], 1);
  });
}
