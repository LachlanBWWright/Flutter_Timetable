import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

import 'realtime_service_date.dart';
import 'safe_value_utils.dart';

/// Match one service instance, never the first vehicle sharing its route.
TripUpdate? matchRealtimeUpdateForLeg(
  Iterable<TripUpdate> updates,
  Leg leg,
  Set<String> tripIds,
) {
  TripUpdate? match;
  for (final update in updates) {
    final trip = update.trip;
    if (!trip.hasTripId() || trip.tripId.trim().isEmpty) continue;
    if (!_compatibleDescriptor(trip, leg, tripIds)) continue;
    final stopMatch = _matchesScheduledStops(update, leg);
    if (!realtimeServiceDateMatches(
      trip,
      leg,
      allowPreviousServiceDate: stopMatch,
    )) {
      continue;
    }
    if (tripIds.isEmpty && !stopMatch) continue;
    // Reused trip IDs and multiple plausible departures are ambiguous too.
    if (match != null) return null;
    match = update;
  }
  return match;
}

/// Vehicle filtering also checks the selected update's service instance.
/// A trip's start time is its first stop's time, not the boarding stop's time.
bool realtimeDescriptorMatchesLeg(
  TripDescriptor descriptor,
  Leg leg,
  Set<String> tripIds, {
  TripDescriptor? matchedTrip,
}) {
  if (tripIds.isEmpty || !descriptor.hasTripId()) return false;
  if (!_compatibleDescriptor(descriptor, leg, tripIds)) return false;
  if (matchedTrip != null) {
    for (final pair in [
      (descriptor.tripId, matchedTrip.tripId),
      (descriptor.startDate, matchedTrip.startDate),
      (descriptor.startTime, matchedTrip.startTime),
    ]) {
      if (pair.$1.isNotEmpty && pair.$2.isNotEmpty && pair.$1 != pair.$2) {
        return false;
      }
    }
  }
  return realtimeServiceDateMatches(
    descriptor,
    leg,
    allowPreviousServiceDate:
        matchedTrip?.hasStartDate() == true &&
        matchedTrip!.startDate == descriptor.startDate,
  );
}

/// Ambiguous vehicle service instances fail closed even with a reused trip ID.
List<VehiclePosition> filterRealtimeVehiclesForLeg(
  Iterable<VehiclePosition> vehicles,
  Leg leg,
  Set<String> tripIds, {
  TripDescriptor? matchedTrip,
}) {
  final candidates = vehicles
      .where(
        (vehicle) => realtimeDescriptorMatchesLeg(
          vehicle.trip,
          leg,
          tripIds,
          matchedTrip: matchedTrip,
        ),
      )
      .toList();
  final instances = <String, Set<String>>{};
  for (final vehicle in candidates) {
    final trip = vehicle.trip;
    instances
        .putIfAbsent(trip.tripId, () => {})
        .add('${trip.startDate}/${trip.startTime}');
  }
  return candidates
      .where((vehicle) => instances[vehicle.trip.tripId]!.length == 1)
      .toList();
}

bool _compatibleDescriptor(
  TripDescriptor descriptor,
  Leg leg,
  Set<String> tripIds,
) {
  final raw = leg.rawJson;
  // This matcher consumes TfNSW feeds. Regional legs retain their provenance.
  if (raw['provenance'] == 'regional_journey_planner') return false;
  for (final entry in [
    ('transitRegion', 'nsw'),
    ('transitProvider', 'tfnsw'),
  ]) {
    final value = trimmedOrNull(tryReadStringValue(raw, entry.$1));
    if (value != null && value != entry.$2) return false;
  }
  if (tripIds.isNotEmpty && !tripIds.contains(descriptor.tripId)) return false;
  final routeId = trimmedOrNull(leg.transportation?.id);
  if (routeId != null && tripIds.isEmpty && descriptor.routeId.trim().isEmpty) {
    return false;
  }
  if (routeId != null &&
      descriptor.hasRouteId() &&
      descriptor.routeId.trim().isNotEmpty &&
      descriptor.routeId != routeId) {
    return false;
  }
  for (final entry in [
    ('startDate', descriptor.startDate),
    ('startTime', descriptor.startTime),
    ('start_date', descriptor.startDate),
    ('start_time', descriptor.startTime),
  ]) {
    final expected = trimmedOrNull(tryReadStringValue(raw, entry.$1));
    if (expected != null && entry.$2.isNotEmpty && expected != entry.$2) {
      return false;
    }
  }
  return true;
}

bool _matchesScheduledStops(TripUpdate update, Leg leg) {
  final departure = tfnswDepartureInstant(leg);
  if (departure == null) return false;
  final origins = _stopIds(leg.origin);
  final destinations = _stopIds(leg.destination);
  if (origins.isEmpty || destinations.isEmpty) return false;
  var matchedDeparture = false;
  for (final stop in update.stopTimeUpdate) {
    if (!stop.hasStopId()) continue;
    if (matchedDeparture && destinations.contains(stop.stopId)) return true;
    if (!origins.contains(stop.stopId) || !stop.hasDeparture()) continue;
    final event = stop.departure;
    // Delay is required to recover the scheduled instant from a live estimate.
    if (!event.hasTime() || !event.hasDelay()) continue;
    final planned = DateTime.fromMillisecondsSinceEpoch(
      (event.time.toInt() - event.delay) * 1000,
      isUtc: true,
    );
    if (planned.difference(departure).abs() <= const Duration(seconds: 30)) {
      matchedDeparture = true;
    }
  }
  return false;
}

Set<String> _stopIds(Stop stop) => {
  if (stop.id.trim().isNotEmpty) stop.id.trim(),
  for (final source in [
    tryReadJsonMap(stop.rawJson, 'properties'),
    tryReadJsonMap(tryReadJsonMap(stop.rawJson, 'parent'), 'properties'),
  ])
    if (tryReadStringValue(source, 'stopId')?.trim().isNotEmpty == true)
      tryReadStringValue(source, 'stopId')!.trim(),
};
