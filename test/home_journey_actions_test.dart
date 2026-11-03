import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/main.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home search, pin, and delete actions update saved journeys', (
    tester,
  ) async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final journeyId = await database.insertJourney(
      db.JourneysCompanion.insert(
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
          title: 'Flutter Timetable',
          skipInitialLoad: true,
          initialJourneys: initialJourneys,
          database: database,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Central'), findsOneWidget);
    expect(find.text('South Bank'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();
    // The query field and saved journey card both display the matching name.
    expect(find.text('Central'), findsNWidgets(2));
    expect(find.text('South Bank'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.push_pin_outlined));
    await tester.pumpAndSettle();

    expect((await database.getPinnedJourneys()).single.id, journeyId);
    expect(find.byIcon(Icons.push_pin), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(await database.getAllJourneys(), isEmpty);
    expect(find.text('No trips saved yet'), findsOneWidget);
  });
}
