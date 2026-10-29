import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/realtime_status_banner.dart';

TripDescriptor _descriptor(String startTime) => TripDescriptor(
  tripId: 'trip',
  routeId: 'route',
  startDate: '20261015',
  startTime: startTime,
);

VehiclePosition _vehicle(String startTime, double latitude) => VehiclePosition(
  trip: _descriptor(startTime),
  vehicle: VehicleDescriptor(id: 'vehicle-$startTime'),
  position: Position(latitude: latitude, longitude: 151.20),
);

List<Marker> _vehicles(WidgetTester tester) =>
    tester.widget<MarkerLayer>(find.byType(MarkerLayer).last).markers;

void main() {
  testWidgets('fullscreen map follows refreshed matching identity in place', (
    tester,
  ) async {
    final revision = ValueNotifier(0);
    final leg = Leg(
      origin: Stop(
        id: 'origin',
        name: 'Origin',
        type: 'stop',
        departureTimePlanned: '2026-10-15T11:00:00',
      ),
      destination: Stop(id: 'destination', name: 'Destination', type: 'stop'),
      transportation: Transportation(id: 'route'),
    );
    var aggregateCalls = 0;
    var refreshCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: RealtimeMapPage(
          showTileLayer: false,
          legListenable: revision,
          getLegSnapshot: () => RealtimeMapLegSnapshot(
            leg: leg,
            additionalLegs: const [],
            transportMode: TransportMode.bus,
            routeFilter: 'route',
            tripIds: revision.value == 0 ? {} : {'trip'},
            matchedTrip: revision.value == 0
                ? null
                : _descriptor(revision.value == 1 ? '10:00:00' : '11:00:00'),
            refreshGeneration: revision.value,
          ),
          onRefresh: () async {
            refreshCalls++;
            revision.value = 1;
          },
          getAllVehiclesAggregated: () async {
            aggregateCalls++;
            return VehiclePositionAggregationResult(
              vehicles: [
                _vehicle('10:00:00', -33.86),
                _vehicle('11:00:00', -33.87),
              ],
              breakdown: const {'bus': 2},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final originalMapState = tester.state(find.byType(RealtimeMapWidget));
    expect(_vehicles(tester), isEmpty);
    expect(aggregateCalls, 1);

    await tester.tap(find.byTooltip('Refresh live map'));
    await tester.pumpAndSettle();
    expect(refreshCalls, 1);
    expect(aggregateCalls, greaterThan(1));
    expect(_vehicles(tester), hasLength(1));
    expect(_vehicles(tester).single.point.latitude, closeTo(-33.86, 0.001));

    // Later update matching must also reach the already-open fullscreen map.
    revision.value = 2;
    await tester.pumpAndSettle();
    expect(_vehicles(tester), hasLength(1));
    expect(_vehicles(tester).single.point.latitude, closeTo(-33.87, 0.001));
    expect(
      tester.state(find.byType(RealtimeMapWidget)),
      same(originalMapState),
    );
    expect(find.byType(RealtimeStatusBanner), findsNothing);
    expect(find.text('Retry'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    revision.dispose();
  });
}
