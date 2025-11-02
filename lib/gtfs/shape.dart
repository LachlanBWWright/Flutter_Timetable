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

  factory Shape.fromCsv(List<String> row) => Shape(
        shapeId: row[0],
        shapePtLat: row[1],
        shapePtLon: row[2],
        shapePtSequence: row[3],
        shapeDistTraveled: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
      );

  /// Expected CSV header for shapes.txt
  static List<String> expectedCsvHeader() => [
        'shape_id',
        'shape_pt_lat',
        'shape_pt_lon',
        'shape_pt_sequence',
        'shape_dist_traveled',
      ];

  static void validateCsvHeader(List<String> header) {
    // Require presence and order of required (non-nullable) columns.
    final required = [
      'shape_id',
      'shape_pt_lat',
      'shape_pt_lon',
      'shape_pt_sequence'
    ];
    var lastIndex = -1;
    for (final col in required) {
      final idx = header.indexOf(col);
      if (idx == -1) {
        throw FormatException('shapes.txt missing required column "$col"');
      }
      if (idx <= lastIndex) {
        throw FormatException('shapes.txt column "$col" is out of order');
      }
      lastIndex = idx;
    }
  }
}
