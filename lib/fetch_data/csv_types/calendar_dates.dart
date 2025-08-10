/// Dart class for GTFS calendar_dates.txt
class CalendarDate {
  final String serviceId;
  final String date;
  final String exceptionType;

  CalendarDate({
    required this.serviceId,
    required this.date,
    required this.exceptionType,
  });

  factory CalendarDate.fromCsvRow(List<String> row) => CalendarDate(
        serviceId: row[0],
        date: row[1],
        exceptionType: row[2],
      );

  List<String> toCsvRow() => [serviceId, date, exceptionType];
}
