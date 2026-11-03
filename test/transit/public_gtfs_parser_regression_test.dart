import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';

void main() {
  test('parses GTFS files with whitespace-padded headers', () {
    final data = parseGtfsFiles({
      'calendar.txt':
          ' service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date\n'
          'daily,1,1,1,1,1,1,1,20260101,20261231\n',
      'routes.txt':
          ' route_id, route_short_name, route_long_name, route_type\n'
          'R1,10,Test Line,3\n',
      'stops.txt':
          ' location_type, parent_station, stop_id, stop_code, stop_name, stop_desc, stop_lat, stop_lon\n'
          '0,,A,A,Alpha,,${-27.4},153.0\n'
          '0,,B,B,Beta,,${-27.5},153.1\n',
      'trips.txt':
          ' trip_id, route_id, service_id, trip_headsign\n'
          'T1,R1,daily,Beta\n',
      'stop_times.txt':
          ' trip_id, arrival_time, departure_time, stop_id, stop_sequence\n'
          'T1,10:00:00,10:00:00,A,1\n'
          'T1,10:10:00,10:10:00,B,2\n',
    });

    expect(
      data.stops.map((stop) => stop.stopId),
      containsAll(<String>['A', 'B']),
    );
    expect(data.routes.single.routeId, 'R1');
    expect(data.trips.single.tripId, 'T1');
    expect(data.stopTimes, hasLength(2));
  });

  test('keeps a valid empty result when optional GTFS files are absent', () {
    final data = parseGtfsFiles({
      'stops.txt':
          'stop_id,stop_name,stop_lat,stop_lon\n'
          'A,Alpha,-27.4,153.0\n',
    });

    expect(data.stops, hasLength(1));
    expect(data.routes, isEmpty);
    expect(data.trips, isEmpty);
    expect(data.stopTimes, isEmpty);
  });
}
