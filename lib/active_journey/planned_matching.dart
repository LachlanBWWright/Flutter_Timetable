import '../constants/transport_modes.dart';
import '../models/manual_trip_models.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../schema/database.dart' show Journey;
import '../services/transport_api_service.dart' as api;
import '../utils/realtime_leg_match.dart';
import '../utils/realtime_service_date.dart';
import '../utils/realtime_trip_id_utils.dart';
import '../vehicle_finder/models.dart';
import 'matching.dart';
import 'models.dart';

/// A whole itinerary can contain walking connectors or onward vehicles. Only
/// an unambiguous exact service leg supplies the currently ridden segment.
ActiveJourneyMatch? matchPlannedJourney(
  Journey journey,
  bool reverse,
  FinderVehicle vehicle,
  api.TripJourney plan,
  List<RunningStop> live,
  DateTime now,
  TripUpdate? update,
) {
  if (plan.legs.isEmpty ||
      (journey.savedMode != null && journey.savedMode != vehicle.mode)) {
    return null;
  }
  final origin = nswStopId(reverse ? journey.destinationId : journey.originId);
  final destination = nswStopId(
    reverse ? journey.originId : journey.destinationId,
  );
  bool endpoint(api.Stop stop, String? id) =>
      id != null && (stop.id == id || stop.parent?.id == id);
  if (!endpoint(plan.legs.first.origin, origin) ||
      !endpoint(plan.legs.last.destination, destination)) {
    return null;
  }
  for (var i = 1; i < plan.legs.length; i++) {
    final previous = plan.legs[i - 1].destination;
    final next = plan.legs[i].origin;
    if (previous.id != next.id &&
        previous.parent?.id != next.id &&
        next.parent?.id != previous.id &&
        (previous.parent?.id == null ||
            previous.parent?.id != next.parent?.id)) {
      return null;
    }
  }
  final matches = <ActiveJourneyMatch>[];
  for (final entry in plan.legs.indexed) {
    final leg = entry.$2;
    final productClass = leg.transportation?.product?.classField;
    if (productClass != null) {
      final legMode = switch (productClass) {
        1 => TransportMode.train,
        2 => TransportMode.metro,
        4 => TransportMode.lightrail,
        5 || 11 => TransportMode.bus,
        9 => TransportMode.ferry,
        _ => null,
      };
      // Unknown explicit products (including walking) cannot establish a ride.
      if (legMode != vehicle.mode) continue;
    }
    final ids = collectTripIdsForVehicleFiltering(
      // A whole itinerary's identity cannot identify an individual vehicle leg.
      tripRawJson: plan.legs.length == 1 ? plan.rawJson : null,
      legRawJson: leg.rawJson,
    );
    if (!ids.contains(vehicle.service!.tripId)) continue;
    if (!realtimeDescriptorMatchesLeg(
      vehicle.service!.descriptor,
      api.Leg(
        origin: leg.origin,
        destination: leg.destination,
        rawJson: leg.rawJson,
      ),
      ids,
      matchedTrip: update?.trip,
    )) {
      continue;
    }
    final segment = Journey(
      id: journey.id,
      tripType: 'direct',
      origin: leg.origin.name,
      originId: leg.origin.id,
      destination: leg.destination.name,
      destinationId: leg.destination.id,
      mode: vehicle.mode.id,
      isPinned: journey.isPinned,
    );
    final pattern = matchRunningPattern(
      segment,
      false,
      vehicle,
      plannedStops(leg, live),
      now,
      absoluteSequences: false,
    );
    if (pattern == null || outsideLiveSegment(vehicle, leg, live)) continue;
    matches.add(
      ActiveJourneyMatch(
        journey: journey,
        reverse: reverse,
        stops: pattern.stops,
        plannedTrip: plan,
        currentLegIndex: entry.$1,
        currentLegDestinationId: leg.destination.id,
        currentLegDestinationName: leg.destination.name,
      ),
    );
  }
  return matches.length == 1 ? matches.single : null;
}

bool outsideLiveSegment(
  FinderVehicle vehicle,
  api.Leg leg,
  List<RunningStop> live,
) {
  final sequence = vehicle.currentStopSequence;
  if (sequence == null) return false;
  final origin = live
      .where((s) => s.matches(leg.origin.id) || s.id == leg.origin.parent?.id)
      .toList();
  final destination = live
      .where(
        (s) =>
            s.matches(leg.destination.id) || s.id == leg.destination.parent?.id,
      )
      .toList();
  if (destination.length == 1 && sequence > destination.single.sequence) {
    return true;
  }
  if (origin.length == 1 &&
      (sequence < origin.single.sequence ||
          (sequence == origin.single.sequence && !vehicle.atStop))) {
    return true;
  }
  return false;
}

List<RunningStop> plannedStops(api.Leg leg, List<RunningStop> live) {
  final sequence = [leg.origin, ...?leg.stopSequence, leg.destination];
  final stops = <RunningStop>[];
  for (final stop in sequence) {
    if (stops.isNotEmpty && stops.last.id == stop.id) continue;
    final updates = live
        .where((s) => s.id == stop.id || s.stationId == stop.id)
        .toList();
    final realtime = updates.length == 1 ? updates.single : null;
    stops.add(
      RunningStop(
        id: stop.id,
        name: stop.name,
        stationId: stop.parent?.id,
        sequence: stops.length,
        arrival:
            realtime?.arrival ??
            tfnswTimeInstant(
              stop.arrivalTimeEstimated ?? stop.arrivalTimePlanned,
            ),
        departure:
            realtime?.departure ??
            tfnswTimeInstant(
              stop.departureTimeEstimated ?? stop.departureTimePlanned,
            ),
        skipped: realtime?.skipped ?? false,
      ),
    );
  }
  return stops;
}
