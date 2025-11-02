class Agency {
  final String? agencyId;
  final String agencyName;
  final String agencyUrl;
  final String agencyTimezone;
  final String? agencyLang;
  final String? agencyPhone;
  final String? agencyFareUrl;
  final String? agencyEmail;

  Agency({
    this.agencyId,
    required this.agencyName,
    required this.agencyUrl,
    required this.agencyTimezone,
    this.agencyLang,
    this.agencyPhone,
    this.agencyFareUrl,
    this.agencyEmail,
  });

  /// Create an Agency from a CSV row using header-based field mapping
  factory Agency.fromCsv(List<String> header, List<String> row) {
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    return Agency(
      agencyId: getField('agency_id'),
      agencyName: getField('agency_name') ?? '',
      agencyUrl: getField('agency_url') ?? '',
      agencyTimezone: getField('agency_timezone') ?? '',
      agencyLang: getField('agency_lang'),
      agencyPhone: getField('agency_phone'),
      agencyFareUrl: getField('agency_fare_url'),
      agencyEmail: getField('agency_email'),
    );
  }

  /// Expected CSV header for agency.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
        'agency_id',
        'agency_name',
        'agency_url',
        'agency_timezone',
        'agency_lang',
        'agency_phone',
        'agency_fare_url',
        'agency_email',
      ];

  static void validateCsvHeader(List<String> header) {
    // Require presence of required columns per GTFS spec
    final required = [
      'agency_name',
      'agency_url',
      'agency_timezone'
    ];
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('agency.txt missing required column "$col"');
      }
    }
  }
}
