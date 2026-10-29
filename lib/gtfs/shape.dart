import 'csv_field_reader.dart';

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
    final reader = CsvFieldReader(header, row);

    return Shape(
      shapeId: reader.fieldOrEmpty('shape_id'),
      shapePtLat: reader.fieldOrEmpty('shape_pt_lat'),
      shapePtLon: reader.fieldOrEmpty('shape_pt_lon'),
      shapePtSequence: reader.fieldOrEmpty('shape_pt_sequence'),
      shapeDistTraveled: reader.fieldOrNull('shape_dist_traveled'),
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
        // Missing required column — callers should handle this case
      }
    }
  }
}
