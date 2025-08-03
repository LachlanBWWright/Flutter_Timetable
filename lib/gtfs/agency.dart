class Agency {
  final String agencyId;
  final String agencyName;
  final String agencyUrl;
  final String agencyTimezone;
  final String? agencyLang;
  final String? agencyPhone;
  final String? agencyFareUrl;
  final String? agencyEmail;

  Agency({
    required this.agencyId,
    required this.agencyName,
    required this.agencyUrl,
    required this.agencyTimezone,
    this.agencyLang,
    this.agencyPhone,
    this.agencyFareUrl,
    this.agencyEmail,
  });

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
}
