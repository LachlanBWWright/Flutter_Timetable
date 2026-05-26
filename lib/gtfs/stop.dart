import 'csv_field_reader.dart';

class Stop {
  final String stopId;
  final String? stopCode;
  final String stopName;
  final String? ttsStopName;
  final String? stopDesc;
  final double stopLat;
  final double stopLon;
  final String? zoneId;
  final String? stopUrl;
  final int locationType;
  final String? parentStation;
  final String? stopTimezone;
  final int wheelchairBoarding;
  final String? levelId;
  final String? platformCode;

  Stop({
    required this.stopId,
    this.stopCode,
    required this.stopName,
    this.ttsStopName,
    this.stopDesc,
    required this.stopLat,
    required this.stopLon,
    this.zoneId,
    this.stopUrl,
    required this.locationType,
    this.parentStation,
    this.stopTimezone,
    required this.wheelchairBoarding,
    this.levelId,
    this.platformCode,
  });

  /// Create a Stop from a CSV row using header-based field mapping
  factory Stop.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    // Resolve stop_id with fallbacks for feeds that omit stop_id values.
    // Prefer stop_id, then stop_code, then derive a deterministic id from
    // stop_name + lat/lon to ensure we can persist the stop rather than
    // dropping rows silently.
    String resolveStopId() {
      final rawId = reader.fieldOrNull('stop_id');
      if (rawId != null && rawId.trim().isNotEmpty) return rawId.trim();
      final code = reader.fieldOrNull('stop_code');
      if (code != null && code.trim().isNotEmpty) return code.trim();
      final name = reader.fieldOrNull('stop_name') ?? 'unknown';
      final lat = reader.fieldOrEmpty('stop_lat');
      final lon = reader.fieldOrEmpty('stop_lon');
      // Create a compact derived id. Replace whitespace with underscores and
      // remove commas to keep the id DB-friendly.
      final safeName = name.replaceAll(RegExp(r'[\s,]+'), '_');
      return '${safeName}_${lat}_$lon';
    }

    return Stop(
      stopId: resolveStopId(),
      stopCode: reader.fieldOrNull('stop_code'),
      stopName: reader.fieldOrEmpty('stop_name'),
      ttsStopName: reader.fieldOrNull('tts_stop_name'),
      stopDesc: reader.fieldOrNull('stop_desc'),
      stopLat: reader.doubleField('stop_lat'),
      stopLon: reader.doubleField('stop_lon'),
      zoneId: reader.fieldOrNull('zone_id'),
      stopUrl: reader.fieldOrNull('stop_url'),
      locationType: reader.intField('location_type'),
      parentStation: reader.fieldOrNull('parent_station'),
      stopTimezone: reader.fieldOrNull('stop_timezone'),
      wheelchairBoarding: reader.intField('wheelchair_boarding'),
      levelId: reader.fieldOrNull('level_id'),
      platformCode: reader.fieldOrNull('platform_code'),
    );
  }

  /// Expected CSV header for stops.txt per GTFS specification
  static List<String> expectedCsvHeader() => [
    'stop_id',
    'stop_code',
    'stop_name',
    'tts_stop_name',
    'stop_desc',
    'stop_lat',
    'stop_lon',
    'zone_id',
    'stop_url',
    'location_type',
    'parent_station',
    'stop_timezone',
    'wheelchair_boarding',
    'level_id',
    'platform_code',
  ];

  static bool validateCsvHeader(List<String> header) {
    return header.contains('stop_id');
  }

  @override
  String toString() =>
      'Stop(stopId: $stopId, stopCode: $stopCode, stopName: $stopName, stopLat: $stopLat, stopLon: $stopLon, locationType: $locationType, parentStation: $parentStation, wheelchairBoarding: $wheelchairBoarding, platformCode: $platformCode)';
}
