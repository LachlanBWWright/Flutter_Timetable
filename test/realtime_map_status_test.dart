import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/realtime_status_banner.dart';

void main() {
  Widget map(Future<Map<TransportMode, FeedMessage?>> Function() fetch) =>
      MaterialApp(
        home: RealtimeMapWidget(showTileLayer: false, getPositions: fetch),
      );

  testWidgets('empty and unavailable feeds keep the map free of banners', (
    tester,
  ) async {
    await tester.pumpWidget(
      map(() async => {TransportMode.bus: FeedMessage()}),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('0 vehicles'), findsOneWidget);
    _expectNoStatusBanners();

    await tester.pumpWidget(map(() async => {TransportMode.bus: null}));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('0 vehicles'), findsOneWidget);
    _expectNoStatusBanners();
  });

  testWidgets(
    'trip filter excludes unrelated vehicles without a status banner',
    (tester) async {
      final feed = FeedMessage(
        entity: [
          FeedEntity(
            id: 'v',
            vehicle: VehiclePosition(
              trip: TripDescriptor(tripId: 'other-trip'),
              vehicle: VehicleDescriptor(id: 'v'),
              position: Position(latitude: -33.86, longitude: 151.20),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: RealtimeMapWidget(
            showTileLayer: false,
            filterByLegTrip: true,
            tripIds: const {'this-trip'},
            getPositions: () async => {TransportMode.bus: feed},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_vehicleMarkers(tester), isEmpty);
      expect(find.text('0 vehicles'), findsOneWidget);
      _expectNoStatusBanners();
    },
  );

  testWidgets('manual refresh preserves last vehicles after a failure', (
    tester,
  ) async {
    var calls = 0;
    final fetchedAt = DateTime(2026, 10, 13, 12);
    Future<VehiclePositionAggregationResult> fetch() async {
      if (++calls == 2) throw StateError('offline');
      return VehiclePositionAggregationResult(
        vehicles: [
          VehiclePosition(
            trip: TripDescriptor(tripId: 'trip'),
            vehicle: VehicleDescriptor(id: 'v'),
            position: Position(latitude: -33.86, longitude: 151.20),
          ),
        ],
        breakdown: const {'bus': 1},
        metadata: RealtimeSnapshotMetadata(
          fetchedAt: fetchedAt,
          failedSources: const {'bus'},
          staleSources: const {'bus'},
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapPage(
          showTileLayer: false,
          getAllVehiclesAggregated: fetch,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 vehicles'), findsOneWidget);
    _expectNoStatusBanners();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('1 vehicles'), findsOneWidget);
    expect(calls, 2);
    expect(_vehicleMarkers(tester), hasLength(1));
    _expectNoStatusBanners();
  });

  testWidgets('map refresh awaits the owner before reading fresh aggregates', (
    tester,
  ) async {
    final refreshed = Completer<void>();
    var generation = 0;
    var ownerRefreshes = 0;
    var aggregateLoads = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapPage(
          showTileLayer: false,
          onRefresh: () async {
            ownerRefreshes++;
            await refreshed.future;
            generation++;
          },
          getAllVehiclesAggregated: () async {
            aggregateLoads++;
            return VehiclePositionAggregationResult(
              vehicles: [
                VehiclePosition(
                  vehicle: VehicleDescriptor(id: 'vehicle'),
                  trip: TripDescriptor(tripId: 'trip'),
                  position: Position(
                    latitude: generation == 0 ? -33.86 : -33.87,
                    longitude: 151.20,
                  ),
                ),
              ],
              breakdown: const {'bus': 1},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final initialLatitude = _vehicleMarkers(tester).single.point.latitude;
    expect(aggregateLoads, 1);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(ownerRefreshes, 1);
    expect(aggregateLoads, 1);
    expect(_vehicleMarkers(tester).single.point.latitude, initialLatitude);

    refreshed.complete();
    await tester.pumpAndSettle();
    expect(aggregateLoads, 2);
    expect(
      _vehicleMarkers(tester).single.point.latitude,
      closeTo(-33.87, 0.001),
    );
    _expectNoStatusBanners();
  });

  for (final aggregated in [false, true]) {
    testWidgets(
      '${aggregated ? 'unavailable aggregate' : 'null feed'} refresh preserves snapshot',
      (tester) async {
        var failRefresh = false;
        final vehicle = VehiclePosition(
          trip: TripDescriptor(tripId: 'trip', routeId: 'B1'),
          vehicle: VehicleDescriptor(id: 'v'),
          position: Position(latitude: -33.86, longitude: 151.20),
        );
        Future<Map<TransportMode, FeedMessage?>> fetchPositions() async => {
          TransportMode.bus: failRefresh
              ? null
              : FeedMessage(
                  entity: [FeedEntity(id: 'v', vehicle: vehicle)],
                ),
        };
        Future<VehiclePositionAggregationResult> fetchAggregate() async =>
            VehiclePositionAggregationResult(
              vehicles: failRefresh ? [] : [vehicle],
              breakdown: {'bus': failRefresh ? 0 : 1},
              metadata: failRefresh
                  ? const RealtimeSnapshotMetadata(failedSources: {'bus'})
                  : RealtimeSnapshotMetadata(
                      fetchedAt: DateTime(2026, 10, 13, 12),
                    ),
            );

        await tester.pumpWidget(
          MaterialApp(
            home: RealtimeMapPage(
              showTileLayer: false,
              getPositions: aggregated ? null : fetchPositions,
              getAllVehiclesAggregated: aggregated ? fetchAggregate : null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final markers = _vehicleMarkers(tester);
        expect(markers, hasLength(1));
        _expectNoStatusBanners();

        failRefresh = true;
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();
        expect(identical(_vehicleMarkers(tester), markers), isTrue);
        expect(find.text('1 vehicles'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        _expectNoStatusBanners();
      },
    );
  }
}

List<Marker> _vehicleMarkers(WidgetTester tester) =>
    tester.widget<MarkerLayer>(find.byType(MarkerLayer).last).markers;

void _expectNoStatusBanners() {
  expect(find.byType(RealtimeStatusBanner), findsNothing);
  expect(find.text('Retry'), findsNothing);
  for (final message in [
    'No live vehicles available.',
    'No live vehicles match this trip or filter.',
    'Live data is unavailable right now.',
    'Live information may be out of date.',
    'Some live updates are unavailable.',
    'Updated',
    'Fetched',
  ]) {
    expect(find.textContaining(message), findsNothing);
  }
}
