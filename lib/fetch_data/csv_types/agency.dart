/// Dart class for GTFS agency.txt
class Agency {
  final String agencyId;
  final String agencyName;
  final String agencyUrl;
  final String agencyTimezone;
  final String agencyLang;
  final String agencyPhone;
  final String agencyFareUrl;
  final String agencyEmail;

  Agency({
    required this.agencyId,
    required this.agencyName,
    required this.agencyUrl,
    required this.agencyTimezone,
    required this.agencyLang,
    required this.agencyPhone,
    required this.agencyFareUrl,
    required this.agencyEmail,
  });

  factory Agency.fromCsvRow(List<String> row) => Agency(
        agencyId: row[0],
        agencyName: row[1],
        agencyUrl: row[2],
        agencyTimezone: row[3],
        agencyLang: row[4],
        agencyPhone: row[5],
        agencyFareUrl: row[6],
        agencyEmail: row[7],
      );

  List<String> toCsvRow() => [
        agencyId,
        agencyName,
        agencyUrl,
        agencyTimezone,
        agencyLang,
        agencyPhone,
        agencyFareUrl,
        agencyEmail,
      ];
}
