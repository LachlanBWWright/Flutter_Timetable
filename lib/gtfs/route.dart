class Route {
  final String routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String? routeDesc;
  final String routeType;
  final String? routeColor;
  final String? routeTextColor;
  final String? routeUrl;

  Route({
    required this.routeId,
    required this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    this.routeDesc,
    required this.routeType,
    this.routeColor,
    this.routeTextColor,
    this.routeUrl,
  });

  factory Route.fromCsv(List<String> row) => Route(
        routeId: row[0],
        agencyId: row[1],
        routeShortName: row[2],
        routeLongName: row[3],
        routeDesc: row.length > 4 && row[4].isNotEmpty ? row[4] : null,
        routeType: row[5],
        routeColor: row.length > 6 && row[6].isNotEmpty ? row[6] : null,
        routeTextColor: row.length > 7 && row[7].isNotEmpty ? row[7] : null,
        routeUrl: row.length > 8 && row[8].isNotEmpty ? row[8] : null,
      );

  /// Expected CSV header for routes.txt
  static List<String> expectedCsvHeader() => [
        'route_id',
        'agency_id',
        'route_short_name',
        'route_long_name',
        'route_desc',
        'route_type',
        'route_color',
        'route_text_color',
        'route_url',
      ];

  static void validateCsvHeader(List<String> header) {
    // Require presence and order of required (non-nullable) columns.
    final required = [
      'route_id',
      'agency_id',
      'route_short_name',
      'route_long_name',
      'route_type'
    ];
    var lastIndex = -1;
    for (final col in required) {
      final idx = header.indexOf(col);
      if (idx == -1) {
        throw FormatException('routes.txt missing required column "$col"');
      }
      if (idx <= lastIndex) {
        throw FormatException('routes.txt column "$col" is out of order');
      }
      lastIndex = idx;
    }
  }
}
