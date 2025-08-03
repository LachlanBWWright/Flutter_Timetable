class Trip {
  final String routeId;
  final String serviceId;
  final String tripId;
  final String shapeId;
  final String? tripHeadsign;
  final String? directionId;
  final String? tripShortName;
  final String? blockId;
  final String? wheelchairAccessible;
  final String? tripNote;
  final String? routeDirection;
  final String? bikesAllowed;

  Trip({
    required this.routeId,
    required this.serviceId,
    required this.tripId,
    required this.shapeId,
    this.tripHeadsign,
    this.directionId,
    this.tripShortName,
    this.blockId,
    this.wheelchairAccessible,
    this.tripNote,
    this.routeDirection,
    this.bikesAllowed,
  });

  factory Trip.fromCsv(List<String> row) => Trip(
        routeId: row[0],
        serviceId: row[1],
        tripId: row[2],
        shapeId: row[3],
        tripHeadsign: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        directionId: row.length > 5 && row[5].isNotEmpty ? row[5] : null,
        tripShortName: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        blockId: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
        wheelchairAccessible:
            row.length > 8 && row[8].isNotEmpty ? row[8] : null,
        tripNote: row.length > 9 && row[9].isNotEmpty ? row[9] : null,
        routeDirection: row.length > 10 && row[10].isNotEmpty ? row[10] : null,
        bikesAllowed: row.length > 11 && row[11].isNotEmpty ? row[11] : null,
      );
}
