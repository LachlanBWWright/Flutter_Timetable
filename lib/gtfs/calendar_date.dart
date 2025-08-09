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
