import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/note.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/shape.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart' as gtfs_trip;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';

void main() {
  setUp(() {
    DebugService.showDebugData.value = false;
  });

  GtfsData emptyGtfsData() {
    return GtfsData(
      agencies: const <gtfs_agency.Agency>[],
      calendars: const [],
      calendarDates: const [],
      routes: const <gtfs_route.Route>[],
      stops: const <gtfs_stop.Stop>[],
      stopTimes: const <StopTime>[],
      trips: const <gtfs_trip.Trip>[],
      shapes: const <Shape>[],
      notes: const <Note>[],
    );
  }

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
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
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
    final transportation = Transportation(
      id: 'ROUTE1',
      name: 'Line 1',
      product: Product(classField: 5),
    );
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
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
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
          getGtfsDataForEndpoint: (_) async => emptyGtfsData(),
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Trip debug data'), findsOneWidget);
    expect(find.text('Route debug data'), findsOneWidget);
    expect(find.textContaining('GTFS route lookup:'), findsOneWidget);
    expect(find.textContaining('rating:'), findsOneWidget);
    // Now that trip debug prints legs in full, ensure we see a leg detail in output
    // Use a more unique string to avoid matching other 'Origin' labels
    expect(find.textContaining('--- Leg 1 ---'), findsOneWidget);

    // Verify that raw JSON is printed and includes our custom field
    expect(find.textContaining('customValue'), findsOneWidget);

    // New: ensure Route IDs and Trip IDs are printed at the top of the debug output
    expect(find.textContaining('Route IDs:'), findsOneWidget);
    expect(find.textContaining('Route IDs: ROUTE1'), findsOneWidget);
    expect(find.textContaining('Trip IDs: N/A'), findsOneWidget);
  });

  testWidgets('Trip detail screen includes RealtimeTripId from raw JSON', (
    tester,
  ) async {
    const realtimeTripId = '15-M.951.145.2.B.8.87185004';
    final transportation = Transportation(
      id: 'ROUTE1',
      name: 'Line 1',
      product: Product(classField: 5),
    );
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
          'id': 'ROUTE1',
          'properties': {'RealtimeTripId': realtimeTripId},
        },
      },
    );
    final trip = TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 7,
      rawJson: {
        'isAdditional': false,
        'rating': 7,
        'legs': [
          {
            'transportation': {
              'id': 'ROUTE1',
              'properties': {'RealtimeTripId': realtimeTripId},
            },
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
          getGtfsDataForEndpoint: (_) async => emptyGtfsData(),
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Trip IDs:'), findsOneWidget);
    expect(find.textContaining(realtimeTripId), findsOneWidget);
  });

  testWidgets(
    'TripLegDetailScreen respects DebugService.showDebugData toggle',
    (tester) async {
      final transportation = Transportation(
        id: 'ROUTE1',
        name: 'Line 1',
        product: Product(classField: 5),
      );
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
            getGtfsDataForEndpoint: (_) async => emptyGtfsData(),
            skipInitialLoadDelay: true,
            getAllVehiclesAggregated: () async =>
                const VehiclePositionAggregationResult(
                  vehicles: <VehiclePosition>[],
                  breakdown: <String, int>{},
                ),
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
    final transportation = Transportation(
      id: 'ROUTE-A',
      name: 'Line A',
      product: Product(classField: 5),
    );
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
          getGtfsDataForEndpoint: (_) async => emptyGtfsData(),
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async =>
              VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[vpMatch, vpOther],
                breakdown: <String, int>{},
              ),
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

  testWidgets('Stops card toggles to the full vehicle stop list', (
    tester,
  ) async {
    final transportation = Transportation(
      id: 'ROUTE1',
      name: 'Line 1',
      product: Product(classField: 5),
    );
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop', coord: [0.0, 0.0]),
      destination: Stop(
        id: 'D1',
        name: 'Destination',
        type: 'stop',
        coord: [0.3, 0.3],
      ),
      transportation: transportation,
      stopSequence: [
        Stop(id: 'LEG1', name: 'Leg Stop 1', type: 'stop'),
        Stop(id: 'LEG2', name: 'Leg Stop 2', type: 'stop'),
      ],
      rawJson: {
        'transportation': {
          'id': 'ROUTE1',
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
              'id': 'ROUTE1',
              'properties': {'RealtimeTripId': 'MATCH123'},
            },
          },
        ],
      },
    );

    final tripDescriptor = TripDescriptor();
    tripDescriptor.tripId = 'MATCH123';
    tripDescriptor.routeId = 'ROUTE1';

    TripUpdate_StopTimeEvent buildEvent(int unixSeconds) {
      final event = TripUpdate_StopTimeEvent();
      event.time = Int64(unixSeconds);
      return event;
    }

    final stopA = TripUpdate_StopTimeUpdate();
    stopA.stopSequence = 1;
    stopA.stopId = 'RT1';
    stopA.departure = buildEvent(1_700_000_000);

    final stopB = TripUpdate_StopTimeUpdate();
    stopB.stopSequence = 2;
    stopB.stopId = 'RT2';
    stopB.departure = buildEvent(1_700_000_600);

    final stopC = TripUpdate_StopTimeUpdate();
    stopC.stopSequence = 3;
    stopC.stopId = 'RT3';
    stopC.departure = buildEvent(1_700_001_200);

    final tripUpdate = TripUpdate();
    tripUpdate.trip = tripDescriptor;
    tripUpdate.stopTimeUpdate.addAll([stopA, stopB, stopC]);

    DebugService.showDebugData.value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          trip: trip,
          getGtfsDataForEndpoint: (_) async => emptyGtfsData(),
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
          getAllTripUpdatesAggregated: () async => TripUpdateAggregationResult(
            tripUpdates: <TripUpdate>[tripUpdate],
            breakdown: <String, int>{},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Trip stops (2)'), findsOneWidget);
    expect(find.text('Show all stops'), findsOneWidget);
    expect(find.text('Leg Stop 1'), findsOneWidget);
    expect(find.text('RT1'), findsNothing);

    await tester.tap(find.text('Show all stops'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('All stops (3)'), findsOneWidget);
    expect(find.text('Show scheduled stops'), findsOneWidget);
    expect(find.text('Leg Stop 1'), findsOneWidget);
    expect(find.text('Leg Stop 2'), findsOneWidget);
    expect(find.text('RT1'), findsNothing);
    expect(find.text('RT2'), findsNothing);
    expect(find.text('RT3'), findsOneWidget);
  });

  testWidgets('Route debug card shows GTFS route and agency fields', (
    tester,
  ) async {
    final transportation = Transportation(
      id: 'ROUTE1',
      name: 'Line 1',
      description: 'Limited stops',
      disassembledName: 'Line 1 City',
      iconId: 77,
      number: 'L1',
      operator: Operator(id: 'OP1', name: 'Transit Co'),
      destination: TransportationDestination(id: 'DEST1', name: 'Central'),
      product: Product(classField: 5, iconId: 12, name: 'Bus'),
      properties: TransportationProperties(isTTB: true, tripCode: 456),
    );
    final leg = Leg(
      origin: Stop(id: 'O1', name: 'Origin', type: 'stop'),
      destination: Stop(id: 'D1', name: 'Destination', type: 'stop'),
      transportation: transportation,
      rawJson: {
        'transportation': {'id': 'ROUTE1', 'customField': 'customValue'},
      },
    );
    final trip = TripJourney(isAdditional: false, legs: [leg], rating: 1);

    final gtfsData = GtfsData(
      agencies: [
        gtfs_agency.Agency(
          agencyId: 'A1',
          agencyName: 'Agency Name',
          agencyUrl: 'https://agency.example',
          agencyTimezone: 'Australia/Sydney',
          agencyLang: 'en',
          agencyPhone: '1234',
          agencyFareUrl: 'https://agency.example/fares',
          agencyEmail: 'info@agency.example',
        ),
      ],
      calendars: const [],
      calendarDates: const [],
      routes: [
        gtfs_route.Route(
          routeId: 'ROUTE1',
          agencyId: 'A1',
          routeShortName: 'L1',
          routeLongName: 'Line 1 Long Name',
          routeDesc: 'Main corridor',
          routeType: '3',
          routeUrl: 'https://route.example',
          routeColor: '112233',
          routeTextColor: 'FAFAFA',
          routeSortOrder: '10',
          continuousPickup: '0',
          continuousDropOff: '1',
          networkId: 'NET1',
        ),
      ],
      stops: const <gtfs_stop.Stop>[],
      stopTimes: const <StopTime>[],
      trips: const <gtfs_trip.Trip>[],
      shapes: const <Shape>[],
      notes: const <Note>[],
    );

    DebugService.showDebugData.value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg,
          trip: trip,
          skipInitialLoadDelay: true,
          getGtfsDataForEndpoint: (endpoint) async {
            if (endpoint == StopsEndpoint.buses) {
              return gtfsData;
            }
            return emptyGtfsData();
          },
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: <VehiclePosition>[],
                breakdown: <String, int>{},
              ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Route debug data'), findsOneWidget);
    expect(find.textContaining('description: Limited stops'), findsOneWidget);
    expect(find.textContaining('operator.name: Transit Co'), findsOneWidget);
    expect(find.textContaining('product.name: Bus'), findsOneWidget);
    expect(find.textContaining('route_short_name: L1'), findsOneWidget);
    expect(
      find.textContaining('route_long_name: Line 1 Long Name'),
      findsOneWidget,
    );
    expect(find.textContaining('route_color: 112233'), findsOneWidget);
    expect(find.textContaining('agency_name: Agency Name'), findsOneWidget);
    expect(find.textContaining('endpoint: buses'), findsOneWidget);
  });
}
