import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home shows retry after load failure and keeps displayed trips', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    final journeyId = await database.insertJourney(
      db.JourneysCompanion.insert(
        origin: 'Central',
        originId: 'central',
        destination: 'Town Hall',
        destinationId: 'town-hall',
      ),
    );
    final journeys = await database.getAllJourneys();
    await database.close();

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(
          title: 'Timetable',
          initialJourneys: journeys,
          database: database,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(journeyId, greaterThan(0));
    expect(find.text('Central'), findsOneWidget);
    expect(
      find.text('Could not load saved trips. Pull down to retry.'),
      findsOneWidget,
    );
    expect(find.text('RETRY'), findsOneWidget);
  });
}
