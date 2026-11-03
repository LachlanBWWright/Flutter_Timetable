import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/widgets/realtime_status_banner.dart';

Leg leg(String route, {bool withStops = false}) => Leg(
  origin: Stop(id: 'o', name: 'Origin', type: 'stop'),
  destination: Stop(id: 'd', name: 'Destination', type: 'stop'),
  transportation: Transportation(
    id: route,
    name: route,
    product: Product(classField: 5),
  ),
  stopSequence: withStops
      ? [
          Stop(
            id: 'scheduled',
            name: 'Scheduled',
            type: 'stop',
            departureTimePlanned: '2024-01-01T10:00:00Z',
          ),
        ]
      : null,
);

GtfsData routeData(String id) => GtfsData(
  agencies: [],
  calendars: [],
  calendarDates: [],
  routes: [
    gtfs.Route(
      routeId: id,
      routeShortName: id,
      routeLongName: 'GTFS $id',
      routeType: '3',
    ),
  ],
  stops: [],
  stopTimes: [],
  trips: [],
  shapes: [],
  notes: [],
);

void main() {
  setUp(() => DebugService.showDebugData.value = true);
  tearDown(() => DebugService.showDebugData.value = false);

  testWidgets('older vehicle refresh cannot overwrite a newer result', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    final old = Completer<VehiclePositionAggregationResult>();
    final newest = Completer<VehiclePositionAggregationResult>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg('A'),
          skipInitialLoadDelay: true,
          debugPageLoader: (_) async => throw UnimplementedError(),
          debugListLoader: (_) async => throw UnimplementedError(),
          getGtfsDataForEndpoint: (_) async => null,
          getAllVehiclesAggregated: () =>
              calls++ == 0 ? old.future : newest.future,
          getAllTripUpdatesAggregated: () async =>
              const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    newest.complete(
      const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {'newest': 2},
      ),
    );
    await tester.pump();
    expect(find.text('newest: 2'), findsOneWidget);
    old.complete(
      const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {'obsolete': 1},
      ),
    );
    await tester.pump();
    expect(find.text('newest: 2'), findsOneWidget);
    expect(find.text('obsolete: 1'), findsNothing);
  });

  testWidgets('GTFS route completion from an earlier leg is ignored', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    final old = Completer<GtfsData?>();
    var calls = 0;
    final a = leg('A');
    final b = leg('B');
    Widget screen(Leg active) => MaterialApp(
      home: TripLegDetailScreen(
        key: const ValueKey('details'),
        leg: active,
        skipInitialLoadDelay: true,
        debugPageLoader: (_) async => throw UnimplementedError(),
        debugListLoader: (_) async => throw UnimplementedError(),
        getGtfsDataForEndpoint: (_) =>
            calls++ == 0 ? old.future : Future.value(routeData('B')),
        getAllVehiclesAggregated: () async =>
            const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
        getAllTripUpdatesAggregated: () async =>
            const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
      ),
    );
    await tester.pumpWidget(screen(a));
    await tester.pump();
    await tester.pumpWidget(screen(b));
    await tester.pump();
    await tester.pump();
    old.complete(routeData('A'));
    await tester.pump();
    final text = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? '')
        .join('\n');
    expect(text, contains('GTFS B'));
    expect(text, isNot(contains('GTFS A')));
    expect(tester.takeException(), isNull);
  });
  testWidgets('old stop request cannot replace the new leg stop list', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    DebugService.showDebugData.value = false;
    final old = Completer<TripUpdateAggregationResult>();
    final newest = Completer<TripUpdateAggregationResult>();
    var calls = 0;
    Leg withStops(String route) => Leg(
      origin: Stop(id: 'o', name: 'Origin', type: 'stop'),
      destination: Stop(id: 'd', name: 'Destination', type: 'stop'),
      transportation: Transportation(
        id: route,
        name: route,
        product: Product(classField: 5),
      ),
      rawJson: {
        'transportation': {
          'properties': {'RealtimeTripId': 'trip-$route'},
        },
      },
      stopSequence: [
        Stop(
          id: 'scheduled',
          name: 'Scheduled',
          type: 'stop',
          departureTimePlanned: '2024-01-01T10:00:00Z',
        ),
      ],
    );
    final a = withStops('A');
    final b = withStops('B');
    Widget screen(Leg active) => MaterialApp(
      home: TripLegDetailScreen(
        key: const ValueKey('details'),
        leg: active,
        skipInitialLoadDelay: true,
        getGtfsDataForEndpoint: (_) async => null,
        debugPageLoader: (_) async => throw UnimplementedError(),
        debugListLoader: (_) async => throw UnimplementedError(),
        getAllVehiclesAggregated: () async =>
            const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
        getAllTripUpdatesAggregated: () =>
            calls++ == 0 ? old.future : newest.future,
      ),
    );
    TripUpdateAggregationResult result(String route, String stop) =>
        TripUpdateAggregationResult(
          tripUpdates: [
            TripUpdate(
              trip: TripDescriptor(routeId: route, tripId: 'trip-$route'),
              stopTimeUpdate: [TripUpdate_StopTimeUpdate(stopId: stop)],
            ),
          ],
          breakdown: {},
        );
    await tester.pumpWidget(screen(a));
    await tester.pump();
    await tester.ensureVisible(find.text('Show all stops'));
    await tester.tap(find.text('Show all stops'));
    await tester.pump();
    await tester.pumpWidget(screen(b));
    await tester.pump();
    newest.complete(result('B', 'new-extra'));
    await tester.pump();
    await tester.pump();
    expect(find.text('new-extra'), findsOneWidget);
    old.complete(result('A', 'old-extra'));
    await tester.pump();
    expect(find.text('new-extra'), findsOneWidget);
    expect(find.text('old-extra'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('failed live data keeps scheduled stops and refresh recovers', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    DebugService.showDebugData.value = false;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: leg('A', withStops: true),
          skipInitialLoadDelay: true,
          getGtfsDataForEndpoint: (_) async => null,
          debugPageLoader: (_) async => throw UnimplementedError(),
          debugListLoader: (_) async => throw UnimplementedError(),
          getAllVehiclesAggregated: () async {
            if (calls++ == 0) throw Exception('offline');
            return VehiclePositionAggregationResult(
              vehicles: [],
              breakdown: {},
              metadata: RealtimeSnapshotMetadata(
                fetchedAt: DateTime(2026, 10, 13, 9, 30),
              ),
            );
          },
          getAllTripUpdatesAggregated: () async =>
              const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
        ),
      ),
    );
    await tester.pump();
    expect(calls, 1);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Trip stops (1)'), findsOneWidget);
    expect(find.byType(RealtimeStatusBanner), findsNothing);
    expect(find.text('Live data is unavailable right now.'), findsNothing);
    expect(find.text('No live vehicle matched this trip.'), findsNothing);
    expect(find.text('Retry'), findsNothing);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Trip stops (1)'), findsOneWidget);
    expect(find.byType(RealtimeStatusBanner), findsNothing);
    expect(find.text('Live data is unavailable right now.'), findsNothing);
    expect(find.text('No live vehicle matched this trip.'), findsNothing);
    expect(find.textContaining('Updated '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refresh clears the spinner for an invalidated stop request', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    DebugService.showDebugData.value = false;
    final oldStops = Completer<TripUpdateAggregationResult>();
    var calls = 0;
    final active = Leg(
      origin: Stop(id: 'o', name: 'Origin', type: 'stop'),
      destination: Stop(id: 'd', name: 'Destination', type: 'stop'),
      transportation: Transportation(id: 'A', product: Product(classField: 5)),
      stopSequence: [
        Stop(
          id: 'o',
          name: 'Origin',
          type: 'stop',
          departureTimePlanned: '2024-01-01T10:00:00Z',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TripLegDetailScreen(
          leg: active,
          skipInitialLoadDelay: true,
          getAllVehiclesAggregated: () async =>
              const VehiclePositionAggregationResult(
                vehicles: [],
                breakdown: {},
              ),
          getAllTripUpdatesAggregated: () => calls++ == 0
              ? oldStops.future
              : Future.value(
                  const TripUpdateAggregationResult(
                    tripUpdates: [],
                    breakdown: {},
                  ),
                ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Show all stops'));
    await tester.tap(find.text('Show all stops'));
    await tester.pump();
    final stopHeader = find
        .ancestor(of: find.text('Trip stops (1)'), matching: find.byType(Row))
        .first;
    Finder stopSpinner() => find.descendant(
      of: stopHeader,
      matching: find.byType(CircularProgressIndicator),
    );
    expect(stopSpinner(), findsOneWidget);
    await tester.tap(find.text('Show trip stops'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(stopSpinner(), findsNothing);
    oldStops.complete(
      const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
    );
    await tester.pump();
    expect(stopSpinner(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pending trip updates keep scheduled stops without status banners',
    (tester) async {
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
      DebugService.showDebugData.value = false;
      final updates = Completer<TripUpdateAggregationResult>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: TripLegDetailScreen(
            leg: leg('A', withStops: true),
            skipInitialLoadDelay: true,
            getGtfsDataForEndpoint: (_) async => null,
            getAllVehiclesAggregated: () async =>
                const VehiclePositionAggregationResult(
                  vehicles: [],
                  breakdown: {},
                ),
            getAllTripUpdatesAggregated: () {
              calls++;
              return updates.future;
            },
          ),
        ),
      );
      await tester.pump();
      // Initial realtime loading includes trip updates. A refresh must
      // start another request even while the first update load is pending.
      expect(calls, 1);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(calls, 2);
      expect(find.text('Scheduled'), findsOneWidget);
      expect(find.byType(RealtimeStatusBanner), findsNothing);
      expect(find.text('Loading live data…'), findsNothing);
      expect(
        find.text('No live update for this trip. Showing scheduled times.'),
        findsNothing,
      );
      updates.complete(
        const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
      );
      await tester.pump();
      expect(find.text('Scheduled'), findsOneWidget);
      expect(find.text('Trip stops (1)'), findsOneWidget);
      expect(find.byType(RealtimeStatusBanner), findsNothing);
      expect(find.text('Loading live data…'), findsNothing);
      expect(
        find.text('No live update for this trip. Showing scheduled times.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
