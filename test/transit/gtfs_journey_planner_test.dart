import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';

void main() {
  test('finds earliest journey and coalesces connections on one trip', () async {
    final data = parseGtfsFiles({
      'calendar.txt':
          'service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\n'
          'daily,1,1,1,1,1,1,1,20260101,20261231\n',
      'routes.txt':
          'route_id,route_short_name,route_long_name,route_type\nR1,10,Test Line,3\n',
      'stops.txt':
          'stop_id,stop_name,stop_lat,stop_lon\nA,Alpha,-27.4,153.0\nB,Beta,-27.5,153.1\nC,Gamma,-27.6,153.2\n',
      'trips.txt':
          'route_id,service_id,trip_id,trip_headsign\nR1,daily,T1,Gamma\n',
      'stop_times.txt':
          'trip_id,arrival_time,departure_time,stop_id,stop_sequence\n'
          'T1,10:00:00,10:00:00,A,1\nT1,10:10:00,10:11:00,B,2\nT1,10:20:00,10:20:00,C,3\n',
    });
    const source = TransitSourceId('qld:SEQ');
    final planner = GtfsJourneyPlanner(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      loadData: (_) async => data,
    );

    final result = await planner.planJourney(
      JourneyPlanRequest(
        origin: const TransitStopRef(
          region: TransitRegion.queensland,
          provider: TransitProviderId.translink,
          sourceId: source,
          stopId: 'A',
        ),
        destination: const TransitStopRef(
          region: TransitRegion.queensland,
          provider: TransitProviderId.translink,
          sourceId: source,
          stopId: 'C',
        ),
        when: DateTime(2026, 8, 13, 9, 55),
      ),
    );

    expect(result.journeys, hasLength(1));
    expect(result.journeys.single.legs, hasLength(1));
    expect(result.journeys.single.legs.single.destination.name, 'Gamma');
    expect(result.journeys.single.legs.single.route?.shortName, '10');
  });
}
