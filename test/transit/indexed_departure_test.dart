import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

class _CountedTimes extends ListBase<StopTime> {
  _CountedTimes(this.values);
  final List<StopTime> values;
  int reads = 0;
  @override
  int get length => values.length;
  @override
  set length(int value) => throw UnsupportedError('Snapshot is immutable');
  @override
  StopTime operator [](int index) {
    reads++;
    return values[index];
  }

  @override
  void operator []=(int index, StopTime value) =>
      throw UnsupportedError('Snapshot is immutable');
}

const stop = TransitStopRef(
  region: TransitRegion.southAustralia,
  provider: TransitProviderId.adelaideMetro,
  sourceId: TransitSourceId('sa:static'),
  stopId: 'A',
);

void main() {
  for (final transition in [
    (
      date: '20260405',
      when: DateTime.utc(2026, 4, 4, 16, 55),
      expected: DateTime.utc(2026, 4, 4, 17),
    ),
    (
      date: '20261004',
      when: DateTime.utc(2026, 10, 3, 15, 55),
      expected: DateTime.utc(2026, 10, 3, 16),
    ),
  ]) {
    test(
      'departure and journey clocks agree across DST ${transition.date}',
      () async {
        final data = plannerData(
          timezone: 'Australia/Sydney',
          serviceDate: transition.date,
          times: 'T1,03:00:00,03:00:00,A,1,0,0\nT1,03:20:00,03:20:00,C,2,0,0\n',
        );
        final result = await AdelaideMetroDepartureRepository(
          loadData: () async => data,
        ).getDepartures(DepartureRequest(stop: stop, when: transition.when));
        expect(result.single.plannedTime, transition.expected);
        expect(result.single.plannedTime!.isUtc, isTrue);
      },
    );
  }
  test(
    'repeated departures reuse the feed index across provenance updates',
    () async {
      final original = plannerData(timezone: 'Australia/Adelaide');
      final counted = _CountedTimes(original.stopTimes);
      var data = GtfsData(
        agencies: original.agencies,
        calendars: original.calendars,
        calendarDates: original.calendarDates,
        stops: original.stops,
        routes: original.routes,
        trips: original.trips,
        stopTimes: counted,
        shapes: [],
        notes: [],
      );
      final repository = AdelaideMetroDepartureRepository(
        loadData: () async => data.withTimetable(
          TimetableProvenance(fetchedAt: DateTime.utc(2026), isStale: false),
        ),
      );
      final request = DepartureRequest(
        stop: stop,
        when: DateTime.utc(2026, 8, 13, 0, 25),
      );
      final first = await repository.getDepartures(request);
      final reads = counted.reads;
      expect(first.single.plannedTime, DateTime.utc(2026, 8, 13, 0, 30));
      expect(reads, greaterThan(0));
      final second = await repository.getDepartures(request);
      expect(second.single.plannedTime, first.single.plannedTime);
      expect(
        counted.reads,
        reads,
        reason: 'No second scan of the source stop-time list',
      );
      data = plannerData(
        timezone: 'Australia/Adelaide',
        times: 'T1,11:00:00,11:00:00,A,1,0,0\nT1,11:20:00,11:20:00,C,2,0,0\n',
      );
      expect(
        (await repository.getDepartures(request)).single.plannedTime,
        DateTime.utc(2026, 8, 13, 1, 30),
      );
    },
  );
  test('station departure boards include platforms and exclude prohibited pickups', () {
    final data = parseGtfsFiles({
      'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Adelaide\n',
      'stops.txt': 'stop_id,stop_name,parent_station,platform_code\nA,Station,,\nP,Platform,A,1\n',
      'routes.txt':
          'route_id,route_short_name,route_long_name,route_type\nR,1,Route,2\n',
      'trips.txt': 'route_id,service_id,trip_id\nR,S,T\nR,S,U\n',
      'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
      'stop_times.txt':
          'trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type\n'
          'T,10:00:00,10:00:00,P,1,0\nU,10:05:00,10:05:00,P,1,1\n',
    });
    final result = scheduledGtfsDepartures(
      data,
      DepartureRequest(stop: stop, when: DateTime.utc(2026, 8, 13, 0, 25)),
    );
    expect(result.single.tripId, 'T');
    expect(result.single.platform, '1');
  });
}
