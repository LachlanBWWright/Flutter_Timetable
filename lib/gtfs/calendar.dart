import 'csv_field_reader.dart';

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

  /// Create a Calendar from a CSV row using header-based field mapping
  factory Calendar.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    return Calendar(
      serviceId: reader.fieldOrEmpty('service_id'),
      monday: reader.fieldOrEmpty('monday'),
      tuesday: reader.fieldOrEmpty('tuesday'),
      wednesday: reader.fieldOrEmpty('wednesday'),
      thursday: reader.fieldOrEmpty('thursday'),
      friday: reader.fieldOrEmpty('friday'),
      saturday: reader.fieldOrEmpty('saturday'),
      sunday: reader.fieldOrEmpty('sunday'),
      startDate: reader.fieldOrEmpty('start_date'),
      endDate: reader.fieldOrEmpty('end_date'),
    );
  }

  /// Expected CSV header for calendar.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'service_id',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
    'start_date',
    'end_date',
  ];

  static void validateCsvHeader(List<String> header) {
    // All fields are required in calendar.txt per GTFS spec
    final required = expectedCsvHeader();
    for (final col in required) {
      if (!header.contains(col)) {
        // Missing required column — callers should handle this case
      }
    }
  }
}
