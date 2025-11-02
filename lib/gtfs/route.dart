class Route {
  final String routeId;
  final String? agencyId;
  final String routeShortName;
  final String routeLongName;
  final String? routeDesc;
  final String routeType;
  final String? routeUrl;
  final String? routeColor;
  final String? routeTextColor;
  final String? routeSortOrder;

  Route({
    required this.routeId,
    this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    this.routeDesc,
    required this.routeType,
    this.routeUrl,
    this.routeColor,
    this.routeTextColor,
    this.routeSortOrder,
  });

  /// Create a Route from a CSV row using header-based field mapping
  factory Route.fromCsvWithHeader(List<String> header, List<String> row) {
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    return Route(
      routeId: getField('route_id') ?? '',
      agencyId: getField('agency_id'),
      routeShortName: getField('route_short_name') ?? '',
      routeLongName: getField('route_long_name') ?? '',
      routeDesc: getField('route_desc'),
      routeType: getField('route_type') ?? '',
      routeUrl: getField('route_url'),
      routeColor: getField('route_color'),
      routeTextColor: getField('route_text_color'),
      routeSortOrder: getField('route_sort_order'),
    );
  }

  /// Legacy constructor for backward compatibility with positional CSV parsing
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
        routeSortOrder: null,
      );

  /// Expected CSV header for routes.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
        'route_id',
        'agency_id',
        'route_short_name',
        'route_long_name',
        'route_desc',
        'route_type',
        'route_url',
        'route_color',
        'route_text_color',
        'route_sort_order',
      ];

  static void validateCsvHeader(List<String> header) {
    // Require presence of required columns per GTFS spec
    final required = [
      'route_id',
      'route_short_name',
      'route_long_name',
      'route_type'
    ];
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('routes.txt missing required column "$col"');
      }
    }
  }
}
