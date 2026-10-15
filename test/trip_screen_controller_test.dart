import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
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
  test('newer request wins when older request completes later', () async {
    final first = Completer<TripCacheSnapshot>();
    final second = Completer<TripCacheSnapshot>();
    var count = 0;
    final controller = TripScreenController(
      trip: journey(),
      startAgingTimer: false,
      cacheLoader:
          ({
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
