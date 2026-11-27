import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

Stop _stop(String id, {double latitude = -33.8688}) => Stop(
  stopId: id,
  stopName: 'Central',
  stopLat: latitude,
  stopLon: 151.2093,
  locationType: 0,
  wheelchairBoarding: 0,
  platformCode: '2',
);

void main() {
  testWidgets('changing the stop filter updates the map and selects a stop', (
    tester,
  ) async {
    final stops = [_stop('central'), _stop('invalid', latitude: 0)];
    final events = <String>[];

    Future<void> showMap(Set<String> allowed) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StopsMapWidget(
              transportMode: TransportMode.train,
              modeDisplayName: 'Train',
              embedded: true,
              skipInitialLoad: true,
              showTileLayer: false,
              initialStops: stops,
              allowedStopIds: allowed,
              onStopSelected: (name, id) => events.add('$name $id'),
              onClose: () => events.add('closed'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showMap({'invalid'});
    expect(find.text('No train stops found'), findsOneWidget);

    await showMap({'central', 'invalid'});
    await tester.tap(find.byIcon(Icons.directions_train));
    await tester.pumpAndSettle();
    expect(find.text('Central'), findsOneWidget);
    expect(find.text('Platform: 2'), findsOneWidget);

    await tester.tap(find.text('Select Stop'));
    await tester.pumpAndSettle();
    expect(events, ['Central central', 'closed']);
    expect(find.text('Select Stop'), findsNothing);
  });

  testWidgets('bus markers appear after zooming into the viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StopsMapWidget(
          transportMode: TransportMode.bus,
          modeDisplayName: 'Bus',
          onStopSelected: (_, _) {},
          skipInitialLoad: true,
          showTileLayer: false,
          initialStops: [_stop('central')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bus Stops Map'), findsOneWidget);
    expect(find.text('Zoom In to View Stops'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsNothing);

    final controller = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!;
    controller.move(controller.camera.center, 16);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(find.text('Zoom In to View Stops'), findsNothing);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
  });
}
