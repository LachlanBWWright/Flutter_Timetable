class Stop {
  final String stopId;
  final String stopName;
  final double stopLat;
  final double stopLon;
  final int locationType;
  final String? parentStation;
  final int wheelchairBoarding;
  final String? platformCode;

  Stop({
    required this.stopId,
    required this.stopName,
    required this.stopLat,
    required this.stopLon,
    required this.locationType,
    this.parentStation,
    required this.wheelchairBoarding,
    this.platformCode,
  });

  factory Stop.fromCsv(List<String> row) {
    return Stop(
      stopId: row[0],
      stopName: row[1],
      stopLat: double.tryParse(row[2]) ?? 0.0,
      stopLon: double.tryParse(row[3]) ?? 0.0,
      locationType: int.tryParse(row[4]) ?? 0,
      parentStation: row[5].isEmpty ? null : row[5],
      wheelchairBoarding: int.tryParse(row[6]) ?? 0,
      platformCode: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
    );
  }

  @override
  String toString() =>
      'Stop(stopId: $stopId, stopName: $stopName, stopLat: $stopLat, stopLon: $stopLon, locationType: $locationType, parentStation: $parentStation, wheelchairBoarding: $wheelchairBoarding, platformCode: $platformCode)';
}
