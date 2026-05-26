import 'safe_value_utils.dart';

Set<String> collectTripIdsFromRawJson(Map<String, dynamic>? rawJson) {
  final ids = <String>{};
  if (rawJson == null) {
    return ids;
  }

  _addNonEmptyValue(ids, tryReadMapValue(rawJson, 'tripId'));
  _addNonEmptyValue(ids, tryReadMapValue(rawJson, 'id'));
  _addNonEmptyValue(ids, tryReadMapValue(rawJson, 'trip_id'));

  final transport = tryReadJsonMap(rawJson, 'transportation');
  final properties = tryReadJsonMap(transport, 'properties');
  if (properties != null) {
    _addNonEmptyValue(ids, tryReadMapValue(properties, 'RealtimeTripId'));
    _addNonEmptyValue(ids, tryReadMapValue(properties, 'AVMSTripID'));
    _addNonEmptyValue(ids, tryReadMapValue(properties, 'realtimeTripId'));
  }

  return ids;
}

Set<String> collectTripIdsForVehicleFiltering({
  required Map<String, dynamic>? tripRawJson,
  required Map<String, dynamic>? legRawJson,
}) {
  final ids = <String>{};
  ids.addAll(collectTripIdsFromRawJson(tripRawJson));
  ids.addAll(collectTripIdsFromRawJson(legRawJson));

  final legsJson = tryReadListValue(tripRawJson, 'legs');
  if (legsJson is List) {
    for (final legJson in legsJson.whereType<Map<String, dynamic>>()) {
      ids.addAll(collectTripIdsFromRawJson(legJson));
    }
  }

  return ids;
}

void _addNonEmptyValue(Set<String> ids, Object? rawValue) {
  if (rawValue == null) {
    return;
  }

  final value = rawValue.toString().trim();
  if (value.isNotEmpty) {
    ids.add(value);
  }
}
