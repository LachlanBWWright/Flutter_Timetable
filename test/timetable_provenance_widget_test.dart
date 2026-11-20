import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;
import 'package:lbww_flutter/transit/domain/timetable_provenance.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';

void main() {
  testWidgets('journey cards show the original offline timetable date', (
    tester,
  ) async {
    final timetable = TimetableProvenance(
      fetchedAt: DateTime(2026, 11, 1, 9),
      isStale: true,
      offlineFallback: true,
    );
    final journey = api.TripJourney(
      rawJson: {'timetable': timetable.toJson()},
      legs: [
        api.Leg(
          origin: api.Stop(
            id: 'A',
            name: 'Alpha',
            type: 'stop',
            departureTimePlanned: '2026-11-06T10:00:00',
          ),
          destination: api.Stop(
            id: 'B',
            name: 'Beta',
            type: 'stop',
            arrivalTimePlanned: '2026-11-06T10:10:00',
          ),
          isRealtimeControlled: false,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripCard(trip: journey, onSelectLeg: (_) {}),
        ),
      ),
    );
    expect(
      find.text('Offline timetable · downloaded 2026-11-01 09:00'),
      findsOneWidget,
    );
    expect(find.textContaining('Alpha'), findsOneWidget);
  });
}
