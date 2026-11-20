import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_feed_validation.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  test(
    'snapshots defensively copy lists and protect indexes from mutations',
    () {
      final source = plannerData();
      final stops = List<Stop>.of(source.stops);
      final data = GtfsData(
        agencies: source.agencies,
        calendars: source.calendars,
        calendarDates: source.calendarDates,
        routes: source.routes,
        stops: stops,
        trips: source.trips,
        stopTimes: source.stopTimes,
        shapes: [],
        notes: [],
      );
      stops.clear();
      expect(data.index.stops, hasLength(3));
      expect(() => data.stops.clear(), throwsUnsupportedError);
      expect(() => data.stopTimes.clear(), throwsUnsupportedError);
      expect(() => data.stopModes.clear(), throwsUnsupportedError);
    },
  );
  for (final times in [
    'T1,10:70:00,10:70:00,A,1,0,0\n',
    'T1,10:00:00,09:00:00,A,1,0,0\n',
    'T1,10:00:00,10:00:00,A,1,0,0\nT1,09:00:00,09:00:00,C,2,0,0\n',
  ]) {
    test('invalid timetable chronology is rejected: $times', () {
      expect(
        () => validateGtfsFeed(plannerData(times: times)),
        throwsA(isA<InvalidProviderResponse>()),
      );
    });
  }
  test('frequency, transfer and pathway files are parsed', () {
    final data = parseGtfsFiles({
      'stops.txt': 'stop_id,stop_name\nA,Alpha\nB,Beta\n',
      'frequencies.txt': 'trip_id,start_time,end_time,headway_secs,exact_times\nT,10:00:00,12:00:00,600,1\n',
      'transfers.txt': 'from_stop_id,to_stop_id,transfer_type,min_transfer_time\nA,B,2,180\n',
      'pathways.txt': 'pathway_id,from_stop_id,to_stop_id,pathway_mode,is_bidirectional,traversal_time\nP,A,B,5,1,90\n',
    });
    expect(data.frequencies.single.headwaySeconds, 600);
    expect(data.transfers.single.minimumSeconds, 180);
    expect(data.pathways.single.stepFree, isTrue);
    expect(data.pathways.single.traversalSeconds, 90);
  });
}
