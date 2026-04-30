import '../widgets/station_widgets.dart';

List<String> buildStationDebugLines(Station station) {
  return [
    'ID: ${station.id}',
    'Code: ${station.stopCode ?? '-'}',
    'Parent: ${station.parentStation ?? '-'}',
    'Desc: ${station.stopDesc ?? '-'}',
    'Zone: ${station.zoneId ?? '-'}',
    'URL: ${station.stopUrl ?? '-'}',
    'TZ: ${station.stopTimezone ?? '-'}',
    'Level: ${station.levelId ?? '-'}',
    'Wheelchair: ${station.wheelchairBoarding ?? '-'}',
    'Platform: ${station.platformCode ?? '-'}',
    'Lat/Lon: ${station.latitude?.toStringAsFixed(5) ?? '-'}, ${station.longitude?.toStringAsFixed(5) ?? '-'}',
  ];
}

String? formatStationDistanceLine(
  double? distance, {
  required bool debugFormat,
}) {
  if (distance == null) {
    return null;
  }

  if (debugFormat) {
    return 'Distance: ${distance.toStringAsFixed(2)} km';
  }
  return '${distance.toStringAsFixed(1)} km away';
}
