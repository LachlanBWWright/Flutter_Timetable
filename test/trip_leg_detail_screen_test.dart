import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/swagger_generated/trip_planner.enums.swagger.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';

void main() {
  testWidgets('TripLegDetailScreen hides map button when transport id missing',
      (tester) async {
    const leg = Leg(
      origin: Stop(
        id: 'O1',
        name: 'Origin',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.0, 0.0],
      ),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.1, 0.1],
      ),
      transportation: null,
    );

    await tester.pumpWidget(MaterialApp(
        home: TripLegDetailScreen(
            leg: leg,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
                  'vehicles': <VehiclePosition>[],
                  'breakdown': <String, int>{}
                })));

    // Use pump instead of pumpAndSettle to avoid long frame settle with large debug text
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Map icon shouldn't be present
    expect(find.byIcon(Icons.map), findsNothing);
  });

  testWidgets('TripLegDetailScreen shows map button when transport id present',
      (tester) async {
    const transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    const leg = Leg(
      origin: Stop(
        id: 'O1',
        name: 'Origin',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.0, 0.0],
      ),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
    );

    await tester.pumpWidget(MaterialApp(
        home: TripLegDetailScreen(
            leg: leg,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
                  'vehicles': <VehiclePosition>[],
                  'breakdown': <String, int>{}
                })));

    // Use small pump increments to avoid long frame settle with large debug text
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.map), findsOneWidget);
  });

  testWidgets('Trip debug card displayed when TripJourney passed',
      (tester) async {
    const transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    const leg = Leg(
      origin: Stop(
        id: 'O1',
        name: 'Origin',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.0, 0.0],
      ),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
    );
    const trip = TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 7,
    );

    await tester.pumpWidget(MaterialApp(
        home: TripLegDetailScreen(
            leg: leg,
            trip: trip,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
                  'vehicles': <VehiclePosition>[],
                  'breakdown': <String, int>{}
                })));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Trip debug data'), findsOneWidget);
    expect(find.textContaining('rating:'), findsOneWidget);
    // Now that trip debug prints legs in full, ensure we see a leg detail in output
    // Use a more unique string to avoid matching other 'Origin' labels
    expect(find.textContaining('--- Leg 1 ---'), findsOneWidget);

    // Verify that raw JSON is printed and includes our custom field
    expect(find.textContaining('customValue'), findsOneWidget);
  });

/*   testWidgets('Trip detail screen shows nested raw JSON for leg and origin',
      (tester) async {
    final file = File('lib/trip_leg_raw_json.json');
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final trip = TripJourney.fromJson(data);
    final leg = trip.legs.first;

    await tester.pumpWidget(MaterialApp(
        home: TripLegDetailScreen(
            leg: leg,
            trip: trip,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
                  'vehicles': <VehiclePosition>[],
                  'breakdown': <String, int>{}
                })));
    await tester.pump(const Duration(seconds: 2));

    // Should include headers for Raw JSON blocks and RealtimeTripId
    expect(find.textContaining('Raw leg JSON:'), findsOneWidget);
    expect(find.textContaining('Origin raw JSON:'), findsOneWidget);
    expect(find.textContaining('RealtimeTripId'), findsOneWidget);
  }); */

  testWidgets('TripLegDetailScreen respects DebugService.showDebugData toggle',
      (tester) async {
    const transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    const leg = Leg(
      origin: Stop(
        id: 'O1',
        name: 'Origin',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.0, 0.0],
      ),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: TripRequestResponseJourneyLegStopType.stop,
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
    );
    const trip = TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 5,
    );

    // Hide debug data first
    DebugService.showDebugData.value = false;
    await tester.pumpWidget(MaterialApp(
        home: TripLegDetailScreen(
            leg: leg,
            trip: trip,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
                  'vehicles': <VehiclePosition>[],
                  'breakdown': <String, int>{}
                })));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should not show trip debug card when disabled
    expect(find.text('Trip debug data'), findsNothing);

    // Now toggle the debug flag to true and rebuild
    DebugService.showDebugData.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Trip debug data'), findsOneWidget);
  });
}
