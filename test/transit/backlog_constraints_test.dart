import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_realtime_updates.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

GtfsData interchange({
  String transfer = '',
  String path = '',
  bool accessible = true,
}) => parseGtfsFiles({
  'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Brisbane\n',
  'stops.txt': 'stop_id,stop_name,location_type,parent_station,wheelchair_boarding\nA,Alpha,0,,1\nB,Beta,0,P,1\nX,Platform,0,P,1\nP,Parent,1,,1\nC,Gamma,0,,1\n',
  'routes.txt':
      'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
  'trips.txt':
      'route_id,service_id,trip_id,wheelchair_accessible\nR,S,T1,${accessible ? 1 : 0}\nR,S,T2,${accessible ? 1 : 0}\n',
  'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
  'stop_times.txt': 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT1,10:00:00,10:00:00,A,1\nT1,10:10:00,10:10:00,B,2\nT2,10:15:00,10:15:00,X,1\nT2,10:30:00,10:30:00,C,2\n',
  if (transfer.isNotEmpty) 'transfers.txt': transfer,
  if (path.isNotEmpty) 'pathways.txt': path,
});
const pathHeader =
    'pathway_id,from_stop_id,to_stop_id,pathway_mode,is_bidirectional,traversal_time\n';
void main() {
  test('published in-seat links connect terminal trips without using a walking budget', () async {
    final data = interchange(
      transfer: 'from_stop_id,to_stop_id,transfer_type,from_trip_id,to_trip_id\nB,X,4,T1,T2\n',
    );
    final plan = await fixturePlanner(data)
        .planJourney(plannerRequest(walkingLimit: Duration.zero));
    expect(plan.journeys.single.legs, hasLength(2));
    expect(plan.journeys.single.legs.every((leg) => !leg.isWalking), isTrue);
    final reboard = interchange(
      transfer: 'from_stop_id,to_stop_id,transfer_type,from_trip_id,to_trip_id\nB,X,5,T1,T2\n',
    );
    expect(
      (await fixturePlanner(reboard)
              .planJourney(plannerRequest(walkingLimit: Duration.zero)))
          .journeys,
      isEmpty,
    );
  });

  test(
    'positive walking budget includes the entire platform interchange',
    () async {
      final planner = fixturePlanner(interchange());
      expect(
        (await planner.planJourney(
          plannerRequest(walkingLimit: const Duration(seconds: 119)),
        )).journeys,
        isEmpty,
      );
      final plan = await planner.planJourney(
        plannerRequest(walkingLimit: const Duration(seconds: 120)),
      );
      expect(
        plan.journeys.single.legs
            .where((l) => l.isWalking)
            .single
            .arrivalTime!
            .difference(plan.journeys.single.legs[1].departureTime!),
        const Duration(seconds: 120),
      );
    },
  );
  test(
    'published pathways replace inferred links and preserve direction',
    () async {
      final data = interchange(path: '${pathHeader}stairs,B,X,2,0,90\n');
      expect(
        (await fixturePlanner(data).planJourney(plannerRequest())).journeys,
        isNotEmpty,
      );
      expect(
        (await fixturePlanner(data).planJourney(
          plannerRequest(accessibility: TransitAccessibility.stepFreeOnly),
        )).journeys,
        isEmpty,
      );
      final elevator = interchange(path: '${pathHeader}lift,B,X,5,0,90\n');
      expect(
        (await fixturePlanner(elevator).planJourney(
          plannerRequest(accessibility: TransitAccessibility.stepFreeOnly),
        )).journeys,
        isNotEmpty,
      );
      final graphStops = elevator.index;
      expect(graphStops.pathways.single.bidirectional, isFalse);
    },
  );
  test(
    'strict access rejects unknown vehicles, preferred allows unknown',
    () async {
      final data = interchange(
        accessible: false,
        path: '${pathHeader}lift,B,X,5,1,90\n',
      );
      expect(
        (await fixturePlanner(data).planJourney(
          plannerRequest(accessibility: TransitAccessibility.stepFreeOnly),
        )).journeys,
        isEmpty,
      );
      expect(
        (await fixturePlanner(data).planJourney(
          plannerRequest(
            accessibility: TransitAccessibility.wheelchairPreferred,
          ),
        )).journeys,
        isNotEmpty,
      );
    },
  );
  for (final rule in ['B,X,3,', 'B,X,2,360']) {
    test('enforces transfer prohibition or minimum: $rule', () async {
      final data = interchange(
        transfer:
            'from_stop_id,to_stop_id,transfer_type,min_transfer_time\n$rule\n',
      );
      expect(
        (await fixturePlanner(data).planJourney(plannerRequest())).journeys,
        isEmpty,
      );
    });
  }
  test(
    'specific trip rule takes precedence over a general prohibition',
    () async {
      final data = interchange(
        transfer: 'from_stop_id,to_stop_id,transfer_type,from_trip_id,to_trip_id\nB,X,3,,\nB,X,0,T1,T2\n',
      );
      expect(
        (await fixturePlanner(data).planJourney(plannerRequest())).journeys,
        isNotEmpty,
      );
    },
  );
  test('service times beyond 167 hours remain usable', () async {
    final data = plannerData(
      serviceDate: '20260806',
      times: 'T1,178:00:00,178:00:00,A,1,0,0\nT1,178:20:00,178:20:00,C,2,0,0\n',
    );
    final result = await fixturePlanner(data).planJourney(plannerRequest());
    expect(
      result.journeys.single.legs.single.departureTime,
      DateTime.utc(2026, 8, 13),
    );
    expect(
      scheduledGtfsDepartures(
        data,
        DepartureRequest(stop: plannerStop('A'), when: plannerRequest().when),
      ),
      hasLength(1),
    );
  });
  test('multi-agency route clocks use their own timezone', () async {
    final base = plannerData();
    final agencies = parseGtfsFiles({
      'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\ne,East,https://example.com,Australia/Brisbane\nw,West,https://example.com,Australia/Perth\n',
      'routes.txt': 'route_id,agency_id,route_short_name,route_long_name,route_type\nR1,w,1,West,3\n',
    });
    final data = GtfsData(
      agencies: agencies.agencies,
      routes: agencies.routes,
      stops: base.stops,
      trips: base.trips,
      stopTimes: base.stopTimes,
      calendars: base.calendars,
      calendarDates: [],
      shapes: [],
      notes: [],
    );
    final plan = await fixturePlanner(data)
        .planJourney(plannerRequest(when: DateTime.utc(2026, 8, 13, 1, 55)));
    expect(
      plan.journeys.single.legs.single.departureTime,
      DateTime.utc(2026, 8, 13, 2),
    );
  });
  test(
    'fresh trip delays apply, stale snapshots leave planned times intact',
    () async {
      for (final stale in [false, true]) {
        final planner = GtfsJourneyPlanner(
          region: TransitRegion.queensland,
          provider: TransitProviderId.translink,
          loadData: (_) async => plannerData(),
          loadRealtime: (_) async => RealtimeSnapshot(
            items: [
              const TransitTripUpdate(
                tripId: 'T1',
                sourceId: plannerSource,
                serviceDate: '20260813',
                delaySeconds: 600,
              ),
            ],
            fetchedAt: DateTime.now().subtract(
              Duration(minutes: stale ? 3 : 0),
            ),
          ),
        );
        final result = await planner.planJourney(plannerRequest());
        expect(
          result.journeys.single.legs.single.departureTime,
          DateTime.utc(2026, 8, 13, 0, stale ? 0 : 10),
        );
        expect(result.journeys.single.legs.single.isRealtime, !stale);
        if (stale) {
          expect(
            (result.rawPayload as Map)['realtimeStatus'],
            contains('stale'),
          );
        }
      }
    },
  );
  test(
    'cancellation and skipped boarding apply only to matching service dates',
    () async {
      final data = plannerData(serviceDate: '20260813');
      for (final update in [
        const TransitTripUpdate(
          tripId: 'T1',
          sourceId: plannerSource,
          serviceDate: '20260813',
          cancelled: true,
        ),
        TransitTripUpdate(
          tripId: 'T1',
          sourceId: plannerSource,
          serviceDate: '20260813',
          stop: plannerStop('A'),
          skipped: true,
        ),
      ]) {
        final planner = GtfsJourneyPlanner(
          region: TransitRegion.queensland,
          provider: TransitProviderId.translink,
          loadData: (_) async => data,
          loadRealtime: (_) async =>
              RealtimeSnapshot(items: [update], fetchedAt: DateTime.now()),
        );
        expect((await planner.planJourney(plannerRequest())).journeys, isEmpty);
      }
      final ignored = gtfsUpdatedTime(
        [
          const TransitTripUpdate(
            tripId: 'T1',
            serviceDate: '20260812',
            delaySeconds: 600,
          ),
        ],
        'A',
        DateTime.utc(2026, 8, 13),
        DateTime.utc(2026, 8, 13),
        arrival: false,
      );
      expect(ignored, isNull);
    },
  );
}
