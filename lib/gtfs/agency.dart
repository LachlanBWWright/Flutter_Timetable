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
  factory Agency.fromCsvWithHeader(List<String> header, List<String> row) {
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

  /// Legacy constructor for backward compatibility with positional CSV parsing
  factory Agency.fromCsv(List<String> row) => Agency(
        agencyId: row[0],
        agencyName: row[1],
        agencyUrl: row[2],
        agencyTimezone: row[3],
        agencyLang: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        agencyPhone: row.length > 5 && row[5].isNotEmpty ? row[5] : null,
        agencyFareUrl: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        agencyEmail: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
      );

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
