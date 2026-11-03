import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/session.dart';

import 'fixtures.dart';

void main() {
  test(
    'retains a service, requires destination confirmation and ages occupancy claims',
    () async {
      var clock = now;
      final session = ActiveJourneySession(
        clock: () => clock,
        resolve: (v, j, n, p) async => running(v, j, n),
        vehicles: (v) async => [detected(observedAt: clock)],
      );
      addTearDown(session.dispose);
      final journeys = [saved(), saved(id: 2, destination: 'D')];
      await session.selectVehicle(detected(), journeys);
      expect(session.labelFor(journeys.first, false), 'Possible current trip');
      expect(session.labelFor(journeys.last, false), 'Possible current trip');
      session.confirmJourney(session.service!.matches.first);
      expect(session.labelFor(journeys.first, false), 'Current trip');
      expect(session.labelFor(journeys.last, false), isNull);
      clock = now.add(const Duration(minutes: 3));
      await session.refresh(journeys);
      expect(session.labelFor(journeys.first, false), 'Following this service');
      clock = clock.add(const Duration(minutes: 2));
      expect(session.labelFor(journeys.first, false), 'Last confirmed');
      session.end();
      expect(session.service, isNull);
      expect(session.labelFor(journeys.first, false), isNull);
    },
  );
  test(
    'concurrent refreshes coalesce even when the pending request fails',
    () async {
      final pending = Completer<RunningService>();
      var calls = 0;
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) {
          calls++;
          return pending.future;
        },
      );
      addTearDown(session.dispose);
      final start = session.selectVehicle(detected(), [saved()]);
      final refreshes = List.generate(20, (_) => session.refresh([saved()]));
      pending.completeError(StateError('failed'));
      await start;
      await Future.wait(refreshes);
      expect(calls, 1);
      expect(session.error, isNotNull);
      expect(session.loading, isFalse);
    },
  );
  test(
    'ending a session prevents late responses from resurrecting its selection',
    () async {
      final pending = Completer<RunningService>();
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) => pending.future,
      );
      addTearDown(session.dispose);
      final task = session.selectVehicle(detected(), [saved()]);
      session.end();
      pending.complete(running(detected(), [saved()], now));
      await task;
      expect(session.vehicle, isNull);
      expect(session.service, isNull);
    },
  );
  test('removed or edited saved journeys lose their indicators', () async {
    final session = ActiveJourneySession(
      clock: () => now,
      resolve: (v, j, n, p) async => running(v, j, n),
    );
    addTearDown(session.dispose);
    await session.selectVehicle(detected(), [saved()]);
    session.confirmJourney(session.service!.matches.single);
    session.reconcile([saved(origin: 'Other')]);
    expect(session.service!.matches, isEmpty);
    expect(session.selectedKey, isNull);
  });
  test(
    'a reused physical vehicle serving a different trip is not followed',
    () async {
      final session = ActiveJourneySession(
        clock: () => now,
        resolve: (v, j, n, p) async => running(v, j, n),
        vehicles: (v) async => [],
      );
      addTearDown(session.dispose);
      await session.selectVehicle(detected(), [saved()]);
      session.confirmJourney(session.service!.matches.single);
      await session.refresh([saved()]);
      expect(session.error, isNotNull);
      expect(session.labelFor(saved(), false), 'Last confirmed');
    },
  );
  test(
    'selection expires without starting any background timer or GPS work',
    () async {
      var clock = now;
      final session = ActiveJourneySession(
        clock: () => clock,
        resolve: (v, j, n, p) async => running(v, j, n),
      );
      addTearDown(session.dispose);
      await session.selectVehicle(detected(), [saved()]);
      clock = now.add(ActiveJourneySession.lifetime);
      expect(session.hasSelection, isFalse);
      expect(session.labelFor(saved(), false), isNull);
      await session.refresh([saved()]);
      expect(session.vehicle, isNull);
    },
  );
}
