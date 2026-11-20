import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/regional_saved_trip_service.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/wrappers/trip_cache_service/persistence.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  for (final realtime in [false, true]) {
    for (final walking in [false, true]) {
      test(
        'regional trip JSON restores ${walking ? 'walking' : 'riding'} stops, times, routes, and timetable age (live=$realtime)',
        () async {
          const origin = TransitStopRef(
            region: TransitRegion.nsw,
            provider: TransitProviderId.tfnsw,
            sourceId: TransitSourceId('fixture'),
            stopId: 'A',
          );
          const destination = TransitStopRef(
            region: TransitRegion.nsw,
            provider: TransitProviderId.tfnsw,
            sourceId: TransitSourceId('fixture'),
            stopId: 'B',
          );
          final fetched = DateTime.utc(2026, 11, 1);
          final trips = await RegionalSavedTripService.planSavedTrip(
            db.Journey(
              id: 1,
              origin: 'Alpha',
              originId: origin.storageKey,
              destination: 'Beta',
              destinationId: destination.storageKey,
              tripType: 'stops',
              isPinned: false,
            ),
            planLoader: (_) async => JourneyPlan(
              rawPayload: const {'realtimeStatus': 'Fixture live status'},
              timetable: TimetableProvenance(
                fetchedAt: fetched,
                isStale: true,
                offlineFallback: true,
              ),
              journeys: [
                TransitJourney(
                  legs: [
                    TransitLeg(
                      isWalking: walking,
                      isRealtime: realtime,
                      isApproximate: true,
                      plannedDepartureTime: realtime
                          ? DateTime.utc(2026, 11, 7, 0, 58)
                          : null,
                      mode: walking ? null : TransportMode.train,
                      origin: const TransitStop(
                        ref: origin,
                        name: 'Alpha',
                        latitude: -33,
                        longitude: 151,
                      ),
                      destination: const TransitStop(
                        ref: destination,
                        name: 'Beta',
                      ),
                      departureTime: DateTime.utc(2026, 11, 7, 1),
                      arrivalTime: DateTime.utc(2026, 11, 7, 1, 10),
                      route: walking
                          ? null
                          : const TransitRoute(
                              ref: TransitRouteRef(
                                region: TransitRegion.nsw,
                                provider: TransitProviderId.tfnsw,
                                sourceId: TransitSourceId('fixture'),
                                routeId: 'R',
                              ),
                              name: 'Route',
                              shortName: '1',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
          final restored = parseTripCache(
            jsonEncode({
              'journeys': trips.map((t) => t.rawJson).toList(),
              'version': 'regional',
            }),
          );
          final leg = restored!.tripJourneys.single.legs.single;
          expect(leg.origin.id, origin.storageKey);
          expect(leg.origin.name, 'Alpha');
          expect(leg.origin.coord, [-33, 151]);
          expect(leg.destination.id, destination.storageKey);
          expect(
            leg.origin.departureTimePlanned,
            realtime ? '2026-11-07T00:58:00.000Z' : '2026-11-07T01:00:00.000Z',
          );
          expect(leg.transportation!.name, walking ? 'Walk' : 'Route');
          expect(leg.transportation!.product!.classField, walking ? 100 : 1);
          expect(leg.duration, 600);
          expect(leg.stopSequence!.map((stop) => stop.id), [
            origin.storageKey,
            destination.storageKey,
          ]);
          expect(
            leg.origin.departureTimeEstimated,
            realtime ? '2026-11-07T01:00:00.000Z' : null,
          );
          expect(leg.isRealtimeControlled, realtime);
          expect(restored.tripJourneys.single.rawJson['isApproximate'], isTrue);
          expect(
            restored.tripJourneys.single.rawJson['realtimeStatus'],
            'Fixture live status',
          );
          expect(leg.rawJson['provenance'], 'regional_journey_planner');
          expect(leg.origin.rawJson['stopStorageKey'], origin.storageKey);
          expect(
            TimetableProvenance.tryParse(
              restored.tripJourneys.single.rawJson['timetable'],
            )!.fetchedAt,
            fetched,
          );
        },
      );
    }
  }
  test(
    'static departures find previous-day service using the agency timezone',
    () async {
      final data = plannerData(
        timezone: 'Australia/Adelaide',
        serviceDate: '20260812',
        times: 'T1,25:00:00,25:00:00,A,1,0,0\nT1,25:10:00,25:10:00,C,2,0,0\n',
      );
      final repository = AdelaideMetroDepartureRepository(
        loadData: () async => data,
      );
      const stop = TransitStopRef(
        region: TransitRegion.southAustralia,
        provider: TransitProviderId.adelaideMetro,
        sourceId: TransitSourceId('sa:static'),
        stopId: 'A',
      );
      final departures = await repository.getDepartures(
        DepartureRequest(stop: stop, when: DateTime.utc(2026, 8, 12, 15, 25)),
      );
      expect(departures, hasLength(1));
      expect(departures.single.plannedTime, DateTime.utc(2026, 8, 12, 15, 30));
    },
  );

  test(
    'departure ownership is checked before invoking the timetable loader',
    () async {
      var loads = 0;
      final repository = AdelaideMetroDepartureRepository(
        loadData: () async {
          loads++;
          return plannerData();
        },
      );
      await expectLater(
        repository.getDepartures(DepartureRequest(stop: plannerStop('A'))),
        throwsA(isA<InvalidJourneyRequest>()),
      );
      expect(loads, 0);
    },
  );
}
