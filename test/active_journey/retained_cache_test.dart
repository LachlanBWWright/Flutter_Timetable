import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:option_result/option_result.dart';

import 'fixtures.dart';

void main() {
  test(
    'retained reads keep boarded departures while next-trip reads filter them',
    () async {
      var fetches = 0;
      var clock = now;
      final response = GetTripsResponse(
        tripJourneys: [
          TripJourney(
            legs: [
              Leg(
                origin: Stop(
                  id: 'A',
                  name: 'A',
                  type: 'stop',
                  departureTimePlanned: now
                      .subtract(const Duration(minutes: 10))
                      .toIso8601String(),
                ),
                destination: Stop(
                  id: 'C',
                  name: 'C',
                  type: 'stop',
                  arrivalTimePlanned: now
                      .add(const Duration(minutes: 10))
                      .toIso8601String(),
                ),
              ),
            ],
          ),
        ],
        systemMessages: const SystemMessages(),
        version: 'test',
        rawJson: const {},
      );
      final repository = TripCacheRepository(
        clock: () => clock,
        fetchTrips: (_, _) async {
          fetches++;
          return Ok(response);
        },
        readCache: (_, _) async => null,
        writeCache: (_, _, _) async {},
      );
      await repository.getSnapshotOrFetch(originId: 'A', destinationId: 'C');
      expect(
        repository.peekSnapshot('A', 'C')!.response!.tripJourneys,
        isEmpty,
      );
      expect(
        (await repository.getRetainedSnapshot(
          'A',
          'C',
        ))!.response!.tripJourneys,
        hasLength(1),
      );
      expect(fetches, 1);
      clock = now.add(const Duration(hours: 24));
      expect(
        (await repository.getRetainedSnapshot('A', 'C'))!.response,
        isNull,
      );
      expect(fetches, 1);
    },
  );
}
