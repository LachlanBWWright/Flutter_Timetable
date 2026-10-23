import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/realtime_status_banner.dart';

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
    'exact vehicle filter excludes route matches with a different vehicle id',
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
          home: RealtimeMapPage(
            showTileLayer: false,
            // A route identifier must not match a different vehicle descriptor.
            vehicleId: 'ROUTE-ABC',
            getPositions: fakeGet,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 vehicles'), findsOneWidget);
      expect(
        tester.widget<MarkerLayer>(find.byType(MarkerLayer).last).markers,
        isEmpty,
      );
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
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

  testWidgets('older map requests cannot replace a newer leg result', (
    WidgetTester tester,
  ) async {
    final first = Completer<VehiclePositionAggregationResult>();
    final second = Completer<VehiclePositionAggregationResult>();
    var calls = 0;
    Future<VehiclePositionAggregationResult> fakeGet() =>
        ++calls == 1 ? first.future : second.future;

    Widget map(Set<String> tripIds) => MaterialApp(
      home: RealtimeMapWidget(
        showTileLayer: false,
        transportMode: TransportMode.bus,
        filterByLegTrip: true,
        tripIds: tripIds,
        getAllVehiclesAggregated: fakeGet,
      ),
    );

    await tester.pumpWidget(map(const {'old-trip'}));
    await tester.pumpWidget(map(const {'new-trip'}));
    second.complete(
      VehiclePositionAggregationResult(
        vehicles: [
          buildVehicle(vehicleId: 'NEW', routeId: 'R1', tripId: 'new-trip'),
        ],
        breakdown: const {'test': 1},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 vehicles'), findsOneWidget);

    first.complete(
      const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {'test': 0},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 vehicles'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.directions_bus));
    await tester.pumpAndSettle();
    expect(find.text('NEW'), findsOneWidget);
  });

  for (final unavailable in [false, true]) {
    testWidgets('empty map keeps controls without live status banners '
        '(unavailable: $unavailable)', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: RealtimeMapPage(
            showTileLayer: false,
            filterByLegTrip: true,
            tripIds: const {'missing-trip'},
            getAllVehiclesAggregated: () async {
              calls++;
              return VehiclePositionAggregationResult(
                vehicles: const [],
                breakdown: const {},
                metadata: RealtimeSnapshotMetadata(
                  failedSources: unavailable ? const {'test'} : const {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(RealtimeStatusBanner), findsNothing);
      expect(find.textContaining('Updated '), findsNothing);
      expect(find.textContaining('No live vehicles'), findsNothing);
      expect(find.text('Live data is unavailable right now.'), findsNothing);
      expect(calls, 1);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(RealtimeStatusBanner), findsNothing);
    });
  }

  testWidgets('static route layers survive vehicle refresh rebuilds', (
    WidgetTester tester,
  ) async {
    final response = Completer<Map<TransportMode, FeedMessage?>>();
    final origin = Stop(
      id: 'O',
      name: 'Origin',
      type: 'stop',
      coord: [-33.86, 151.20],
    );
    final destination = Stop(
      id: 'D',
      name: 'Destination',
      type: 'stop',
      coord: [-33.87, 151.21],
    );
    final leg = Leg(
      origin: origin,
      destination: destination,
      stopSequence: [origin, destination],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapWidget(
          showTileLayer: false,
          leg: leg,
          transportMode: TransportMode.bus,
          getPositions: () => response.future,
        ),
      ),
    );
    final route = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    final stops = tester.widget<MarkerLayer>(find.byType(MarkerLayer).first);
    response.complete({TransportMode.bus: FeedMessage()});
    await tester.pumpAndSettle();
    final rebuiltRoute = tester.widget<PolylineLayer>(
      find.byType(PolylineLayer),
    );
    final rebuiltStops = tester.widget<MarkerLayer>(
      find.byType(MarkerLayer).first,
    );
    expect(identical(route.polylines, rebuiltRoute.polylines), isTrue);
    expect(identical(stops.markers, rebuiltStops.markers), isTrue);
  });
}
