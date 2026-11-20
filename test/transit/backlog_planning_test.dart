import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  test(
    'arrive-by chooses the latest departure that meets the deadline',
    () async {
      final data = plannerData(
        tripRows: 'R1,daily,T1,Gamma\nR1,daily,T2,Gamma\n',
        times:
            'T1,10:00:00,10:00:00,A,1,0,0\nT1,10:20:00,10:20:00,C,2,0,0\n'
            'T2,10:10:00,10:10:00,A,1,0,0\nT2,10:30:00,10:30:00,C,2,0,0\n',
      );
      final plan = await fixturePlanner(data).planJourney(
        plannerRequest(
          arrivalBased: true,
          when: DateTime.utc(2026, 8, 13, 0, 25),
        ),
      );
      expect(
        plan.journeys.single.legs.first.departureTime,
        DateTime.utc(2026, 8, 13),
      );
      expect(
        plan.journeys.single.legs.last.arrivalTime,
        DateTime.utc(2026, 8, 13, 0, 20),
      );
    },
  );
  for (final exact in ['0', '1']) {
    test('frequency services expand instances and preserve exact_times=$exact', () async {
      final data = parseGtfsFiles({
        'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Brisbane\n',
        'stops.txt': 'stop_id,stop_name\nA,Alpha\nC,Gamma\n',
        'routes.txt': 'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
        'trips.txt': 'route_id,service_id,trip_id\nR,S,T\n',
        'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
        'stop_times.txt': 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,06:00:00,06:00:00,A,1\nT,06:20:00,06:20:00,C,2\n',
        'frequencies.txt':
            'trip_id,start_time,end_time,headway_secs,exact_times\nT,10:00:00,11:00:00,600,$exact\n',
      });
      final board = scheduledGtfsDepartures(
        data,
        DepartureRequest(
          stop: plannerStop('A'),
          when: DateTime.utc(2026, 8, 13, 0, 5),
        ),
      );
      expect(board.first.plannedTime, DateTime.utc(2026, 8, 13, 0, 10));
      expect(board, hasLength(5));
      expect(board.first.isApproximate, exact == '0');
      final plan = await fixturePlanner(data)
          .planJourney(plannerRequest(when: DateTime.utc(2026, 8, 13, 0, 5)));
      expect(
        plan.journeys.single.legs.single.arrivalTime,
        DateTime.utc(2026, 8, 13, 0, 30),
      );
      expect(plan.journeys.single.legs.single.isApproximate, exact == '0');
    });
  }
}
