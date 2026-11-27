import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/saved_trip_render_service.dart';

void main() {
  test(
    'manual trip resolves scoped stops and falls back when a stop is missing',
    () async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await database.insertStop(
        StopsCompanion.insert(
          endpoint: 'other-feed',
          stopId: 'shared',
          stopName: 'Wrong station',
        ),
      );
      await database.insertStop(
        StopsCompanion.insert(
          endpoint: 'rail-feed',
          stopId: 'shared',
          stopName: 'Central Station',
          stopLat: const Value(-33.88),
          stopLon: const Value(151.20),
        ),
      );

      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Saved Central',
            originId: 'nsw|tfnsw|rail-feed|shared',
            destinationName: 'Saved Redfern',
            destinationId: 'nsw|tfnsw|rail-feed|redfern',
            mode: TransportMode.train,
            lineId: 'T1',
            lineName: 'North Shore Line',
          ),
        ],
      );
      final journey = Journey(
        id: 1,
        origin: 'Saved Central',
        originId: definition.legs.single.originId,
        destination: 'Saved Redfern',
        destinationId: definition.legs.single.destinationId,
        tripType: SavedTripType.manualMultiLeg.storageValue,
        legsJson: definition.toLegsJson(),
        isPinned: false,
      );

      final rendered = await SavedTripRenderService.buildManualTripJourney(
        journey,
        database: database,
      );

      final leg = rendered!.legs.single;
      expect(leg.origin.id, 'shared');
      expect(leg.origin.name, 'Central Station');
      expect(leg.origin.coord, [-33.88, 151.20]);
      expect(leg.origin.rawJson['transitSourceId'], 'rail-feed');
      expect(leg.destination.name, 'Saved Redfern');
      expect(leg.destination.coord, isNull);
      expect(leg.stopSequence, [leg.origin, leg.destination]);
      expect(leg.transportation?.name, 'North Shore Line');
      expect(leg.isRealtimeControlled, isFalse);
    },
  );
}
