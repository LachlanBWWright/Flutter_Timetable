import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

void main() {
  testWidgets('RealtimeMapWidget shows matching vehicle by vehicle id', (
    WidgetTester tester,
  ) async {
    // Build fake feed: one vehicle with vehicle.id 'V1' and routeId 'R1'
    final feed = FeedMessage();
    final entity = FeedEntity();
    final vp = VehiclePosition();
    final vehicle = VehicleDescriptor();
    vehicle.id = 'V1';
    vp.vehicle = vehicle;
    final trip = TripDescriptor();
    trip.routeId = 'R1';
    vp.trip = trip;
    final position = Position();
    position.latitude = -33.86;
    position.longitude = 151.20;
    vp.position = position;
    entity.vehicle = vp;
    feed.entity.add(entity);

    Future<Map<TransportMode, FeedMessage?>> fakeGet() async {
      return {TransportMode.bus: feed};
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapWidget(vehicleId: 'V1', getPositions: fakeGet),
      ),
    );

    // Wait for async load
    await tester.pumpAndSettle();

    // Should show overlay with 1 vehicle
    expect(find.textContaining('vehicles'), findsOneWidget);
    expect(find.text('1 vehicles'), findsOneWidget);
  });

  testWidgets(
    'RealtimeMapWidget falls back to route id when vehicle id missing',
    (WidgetTester tester) async {
      final feed = FeedMessage();
      final entity = FeedEntity();
      final vp = VehiclePosition();
      final vehicle = VehicleDescriptor();
      vehicle.id = 'OTHER';
      vp.vehicle = vehicle;
      final trip = TripDescriptor();
      trip.routeId = 'ROUTE-ABC';
      vp.trip = trip;
      final position = Position();
      position.latitude = -33.86;
      position.longitude = 151.20;
      vp.position = position;
      entity.vehicle = vp;
      feed.entity.add(entity);

      Future<Map<TransportMode, FeedMessage?>> fakeGet() async {
        return {TransportMode.bus: feed};
      }

      await tester.pumpWidget(
        MaterialApp(
          home: RealtimeMapWidget(
            // asking for a vehicle id that doesn't match vehicle descriptor
            vehicleId: 'ROUTE-ABC',
            getPositions: fakeGet,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1 vehicles'), findsOneWidget);
    },
  );
}
