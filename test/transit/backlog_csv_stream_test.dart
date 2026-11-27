import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';

Map<String, String> snapshotFiles(String times) => {
  'stops.txt': 'stop_id,stop_name\nA,Alpha\nB,Beta\n',
  'routes.txt':
      'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
  'trips.txt': 'route_id,service_id,trip_id\nR,S,T\n',
  'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
  'stop_times.txt':
      'trip_id,arrival_time,departure_time,stop_id,stop_sequence\n$times',
};

void main() {
  test('compact imports support a timetable inside a ZIP folder', () {
    final files = snapshotFiles(
      'T,10:00:00,10:00:00,A,1\nT,10:20:00,10:20:00,B,2\n',
    );
    final compact = parseGtfsStopFiles({
      for (final e in files.entries) 'feed/${e.key}': e.value,
    });
    expect(compact.stopModes['A'], isNotEmpty);
    expect(compact.stopTimes, isEmpty);
  });

  test('full snapshots enforce row budgets while compact imports retain validated modes', () {
    final files = snapshotFiles(
      'T,10:00:00,10:00:00,A,1\nT,10:20:00,10:20:00,B,2\n',
    );
    expect(
      () => parseGtfsFiles(files, maximumStopTimes: 1),
      throwsA(isA<TransitResourceLimit>()),
    );
    final compact = parseGtfsStopFiles(files, namespace: 'mode');
    expect(compact.stopTimes, isEmpty);
    expect(compact.stopModes['A'], isNotEmpty);
    expect(compact.isStopSnapshot, isTrue);
  });
  test('compact validation accepts unsorted rows but rejects duplicate sequences and chronology', () {
    final compact = parseGtfsStopFiles(
      snapshotFiles('T,10:20:00,10:20:00,B,2\nT,10:00:00,10:00:00,A,1\n'),
    );
    expect(compact.stops, hasLength(2));
    for (final times in [
      'T,10:20:00,10:20:00,B,2\nT,10:30:00,10:30:00,A,1\n',
      'T,10:00:00,10:00:00,B,1\nT,10:20:00,10:20:00,A,1\n',
    ]) {
      expect(
        () => parseGtfsStopFiles(snapshotFiles(times)),
        throwsA(isA<InvalidProviderResponse>()),
      );
    }
  });

  test('chunked CSV keeps quoted newlines and escaped quotes across chunk boundaries', () {
    final name = '${List.filled(65525, 'x').join()}\nSecond "platform"';
    final escaped = name.replaceAll('"', '""');
    final stops = parseStopsCsv('stop_id,stop_name\nA,"$escaped"\nB,Next\n');
    expect(stops, hasLength(2));
    expect(stops.first.stopName, name);
    expect(stops.last.stopId, 'B');
  });
  test(
    'large repeated stop-time identifiers share storage without losing rows',
    () {
      final csv = StringBuffer(
        'trip_id,arrival_time,departure_time,stop_id,stop_sequence\n',
      );
      for (var i = 1; i <= 20000; i++) {
        csv.writeln('T,10:00:00,10:00:00,A,$i');
      }
      final times = parseStopTimesCsv(csv.toString());
      expect(times, hasLength(20000));
      expect(times.last.stopSequence, '20000');
      expect(identical(times.first.tripId, times.last.tripId), isTrue);
    },
  );
}
