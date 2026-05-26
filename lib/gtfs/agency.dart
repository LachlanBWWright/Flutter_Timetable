import 'csv_field_reader.dart';

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
    final reader = CsvFieldReader(header, row);

    return Agency(
      agencyId: reader.fieldOrNull('agency_id'),
      agencyName: reader.fieldOrEmpty('agency_name'),
      agencyUrl: reader.fieldOrEmpty('agency_url'),
      agencyTimezone: reader.fieldOrEmpty('agency_timezone'),
      agencyLang: reader.fieldOrNull('agency_lang'),
      agencyPhone: reader.fieldOrNull('agency_phone'),
      agencyFareUrl: reader.fieldOrNull('agency_fare_url'),
      agencyEmail: reader.fieldOrNull('agency_email'),
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

  static bool validateCsvHeader(List<String> header) {
    const required = ['agency_name', 'agency_url', 'agency_timezone'];
    return required.every(header.contains);
  }
}
