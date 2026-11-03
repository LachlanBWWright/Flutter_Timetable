import '../schema/database.dart' show Journey;
import '../services/transport_api_service.dart' show TripJourney;
import '../vehicle_finder/models.dart';

class RunningStop {
  const RunningStop({
    required this.id,
    required this.name,
    required this.sequence,
    this.stationId,
    this.arrival,
    this.departure,
    this.skipped = false,
  });
  final String id;
  final String? stationId;
  final String name;
  final int sequence;
  final DateTime? arrival;
  final DateTime? departure;
  final bool skipped;
  bool matches(String stopId) => id == stopId || stationId == stopId;
}

class ActiveJourneyMatch {
  const ActiveJourneyMatch({
    required this.journey,
    required this.reverse,
    required this.stops,
    this.plannedTrip,
    this.currentLegDestinationId,
    this.currentLegDestinationName,
    this.currentLegIndex,
  });
  final Journey journey;
  final bool reverse;
  final List<RunningStop> stops;
  final TripJourney? plannedTrip;

  /// The boarded vehicle segment, distinct from the intended final destination.
  final String? currentLegDestinationId;
  final String? currentLegDestinationName;
  final int? currentLegIndex;
  String get currentDestination => currentLegDestinationName ?? destination;
  bool get hasOnwardTravel {
    if (currentLegDestinationId == null) return false;
    final intended = (reverse ? journey.originId : journey.destinationId)
        .split('|')
        .last;
    return currentLegDestinationId!.split('|').last != intended &&
        (stops.isEmpty || stops.last.stationId != intended);
  }

  String get key => '${journey.id}:$reverse';
  String get origin => reverse ? journey.destination : journey.origin;
  String get destination => reverse ? journey.origin : journey.destination;
  String get title => '$origin → $destination';
}

class RunningService {
  RunningService({
    required this.vehicle,
    required List<RunningStop> stops,
    required List<ActiveJourneyMatch> matches,
    required this.checkedAt,
    Set<String> checkedDirections = const {},
    Map<String, TripJourney> retainedTrips = const {},
    DateTime? cacheCheckedAt,
    this.partial = false,
  }) : cacheCheckedAt = cacheCheckedAt ?? checkedAt,
       stops = List.unmodifiable(stops),
       matches = List.unmodifiable(matches),
       checkedDirections = Set.unmodifiable(checkedDirections),
       retainedTrips = Map.unmodifiable(retainedTrips);
  final FinderVehicle vehicle;
  final List<RunningStop> stops;
  final List<ActiveJourneyMatch> matches;
  final DateTime checkedAt;
  final DateTime cacheCheckedAt;
  final Set<String> checkedDirections;

  /// Only exact matching departures are retained; unrelated search results aren't.
  final Map<String, TripJourney> retainedTrips;
  final bool partial;
}
