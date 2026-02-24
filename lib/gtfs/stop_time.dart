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
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    return StopTime(
      tripId: getField('trip_id') ?? '',
      arrivalTime: getField('arrival_time') ?? '',
      departureTime: getField('departure_time') ?? '',
      stopId: getField('stop_id') ?? '',
      stopSequence: getField('stop_sequence') ?? '',
      stopHeadsign: getField('stop_headsign'),
      pickupType: getField('pickup_type'),
      dropOffType: getField('drop_off_type'),
      continuousPickup: getField('continuous_pickup'),
      continuousDropOff: getField('continuous_drop_off'),
      shapeDistTraveled: getField('shape_dist_traveled'),
      timepoint: getField('timepoint'),
      stopNote: getField('stop_note'),
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

  static void validateCsvHeader(List<String> header) {
    // Require presence of required columns per GTFS spec
    final required = [
      'trip_id',
      'arrival_time',
      'departure_time',
      'stop_id',
      'stop_sequence',
    ];
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('stop_times.txt missing required column "$col"');
      }
    }
  }
}
