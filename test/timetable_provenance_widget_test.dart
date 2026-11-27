import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('journey cards show a delay in the updated departure time', (
    tester,
  ) async {
    final journey = api.TripJourney(
      legs: [
        api.Leg(
          origin: api.Stop(
            id: 'A',
            name: 'Alpha',
            type: 'stop',
            departureTimePlanned: '2026-11-06T10:00:00',
            departureTimeEstimated: '2026-11-06T10:04:00',
          ),
          destination: api.Stop(id: 'B', name: 'Beta', type: 'stop'),
          isRealtimeControlled: true,
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

    expect(find.textContaining('+4m late'), findsOneWidget);
    expect(find.text('Live updates applied'), findsNothing);
    expect(find.text('Live'), findsNothing);
  });

  testWidgets('expanded leg times wrap and leave room for stop names', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final transfer = api.Stop(
      id: 'B',
      name: 'Marion Light Rail',
      type: 'stop',
      arrivalTimePlanned: '2026-11-06T10:10:00',
    );
    final journey = api.TripJourney(
      legs: [
        api.Leg(
          origin: api.Stop(
            id: 'A',
            name: 'Arlington Light Rail',
            type: 'stop',
            departureTimePlanned: '2026-11-06T09:30:00',
            departureTimeEstimated: '2026-11-06T10:04:00',
          ),
          destination: transfer,
        ),
        api.Leg(
          origin: transfer,
          destination: api.Stop(id: 'C', name: 'Chiswick Wharf', type: 'stop'),
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
    await tester.tap(find.text('Arlington Light Rail to Chiswick Wharf'));
    await tester.pumpAndSettle();

    const range = '10:04AM (+34m late) - 10:10AM';
    final times = find.text(range);
    final stops = find.text('Arlington Light Rail → Marion Light Rail');
    final paragraph = tester.renderObject<RenderParagraph>(times);
    final lines = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: range.length),
        )
        .map((box) => box.top)
        .toSet();
    expect(lines.length, greaterThan(1));
    expect(
      tester.getSize(stops).width,
      greaterThan(tester.getSize(times).width),
    );
  });
}
