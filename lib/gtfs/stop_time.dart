class StopTime {
  final String tripId;
  final String arrivalTime;
  final String departureTime;
  final String stopId;
  final String stopSequence;
  final String? stopHeadsign;
  final String? pickupType;
  final String? dropOffType;
  final String? shapeDistTraveled;
  final String? timepoint;
  final String? stopNote;

  StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.stopSequence,
    this.stopHeadsign,
    this.pickupType,
    this.dropOffType,
    this.shapeDistTraveled,
    this.timepoint,
    this.stopNote,
  });

  factory StopTime.fromCsv(List<String> row) => StopTime(
        tripId: row[0],
        arrivalTime: row[1],
        departureTime: row[2],
        stopId: row[3],
        stopSequence: row[4],
        stopHeadsign: row.length > 5 && row[5].isNotEmpty ? row[5] : null,
        pickupType: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        dropOffType: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
        shapeDistTraveled: row.length > 8 && row[8].isNotEmpty ? row[8] : null,
        timepoint: row.length > 9 && row[9].isNotEmpty ? row[9] : null,
        stopNote: row.length > 10 && row[10].isNotEmpty ? row[10] : null,
      );
}
