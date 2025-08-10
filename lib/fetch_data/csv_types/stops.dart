/// Dart class for GTFS stops.txt
class Stop {
  final String stopId;
  final String stopName;
  final double stopLat;
  final double stopLon;
  final int locationType;
  final String parentStation;
  final int wheelchairBoarding;
  final String platformCode;

  Stop({
    required this.stopId,
    required this.stopName,
    required this.stopLat,
    required this.stopLon,
    required this.locationType,
    required this.parentStation,
    required this.wheelchairBoarding,
    required this.platformCode,
  });

  factory Stop.fromCsvRow(List<String> row) => Stop(
        stopId: row[0],
        stopName: row[1],
        stopLat: double.parse(row[2]),
        stopLon: double.parse(row[3]),
        locationType: int.parse(row[4]),
        parentStation: row[5],
        wheelchairBoarding: int.parse(row[6]),
        platformCode: row[7],
      );

  List<String> toCsvRow() => [
        stopId,
        stopName,
        stopLat.toString(),
        stopLon.toString(),
        locationType.toString(),
        parentStation,
        wheelchairBoarding.toString(),
        platformCode,
      ];
}
