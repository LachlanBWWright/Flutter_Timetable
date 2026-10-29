import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/recovery.dart';
import 'package:lbww_flutter/active_journey/session.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

void main() {
  testWidgets(
    'Home recovery remains scrollable with long names and large text',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = ActiveJourneySession.instance;
      session.end();
      addTearDown(session.end);
      final journey = saved().copyWith(
        origin: 'International Airport Railway Station',
        destination: 'Macquarie University Railway Station',
      );
      session.recovery = ActiveJourneyRecovery(
        vehicle: detected(),
        match: ActiveJourneyMatch(
          journey: journey,
          reverse: false,
          stops: pattern(),
        ),
        selectedAt: DateTime.now(),
        confirmedAt: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: MyHomePage(
            title: 'Home',
            skipInitialLoad: true,
            initialJourneys: [journey],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(session.vehicle, isNull);
      await tester.scrollUntilVisible(find.text('Dismiss'), 120);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(session.recovery, isNull);
      expect(session.vehicle, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
