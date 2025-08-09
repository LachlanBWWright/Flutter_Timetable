class Agency {
  final String agencyId;
  final String agencyName;
  final String agencyUrl;
  final String agencyTimezone;
  final String? agencyLang;
  final String? agencyPhone;
  final String? agencyFareUrl;
  final String? agencyEmail;

  Agency({
    required this.agencyId,
    required this.agencyName,
    required this.agencyUrl,
    required this.agencyTimezone,
    this.agencyLang,
    this.agencyPhone,
    this.agencyFareUrl,
    this.agencyEmail,
  });

  factory Agency.fromCsv(List<String> row) => Agency(
        agencyId: row[0],
        agencyName: row[1],
        agencyUrl: row[2],
        agencyTimezone: row[3],
        agencyLang: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        agencyPhone: row.length > 5 && row[5].isNotEmpty ? row[5] : null,
        agencyFareUrl: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        agencyEmail: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
      );
}

class Calendar {
  final String serviceId;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;
  final String startDate;
  final String endDate;

  Calendar({
    required this.serviceId,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
  });

  factory Calendar.fromCsv(List<String> row) => Calendar(
        serviceId: row[0],
        monday: row[1],
        tuesday: row[2],
        wednesday: row[3],
        thursday: row[4],
        friday: row[5],
        saturday: row[6],
        sunday: row[7],
        startDate: row[8],
        endDate: row[9],
      );
}

class CalendarDate {
  final String serviceId;
  final String date;
  final String exceptionType;

  CalendarDate({
    required this.serviceId,
    required this.date,
    required this.exceptionType,
  });

  factory CalendarDate.fromCsv(List<String> row) => CalendarDate(
        serviceId: row[0],
        date: row[1],
        exceptionType: row[2],
      );
}

class Route {
  final String routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String? routeDesc;
  final String routeType;
  final String? routeColor;
  final String? routeTextColor;
  final String? routeUrl;

  Route({
    required this.routeId,
    required this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    this.routeDesc,
    required this.routeType,
    this.routeColor,
    this.routeTextColor,
    this.routeUrl,
  });

  factory Route.fromCsv(List<String> row) => Route(
        routeId: row[0],
        agencyId: row[1],
        routeShortName: row[2],
        routeLongName: row[3],
        routeDesc: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        routeType: row[5],
        routeColor: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        routeTextColor: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
        routeUrl: row.length > 8 && row[8].isNotEmpty ? row[8] : null,
      );
}

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

class Note {
  final String noteId;
  final String noteText;

  Note({
    required this.noteId,
    required this.noteText,
  });

  factory Note.fromCsv(List<String> row) => Note(
        noteId: row[0],
        noteText: row[1],
      );
}
