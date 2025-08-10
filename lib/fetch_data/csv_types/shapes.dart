/// Dart class for GTFS shapes.txt
class Shape {
  final String shapeId;
  final double shapePtLat;
  final double shapePtLon;
  final int shapePtSequence;
  final double shapeDistTraveled;

  Shape({
    required this.shapeId,
    required this.shapePtLat,
    required this.shapePtLon,
    required this.shapePtSequence,
    required this.shapeDistTraveled,
  });

  factory Shape.fromCsvRow(List<String> row) => Shape(
        shapeId: row[0],
        shapePtLat: double.parse(row[1]),
        shapePtLon: double.parse(row[2]),
        shapePtSequence: int.parse(row[3]),
        shapeDistTraveled: double.parse(row[4]),
      );

  List<String> toCsvRow() => [
        shapeId,
        shapePtLat.toString(),
        shapePtLon.toString(),
        shapePtSequence.toString(),
        shapeDistTraveled.toString(),
      ];
}
