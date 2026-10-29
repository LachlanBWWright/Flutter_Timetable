import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/previews/preview_fixtures.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiKeyService.init();
    TransportPreferencesService.enabledRegions.value = {TransitRegion.nsw};
    TransportPreferencesService.selectedRegion.value = TransitRegion.nsw;
  });

  Future<void> checkAccessibility(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final brightness in Brightness.values) {
    testWidgets('home controls and search are accessible in $brightness', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const MyHomePage(
            title: 'Timetable',
            skipInitialLoad: true,
            initialJourneys: [previewJourney],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip('Add trip'), findsOneWidget);
      await checkAccessibility(tester);
      await tester.tap(find.byTooltip('Search trips'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Central');
      await tester.pumpAndSettle();
      await checkAccessibility(tester);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit trips'));
      await tester.pumpAndSettle();
      await checkAccessibility(tester);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets(
      'settings preferences have accessible labels, targets and contrast in $brightness',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: const SettingsScreen(
                stopsManagementWidget: SizedBox.shrink(),
                stopsSearchWidget: SizedBox.shrink(),
                realtimeInfoWidget: SizedBox.shrink(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await checkAccessibility(tester);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'selected station supports large text and accessible clearing in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();
        var clears = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: SelectedStationCard(
                label: 'From',
                stationName: 'Central Station, Sydney',
                onCancel: () => clears++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await checkAccessibility(tester);
        await tester.tap(
          find.byTooltip('Clear from stop Central Station, Sydney'),
        );
        expect(clears, 1);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'home and settings support large text on narrow screens in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Widget app(Widget home) => MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: home,
        );
        await tester.pumpWidget(
          app(
            const MyHomePage(
              title: 'Timetable',
              skipInitialLoad: true,
              initialJourneys: [previewJourney],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          app(
            const SettingsScreen(
              stopsManagementWidget: SizedBox.shrink(),
              stopsSearchWidget: SizedBox.shrink(),
              realtimeInfoWidget: SizedBox.shrink(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final title in [
          'Regions and providers',
          'Offline data',
          'Diagnostics',
        ]) {
          await tester.ensureVisible(find.text(title));
          await tester.pumpAndSettle();
          expect(find.text(title).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'settings prioritises preferences and reveals advanced sections on demand',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(
            stopsManagementWidget: Text('Stop diagnostics fixture'),
            stopsSearchWidget: SizedBox.shrink(),
            realtimeInfoWidget: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Transit Regions'), findsNothing);
      expect(find.text('Update Provider Data'), findsNothing);
      expect(find.text('Stop diagnostics fixture'), findsNothing);
      for (final section in [
        'Regions and providers',
        'Offline data',
        'Diagnostics',
      ]) {
        await tester.ensureVisible(find.text(section));
        await tester.tap(find.text(section));
        await tester.pumpAndSettle();
        final content = switch (section) {
          'Regions and providers' => 'Transit Regions',
          'Offline data' => 'Update Provider Data',
          _ => 'Stop diagnostics fixture',
        };
        expect(find.text(content), findsOneWidget);
        await tester.ensureVisible(find.text(section));
        await tester.tap(find.text(section));
        await tester.pumpAndSettle();
        expect(find.text(content), findsNothing);
      }
    },
  );
}
