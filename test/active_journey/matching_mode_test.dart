import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/resolver.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

import 'fixtures.dart';
import 'resolver_test.dart' as existing;

api.Leg vehicleLeg({int product = 1}) {
  final leg = existing.plan().legs.single;
  return api.Leg(
    origin: leg.origin,
    destination: leg.destination,
    stopSequence: leg.stopSequence,
    rawJson: leg.rawJson,
    transportation: api.Transportation(
      product: api.Product(classField: product),
    ),
  );
}

Future<RunningService> resolve(
  api.TripJourney plan, {
  String mode = 'train',
  String destination = 'C',
}) =>
    ActiveServiceResolver(
      updates: (_) async => existing.updates([]),
      stored: (o, d) async => o == 'A' ? existing.snapshot(plan) : null,
      stopInfo: (id) async => (name: id, parent: null),
    ).resolve(detected(), [
      saved(destination: destination).copyWith(mode: Value(mode)),
    ], now);

void main() {
  test('cached train service does not infer a saved bus journey', () async {
    final result = await resolve(existing.plan(), mode: 'bus');
    expect(result.matches, isEmpty);
  });
  test('per-leg product rejects trip IDs colliding across feeds', () async {
    final result = await resolve(
      api.TripJourney(legs: [vehicleLeg(product: 5)]),
    );
    expect(result.matches, isEmpty);
  });
  test(
    'mixed transfer plan accepts correct current vehicle leg mode',
    () async {
      final result = await resolve(
        api.TripJourney(
          legs: [
            vehicleLeg(),
            api.Leg(
              origin: api.Stop(id: 'C', name: 'Gamma', type: 'stop'),
              destination: api.Stop(id: 'Z', name: 'Zeta', type: 'stop'),
              transportation: api.Transportation(
                product: api.Product(classField: 5),
              ),
              rawJson: {'tripId': 'another-trip'},
            ),
          ],
        ),
        destination: 'Z',
      );
      expect(result.matches, hasLength(1));
      expect(result.matches.single.currentLegDestinationId, 'C');
      expect(result.matches.single.hasOnwardTravel, isTrue);
    },
  );
}
