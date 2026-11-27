import 'csv_field_reader.dart';

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
    final reader = CsvFieldReader(header, row);

    return CalendarDate(
      serviceId: reader.fieldOrEmpty('service_id'),
      date: reader.fieldOrEmpty('date'),
      exceptionType: reader.fieldOrEmpty('exception_type'),
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
