class Shape {
  final String shapeId;
  final String shapePtLat;
  final String shapePtLon;
  final String shapePtSequence;
  final String? shapeDistTraveled;

  Shape({
    required this.shapeId,
    required this.shapePtLat,
    required this.shapePtLon,
    required this.shapePtSequence,
    this.shapeDistTraveled,
  });

  /// Create a Shape from a CSV row using header-based field mapping
  factory Shape.fromCsv(List<String> header, List<String> row) {
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    return Shape(
      shapeId: getField('shape_id') ?? '',
      shapePtLat: getField('shape_pt_lat') ?? '',
      shapePtLon: getField('shape_pt_lon') ?? '',
      shapePtSequence: getField('shape_pt_sequence') ?? '',
      shapeDistTraveled: getField('shape_dist_traveled'),
    );
  }

  /// Expected CSV header for shapes.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'shape_id',
    'shape_pt_lat',
    'shape_pt_lon',
    'shape_pt_sequence',
    'shape_dist_traveled',
  ];

  static void validateCsvHeader(List<String> header) {
    // Require presence of required columns per GTFS spec
    final required = [
      'shape_id',
      'shape_pt_lat',
      'shape_pt_lon',
      'shape_pt_sequence',
    ];
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('shapes.txt missing required column "$col"');
      }
    }
  }
}
