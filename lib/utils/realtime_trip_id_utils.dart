Set<String> collectTripIdsFromRawJson(Map<String, dynamic>? rawJson) {
  final ids = <String>{};
  if (rawJson == null) {
    return ids;
  }

  _addNonEmptyValue(ids, rawJson['tripId']);
  _addNonEmptyValue(ids, rawJson['id']);
  _addNonEmptyValue(ids, rawJson['trip_id']);

  final transport = rawJson['transportation'];
  if (transport is Map && transport['properties'] is Map) {
    final properties = transport['properties'] as Map<dynamic, dynamic>;
    _addNonEmptyValue(ids, properties['RealtimeTripId']);
    _addNonEmptyValue(ids, properties['AVMSTripID']);
    _addNonEmptyValue(ids, properties['realtimeTripId']);
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

  final legsJson = tripRawJson?['legs'];
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
