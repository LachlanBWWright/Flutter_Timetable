// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:lbww_flutter/services/app_appearance_service.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingPreferences extends InMemorySharedPreferencesStore {
  _FailingPreferences() : super.empty();

  int writes = 0;
  Completer<bool>? pendingWrite;

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    writes++;
    return pendingWrite?.future ?? Future.value(false);
  }

  @override
  Future<bool> remove(String key) async => false;
}

void main() {
  Future<void> showSettings(
    WidgetTester tester, {
    bool credentials = true,
  }) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(
          stopsManagementWidget: SizedBox.shrink(),
          stopsSearchWidget: SizedBox.shrink(),
          realtimeInfoWidget: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (credentials) {
      await tester.ensureVisible(find.text('Regions and providers'));
      await tester.tap(find.text('Regions and providers'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiKeyService.init();
    TransportPreferencesService.enabledRegions.value = {TransitRegion.nsw};
    TransportPreferencesService.selectedRegion.value = TransitRegion.nsw;
    AppAppearanceService.themeMode.value = ThemeMode.system;
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
    AppAppearanceService.themeMode.value = ThemeMode.system;
  });

  testWidgets('failed API key save retains input and allows retry', (
    tester,
  ) async {
    SharedPreferencesStorePlatform.instance = _FailingPreferences();
    await showSettings(tester);
    final input = find.widgetWithText(TextField, 'TfNSW OpenData API key');
    await reveal(tester, input);
    await tester.enterText(input, 'my-private-key');
    await reveal(tester, find.text('Save key'));
    await tester.tap(find.text('Save key'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save your API key. Please try again.'),
      findsOneWidget,
    );
    expect(ApiKeyService.hasUserApiKey(), isFalse);
    expect(tester.widget<TextField>(input).controller?.text, 'my-private-key');
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Save key'),
          )
          .onPressed,
      isNotNull,
    );
    expect(find.text('Custom API key saved successfully.'), findsNothing);
  });

  testWidgets('failed clear keeps the configured API key', (tester) async {
    await ApiKeyService.setUserApiKey('existing-key');
    SharedPreferencesStorePlatform.instance = _FailingPreferences();
    await showSettings(tester);
    await reveal(tester, find.text('Clear override'));
    await tester.tap(find.text('Clear override'));
    await tester.pumpAndSettle();

    expect(ApiKeyService.getEffectiveApiKey(), 'existing-key');
    expect(
      find.text('Could not remove your API key. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Clear override'), findsOneWidget);
  });

  testWidgets('credential writes cannot overlap and reenable after failure', (
    tester,
  ) async {
    final preferences = _FailingPreferences()..pendingWrite = Completer<bool>();
    SharedPreferencesStorePlatform.instance = preferences;
    await showSettings(tester);
    final input = find.widgetWithText(TextField, 'TfNSW OpenData API key');
    await reveal(tester, input);
    await tester.enterText(input, 'my-private-key');
    final button = find.widgetWithText(ElevatedButton, 'Save key');
    await reveal(tester, button);
    // Invoke the same callback twice before a frame disables the button.
    final onPressed = tester.widget<ElevatedButton>(button).onPressed;
    onPressed?.call();
    onPressed?.call();
    await tester.pump();
    expect(preferences.writes, 1);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    expect(tester.widget<TextField>(input).enabled, isFalse);
    preferences.pendingWrite?.complete(false);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    expect(tester.widget<TextField>(input).enabled, isTrue);
  });

  testWidgets('preference writes cannot overlap and restore after failure', (
    tester,
  ) async {
    final preferences = _FailingPreferences()..pendingWrite = Completer<bool>();
    SharedPreferencesStorePlatform.instance = preferences;
    await showSettings(tester, credentials: false);
    final theme = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<ThemeMode>,
    );
    await reveal(tester, theme);
    final onChanged = tester
        .widget<DropdownButtonFormField<ThemeMode>>(theme)
        .onChanged;
    onChanged?.call(ThemeMode.dark);
    onChanged?.call(ThemeMode.light);
    await tester.pump();

    expect(preferences.writes, 1);
    expect(
      tester.widget<DropdownButtonFormField<ThemeMode>>(theme).onChanged,
      isNull,
    );
    expect(AppAppearanceService.themeMode.value, ThemeMode.system);

    preferences.pendingWrite?.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('System default'), findsOneWidget);
    expect(
      tester.widget<DropdownButtonFormField<ThemeMode>>(theme).onChanged,
      isNotNull,
    );
  });

  testWidgets('failed credential save after disposal does not update UI', (
    tester,
  ) async {
    final preferences = _FailingPreferences()..pendingWrite = Completer<bool>();
    SharedPreferencesStorePlatform.instance = preferences;
    await showSettings(tester);
    final input = find.widgetWithText(TextField, 'TfNSW OpenData API key');
    await reveal(tester, input);
    await tester.enterText(input, 'my-private-key');
    final button = find.widgetWithText(ElevatedButton, 'Save key');
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    preferences.pendingWrite?.complete(false);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(ApiKeyService.hasUserApiKey(), isFalse);
  });

  testWidgets('failed theme save restores the persisted selection', (
    tester,
  ) async {
    SharedPreferencesStorePlatform.instance = _FailingPreferences();
    await showSettings(tester, credentials: false);
    await reveal(tester, find.text('System default'));
    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(AppAppearanceService.themeMode.value, ThemeMode.system);
    expect(find.text('System default'), findsOneWidget);
    expect(
      find.text('Could not save this setting. Please try again.'),
      findsOneWidget,
    );
  });
}
