import '../models/manual_trip_models.dart';
import '../schema/database.dart' show Journey;
import '../transit/domain/transit_types.dart';
import '../vehicle_finder/models.dart';
import 'models.dart';

String? nswStopId(String value) {
  if (!value.contains('|')) return value.trim().isEmpty ? null : value;
  final ref = TransitStopRef.tryParse(value);
  return ref?.region == TransitRegion.nsw &&
          ref?.provider == TransitProviderId.tfnsw
      ? ref!.stopId
      : null;
}

ActiveJourneyMatch? matchRunningPattern(
  Journey journey,
  bool reverse,
  FinderVehicle vehicle,
  List<RunningStop> stops,
  DateTime now, {
  bool absoluteSequences = true,
}) {
  if (journey.isManualMultiLeg ||
      (journey.savedMode != null && journey.savedMode != vehicle.mode)) {
    return null;
  }
  final origin = nswStopId(reverse ? journey.destinationId : journey.originId);
  final destination = nswStopId(
    reverse ? journey.originId : journey.destinationId,
  );
  if (origin == null || destination == null || origin == destination) {
    return null;
  }
  final from = stops.indexed.where((s) => s.$2.matches(origin)).toList();
  final to = stops.indexed.where((s) => s.$2.matches(destination)).toList();
  // Repeated calls at a station need more evidence than a stop ID alone.
  if (from.length != 1 || to.length != 1 || from.single.$1 >= to.single.$1) {
    return null;
  }
  final first = from.single.$2;
  final last = to.single.$2;
  if (first.skipped || last.skipped) return null;
  var positionKnown = false;
  final sequence = vehicle.currentStopSequence;
  if (absoluteSequences && sequence != null) {
    positionKnown = true;
    if (sequence < first.sequence ||
        sequence > last.sequence ||
        (sequence == first.sequence && !vehicle.atStop)) {
      return null;
    }
  } else if (vehicle.currentStopId?.isNotEmpty == true) {
    final positions = stops.indexed
        .where((s) => s.$2.matches(vehicle.currentStopId!))
        .toList();
    if (positions.length != 1) return null;
    positionKnown = true;
    final index = positions.single.$1;
    if (index < from.single.$1 ||
        index > to.single.$1 ||
        (index == from.single.$1 && !vehicle.atStop)) {
      return null;
    }
  }
  final departure = first.departure ?? first.arrival;
  final arrival = last.arrival ?? last.departure;
  // Timing-only inference needs both ends, not an open-ended route match.
  if (!positionKnown && (departure == null || arrival == null)) return null;
  if (!positionKnown &&
      (departure!.isAfter(now.add(const Duration(minutes: 2))) ||
          arrival!.isBefore(now.subtract(const Duration(minutes: 2))))) {
    return null;
  }
  return ActiveJourneyMatch(
    journey: journey,
    reverse: reverse,
    stops: List.unmodifiable(stops.sublist(from.single.$1, to.single.$1 + 1)),
  );
}
