import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/resolver.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/vehicle_finder/provider.dart';

import 'fixtures.dart';

TripUpdate update({String date = '20261020', bool origin = true}) => TripUpdate(
  trip: TripDescriptor(
    tripId: 'trip-1',
    routeId: 'T1',
    startDate: date,
    startTime: '11:50:00',
  ),
  timestamp: Int64(now.millisecondsSinceEpoch ~/ 1000),
  stopTimeUpdate: [
    for (final stop in pattern().where((s) => origin || s.id != 'A'))
      TripUpdate_StopTimeUpdate(
        stopId: stop.id,
        stopSequence: stop.sequence,
        arrival: TripUpdate_StopTimeEvent(
          time: Int64(stop.arrival!.millisecondsSinceEpoch ~/ 1000),
        ),
        departure: TripUpdate_StopTimeEvent(
          time: Int64(stop.departure!.millisecondsSinceEpoch ~/ 1000),
        ),
      ),
  ],
);
TripUpdateAggregationResult updates(List<TripUpdate> values) =>
    TripUpdateAggregationResult(
      tripUpdates: values,
      breakdown: const {},
      metadata: RealtimeSnapshotMetadata(fetchedAt: now),
    );
api.TripJourney plan({
  String tripId = 'trip-1',
  String routeId = 'T1',
  String date = '20261020',
}) => api.TripJourney(
  legs: [
    api.Leg(
      origin: api.Stop(
        id: 'A',
        name: 'Alpha',
        type: 'stop',
        departureTimePlanned: now
            .subtract(const Duration(minutes: 10))
            .toIso8601String(),
      ),
      destination: api.Stop(
        id: 'C',
        name: 'Gamma',
        type: 'stop',
        arrivalTimePlanned: now
            .add(const Duration(minutes: 10))
            .toIso8601String(),
      ),
      stopSequence: [api.Stop(id: 'B', name: 'Beta', type: 'stop')],
      transportation: api.Transportation(id: routeId),
      rawJson: {'tripId': tripId, 'startDate': date},
    ),
  ],
);
TripCacheSnapshot snapshot(api.TripJourney value) => TripCacheSnapshot(
  response: api.GetTripsResponse(
    tripJourneys: [value],
    systemMessages: const api.SystemMessages(),
    version: 'test',
    rawJson: const {},
  ),
  fetchedAt: now,
);

void main() {
  test(
    'resolves exact service calls and preserves destination ambiguity',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update()]),
        stored: (_, _) async => null,
        stopInfo: (id) async => (name: 'Stop $id', parent: null),
      );
      final result = await resolver.resolve(detected(), [
        saved(),
        saved(id: 2, destination: 'D'),
      ], now);
      expect(result.matches, hasLength(2));
      expect(result.stops.first.name, 'Stop A');
      expect(result.matches.every((m) => !m.reverse), isTrue);
    },
  );
  test(
    'retains departed plans independently and avoids repeated storage reads',
    () async {
      var reads = 0;
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update(origin: false)]),
        stored: (o, d) async {
          reads++;
          return o == 'A' ? snapshot(plan()) : null;
        },
        stopInfo: (id) async => (name: id, parent: null),
      );
      final initial = await resolver.resolve(detected(), [saved()], now);
      expect(initial.matches, hasLength(1));
      expect(initial.matches.single.plannedTrip, isNotNull);
      expect(reads, 2);
      final refreshed = await resolver.resolve(
        detected(),
        [saved()],
        now.add(const Duration(seconds: 30)),
        previous: initial,
      );
      expect(refreshed.matches, hasLength(1));
      expect(refreshed.retainedTrips, hasLength(1));
      expect(reads, 2);
    },
  );
  test(
    'matching route or wrong service date never substitutes for trip identity',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async =>
            updates([update(date: '20261019', origin: false)]),
        stored: (_, _) async => snapshot(plan(tripId: 'another-trip')),
        stopInfo: (id) async => (name: id, parent: null),
      );
      final result = await resolver.resolve(detected(), [saved()], now);
      expect(result.matches, isEmpty);
    },
  );
  test(
    'multiple matching departures fail closed rather than selecting the first',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update(), update()]),
        stored: (_, _) async => null,
      );
      await expectLater(
        resolver.resolve(detected(), [saved()], now),
        throwsA(isA<VehicleFinderException>()),
      );
    },
  );
  test(
    'explicit realtime trip IDs bridge planner and GTFS route namespaces',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update(origin: false)]),
        stored: (_, _) async => snapshot(plan(routeId: 'efa:T1:outbound')),
        stopInfo: (id) async => (name: id, parent: null),
      );
      final result = await resolver.resolve(detected(), [saved()], now);
      expect(result.matches, hasLength(1));
    },
  );

  test(
    'cached data cannot revive a segment already passed by the vehicle',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update()]),
        stored: (_, _) async => snapshot(plan()),
        stopInfo: (id) async => (name: id, parent: null),
      );
      final result = await resolver.resolve(detected(sequence: 4, stop: null), [
        saved(),
      ], now);
      expect(result.matches, isEmpty);
    },
  );
  test('same trip ID on a different cached service date is rejected', () async {
    final resolver = ActiveServiceResolver(
      updates: (_) async => updates([]),
      stored: (_, _) async => snapshot(plan(date: '20261019')),
    );
    final result = await resolver.resolve(detected(), [saved()], now);
    expect(result.matches, isEmpty);
  });
  test(
    'old trip timestamps do not become fresh because the feed was just fetched',
    () async {
      final old = update()
        ..timestamp = Int64(now.millisecondsSinceEpoch ~/ 1000 - 120);
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([old]),
        stored: (_, _) async => null,
      );
      await expectLater(
        resolver.resolve(detected(), [saved()], now),
        throwsA(isA<VehicleFinderException>()),
      );
    },
  );
  test(
    'a cache read failure does not hide an exact live stopping pattern',
    () async {
      final resolver = ActiveServiceResolver(
        updates: (_) async => updates([update()]),
        stored: (_, _) async => throw StateError('closed cache'),
        stopInfo: (id) async => (name: id, parent: null),
      );
      final result = await resolver.resolve(detected(), [saved()], now);
      expect(result.matches, hasLength(1));
      expect(result.partial, isTrue);
    },
  );

  test('missing cached data is retried after a bounded interval', () async {
    var reads = 0;
    final resolver = ActiveServiceResolver(
      updates: (_) async => updates([]),
      stored: (_, _) async {
        reads++;
        return null;
      },
    );
    final initial = await resolver.resolve(detected(), [saved()], now);
    await resolver.resolve(
      detected(),
      [saved()],
      now.add(const Duration(seconds: 30)),
      previous: initial,
    );
    expect(reads, 2);
    await resolver.resolve(
      detected(),
      [saved()],
      now.add(const Duration(minutes: 6)),
      previous: initial,
    );
    expect(reads, 4);
  });
}
