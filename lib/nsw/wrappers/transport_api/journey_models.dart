part of '../transport_api_service_impl.dart';

class GetTripsResponse {
  final List<TripJourney> tripJourneys;
  final SystemMessages systemMessages;
  final String version;

  /// Original backend fetch time, preserved when shared data is cached locally.
  final DateTime? fetchedAt;

  /// Raw JSON response as returned by the transport API.
  ///
  /// This is useful for debug/diagnostic features when the parsed model
  /// doesn't contain enough context.
  final Map<String, dynamic> rawJson;

  GetTripsResponse({
    required this.tripJourneys,
    required this.systemMessages,
    required this.version,
    required this.rawJson,
    this.fetchedAt,
  });

  factory GetTripsResponse.fromJson(Map<String, dynamic> json) =>
      getTripsResponseFromGenerated(
        generated.TripRequestResponse.fromJson(json),
        rawJson: json,
      );
}

class TripJourney {
  final bool? isAdditional;
  final List<Leg> legs;
  final int? rating;
  // Keep the original raw JSON for this TripJourney as returned by the API.
  // This ensures that any unmapped or subsequently-added fields are retained
  // and accessible for debug/diagnostic features.
  final Map<String, dynamic> rawJson;

  TripJourney({
    this.isAdditional,
    required this.legs,
    this.rating,
    this.rawJson = const <String, dynamic>{},
  });

  factory TripJourney.fromJson(Map<String, dynamic> json) {
    // TripJourney raw json keys logged (removed)
    final legsJson = tryReadListValue(json, 'legs');
    if (legsJson == null) {
      logger.w(
        'TripJourney.fromJson: "legs" is null or missing for journey keys=${json.keys.toList()}',
      );
    }

    final List<Leg> legsList = [];
    if (legsJson != null) {
      for (final entry in legsJson.indexed) {
        final i = entry.$1;
        final legJson = entry.$2;
        if (legJson is! Map<String, dynamic>) {
          logger.w(
            'TripJourney.fromJson: leg #$i is not a Map, type=${legJson.runtimeType}',
          );
          logger.d('raw leg #$i: ${jsonEncode(legJson)}');
          // Skip malformed leg entries but preserve logging to aid debugging
          continue;
        }
        try {
          legsList.add(Leg.fromJson(legJson));
        } catch (e, st) {
          logger.e('TripJourney.fromJson: unhandled error parsing leg #$i: $e');
          logger.d('Stack: $st');
          logger.d('raw leg #$i keys: ${legJson.keys.toList()}');
        }
      }
    }
    return TripJourney(
      isAdditional: _readBoolValue(json, 'isAdditional'),
      legs: legsList,
      rating: tryParseIntValue(tryReadMapValue(json, 'rating')),
      rawJson: json,
    );
  }
}
