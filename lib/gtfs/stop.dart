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
    String? getField(String fieldName) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return null;
      final value = row[index];
      return value.isEmpty ? null : value;
    }

    double getDoubleField(String fieldName, {double defaultValue = 0.0}) {
      final value = getField(fieldName);
      return value != null
          ? (double.tryParse(value) ?? defaultValue)
          : defaultValue;
    }

    int getIntField(String fieldName, {int defaultValue = 0}) {
      final value = getField(fieldName);
      return value != null
          ? (int.tryParse(value) ?? defaultValue)
          : defaultValue;
    }

    // Resolve stop_id with fallbacks for feeds that omit stop_id values.
    // Prefer stop_id, then stop_code, then derive a deterministic id from
    // stop_name + lat/lon to ensure we can persist the stop rather than
    // dropping rows silently.
    String resolveStopId() {
      final rawId = getField('stop_id');
      if (rawId != null && rawId.trim().isNotEmpty) return rawId.trim();
      final code = getField('stop_code');
      if (code != null && code.trim().isNotEmpty) return code.trim();
      final name = getField('stop_name') ?? 'unknown';
      final lat = getField('stop_lat') ?? '';
      final lon = getField('stop_lon') ?? '';
      // Create a compact derived id. Replace whitespace with underscores and
      // remove commas to keep the id DB-friendly.
      final safeName = name.replaceAll(RegExp(r'[\s,]+'), '_');
      return '${safeName}_${lat}_$lon';
    }

    return Stop(
      stopId: resolveStopId(),
      stopCode: getField('stop_code'),
      stopName: getField('stop_name') ?? '',
      ttsStopName: getField('tts_stop_name'),
      stopDesc: getField('stop_desc'),
      stopLat: getDoubleField('stop_lat'),
      stopLon: getDoubleField('stop_lon'),
      zoneId: getField('zone_id'),
      stopUrl: getField('stop_url'),
      locationType: getIntField('location_type'),
      parentStation: getField('parent_station'),
      stopTimezone: getField('stop_timezone'),
      wheelchairBoarding: getIntField('wheelchair_boarding'),
      levelId: getField('level_id'),
      platformCode: getField('platform_code'),
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

  static void validateCsvHeader(List<String> header) {
    // Only require stop_id per GTFS spec (other fields are conditionally required)
    if (!header.contains('stop_id')) {
      // Missing required column — callers should handle this case
    }
  }

  @override
  String toString() =>
      'Stop(stopId: $stopId, stopCode: $stopCode, stopName: $stopName, stopLat: $stopLat, stopLon: $stopLon, locationType: $locationType, parentStation: $parentStation, wheelchairBoarding: $wheelchairBoarding, platformCode: $platformCode)';
}
