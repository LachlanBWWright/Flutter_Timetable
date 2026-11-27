import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/trip_screen/controller.dart';
import 'package:lbww_flutter/wrappers/trip_cache_service/trip_cache_snapshot.dart';

Journey journey() => const Journey(
  id: 1,
  origin: 'A',
  originId: 'a',
  destination: 'B',
  destinationId: 'b',
  tripType: 'direct',
  isPinned: false,
);
TripCacheSnapshot snapshot({String version = 'v'}) => TripCacheSnapshot(
  response: GetTripsResponse(
    tripJourneys: const [],
    systemMessages: const SystemMessages(),
    version: version,
    rawJson: {'version': version},
  ),
  fetchedAt: DateTime.utc(2026),
  isFresh: true,
);

void main() {
  test(
    'retrying a saved manual trip replaces its error with the journey',
    () async {
      final trip = journey().copyWith(tripType: 'manualMultiLeg');
      final rendered = TripJourney(legs: const [], rawJson: {'manual': true});
      var attempts = 0;
      final controller = TripScreenController(
        trip: trip,
        startAgingTimer: false,
        manualBuilder: (savedTrip) async {
          expect(savedTrip, trip);
          return ++attempts == 1 ? null : rendered;
        },
        cacheLoader: ({
          required originId,
          required destinationId,
          required forceRefresh,
        }) => throw StateError('Manual trips should use the manual builder'),
      );
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.state.error, 'Unable to load the saved manual trip.');
      expect(controller.state.isLoading, isFalse);

      await controller.load(forceRefresh: true);
      expect(attempts, 2);
      expect(controller.state.error, isNull);
      expect(controller.state.trips, [rendered]);
      expect(controller.state.rawTripJson, contains('"manual": true'));
    },
  );

  test('a malformed saved stop reference is rejected before lookup', () async {
    final controller = TripScreenController(
      trip: journey().copyWith(originId: 'nsw|tfnsw|missing-stop-id'),
      startAgingTimer: false,
      cacheLoader: ({
        required originId,
        required destinationId,
        required forceRefresh,
      }) => throw StateError('Malformed references should be rejected first'),
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.error, 'Saved trip cannot be loaded.');
    expect(controller.state.trips, isEmpty);
    expect(controller.state.isLoading, isFalse);
  });

  test(
    'custom planning forwards constraints and cancels work when disposed',
    () async {
      final entered = Completer<JourneyPlanRequest>();
      final trip = const Journey(
        id: 1,
        origin: 'A',
        originId: 'nsw|tfnsw|fixture|A',
        destination: 'B',
        destinationId: 'nsw|tfnsw|fixture|B',
        tripType: 'stops',
        isPinned: false,
      );
      final controller = TripScreenController(
        trip: trip,
        startAgingTimer: false,
        regionalPlanLoader: (request) async {
          entered.complete(request);
          await request.cancellation!.whenCancelled;
          request.cancellation!.throwIfCancelled();
          return const JourneyPlan(journeys: []);
        },
      );
      controller.planningTime = DateTime.utc(2026, 11, 7, 3);
      controller.arrivalBased = true;
      controller.walkingLimit = const Duration(minutes: 5);
      controller.accessibility = TransitAccessibility.stepFreeOnly;
      final work = controller.load();
      final request = await entered.future;
      expect(request.when, controller.planningTime);
      expect(request.arrivalBased, isTrue);
      expect(request.walkingLimit, const Duration(minutes: 5));
      expect(request.accessibility, TransitAccessibility.stepFreeOnly);
      controller.dispose();
      await work;
      expect(request.cancellation!.isCancelled, isTrue);
    },
  );

  test('newer request wins when older request completes later', () async {
    final first = Completer<TripCacheSnapshot>();
    final second = Completer<TripCacheSnapshot>();
    var count = 0;
    final controller = TripScreenController(
      trip: journey(),
      startAgingTimer: false,
      cacheLoader: ({
        required originId,
        required destinationId,
        required forceRefresh,
      }) => ++count == 1 ? first.future : second.future,
    );
    final oldLoad = controller.load();
    final newLoad = controller.load(forceRefresh: true);
    second.complete(snapshot(version: 'new'));
    await newLoad;
    first.complete(snapshot(version: 'old'));
    await oldLoad;
    expect(controller.state.rawTripJson, contains('new'));
    expect(controller.state.isLoading, isFalse);
    controller.dispose();
  });

  test('programming errors propagate from the cache loader', () async {
    final controller = TripScreenController(
      trip: journey(),
      startAgingTimer: false,
      cacheLoader:
          ({
            required originId,
            required destinationId,
            required forceRefresh,
          }) async {
            throw StateError('programming defect');
          },
    );
    await expectLater(controller.load(), throwsA(isA<StateError>()));
    controller.dispose();
  });

  test('operational exceptions produce the retryable friendly error', () async {
    final controller = TripScreenController(
      trip: journey(),
      startAgingTimer: false,
      cacheLoader:
          ({
            required originId,
            required destinationId,
            required forceRefresh,
          }) async {
            throw Exception('network unavailable');
          },
    );
    await controller.load();
    expect(controller.state.error, 'Unable to load journeys. Please retry.');
    expect(controller.state.isLoading, isFalse);
    controller.dispose();
  });

  test('snapshot trips collection is immutable', () {
    final values = <TripJourney>[];
    final state = TripScreenState(trips: values);
    values.add(TripJourney(legs: const []));
    expect(state.trips, isEmpty);
    expect(
      () => state.trips.add(TripJourney(legs: const [])),
      throwsUnsupportedError,
    );
  });
}
