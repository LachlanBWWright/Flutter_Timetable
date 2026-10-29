import '../models/manual_trip_models.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../schema/database.dart' as db;
import '../services/realtime_service.dart';
import '../services/transport_api_service.dart' as api;
import '../services/trip_cache_service.dart';
import '../vehicle_finder/models.dart';
import '../vehicle_finder/provider.dart';
import 'matching.dart';
import 'models.dart';
import 'planned_matching.dart';
import 'saved_segments.dart';

/// Uses exact realtime services and previously fetched plans. Never asks the
/// planner for a new departure while trying to identify a boarded journey.
class ActiveServiceResolver {
  ActiveServiceResolver({
    Future<TripUpdateAggregationResult> Function(FinderVehicle)? updates,
    Future<TripCacheSnapshot?> Function(String, String)? stored,
    Future<({String name, String? parent})> Function(String)? stopInfo,
  }) : _updates =
           updates ??
           ((v) => RealtimeService.getTripUpdatesForModeSafe(
             v.mode,
             query: RealtimeQuery(
               tripIds: [if (v.service != null) v.service!.tripId],
             ),
           )),
       _stored = stored ?? TripCacheService.getRetainedSnapshot,
       _stopInfo = stopInfo ?? _lookupStop;
  final Future<TripUpdateAggregationResult> Function(FinderVehicle) _updates;
  final Future<TripCacheSnapshot?> Function(String, String) _stored;
  final Future<({String name, String? parent})> Function(String) _stopInfo;
  final _names = <String, ({String name, String? parent})>{};

  static Future<({String name, String? parent})> _lookupStop(String id) async {
    final rows = await db.AppDatabase().getStopsById(id);
    final names = rows.map((r) => r.stopName).toSet();
    final parents = rows.map((r) => r.parentStation).toSet();
    return (
      name: names.length == 1 ? names.single : id,
      parent: parents.length == 1 ? parents.single : null,
    );
  }

