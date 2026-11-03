import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/screen.dart';
import 'package:lbww_flutter/active_journey/session.dart';

import 'fixtures.dart';

void main() {
  testWidgets(
    'partial stop and timing messages remain legible with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final stops = [
        const RunningStop(id: 'A', name: 'Alpha', sequence: 1),
        const RunningStop(id: 'B', name: 'Beta', sequence: 2),
        RunningStop(
          id: 'C',
          name: 'Gamma',
          sequence: 3,
          arrival: now.add(const Duration(minutes: 10)),
        ),
      ];
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) async => RunningService(
          vehicle: v,
          stops: stops,
          matches: [
            ActiveJourneyMatch(journey: j.single, reverse: false, stops: stops),
          ],
          checkedAt: n,
          partial: true,
        ),
        vehicles: (v) async => [v],
      );
      addTearDown(session.dispose);
      await session.selectVehicle(detected(), [saved()]);
      session.confirmJourney(session.service!.matches.single);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: ActiveJourneyScreen(journeys: [saved()], session: session),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Next reported stop: Beta'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Next reported stop: Beta'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('2 known stops remaining'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('2 known stops remaining'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Arrival times are unavailable for some stops.'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Some stops or live updates'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
