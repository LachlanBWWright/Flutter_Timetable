// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/main.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _RejectedPreferences extends InMemorySharedPreferencesStore {
  _RejectedPreferences() : super.empty();

  @override
  Future<bool> setValue(String type, String key, Object value) async => false;
}

class _PendingPreferences extends InMemorySharedPreferencesStore {
  _PendingPreferences() : super.empty();

  final writes = <Completer<bool>>[];

  @override
  Future<bool> setValue(String type, String key, Object value) {
    final write = Completer<bool>();
    writes.add(write);
    return write.future;
  }
}

Future<void> _showHome(WidgetTester tester) async {
  final database = AppDatabase.connect(NativeDatabase.memory());
  addTearDown(database.close);
  await database.insertJourney(
    JourneysCompanion.insert(
      origin: 'Central',
      originId: 'queensland|translink|qld:SEQ|central',
      destination: 'South Bank',
      destinationId: 'queensland|translink|qld:SEQ|south-bank',
    ),
  );
  final initialJourneys = await database.getAllJourneys();
  await tester.pumpWidget(
    MaterialApp(
      home: MyHomePage(
        title: 'Journeys',
        skipInitialLoad: true,
        initialJourneys: initialJourneys,
        database: database,
      ),
    ),
  );
}

Future<void> _selectNearestFirst(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Sort trips'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Nearest first'));
  await tester.pumpAndSettle();
}

void _expectAlphabeticalSort(WidgetTester tester) {
  expect(
    tester.widget<HomeAppBar>(find.byType(HomeAppBar)).isAlphabeticalSorting,
    isTrue,
  );
}

void main() {
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('failed sort save leaves the current order selected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesStorePlatform.instance = _RejectedPreferences();
    await _showHome(tester);
    await _selectNearestFirst(tester);
    _expectAlphabeticalSort(tester);
    expect(
      find.text('Could not save the sort order. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('pending sort save blocks duplicates and failure allows retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = _PendingPreferences();
    SharedPreferencesStorePlatform.instance = preferences;
    await _showHome(tester);

    await _selectNearestFirst(tester);
    expect(preferences.writes, hasLength(1));
    await _selectNearestFirst(tester);
    expect(preferences.writes, hasLength(1));
    _expectAlphabeticalSort(tester);

    preferences.writes.single.complete(false);
    await tester.pumpAndSettle();
    await _selectNearestFirst(tester);
    expect(preferences.writes, hasLength(2));
    preferences.writes.last.complete(false);
    await tester.pumpAndSettle();
    _expectAlphabeticalSort(tester);
    expect(tester.takeException(), isNull);
  });

  for (final result in [true, false]) {
    testWidgets('sort save completing with $result after disposal is safe', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = _PendingPreferences();
      SharedPreferencesStorePlatform.instance = preferences;
      await _showHome(tester);
      await _selectNearestFirst(tester);
      expect(preferences.writes, hasLength(1));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      preferences.writes.single.complete(result);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
