/// Dart class for GTFS trips.txt
class Trip {
  final String routeId;
  final String serviceId;
  final String tripId;
  final String shapeId;
  final String tripHeadsign;
  final int directionId;
  final String tripShortName;
  final String blockId;
  final int wheelchairAccessible;
  final String tripNote;
  final String routeDirection;
  final int bikesAllowed;

  Trip({
    required this.routeId,
    required this.serviceId,
    required this.tripId,
    required this.shapeId,
    required this.tripHeadsign,
    required this.directionId,
    required this.tripShortName,
    required this.blockId,
    required this.wheelchairAccessible,
    required this.tripNote,
    required this.routeDirection,
    required this.bikesAllowed,
  });

  factory Trip.fromCsvRow(List<String> row) => Trip(
        routeId: row[0],
        serviceId: row[1],
        tripId: row[2],
        shapeId: row[3],
        tripHeadsign: row[4],
        directionId: int.parse(row[5]),
        tripShortName: row[6],
        blockId: row[7],
        wheelchairAccessible: int.parse(row[8]),
        tripNote: row[9],
        routeDirection: row[10],
        bikesAllowed: int.parse(row[11]),
      );

  List<String> toCsvRow() => [
        routeId,
        serviceId,
        tripId,
        shapeId,
        tripHeadsign,
        directionId.toString(),
        tripShortName,
        blockId,
        wheelchairAccessible.toString(),
        tripNote,
        routeDirection,
        bikesAllowed.toString(),
      ];
}
