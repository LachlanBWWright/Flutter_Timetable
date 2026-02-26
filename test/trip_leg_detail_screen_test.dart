import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';

void main() {
  testWidgets('TripLegDetailScreen hides map button when transport id missing', (
    tester,
  ) async {
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: 'stop',
        coord: [0.1, 0.1],
      ),
      transportation: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async => {
            'vehicles': <VehiclePosition>[],
            'breakdown': <String, int>{},
          },
        ),
      ),
    );

    // Use pump instead of pumpAndSettle to avoid long frame settle with large debug text
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Map icon shouldn't be present
    expect(find.byIcon(Icons.map), findsNothing);
  });

  testWidgets('TripLegDetailScreen shows map button when transport id present', (
    tester,
  ) async {
    final transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: 'stop',
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async => {
            'vehicles': <VehiclePosition>[],
            'breakdown': <String, int>{},
          },
        ),
      ),
    );

    // Use small pump increments to avoid long frame settle with large debug text
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.map), findsOneWidget);
  });

  testWidgets('Trip debug card displayed when TripJourney passed', (
    tester,
  ) async {
    final transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: 'stop',
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
    );
    final trip = TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 7,
      rawJson: {
        'isAdditional': false,
        'rating': 7,
        'customField': 'customValue',
        'legs': [
          {
            'origin': {'id': 'O1', 'name': 'Origin', 'type': 'stop'},
            'destination': {'id': 'D1', 'name': 'Destination', 'type': 'stop'},
            'transportation': {'id': 'ROUTE1', 'name': 'Line 1'},
          },
        ],
      },
    );

    // Ensure debug data is visible for this test
    DebugService.showDebugData.value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          trip: trip,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async => {
            'vehicles': <VehiclePosition>[],
            'breakdown': <String, int>{},
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Trip debug data'), findsOneWidget);
    expect(find.textContaining('rating:'), findsOneWidget);
    // Now that trip debug prints legs in full, ensure we see a leg detail in output
    // Use a more unique string to avoid matching other 'Origin' labels
    expect(find.textContaining('--- Leg 1 ---'), findsOneWidget);

    // Verify that raw JSON is printed and includes our custom field
    expect(find.textContaining('customValue'), findsOneWidget);

    // New: ensure Route IDs and Trip IDs are printed at the top of the debug output
    expect(find.textContaining('Route IDs:'), findsOneWidget);
    expect(find.textContaining('ROUTE1'), findsOneWidget);
    expect(find.textContaining('Trip IDs: N/A'), findsOneWidget);
  });

  testWidgets('Trip detail screen includes RealtimeTripId from raw JSON', (
    tester,
  ) async {
    final file = File('lib/trip_leg_raw_json.json');
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final trip = TripJourney.fromJson(data);
    final leg = trip.legs.first;

    // Ensure debug data is visible for this test
    DebugService.showDebugData.value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          trip: trip,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async => {
            'vehicles': <VehiclePosition>[],
            'breakdown': <String, int>{},
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Trip IDs:'), findsOneWidget);
    // Sample data contains RealtimeTripId like '15-M.951.145.2.B.8.87185004'
    expect(find.textContaining('15-M.'), findsOneWidget);
  });

  testWidgets(
    'TripLegDetailScreen respects DebugService.showDebugData toggle',
    (tester) async {
      final transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
      final leg = Leg(
        origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
        destination: Stop(
          id: 'D1',
          name: 'Destination',
          type: 'stop',
          coord: [0.1, 0.1],
        ),
        transportation: transportation,
      );
      final trip = TripJourney(
        isAdditional: false,
        legs: [leg],
        rating: 5,
        rawJson: {
          'isAdditional': false,
          'rating': 5,
          'legs': [
            {
              'origin': {'id': 'O1', 'name': 'Origin', 'type': 'stop'},
              'destination': {
                'id': 'D1',
                'name': 'Destination',
                'type': 'stop',
              },
              'transportation': {'id': 'ROUTE1', 'name': 'Line 1'},
            },
          ],
        },
      );

      // Hide debug data first
      DebugService.showDebugData.value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TripLegDetailScreen(
            leg: leg,
            trip: trip,
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async => {
              'vehicles': <VehiclePosition>[],
              'breakdown': <String, int>{},
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not show trip debug card when disabled
      expect(find.text('Trip debug data'), findsNothing);

      // Now toggle the debug flag to true and rebuild
      DebugService.showDebugData.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Trip debug data'), findsOneWidget);
    },
  );

  testWidgets('Filter uses RealtimeTripId when present', (tester) async {
    // Trip/raw JSON contains a RealtimeTripId which should be preferred for filtering
    final transportation = Transportation(id: 'ROUTE-A', name: 'Line A');
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: 'stop',
        coord: [0.1, 0.1],
      ),
      transportation: transportation,
      rawJson: {
        'transportation': {
          'id': 'ROUTE-A',
          'properties': {'RealtimeTripId': 'MATCH123'},
        },
      },
    );

    final trip = TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 0,
      rawJson: {
        'transportation': {
          'properties': {'RealtimeTripId': 'MATCH123'},
        },
        'legs': [
          {
            'transportation': {
              'id': 'ROUTE-A',
              'properties': {'RealtimeTripId': 'MATCH123'},
            },
          },
        ],
      },
    );

    // Build vehicle positions: one matching the trip id, one different
    final vpMatch = VehiclePosition();
    final tdMatch = TripDescriptor();
    tdMatch.tripId = 'MATCH123';
    vpMatch.trip = tdMatch;
    final vdesc1 = VehicleDescriptor();
    vdesc1.id = 'V-MATCH';
    vpMatch.vehicle = vdesc1;

    final vpOther = VehiclePosition();
    final tdOther = TripDescriptor();
    tdOther.tripId = 'OTHER';
    vpOther.trip = tdOther;
    final vdesc2 = VehicleDescriptor();
    vdesc2.id = 'V-OTHER';
    vpOther.vehicle = vdesc2;

    DebugService.showDebugData.value = true;

    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          trip: trip,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async => {
            'vehicles': <VehiclePosition>[vpMatch, vpOther],
            'breakdown': <String, int>{},
          },
        ),
      ),
    );

    // Let initial load complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Ensure both vehicles are visible initially (filter off)
    expect(find.textContaining('V-MATCH'), findsOneWidget);
    expect(find.textContaining('V-OTHER'), findsOneWidget);

    // Toggle the filter switch on (Filter by route/trip)
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Now only the matching vehicle (by trip id) should be visible
    expect(find.textContaining('V-MATCH'), findsOneWidget);
    expect(find.textContaining('V-OTHER'), findsNothing);
  });
}
