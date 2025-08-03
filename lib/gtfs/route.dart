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
}
