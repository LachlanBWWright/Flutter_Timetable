import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

void main() {
  testWidgets('TripLegDetailScreen hides map button when transport id missing',
      (tester) async {
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination:
          Stop(id: 'D1', name: 'Destination', type: 'stop', coord: [0.1, 0.1]),
      transportation: null,
    );

    await tester.pumpWidget(MaterialApp(home: TripLegDetailScreen(leg: leg)));

    await tester.pumpAndSettle();

    // Map icon shouldn't be present
    expect(find.byIcon(Icons.map), findsNothing);
  });

  testWidgets('TripLegDetailScreen shows map button when transport id present',
      (tester) async {
    final transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination:
          Stop(id: 'D1', name: 'Destination', type: 'stop', coord: [0.1, 0.1]),
      transportation: transportation,
    );

    await tester.pumpWidget(MaterialApp(home: TripLegDetailScreen(leg: leg)));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.map), findsOneWidget);
  });

  testWidgets('Trip debug card displayed when TripJourney passed', (tester) async {
    final transportation = Transportation(id: 'ROUTE1', name: 'Line 1');
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(id: 'D1', name: 'Destination', type: 'stop', coord: [0.1, 0.1]),
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
            'transportation': {'id': 'ROUTE1', 'name': 'Line 1'}
          }
        ]
      },
    );

    await tester.pumpWidget(MaterialApp(home: TripLegDetailScreen(leg: leg, trip: trip)));
    await tester.pumpAndSettle();

    expect(find.text('Trip debug data'), findsOneWidget);
    expect(find.textContaining('rating:'), findsOneWidget);
    // Now that trip debug prints legs in full, ensure we see a leg detail in output
    // Use a more unique string to avoid matching other 'Origin' labels
    expect(find.textContaining('--- Leg 1 ---'), findsOneWidget);

    // Verify that raw JSON is printed and includes our custom field
    expect(find.textContaining('customValue'), findsOneWidget);
  });

  testWidgets('Trip detail screen shows nested raw JSON for leg and origin', (tester) async {
    final file = File('lib/trip_leg_raw_json.json');
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final trip = TripJourney.fromJson(data);
    final leg = trip.legs.first;

    await tester.pumpWidget(MaterialApp(home: TripLegDetailScreen(leg: leg, trip: trip)));
    await tester.pumpAndSettle();

    // Should include headers for Raw JSON blocks and RealtimeTripId
    expect(find.textContaining('Raw leg JSON:'), findsOneWidget);
    expect(find.textContaining('Origin raw JSON:'), findsOneWidget);
    expect(find.textContaining('RealtimeTripId'), findsOneWidget);
  });
}
