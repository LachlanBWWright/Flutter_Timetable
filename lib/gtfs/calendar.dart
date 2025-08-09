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
