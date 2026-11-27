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
  for (final source in [
    rawJson,
    tryReadJsonMap(rawJson, 'properties'),
    properties,
  ]) {
    for (final key in ['RealtimeTripId', 'AVMSTripID', 'realtimeTripId']) {
      _addNonEmptyValue(ids, tryReadMapValue(source, key));
    }
  }

  return ids;
}

Set<String> collectTripIdsForVehicleFiltering({
  required Map<String, dynamic>? tripRawJson,
  required Map<String, dynamic>? legRawJson,
}) {
  final ids = <String>{};
  // An EFA leg/journey's generic `id` is not a GTFS realtime trip ID.
  ids.addAll(
    collectTripIdsFromRawJson(
      legRawJson == null
          ? null
          : (Map<String, dynamic>.of(legRawJson)..remove('id')),
    ),
  );

  // Vehicle filtering must stay scoped to the active leg. Journey raw JSON may
  // contain every leg, so only use top-level trip IDs as a fallback when the
  // active leg itself carries no realtime trip ID.
  if (ids.isEmpty && tryReadMapValue(tripRawJson, 'legs') == null) {
    ids.addAll(
      collectTripIdsFromRawJson(
        tripRawJson == null
            ? null
            : (Map<String, dynamic>.of(tripRawJson)..remove('id')),
      ),
    );
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
