import 'csv_field_reader.dart';

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
  final String? continuousPickup;
  final String? continuousDropOff;
  final String? networkId;

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
    this.continuousPickup,
    this.continuousDropOff,
    this.networkId,
  });

  /// Create a Route from a CSV row using header-based field mapping
  factory Route.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    return Route(
      routeId: reader.fieldOrEmpty('route_id'),
      agencyId: reader.fieldOrNull('agency_id'),
      routeShortName: reader.fieldOrEmpty('route_short_name'),
      routeLongName: reader.fieldOrEmpty('route_long_name'),
      routeDesc: reader.fieldOrNull('route_desc'),
      routeType: reader.fieldOrEmpty('route_type'),
      routeUrl: reader.fieldOrNull('route_url'),
      routeColor: reader.fieldOrNull('route_color'),
      routeTextColor: reader.fieldOrNull('route_text_color'),
      routeSortOrder: reader.fieldOrNull('route_sort_order'),
      continuousPickup: reader.fieldOrNull('continuous_pickup'),
      continuousDropOff: reader.fieldOrNull('continuous_drop_off'),
      networkId: reader.fieldOrNull('network_id'),
    );
  }

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
    'continuous_pickup',
    'continuous_drop_off',
    'network_id',
  ];

  static bool validateCsvHeader(List<String> header) {
    const required = [
      'route_id',
      'route_short_name',
      'route_long_name',
      'route_type',
    ];
    return required.every(header.contains);
  }
}
