import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  Future<JourneyPlan> plan({
    String departure = '10:13:00',
    String parent = 'P',
    String dropOff = '0',
    String origin = 'A',
    String destination = 'C',
    Duration? walkingLimit,
  }) {
    final data = parseGtfsFiles({
      'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Brisbane\n',
      'stops.txt':
          'stop_id,stop_name,parent_station,stop_lat,stop_lon\n'
          'A,Alpha,,-27,153\nP,Interchange,,-27,153\nQ,Other,,-27,153\n'
          'P1,Platform one,P,-27,153\nP2,Platform two,$parent,-27,153\nC,Gamma,,-27,153\n',
      'routes.txt': 'route_id,route_short_name,route_long_name,route_type\nR1,1,First,2\nR2,2,Second,2\n',
      'trips.txt': 'route_id,service_id,trip_id\nR1,S,T1\nR2,S,T2\n',
      'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
      'stop_times.txt':
          'trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type\n'
          'T1,10:00:00,10:00:00,A,1,0,0\nT1,10:10:00,10:10:00,P1,2,0,$dropOff\n'
          'T2,$departure,$departure,P2,1,0,0\nT2,10:25:00,10:25:00,C,2,0,0\n',
    });
    return fixturePlanner(data).planJourney(
      plannerRequest(
        origin: origin,
        destination: destination,
        walkingLimit: walkingLimit,
      ),
    );
  }

  test('connects sibling platforms and includes the two-minute walk', () async {
    final result = await plan();
    final legs = result.journeys.single.legs;
    expect(legs, hasLength(3));
    expect(legs[1].origin.ref.stopId, 'P1');
    expect(legs[1].destination.ref.stopId, 'P2');
    expect(legs[1].label, 'Walk between platforms');
    expect(
      legs[1].arrivalTime!.difference(legs[1].departureTime!),
      const Duration(minutes: 2),
    );
    expect(legs.last.arrivalTime, DateTime.utc(2026, 8, 13, 0, 25));
  });
  test('station selections reach platform services', () async {
    final result = await plan(origin: 'P');
    expect(result.journeys.single.legs.first.origin.ref.stopId, 'P');
    expect(result.journeys.single.legs.last.destination.ref.stopId, 'C');
  });
  test(
    'does not invent a transfer between unrelated stops with equal coordinates',
    () async {
      expect((await plan(parent: 'Q')).journeys, isEmpty);
    },
  );
  test('does not catch a train before the platform walk finishes', () async {
    expect((await plan(departure: '10:11:00')).journeys, isEmpty);
  });
  test('cannot transfer where alighting is prohibited', () async {
    expect((await plan(dropOff: '1')).journeys, isEmpty);
  });
  test(
    'an explicit zero walking limit disables interchange footpaths',
    () async {
      expect((await plan(walkingLimit: Duration.zero)).journeys, isEmpty);
    },
  );
}
