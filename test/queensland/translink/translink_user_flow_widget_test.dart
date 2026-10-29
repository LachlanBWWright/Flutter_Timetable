import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/main.dart';
import 'package:lbww_flutter/schema/database.dart' as db;

void main() {
  testWidgets('saved QLD trips are visible on the home screen', (tester) async {
    const journey = db.Journey(
      id: 42,
      origin: 'Central station',
      originId: 'queensland|translink|qld:SEQ|central',
      destination: 'South Bank station',
      destinationId: 'queensland|translink|qld:SEQ|south-bank',
      tripType: 'direct',
      mode: 'train',
      isPinned: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MyHomePage(
          title: 'Flutter Timetable',
          skipInitialLoad: true,
          initialJourneys: [journey],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(journey.origin), findsOneWidget);
    expect(find.text(journey.destination), findsOneWidget);
  });
}
