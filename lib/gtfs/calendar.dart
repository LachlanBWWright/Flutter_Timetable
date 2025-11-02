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
    String getField(String fieldName, {String defaultValue = ''}) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return defaultValue;
      final value = row[index];
      return value.isEmpty ? defaultValue : value;
    }

    return Calendar(
      serviceId: getField('service_id'),
      monday: getField('monday'),
      tuesday: getField('tuesday'),
      wednesday: getField('wednesday'),
      thursday: getField('thursday'),
      friday: getField('friday'),
      saturday: getField('saturday'),
      sunday: getField('sunday'),
      startDate: getField('start_date'),
      endDate: getField('end_date'),
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
        throw FormatException('calendar.txt missing required column "$col"');
      }
    }
  }
}
