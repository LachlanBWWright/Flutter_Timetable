import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_feed_validation.dart';

void main() {
  test(
    'interchange modes come from child stop times, regardless of stop names',
    () {
      final data = parseGtfsFiles({
        'stops.txt':
            'stop_id,stop_name,parent_station,stop_lat,stop_lon\n'
            'P,Bus named interchange,,-27,153\n'
            'A,Platform one,P,-27,153\nB,Platform two,P,-27,153\n',
        'routes.txt':
            'route_id,route_short_name,route_long_name,route_type\n'
            'R,1,Tram,0\nF,2,Ferry,4\n',
        'trips.txt': 'route_id,service_id,trip_id\nR,S,T\nF,S,U\n',
        'stop_times.txt':
            'trip_id,arrival_time,departure_time,stop_id,stop_sequence\n'
            'T,10:00:00,10:00:00,A,1\nU,10:00:00,10:00:00,B,1\n',
      });
      final modes = deriveGtfsStopModes(data);
      expect(modes['P'], {TransportMode.lightrail, TransportMode.ferry});
      expect(modes['A'], {TransportMode.lightrail});
      expect(modes['B'], {TransportMode.ferry});
    },
  );

  test('standard and extended route types use the same mapping', () {
    for (final type in ['0', '900', '901']) {
      expect(gtfsRouteMode(type), TransportMode.lightrail);
    }
    expect(gtfsRouteMode('1'), TransportMode.metro);
    expect(gtfsRouteMode('100'), TransportMode.train);
    expect(gtfsRouteMode('200'), TransportMode.bus);
    expect(gtfsRouteMode('700'), TransportMode.bus);
    expect(gtfsRouteMode('1000'), TransportMode.ferry);
    expect(gtfsRouteMode('unknown'), isNull);
  });
}
