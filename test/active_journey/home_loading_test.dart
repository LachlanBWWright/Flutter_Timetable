import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/session.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

void main() {
  testWidgets('loading and failed Home reads retain a confirmed destination', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final session = ActiveJourneySession.instance;
    session.end();
    addTearDown(session.end);
    final time = DateTime.now();
    final journey = saved();
    final vehicle = detected(observedAt: time);
    final service = running(vehicle, [journey], time);
    session.vehicle = vehicle;
    session.service = service;
    session.selectedAt = time;
    session.confirmJourney(service.matches.single);
    expect(session.selectedKey, '1:false');

    final database = db.AppDatabase.connect(NativeDatabase.memory());
    await database.close();
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(title: 'Home', database: database),
      ),
    );
    // A new Home starts with an empty list while the authoritative read is pending.
    expect(session.selectedKey, '1:false');
    await tester.pumpAndSettle();
    expect(find.text('Could not load saved trips'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-journeys-ready')), findsNothing);
    expect(session.selectedKey, '1:false');
    expect(session.confirmedMatch?.journey.id, journey.id);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
