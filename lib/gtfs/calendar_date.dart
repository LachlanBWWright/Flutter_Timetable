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

  /// Expected CSV header for calendar_dates.txt
  static List<String> expectedCsvHeader() => [
        'service_id',
        'date',
        'exception_type',
      ];

  static void validateCsvHeader(List<String> header) {
    final expected = expectedCsvHeader();
    for (var i = 0; i < expected.length; i++) {
      if (i >= header.length || header[i] != expected[i]) {
        throw FormatException(
            'calendar_dates.txt header mismatch at column ${i + 1}: expected "${expected[i]}" but found "${i < header.length ? header[i] : '<missing>'}"');
      }
    }
  }
}
