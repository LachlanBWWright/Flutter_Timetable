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
  factory Trip.fromCsvWithHeader(List<String> header, List<String> row) {
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    return Trip(
      routeId: getField('route_id') ?? '',
      serviceId: getField('service_id') ?? '',
      tripId: getField('trip_id') ?? '',
      shapeId: getField('shape_id'),
      tripHeadsign: getField('trip_headsign'),
      tripShortName: getField('trip_short_name'),
      directionId: getField('direction_id'),
      blockId: getField('block_id'),
      wheelchairAccessible: getField('wheelchair_accessible'),
      bikesAllowed: getField('bikes_allowed'),
      tripNote: getField('trip_note'),
      routeDirection: getField('route_direction'),
    );
  }

  /// Legacy constructor for backward compatibility with positional CSV parsing
  factory Trip.fromCsv(List<String> row) => Trip(
        routeId: row[0],
        serviceId: row[1],
        tripId: row[2],
        shapeId: row.length > 3 && row[3].isNotEmpty ? row[3] : null,
        tripHeadsign: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        directionId: row.length > 5 && row[5].isNotEmpty ? row[5] : null,
        tripShortName: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        blockId: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
        wheelchairAccessible:
            row.length > 8 && row[8].isNotEmpty ? row[8] : null,
        tripNote: row.length > 9 && row[9].isNotEmpty ? row[9] : null,
        routeDirection: row.length > 10 && row[10].isNotEmpty ? row[10] : null,
        bikesAllowed: row.length > 11 && row[11].isNotEmpty ? row[11] : null,
      );

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

  static void validateCsvHeader(List<String> header) {
    // Require presence of required columns per GTFS spec
    final required = ['route_id', 'service_id', 'trip_id'];
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('trips.txt missing required column "$col"');
      }
    }
  }
}
