/// Dart class for GTFS routes.txt
class Route {
  final String routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String routeDesc;
  final int routeType;
  final String routeColor;
  final String routeTextColor;
  final String routeUrl;

  Route({
    required this.routeId,
    required this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    required this.routeDesc,
    required this.routeType,
    required this.routeColor,
    required this.routeTextColor,
    required this.routeUrl,
  });

  factory Route.fromCsvRow(List<String> row) => Route(
        routeId: row[0],
        agencyId: row[1],
        routeShortName: row[2],
        routeLongName: row[3],
        routeDesc: row[4],
        routeType: int.parse(row[5]),
        routeColor: row[6],
        routeTextColor: row[7],
        routeUrl: row[8],
      );

  List<String> toCsvRow() => [
        routeId,
        agencyId,
        routeShortName,
        routeLongName,
        routeDesc,
        routeType.toString(),
        routeColor,
        routeTextColor,
        routeUrl,
      ];
}
