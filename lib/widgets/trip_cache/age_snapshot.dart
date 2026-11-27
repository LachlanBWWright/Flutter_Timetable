import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';

/// Rechecks displayed data when time passes without a new network response.
TripCacheSnapshot ageTripCacheSnapshot(
  TripCacheSnapshot snapshot,
  DateTime now,
) {
  final fetchedAt = snapshot.fetchedAt;
  final age = fetchedAt == null ? null : now.difference(fetchedAt);
  final expired =
      snapshot.isExpired ||
      (age != null && (age.isNegative || age >= const Duration(hours: 24)));
  final response = expired ? null : snapshot.response;
  final stale =
      response != null &&
      (snapshot.error != null ||
          snapshot.isOffline ||
          (age != null && age >= const Duration(minutes: 10)));
  final fresh = response != null && age != null && !stale && !expired;
  return TripCacheSnapshot(
    response: response == null
        ? null
        : GetTripsResponse(
            tripJourneys: response.tripJourneys
                .where((journey) {
                  if (journey.legs.isEmpty) return false;
                  final stop = journey.legs.first.origin;
                  final departure =
                      DateTime.tryParse(stop.departureTimeEstimated ?? '') ??
                      DateTime.tryParse(stop.departureTimePlanned ?? '');
                  return departure != null && !departure.isBefore(now);
                })
                .toList(growable: false),
            systemMessages: response.systemMessages,
            version: response.version,
            rawJson: response.rawJson,
          ),
    fetchedAt: fetchedAt,
    error: snapshot.error,
    isFresh: fresh,
    isStale: stale,
    isExpired: expired,
    isOffline: snapshot.isOffline,
  );
}
