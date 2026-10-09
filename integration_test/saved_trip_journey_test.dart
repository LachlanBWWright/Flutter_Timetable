import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lbww_flutter/main.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('saved trips can be searched, pinned, restored, and deleted', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp(
      'fluttertimetable_e2e_',
    );
    final databaseFile = File('${directory.path}/journeys.sqlite');
    var database = db.AppDatabase.connect(NativeDatabase(databaseFile));
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    await database.insertJourney(
      db.JourneysCompanion.insert(
        origin: 'Central',
        originId: 'queensland|translink|qld:SEQ|central',
        destination: 'South Bank',
        destinationId: 'queensland|translink|qld:SEQ|south-bank',
      ),
    );
    await _launchHome(tester, database);

    expect(find.text('Central'), findsOneWidget);
    expect(find.text('South Bank'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();
    expect(find.text('Central'), findsOneWidget);
    expect(find.text('South Bank'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.push_pin_outlined));
    await tester.pumpAndSettle();
    expect((await database.getPinnedJourneys()), hasLength(1));

    // Reopen the app against a new database connection to exercise on-disk
    // persistence across the home screen's lifecycle.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
    database = db.AppDatabase.connect(NativeDatabase(databaseFile));
    final restoredJourneys = await database.getAllJourneys();
    expect(restoredJourneys, hasLength(1));
    expect(restoredJourneys.single.isPinned, isTrue);
    await _launchHome(tester, database, journeys: restoredJourneys);
    expect(find.byIcon(Icons.push_pin), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(await database.getAllJourneys(), isEmpty);
    expect(find.text('No trips saved yet'), findsOneWidget);
  });
}

Future<void> _launchHome(
  WidgetTester tester,
  db.AppDatabase database, {
  List<db.Journey> journeys = const <db.Journey>[],
}) async {
  await tester.pumpWidget(
    MyApp(
      home: MyHomePage(
        title: 'Flutter Timetable',
        skipInitialLoad: true,
        initialJourneys: journeys,
        database: database,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
