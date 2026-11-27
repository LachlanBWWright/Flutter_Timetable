import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/widgets/realtime_widgets.dart';

void main() {
  testWidgets(
    'positions show vehicle, route, trip and location from the feed',
    (tester) async {
      final feed = FeedMessage(
        header: FeedHeader(gtfsRealtimeVersion: '2.0'),
        entity: [
          FeedEntity(
            id: 'vehicle-1',
            vehicle: VehiclePosition(
              vehicle: VehicleDescriptor(id: '123'),
              trip: TripDescriptor(routeId: 'T1', tripId: 'trip-1'),
              position: Position(latitude: -33.8688, longitude: 151.2093),
              timestamp: Int64(1700000000),
            ),
          ),
        ],
      );
      final firstLoad = Completer<FeedMessage?>();
      final requestedModes = <TransportMode>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportPositionsWidget(
              mode: TransportMode.train,
              displayName: 'Train',
              loadPositions: (mode) async {
                requestedModes.add(mode);
                return requestedModes.length == 1 ? firstLoad.future : feed;
              },
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );

      firstLoad.completeError(StateError('Feed unavailable'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Feed unavailable'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(requestedModes, [TransportMode.train, TransportMode.train]);
      expect(find.textContaining('Feed unavailable'), findsNothing);
      expect(find.text('Train Positions'), findsOneWidget);
      expect(find.text('Vehicle 123'), findsOneWidget);
      expect(find.text('T1'), findsOneWidget);
      expect(find.text('Trip: trip-1'), findsOneWidget);
      expect(find.text('Position: -33.8688, 151.2093'), findsOneWidget);
      expect(find.textContaining('Updated:'), findsOneWidget);
    },
  );
}