  Future<RunningService> resolve(
    FinderVehicle vehicle,
    List<db.Journey> journeys,
    DateTime now, {
    RunningService? previous,
  }) async {
    final identity = vehicle.service;
    if (identity == null || identity.tripId.isEmpty) {
      throw const VehicleFinderException(
        'The vehicle has no identifiable trip. Saved journeys cannot be inferred yet.',
      );
    }
    final result = await _updates(vehicle);
    if (result.metadata.isUnavailable || result.metadata.isStale) {
      throw const VehicleFinderException(
        'Live trip updates are unavailable. The last selection is retained.',
      );
    }
    final updates = result.tripUpdates
        .where((u) => identity.compatible(u.trip))
        .toList();
    if (updates.length > 1) {
      throw const VehicleFinderException(
        'Several departures share this trip identity. Try detecting the vehicle again.',
      );
    }
    final update = updates.isEmpty ? null : updates.single;
    if (update?.hasTimestamp() == true) {
      final age =
          now.millisecondsSinceEpoch ~/ 1000 - update!.timestamp.toInt();
      if (age > 90 || age < -5) {
        throw const VehicleFinderException(
          'The trip update is out of date. The last selection is retained.',
        );
      }
    }
    if (update?.trip.scheduleRelationship ==
        TripDescriptor_ScheduleRelationship.CANCELED) {
      throw const VehicleFinderException(
        'This service is cancelled. End this trip or find another vehicle.',
      );
    }
    final serviceStops = <RunningStop>[];
    if (update != null) {
      for (final stop in update.stopTimeUpdate) {
        if (!stop.hasStopId() || !stop.hasStopSequence()) continue;
        final info = await _info(stop.stopId);
        serviceStops.add(
          RunningStop(
            id: stop.stopId,
            name: info.name,
            stationId: info.parent,
            sequence: stop.stopSequence,
            arrival: _eventTime(stop.hasArrival() ? stop.arrival : null),
            departure: _eventTime(stop.hasDeparture() ? stop.departure : null),
            skipped:
                stop.scheduleRelationship ==
                TripUpdate_StopTimeUpdate_ScheduleRelationship.SKIPPED,
          ),
        );
      }
      serviceStops.sort((a, b) => a.sequence.compareTo(b.sequence));
      if (serviceStops.map((s) => s.sequence).toSet().length !=
          serviceStops.length) {
        throw const VehicleFinderException(
          'The live stopping pattern is ambiguous. Try again shortly.',
        );
      }
    }
    var cacheUnavailable = false;
    final matches = <ActiveJourneyMatch>[];
    final checked = <String>{};
    final retained = <String, api.TripJourney>{};
    final sameService = previous?.vehicle.service?.key == identity.key;
    final reuseChecked =
        sameService &&
        previous != null &&
        now.difference(previous.cacheCheckedAt) < const Duration(minutes: 5);
    for (final journey in journeys) {
      if (nswStopId(journey.originId) == null ||
          nswStopId(journey.destinationId) == null ||
          (journey.tripType != 'direct' && !journey.isManualMultiLeg)) {
        continue;
      }
      for (final reverse in [false, true]) {
        final directionMatches = <ActiveJourneyMatch>[];
        for (final segment in savedSegments(journey, reverse, vehicle.mode)) {
          final key =
              '${journey.id}:$reverse:${Uri.encodeComponent(journey.originId)}:${Uri.encodeComponent(journey.destinationId)}:${segment.key}';
          checked.add(key);
          var match = matchRunningPattern(
            segment.journey,
            segment.reverse,
            vehicle,
            serviceStops,
            now,
          );
          api.TripJourney? plan = sameService
              ? previous?.retainedTrips[key]
              : null;
          if (plan == null &&
              !(reuseChecked && previous.checkedDirections.contains(key))) {
            TripCacheSnapshot? snapshot;
            try {
              snapshot = await _stored(
                segment.reverse
                    ? segment.journey.destinationId
                    : segment.journey.originId,
                segment.reverse
                    ? segment.journey.originId
                    : segment.journey.destinationId,
              );
            } catch (_) {
              cacheUnavailable = true;
            }
            final plans =
                snapshot?.response?.tripJourneys
                    .where(
                      (p) =>
                          matchPlannedJourney(
                            segment.journey,
                            segment.reverse,
                            vehicle,
                            p,
                            serviceStops,
                            now,
                            update,
                          ) !=
                          null,
                    )
                    .toList() ??
                [];
            if (plans.length == 1) plan = plans.single;
          }
          if (plan != null) {
            retained[key] = plan;
            final plannedMatch = matchPlannedJourney(
              segment.journey,
              segment.reverse,
              vehicle,
              plan,
              serviceStops,
              now,
              update,
            );
            // Prefer the exact cached leg: it preserves transfer boundaries.
            match = plannedMatch ?? match;
          }
          if (match != null) {
            directionMatches.add(
              ActiveJourneyMatch(
                journey: journey,
                reverse: reverse,
                stops: match.stops,
                plannedTrip: match.plannedTrip,
                currentLegIndex: segment.index ?? match.currentLegIndex,
                currentLegDestinationId:
                    match.currentLegDestinationId ??
                    (journey.isManualMultiLeg ? match.stops.last.id : null),
                currentLegDestinationName:
                    match.currentLegDestinationName ??
                    (journey.isManualMultiLeg ? match.stops.last.name : null),
              ),
            );
          }
        }
        // A looping itinerary may contain the same service more than once.
        if (directionMatches.length == 1) matches.add(directionMatches.single);
      }
    }
    return RunningService(
      vehicle: vehicle,
      stops: serviceStops,
      matches: matches,
      retainedTrips: retained,
      checkedDirections: checked,
      checkedAt: now,
      cacheCheckedAt: reuseChecked ? previous.cacheCheckedAt : now,
      partial: result.metadata.isPartial || update == null || cacheUnavailable,
    );
  }

  Future<({String name, String? parent})> _info(String id) async {
    final known = _names[id];
    if (known != null) return known;
    try {
      final value = await _stopInfo(id);
      if (_names.length >= 256) _names.remove(_names.keys.first);
      _names[id] = value;
      return value;
    } catch (_) {
      return (name: id, parent: null);
    }
  }

  static DateTime? _eventTime(TripUpdate_StopTimeEvent? event) =>
      event?.hasTime() == true
      ? DateTime.fromMillisecondsSinceEpoch(
          event!.time.toInt() * 1000,
          isUtc: true,
        )
      : null;
}
