import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:option_result/option_result.dart';

GetTripsResponse responseAt(DateTime? departure) => GetTripsResponse(
  tripJourneys: [
    TripJourney(
      legs: [
        Leg(
          origin: Stop(
            id: 'o',
            name: 'Origin',
            type: 'stop',
            departureTimePlanned: departure?.toIso8601String(),
          ),
          destination: Stop(id: 'd', name: 'Destination', type: 'stop'),
        ),
      ],
    ),
  ],
  systemMessages: const SystemMessages(),
  version: 'test',
  rawJson: const {},
);

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  TripCacheRepository repository(
    TripCacheEntry entry, {
    DateTime Function()? clock,
    TripCacheFetch? fetch,
  }) => TripCacheRepository(
    clock: clock ?? () => now,
    readCache: (o, d) async => entry,
    fetchTrips: fetch ?? (o, d) async => const Err('Offline'),
    writeCache: (o, d, value) async {},
    markError: (o, d, error) async {},
    deleteCache: (o, d) async {},
    deleteAll: () async {},
  );

  test('10-minute boundary refreshes and labels the fallback stale', () async {
    var calls = 0;
    final entry = TripCacheEntry(
      response: responseAt(now.add(const Duration(hours: 1))),
      fetchedAt: now.subtract(const Duration(minutes: 10)),
    );
    final snapshot = await repository(
      entry,
      fetch: (o, d) async {
        calls++;
        return const Err('Offline');
      },
    ).getSnapshotOrFetch(originId: 'o', destinationId: 'd');
    expect(calls, 1);
    expect(snapshot.isStale, isTrue);
    expect(snapshot.isOffline, isFalse);
    expect(snapshot.error, 'Offline');
    expect(snapshot.hasUsableData, isTrue);
    expect(snapshot.fetchedAt, entry.fetchedAt);
  });

  test(
    '24-hour boundary cannot return usable departures after refresh failure',
    () async {
      for (final age in [const Duration(hours: 24), const Duration(days: 2)]) {
        final snapshot = await repository(
          TripCacheEntry(
            response: responseAt(now.add(const Duration(hours: 1))),
            fetchedAt: now.subtract(age),
          ),
        ).getSnapshotOrFetch(originId: 'o', destinationId: 'd');
        expect(snapshot.isExpired, isTrue);
        expect(snapshot.response, isNull);
        expect(snapshot.hasUsableData, isFalse);
      }
    },
  );

  test('fresh cache is filtered again as clock passes its departure', () async {
    var clock = now;
    var fetches = 0;
    final repo = repository(
      TripCacheEntry(
        response: responseAt(now.add(const Duration(minutes: 1))),
        fetchedAt: now,
      ),
      clock: () => clock,
      fetch: (o, d) async {
        fetches++;
        return const Err('Offline');
      },
    );
    expect(
      (await repo.getSnapshotOrFetch(
        originId: 'o',
        destinationId: 'd',
      )).response!.tripJourneys,
      hasLength(1),
    );
    clock = now.add(const Duration(minutes: 2));
    final snapshot = await repo.getSnapshotOrFetch(
      originId: 'o',
      destinationId: 'd',
    );
    expect(fetches, 1);
    expect(snapshot.response!.tripJourneys, isEmpty);
  });

  test(
    'undated and already departed cached journeys are never shown',
    () async {
      for (final departure in [
        null,
        now.subtract(const Duration(minutes: 1)),
      ]) {
        final snapshot = await repository(
          TripCacheEntry(response: responseAt(departure), fetchedAt: now),
        ).getSnapshotOrFetch(originId: 'o', destinationId: 'd');
        expect(snapshot.response!.tripJourneys, isEmpty);
      }
    },
  );

  test(
    'failed database refresh preserves successful payload timestamp',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final fetchedAt = now.subtract(const Duration(hours: 23));
      await database.upsertTripPlannerCache(
        originId: 'o',
        destinationId: 'd',
        fetchedAt: fetchedAt,
        responseJson: '{"journeys": []}',
      );
      await database.markTripPlannerCacheError(
        originId: 'o',
        destinationId: 'd',
        fetchedAt: now,
        error: 'Offline',
      );
      final stored = await database.getTripPlannerCache('o', 'd');
      expect(stored!.fetchedAt.toUtc(), fetchedAt.toUtc());
      expect(stored.responseJson, '{"journeys": []}');
      expect(stored.error, 'Offline');
    },
  );
}
