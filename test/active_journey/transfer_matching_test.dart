import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/resolver.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart' show Journey;
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

import 'fixtures.dart';
import 'resolver_test.dart' as existing;

api.Leg connector(String from, String to) => api.Leg(
  origin: api.Stop(id: from, name: from, type: 'stop'),
  destination: api.Stop(id: to, name: to, type: 'stop'),
);
api.TripJourney itinerary(List<api.Leg> legs) => api.TripJourney(legs: legs);

void main() {
  Future<RunningService> resolve(api.TripJourney plan, Journey journey) =>
      ActiveServiceResolver(
        updates: (_) async =>
            existing.updates([existing.update(origin: false)]),
        stored: (o, d) async =>
            o == journey.originId ? existing.snapshot(plan) : null,
        stopInfo: (id) async => (name: id, parent: null),
      ).resolve(detected(), [journey], now);

  test(
    'walking connectors retain intended endpoint and current vehicle segment',
    () async {
      final result = await resolve(
        itinerary([
          connector('W', 'A'),
          existing.plan().legs.single,
          connector('C', 'Z'),
        ]),
        saved(origin: 'W', destination: 'Z'),
      );
      final match = result.matches.single;
      expect(match.destination, 'Z');
      expect(match.currentDestination, 'Gamma');
      expect(match.currentLegIndex, 1);
      expect(match.hasOnwardTravel, isTrue);
      expect(match.stops.first.id, 'A');
      expect(match.stops.last.id, 'C');
    },
  );

  test(
    'onward transfer never extends vehicle stopping pattern to final stop',
    () async {
      final result = await resolve(
        itinerary([existing.plan().legs.single, connector('C', 'Z')]),
        saved(destination: 'Z'),
      );
      expect(result.matches.single.stops.last.id, 'C');
      expect(result.matches.single.hasOnwardTravel, isTrue);
    },
  );

  test('can identify current service after an earlier itinerary leg', () async {
    final result = await resolve(
      itinerary([connector('W', 'A'), existing.plan().legs.single]),
      saved(origin: 'W'),
    );
    expect(result.matches.single.currentLegIndex, 1);
    expect(result.matches.single.hasOnwardTravel, isFalse);
  });

  test('disconnected cached itinerary is rejected', () async {
    final result = await resolve(
      itinerary([connector('W', 'X'), existing.plan().legs.single]),
      saved(origin: 'W'),
    );
    expect(result.matches, isEmpty);
  });

  test(
    'whole itinerary trip ID never identifies an anonymous individual leg',
    () async {
      final source = existing.plan().legs.single;
      final anonymous = api.Leg(
        origin: source.origin,
        destination: source.destination,
        stopSequence: source.stopSequence,
      );
      final result = await resolve(
        api.TripJourney(
          legs: [connector('W', 'A'), anonymous],
          rawJson: {'tripId': 'trip-1'},
        ),
        saved(origin: 'W'),
      );
      expect(result.matches, isEmpty);
    },
  );

  test('multiple matching vehicle legs fail closed', () async {
    final result = await resolve(
      itinerary([
        connector('W', 'A'),
        existing.plan().legs.single,
        connector('C', 'A'),
        existing.plan().legs.single,
      ]),
      saved(origin: 'W'),
    );
    expect(result.matches, isEmpty);
  });

  test(
    'manual transfer journey matches a segment separately from destination',
    () async {
      final manual = Journey(
        id: 7,
        origin: 'Alpha',
        originId: 'A',
        destination: 'Delta',
        destinationId: 'D',
        tripType: 'manualMultiLeg',
        isPinned: false,
        legsJson: const ManualTripDefinition(
          legs: [
            ManualTripLeg(
              index: 0,
              originName: 'Alpha',
              originId: 'A',
              destinationName: 'Gamma',
              destinationId: 'C',
              mode: TransportMode.train,
            ),
            ManualTripLeg(
              index: 1,
              originName: 'Gamma',
              originId: 'C',
              destinationName: 'Delta',
              destinationId: 'D',
              mode: TransportMode.bus,
            ),
          ],
        ).toLegsJson(),
      );
      final result = await resolve(existing.plan(), manual);
      expect(result.matches.single.destination, 'Delta');
      expect(result.matches.single.currentDestination, 'Gamma');
      expect(result.matches.single.hasOnwardTravel, isTrue);
    },
  );
}
