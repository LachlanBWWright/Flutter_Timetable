import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/home/home_controller.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/wrappers/journey_service_impl.dart';

void main() {
  test(
    'controller distinguishes load failure and preserves previous journeys',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final journey = db.Journey(
        id: 4,
        origin: 'Central',
        originId: 'central',
        destination: 'Town Hall',
        destinationId: 'town-hall',
        tripType: SavedTripType.direct.storageValue,
        isPinned: false,
      );
      final controller = HomeController(
        database: database,
        initialJourneys: [journey],
        loadJourneys: (_) async => const JourneyLoadResult(
          pinnedJourneys: [],
          unpinnedJourneys: [],
          succeeded: false,
        ),
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.loadFailed, isTrue);
      expect(controller.state.journeys, [journey]);
    },
  );

  test('a stale load cannot replace a newer result', () async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final first = Completer<JourneyLoadResult>();
    var requests = 0;
    final controller = HomeController(
      database: database,
      loadJourneys: (_) {
        requests++;
        if (requests == 1) return first.future;
        // This const result exercises sorting with immutable repository data.
        return Future.value(
          const JourneyLoadResult(pinnedJourneys: [], unpinnedJourneys: []),
        );
      },
    );
    addTearDown(controller.dispose);
    final staleLoad = controller.load();
    await controller.load();
    first.complete(
      const JourneyLoadResult(
        pinnedJourneys: [],
        unpinnedJourneys: [],
        succeeded: false,
      ),
    );
    await staleLoad;

    expect(controller.state.loadFailed, isFalse);
  });

  test('publishes database rows before location sorting completes', () async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final journey = db.Journey(
      id: 7,
      origin: 'Central',
      originId: 'central',
      destination: 'Town Hall',
      destinationId: 'town-hall',
      tripType: SavedTripType.direct.storageValue,
      isPinned: false,
    );
    final sorting = Completer<List<db.Journey>>();
    final controller = HomeController(
      database: database,
      loadJourneys: (_) async =>
          JourneyLoadResult(pinnedJourneys: [], unpinnedJourneys: [journey]),
      sortJourneys: (_) => sorting.future,
    );
    addTearDown(controller.dispose);

    final loading = controller.load();
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.journeys, [journey]);
    expect(controller.state.isLoading, isTrue);
    sorting.complete([journey]);
    await loading;
  });

  test(
    'reports rejected actions and exposes immutable journey lists',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final mutableInput = <db.Journey>[];
      final controller = HomeController(
        database: database,
        initialJourneys: mutableInput,
        deleteJourney: (_, _) async => false,
      );
      addTearDown(controller.dispose);

      mutableInput.add(
        db.Journey(
          id: 8,
          origin: 'A',
          originId: 'a',
          destination: 'B',
          destinationId: 'b',
          tripType: SavedTripType.direct.storageValue,
          isPinned: false,
        ),
      );
      await controller.delete(8);

      expect(controller.state.actionError, 'Could not delete this trip.');
      expect(controller.state.journeys, isEmpty);
      expect(
        () => controller.state.journeys.add(mutableInput.single),
        throwsUnsupportedError,
      );
    },
  );

  test('disposed controller starts no new load I/O', () async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    var loads = 0;
    final controller = HomeController(
      database: database,
      loadJourneys: (_) async {
        loads++;
        return const JourneyLoadResult(
          pinnedJourneys: [],
          unpinnedJourneys: [],
        );
      },
    );
    controller.dispose();

    await controller.load();

    expect(loads, 0);
  });
}
