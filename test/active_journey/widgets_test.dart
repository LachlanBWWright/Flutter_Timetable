import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/indicator.dart';
import 'package:lbww_flutter/active_journey/screen.dart';
import 'package:lbww_flutter/active_journey/session.dart';
import 'package:lbww_flutter/vehicle_finder/controller.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';
import 'package:lbww_flutter/vehicle_finder/screen.dart';

import 'fixtures.dart';

void main() {
  testWidgets(
    'the matching direction opens its running service and allows destination confirmation',
    (tester) async {
      final journey = saved();
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) async => running(v, j, n),
        vehicles: (v) async => [v],
      );
      addTearDown(session.dispose);
      await session.selectVehicle(detected(), [journey]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ActiveJourneyIndicator(
                  journey: journey,
                  reverse: false,
                  session: session,
                ),
                ActiveJourneyIndicator(
                  journey: journey,
                  reverse: true,
                  session: session,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Possible current trip'), findsOneWidget);
      await tester.tap(find.text('Possible current trip'));
      await tester.pumpAndSettle();
      expect(find.byType(ActiveJourneyScreen), findsOneWidget);
      await tester.tap(find.text('A → C'));
      await tester.pumpAndSettle();
      expect(session.selectedKey, '1:false');
      expect(find.text('Current trip'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('End trip'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('End trip'));
      await tester.pumpAndSettle();
      expect(session.vehicle, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Current trip'), findsNothing);
      expect(find.text('Possible current trip'), findsNothing);
    },
  );

  testWidgets(
    'closing the finder retains the shared service without further GPS sampling',
    (tester) async {
      var cancelled = 0;
      final fixes = StreamController<FinderLocation>.broadcast(
        onCancel: () => cancelled++,
      );
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) async => running(v, j, n),
        vehicles: (v) async => [v],
      );
      final controller = VehicleFinderController(
        clock: () => now,
        locations: () => fixes.stream,
        vehicles: (_) async => [detected()],
      );
      addTearDown(session.dispose);
      addTearDown(controller.dispose);
      addTearDown(fixes.close);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          home: Scaffold(
            body: ActiveJourneyIndicator(
              journey: saved(),
              reverse: false,
              session: session,
            ),
          ),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => VehicleFinderScreen(
              controller: controller,
              session: session,
              journeys: [saved()],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start search'));
      fixes.add(
        FinderLocation(
          latitude: -33.86,
          longitude: 151.2,
          timestamp: now,
          accuracy: 10,
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('This is my vehicle'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      await tester.tap(find.text('This is my vehicle'));
      await tester.pumpAndSettle();
      expect(cancelled, 1);
      expect(session.service, isNotNull);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Possible current trip'), findsOneWidget);
      expect(controller.running, isFalse);
      await tester.pump(const Duration(minutes: 1));
      expect(cancelled, 1);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'active journey controls support large text and accessibility in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final session = ActiveJourneySession(
          clock: () => now,
          resolve: (v, j, n, p) async => running(v, j, n),
          vehicles: (v) async => [v],
        );
        addTearDown(session.dispose);
        await session.selectVehicle(detected(), [saved()]);
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
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
            find.text('End trip'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
