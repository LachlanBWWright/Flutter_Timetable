import '../../gtfs/timetable_index.dart';

/// Exact frequency periods expand fixed schedules. Headway services remain
/// explicitly approximate in every result; the template itself is not a run.
Iterable<({int offset, bool approximate, int? headway})> gtfsTripInstances(
  GtfsTimetableIndex index,
  String tripId,
) sync* {
  final periods = index.frequenciesByTrip[tripId];
  if (periods == null || periods.isEmpty) {
    yield (offset: 0, approximate: false, headway: null);
    return;
  }
  final times = index.timesByTrip[tripId];
  if (times == null || times.isEmpty) return;
  final anchor = gtfsTimeSeconds(times.first.departureTime);
  if (anchor == null) return;
  for (final period in periods) {
    final start = gtfsTimeSeconds(period.startTime),
        end = gtfsTimeSeconds(period.endTime);
    if (start == null || end == null || period.headwaySeconds <= 0) continue;
    for (var time = start; time < end; time += period.headwaySeconds) {
      yield (
        offset: time - anchor,
        approximate: !period.exact,
        headway: period.headwaySeconds,
      );
    }
  }
}

String gtfsSecondsText(int seconds) =>
    '${(seconds ~/ 3600).toString().padLeft(2, '0')}:'
    '${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
