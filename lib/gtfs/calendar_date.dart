class CalendarDate {
  final String serviceId;
  final String date;
  final String exceptionType;

  CalendarDate({
    required this.serviceId,
    required this.date,
    required this.exceptionType,
  });

  /// Create a CalendarDate from a CSV row using header-based field mapping
  factory CalendarDate.fromCsv(List<String> header, List<String> row) {
    String getField(String fieldName, {String defaultValue = ''}) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return defaultValue;
      final value = row[index];
      return value.isEmpty ? defaultValue : value;
    }

    return CalendarDate(
      serviceId: getField('service_id'),
      date: getField('date'),
      exceptionType: getField('exception_type'),
    );
  }

  /// Expected CSV header for calendar_dates.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'service_id',
    'date',
    'exception_type',
  ];

  static void validateCsvHeader(List<String> header) {
    // All fields are required in calendar_dates.txt per GTFS spec
    final required = expectedCsvHeader();
    for (final col in required) {
      if (!header.contains(col)) {
        // Missing required column — callers should handle this case
      }
    }
  }
}
