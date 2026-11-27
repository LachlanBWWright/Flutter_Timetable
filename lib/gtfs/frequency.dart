import 'csv_field_reader.dart';

class GtfsFrequency {
  const GtfsFrequency({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.headwaySeconds,
    this.exact = false,
  });
  final String tripId, startTime, endTime;
  final int headwaySeconds;
  final bool exact;
  factory GtfsFrequency.fromCsv(List<String> header, List<String> row) {
    final r = CsvFieldReader(header, row);
    if (!['', '0', '1'].contains(r.fieldOrEmpty('exact_times'))) {
      throw const FormatException('Invalid exact_times');
    }
    return GtfsFrequency(
      tripId: r.fieldOrEmpty('trip_id'),
      startTime: r.fieldOrEmpty('start_time'),
      endTime: r.fieldOrEmpty('end_time'),
      headwaySeconds: r.intField('headway_secs'),
      exact: r.fieldOrEmpty('exact_times') == '1',
    );
  }
}
