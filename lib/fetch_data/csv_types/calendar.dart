/// Dart class for GTFS calendar.txt
class Calendar {
  final String serviceId;
  final int monday;
  final int tuesday;
  final int wednesday;
  final int thursday;
  final int friday;
  final int saturday;
  final int sunday;
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

  factory Calendar.fromCsvRow(List<String> row) => Calendar(
        serviceId: row[0],
        monday: int.parse(row[1]),
        tuesday: int.parse(row[2]),
        wednesday: int.parse(row[3]),
        thursday: int.parse(row[4]),
        friday: int.parse(row[5]),
        saturday: int.parse(row[6]),
        sunday: int.parse(row[7]),
        startDate: row[8],
        endDate: row[9],
      );

  List<String> toCsvRow() => [
        serviceId,
        monday.toString(),
        tuesday.toString(),
        wednesday.toString(),
        thursday.toString(),
        friday.toString(),
        saturday.toString(),
        sunday.toString(),
        startDate,
        endDate,
      ];
}
