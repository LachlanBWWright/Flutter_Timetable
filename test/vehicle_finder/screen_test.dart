import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/session.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/vehicle_finder/controller.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';
import 'package:lbww_flutter/vehicle_finder/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

void main() {
  setUp(() => ActiveJourneySession.instance.end());
  tearDown(() => ActiveJourneySession.instance.end());
  testWidgets('temporary Home toolbar button opens an idle experiment', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: MyHomePage(title: 'Home', skipInitialLoad: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Find my vehicle (experimental)'));
    await tester.pumpAndSettle();
    expect(find.byType(VehicleFinderScreen), findsOneWidget);
    expect(find.text('Start search'), findsOneWidget);
    expect(find.text('Stop search'), findsNothing);
    expect(find.text('Experimental · NSW'), findsOneWidget);
  });

  testWidgets(
    'search starts explicitly, confirms a candidate, and cancels on disposal',
    (tester) async {
      var starts = 0;
      var cancels = 0;
      final stream = StreamController<FinderLocation>.broadcast(
        onCancel: () => cancels++,
      );
      final controller = VehicleFinderController(
        locations: () {
          starts++;
          return stream.stream;
        },
        vehicles: (_) async => [vehicle(0)],
        clock: () => instant(0),
      );
      addTearDown(controller.dispose);
      addTearDown(stream.close);
      await tester.pumpWidget(
        MaterialApp(home: VehicleFinderScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(starts, 0);
      await tester.tap(find.text('Start search'));
      await tester.pump();
      stream.add(phone(0));
      await tester.pump();
      expect(starts, 1);
      expect(find.text('Possible vehicle'), findsOneWidget);
      expect(find.text('Likely your vehicle'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('This is my vehicle'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.text('This is my vehicle'));
      await tester.pumpAndSettle();
      expect(controller.running, isFalse);
      expect(cancels, 1);
      expect(find.text('View on map'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(minutes: 5));
      expect(cancels, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('backgrounding stops sampling and does not silently restart', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var cancelled = 0;
    final stream = StreamController<FinderLocation>.broadcast(
      onCancel: () => cancelled++,
    );
    final controller = VehicleFinderController(
      locations: () => stream.stream,
      vehicles: (_) async => [],
    );
    addTearDown(controller.dispose);
    addTearDown(stream.close);
    await tester.pumpWidget(
      MaterialApp(home: VehicleFinderScreen(controller: controller)),
    );
    await tester.tap(find.text('Start search'));
    await tester.pump();
    // Permission prompts may transiently mark an app inactive.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(controller.running, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(cancelled, 1);
    expect(controller.running, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.running, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('covering or closing the finder route stops a running search', (
    tester,
  ) async {
    final stream = StreamController<FinderLocation>.broadcast();
    final controller = VehicleFinderController(
      locations: () => stream.stream,
      vehicles: (_) async => [],
    );
    addTearDown(controller.dispose);
    addTearDown(stream.close);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: VehicleFinderScreen(controller: controller),
      ),
    );
    await tester.tap(find.text('Start search'));
    await tester.pump();
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Covered')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.running, isFalse);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start search'));
    await tester.pump();
    expect(controller.running, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(controller.running, isFalse);
    await tester.pump(const Duration(minutes: 5));
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'finder supports accessible controls and large text in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
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
              home: const VehicleFinderScreen(),
            ),
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Start search'),
            300,
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

  testWidgets(
    'unsupported regions explain availability without starting location',
    (tester) async {
      var requests = 0;
      final controller = VehicleFinderController(
        locations: () {
          requests++;
          return const Stream.empty();
        },
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: VehicleFinderScreen(controller: controller, supported: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('currently supports New South Wales'),
        findsOneWidget,
      );
      expect(find.text('Start search'), findsNothing);
      expect(requests, 0);
    },
  );
}
