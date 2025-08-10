/// Dart class for GTFS stop_times.txt
class StopTime {
  final String tripId;
  final String arrivalTime;
  final String departureTime;
  final String stopId;
  final int stopSequence;
  final String stopHeadsign;
  final int pickupType;
  final int dropOffType;
  final String shapeDistTraveled;
  final int timepoint;
  final String stopNote;

  StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.stopSequence,
    required this.stopHeadsign,
    required this.pickupType,
    required this.dropOffType,
    required this.shapeDistTraveled,
    required this.timepoint,
    required this.stopNote,
  });

  factory StopTime.fromCsvRow(List<String> row) => StopTime(
        tripId: row[0],
        arrivalTime: row[1],
        departureTime: row[2],
        stopId: row[3],
        stopSequence: int.parse(row[4]),
        stopHeadsign: row[5],
        pickupType: int.parse(row[6]),
        dropOffType: int.parse(row[7]),
        shapeDistTraveled: row[8],
        timepoint: int.parse(row[9]),
        stopNote: row[10],
      );

  List<String> toCsvRow() => [
        tripId,
        arrivalTime,
        departureTime,
        stopId,
        stopSequence.toString(),
        stopHeadsign,
        pickupType.toString(),
        dropOffType.toString(),
        shapeDistTraveled,
        timepoint.toString(),
        stopNote,
      ];
}
