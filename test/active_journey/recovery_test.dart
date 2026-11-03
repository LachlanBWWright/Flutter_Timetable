import 'dart:async';

import 'package:drift/drift.dart' show Value;

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/recovery.dart';
import 'package:lbww_flutter/active_journey/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

class MemoryStore implements ActiveJourneyRecoveryStore {
  ActiveJourneyRecovery? value;
  @override
  Future<ActiveJourneyRecovery?> read() async => value;
  @override
  Future<void> write(ActiveJourneyRecovery? recovery) async => value = recovery;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'missing match retains confirmation but cannot promote stale evidence',
    () async {
      var matches = true;
      final session = ActiveJourneySession(
        clock: () => now,
        vehicles: (v) async => [detected()],
        resolve: (v, j, n, p) async => matches
            ? running(v, j, n)
            : RunningService(vehicle: v, stops: [], matches: [], checkedAt: n),
      );
      addTearDown(session.dispose);
      await session.selectVehicle(detected(), [saved()]);
      session.confirmJourney(session.service!.matches.single);
      matches = false;
      await session.refresh([saved()]);
      expect(session.confirmedMatch!.journey.id, saved().id);
      expect(session.selectedKey, '1:false');
      expect(session.labelFor(saved(), false), 'Last confirmed');
      expect(session.fresh, isFalse);
      expect(session.confirmedMatchIsLive, isFalse);
      matches = true;
      await session.refresh([saved()]);
      expect(session.fresh, isTrue);
      expect(session.confirmedMatchIsLive, isTrue);
    },
  );

  test(
    'recovery requires explicit resume then validates against fresh feed',
    () async {
      final store = MemoryStore();
      final first = ActiveJourneySession(
        recoveryStore: store,
        clock: () => now,
        resolve: (v, j, n, p) async => running(v, j, n),
      );
      await first.selectVehicle(detected(), [saved()]);
      first.confirmJourney(first.service!.matches.single);
      first.dispose();
      final pending = Completer<List<dynamic>>();
      var requests = 0;
      final resumed = ActiveJourneySession(
        recoveryStore: store,
        clock: () => now,
        vehicles: (v) async {
          requests++;
          await pending.future;
          return [detected()];
        },
        resolve: (v, j, n, p) async => running(v, j, n),
      );
      addTearDown(resumed.dispose);
      await resumed.loadRecovery([saved()]);
      expect(resumed.recovery?.title, 'A → C');
      expect(resumed.hasSelection, isFalse);
      expect(requests, 0);
      final task = resumed.resumeRecovery([saved()]);
      expect(resumed.labelFor(saved(), false), 'Last confirmed');
      expect(resumed.fresh, isFalse);
      pending.complete([]);
      await task;
      expect(resumed.fresh, isTrue);
      expect(resumed.recovery, isNull);
      resumed.end();
      expect(store.value, isNull);
    },
  );

  test('expired and edited saved journeys cannot be resumed', () async {
    final snapshot = ActiveJourneyRecovery(
      vehicle: detected(),
      match: running(detected(), [saved()], now).matches.single,
      selectedAt: now,
      confirmedAt: now,
    );
    for (final expired in [false, true]) {
      final store = MemoryStore()..value = snapshot;
      final session = ActiveJourneySession(
        recoveryStore: store,
        clock: () => expired ? now.add(ActiveJourneySession.lifetime) : now,
      );
      await session.loadRecovery([expired ? saved() : saved(origin: 'Other')]);
      expect(session.recovery, isNull);
      expect(store.value, isNull);
      session.dispose();
    }
  });

  test('renames update confirmation while mode edits invalidate it', () async {
    final session = ActiveJourneySession(
      clock: () => now,
      resolve: (v, j, n, p) async => running(v, j, n),
    );
    addTearDown(session.dispose);
    await session.selectVehicle(detected(), [saved()]);
    session.confirmJourney(session.service!.matches.single);
    session.reconcile([saved().copyWith(origin: 'Renamed')]);
    expect(session.confirmedMatch!.origin, 'Renamed');
    session.reconcile([saved().copyWith(mode: const Value('bus'))]);
    expect(session.confirmedMatch, isNull);
    expect(session.selectedKey, isNull);
  });

  test(
    'preferences round trip excludes coordinates and ordered clear wins',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesJourneyRecoveryStore();
      final snapshot = ActiveJourneyRecovery(
        vehicle: detected(),
        match: ActiveJourneyMatch(
          journey: saved(),
          reverse: false,
          stops: pattern().take(2).toList(),
          currentLegDestinationId: 'B',
          currentLegDestinationName: 'Beta',
          currentLegIndex: 1,
        ),
        selectedAt: now,
        confirmedAt: now,
      );
      await store.write(snapshot);
      final restored = await store.read();
      expect(restored!.vehicle.service!.key, identity.key);
      expect(restored.match.stops.map((s) => s.id), ['A', 'B']);
      expect(restored.match.hasOnwardTravel, isTrue);
      expect(restored.match.currentDestination, 'Beta');
      expect(restored.match.currentLegIndex, 1);
      expect(restored.vehicle.latitude, 0);
      await Future.wait([store.write(snapshot), store.write(null)]);
      expect(await store.read(), isNull);
    },
  );
}
