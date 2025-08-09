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
}
