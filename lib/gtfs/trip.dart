import 'csv_field_reader.dart';

class Trip {
  final String routeId;
  final String serviceId;
  final String tripId;
  final String? shapeId;
  final String? tripHeadsign;
  final String? tripShortName;
  final String? directionId;
  final String? blockId;
  final String? wheelchairAccessible;
  final String? bikesAllowed;
  // Non-standard fields used by NSW Transport API
  final String? tripNote;
  final String? routeDirection;

  Trip({
    required this.routeId,
    required this.serviceId,
    required this.tripId,
    this.shapeId,
    this.tripHeadsign,
    this.tripShortName,
    this.directionId,
    this.blockId,
    this.wheelchairAccessible,
    this.bikesAllowed,
    this.tripNote,
    this.routeDirection,
  });

  /// Create a Trip from a CSV row using header-based field mapping
  factory Trip.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    return Trip(
      routeId: reader.fieldOrEmpty('route_id'),
      serviceId: reader.fieldOrEmpty('service_id'),
      tripId: reader.fieldOrEmpty('trip_id'),
      shapeId: reader.fieldOrNull('shape_id'),
      tripHeadsign: reader.fieldOrNull('trip_headsign'),
      tripShortName: reader.fieldOrNull('trip_short_name'),
      directionId: reader.fieldOrNull('direction_id'),
      blockId: reader.fieldOrNull('block_id'),
      wheelchairAccessible: reader.fieldOrNull('wheelchair_accessible'),
      bikesAllowed: reader.fieldOrNull('bikes_allowed'),
      tripNote: reader.fieldOrNull('trip_note'),
      routeDirection: reader.fieldOrNull('route_direction'),
    );
  }

  /// Expected CSV header for trips.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'route_id',
    'service_id',
    'trip_id',
    'trip_headsign',
    'trip_short_name',
    'direction_id',
    'block_id',
    'shape_id',
    'wheelchair_accessible',
    'bikes_allowed',
  ];

  static bool validateCsvHeader(List<String> header) {
    const required = ['route_id', 'service_id', 'trip_id'];
    return required.every(header.contains);
  }
}
