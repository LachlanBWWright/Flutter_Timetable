// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';

void main() {
  VehiclePosition buildVehicle({
    required String vehicleId,
    required String routeId,
    String? tripId,
    double latitude = -33.86,
    double longitude = 151.20,
  }) {
    final vp = VehiclePosition();
    final vehicle = VehicleDescriptor();
    vehicle.id = vehicleId;
    vp.vehicle = vehicle;
    final trip = TripDescriptor();
    trip.routeId = routeId;
    if (tripId != null) {
      trip.tripId = tripId;
    }
    vp.trip = trip;
    final position = Position();
    position.latitude = latitude;
    position.longitude = longitude;
    vp.position = position;
    return vp;
  }

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

  testWidgets('RealtimeMapWidget uses selected mode for aggregated vehicles', (
    WidgetTester tester,
  ) async {
    Future<VehiclePositionAggregationResult> fakeGet() async {
      return VehiclePositionAggregationResult(
        vehicles: [buildVehicle(vehicleId: 'V1', routeId: 'R1')],
        breakdown: const <String, int>{'test': 1},
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapWidget(
          transportMode: TransportMode.bus,
          getAllVehiclesAggregated: fakeGet,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsNothing);
  });

  testWidgets('RealtimeMapWidget infers mode for aggregated route ids', (
    WidgetTester tester,
  ) async {
    Future<VehiclePositionAggregationResult> fakeGet() async {
      return VehiclePositionAggregationResult(
        vehicles: [
          buildVehicle(vehicleId: 'TRAIN', routeId: 'T1'),
          buildVehicle(
            vehicleId: 'FERRY',
            routeId: 'F3',
            latitude: -33.87,
            longitude: 151.21,
          ),
        ],
        breakdown: const <String, int>{'test': 2},
      );
    }

    await tester.pumpWidget(
      MaterialApp(home: RealtimeMapWidget(getAllVehiclesAggregated: fakeGet)),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.train), findsOneWidget);
    expect(find.byIcon(Icons.directions_boat), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsNothing);
  });

  testWidgets('RealtimeMapWidget reloads when active leg trip ids change', (
    WidgetTester tester,
  ) async {
    Future<VehiclePositionAggregationResult> fakeGet() async {
      return VehiclePositionAggregationResult(
        vehicles: [
          buildVehicle(vehicleId: 'FIRST', routeId: 'R1', tripId: 'trip-1'),
          buildVehicle(
            vehicleId: 'SECOND',
            routeId: 'R1',
            tripId: 'trip-2',
            latitude: -33.87,
            longitude: 151.21,
          ),
        ],
        breakdown: const <String, int>{'test': 2},
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapWidget(
          transportMode: TransportMode.bus,
          routeFilter: 'R1',
          filterByLegTrip: true,
          tripIds: const {'trip-1'},
          getAllVehiclesAggregated: fakeGet,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.directions_bus));
    await tester.pumpAndSettle();
    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('SECOND'), findsNothing);

    Navigator.of(tester.element(find.byType(RealtimeMapWidget))).pop();
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapWidget(
          transportMode: TransportMode.bus,
          routeFilter: 'R1',
          filterByLegTrip: true,
          tripIds: const {'trip-2'},
          getAllVehiclesAggregated: fakeGet,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.directions_bus));
    await tester.pumpAndSettle();
    expect(find.text('SECOND'), findsOneWidget);
    expect(find.text('FIRST'), findsNothing);
  });
}
