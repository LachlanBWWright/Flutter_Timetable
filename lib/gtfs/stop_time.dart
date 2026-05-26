import 'csv_field_reader.dart';

class StopTime {
  final String tripId;
  final String arrivalTime;
  final String departureTime;
  final String stopId;
  final String stopSequence;
  final String? stopHeadsign;
  final String? pickupType;
  final String? dropOffType;
  final String? continuousPickup;
  final String? continuousDropOff;
  final String? shapeDistTraveled;
  final String? timepoint;
  // Non-standard field used by NSW Transport API
  final String? stopNote;

  StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.stopSequence,
    this.stopHeadsign,
    this.pickupType,
    this.dropOffType,
    this.continuousPickup,
    this.continuousDropOff,
    this.shapeDistTraveled,
    this.timepoint,
    this.stopNote,
  });

  /// Create a StopTime from a CSV row using header-based field mapping
  factory StopTime.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    return StopTime(
      tripId: reader.fieldOrEmpty('trip_id'),
      arrivalTime: reader.fieldOrEmpty('arrival_time'),
      departureTime: reader.fieldOrEmpty('departure_time'),
      stopId: reader.fieldOrEmpty('stop_id'),
      stopSequence: reader.fieldOrEmpty('stop_sequence'),
      stopHeadsign: reader.fieldOrNull('stop_headsign'),
      pickupType: reader.fieldOrNull('pickup_type'),
      dropOffType: reader.fieldOrNull('drop_off_type'),
      continuousPickup: reader.fieldOrNull('continuous_pickup'),
      continuousDropOff: reader.fieldOrNull('continuous_drop_off'),
      shapeDistTraveled: reader.fieldOrNull('shape_dist_traveled'),
      timepoint: reader.fieldOrNull('timepoint'),
      stopNote: reader.fieldOrNull('stop_note'),
    );
  }

  /// Expected CSV header for stop_times.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'trip_id',
    'arrival_time',
    'departure_time',
    'stop_id',
    'stop_sequence',
    'stop_headsign',
    'pickup_type',
    'drop_off_type',
    'continuous_pickup',
    'continuous_drop_off',
    'shape_dist_traveled',
    'timepoint',
  ];

  static bool validateCsvHeader(List<String> header) {
    const required = [
      'trip_id',
      'arrival_time',
      'departure_time',
      'stop_id',
      'stop_sequence',
    ];
    return required.every(header.contains);
  }
}
