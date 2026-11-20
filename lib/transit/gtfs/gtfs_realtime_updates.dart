import '../../gtfs/gtfs_data.dart';
import '../../gtfs/stop_time.dart';
import '../../gtfs/timetable_index.dart';
import '../../nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart' as pb;
import '../domain/transit_types.dart';
import '../errors/transit_failure.dart';
import '../interfaces/transit_interfaces.dart';

List<TransitTripUpdate> gtfsRealtimeUpdates(
  pb.FeedMessage? feed, {
  required TransitRegion region,
  required TransitProviderId provider,
  required TransitSourceId source,
}) {
  DateTime? event(pb.TripUpdate_StopTimeEvent value) => value.hasTime()
      ? DateTime.fromMillisecondsSinceEpoch(
          value.time.toInt() * 1000,
          isUtc: true,
        )
      : null;
  final result = <TransitTripUpdate>[];
  for (final entity in feed?.entity ?? const <pb.FeedEntity>[]) {
    if (!entity.hasTripUpdate()) continue;
    final update = entity.tripUpdate;
    final cancelled = const [
      'CANCELED',
      'DELETED',
    ].contains(update.trip.scheduleRelationship.name);
    final service = update.trip.hasStartDate() ? update.trip.startDate : null;
    if (update.stopTimeUpdate.isEmpty || cancelled) {
      result.add(
        TransitTripUpdate(
          tripId: update.trip.tripId,
          routeId: update.trip.hasRouteId() ? update.trip.routeId : null,
          sourceId: source,
          serviceDate: service,
          startTime: update.trip.hasStartTime() ? update.trip.startTime : null,
          cancelled: cancelled,
          delaySeconds: update.hasDelay() ? update.delay : null,
        ),
      );
    }
    for (final stop in update.stopTimeUpdate) {
      if (!stop.hasStopId() && !stop.hasStopSequence()) continue;
      result.add(
        TransitTripUpdate(
          tripId: update.trip.tripId,
          routeId: update.trip.hasRouteId() ? update.trip.routeId : null,
          sourceId: source,
          stopSequence: stop.hasStopSequence() ? stop.stopSequence : null,
          noData: stop.scheduleRelationship.name == 'NO_DATA',
          stop: TransitStopRef(
            region: region,
            provider: provider,
            sourceId: source,
            stopId: stop.stopId,
          ),
          serviceDate: service,
          startTime: update.trip.hasStartTime() ? update.trip.startTime : null,
          cancelled: cancelled,
          skipped: stop.scheduleRelationship.name == 'SKIPPED',
          estimatedTime: stop.hasDeparture()
              ? event(stop.departure)
              : stop.hasArrival()
              ? event(stop.arrival)
              : null,
          estimatedArrivalTime: stop.hasArrival() ? event(stop.arrival) : null,
          estimatedDepartureTime: stop.hasDeparture()
              ? event(stop.departure)
              : null,
          arrivalDelaySeconds: stop.hasArrival() && stop.arrival.hasDelay()
              ? stop.arrival.delay
              : null,
          departureDelaySeconds:
              stop.hasDeparture() && stop.departure.hasDelay()
              ? stop.departure.delay
              : null,
          delaySeconds: update.hasDelay() ? update.delay : null,
        ),
      );
    }
  }
  return result;
}

bool gtfsUpdateApplies(
  TransitTripUpdate update,
  DateTime date,
  DateTime planned,
) {
  final key =
      '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  if (update.serviceDate != null) return update.serviceDate == key;
  final estimated =
      update.estimatedTime ??
      update.estimatedDepartureTime ??
      update.estimatedArrivalTime;
  if (estimated != null) {
    return estimated.difference(planned).abs() <= const Duration(hours: 6);
  }
  return planned.difference(DateTime.now().toUtc()).abs() <
      const Duration(hours: 24);
}

DateTime? gtfsUpdatedTime(
  List<TransitTripUpdate> updates,
  String stop,
  DateTime planned,
  DateTime date, {
  required bool arrival,
  List<StopTime> stopTimes = const [],
}) {
  final candidates = updates.where((u) => gtfsUpdateApplies(u, date, planned));
  final exact = candidates.where((u) => u.stop?.stopId == stop).lastOrNull;
  final trip = candidates.where((u) => u.stop == null).lastOrNull;
  if (exact?.noData == true) return null;
  final time = arrival
      ? exact?.estimatedArrivalTime
      : exact?.estimatedDepartureTime;
  if (time != null) return time;
  final delay =
      (arrival ? exact?.arrivalDelaySeconds : exact?.departureDelaySeconds) ??
      exact?.delaySeconds ??
      trip?.delaySeconds;
  if (delay != null) return planned.add(Duration(seconds: delay));
  if (exact?.estimatedTime != null) return exact!.estimatedTime;
  final current = stopTimes.where((t) => t.stopId == stop).firstOrNull;
  if (current == null) return null;
  final currentSequence = int.tryParse(current.stopSequence);
  if (currentSequence == null) return null;
  final previous =
      candidates
          .where((u) => u.stop != null && u.stop!.stopId != stop)
          .map((u) {
            final t = stopTimes
                .where((t) => t.stopId == u.stop!.stopId)
                .firstOrNull;
            return (u, t, t == null ? null : int.tryParse(t.stopSequence));
          })
          .where((entry) => entry.$3 != null && entry.$3! < currentSequence)
          .toList()
        ..sort((a, b) => b.$3!.compareTo(a.$3!));
  if (previous.isEmpty || previous.first.$1.noData) return null;
  final (u, t, _) = previous.first;
  final priorDelay =
      u.departureDelaySeconds ?? u.arrivalDelaySeconds ?? u.delaySeconds;
  if (priorDelay != null) return planned.add(Duration(seconds: priorDelay));
  final priorTime =
      u.estimatedDepartureTime ?? u.estimatedArrivalTime ?? u.estimatedTime;
  final priorSeconds = gtfsTimeSeconds(
    u.estimatedDepartureTime != null ? t!.departureTime : t!.arrivalTime,
  );
  final currentSeconds = gtfsTimeSeconds(
    arrival ? current.arrivalTime : current.departureTime,
  );
  if (priorTime != null && priorSeconds != null && currentSeconds != null) {
    return priorTime.add(Duration(seconds: currentSeconds - priorSeconds));
  }
  return null;
}

/// Resolve native realtime IDs only when the static namespace match is unique.
List<TransitTripUpdate> matchGtfsUpdates(
  GtfsData data,
  List<TransitTripUpdate> updates,
) {
  final byNative = <String, List<String>>{};
  for (final trip in data.trips) {
    (byNative[trip.tripId.contains(':')
                ? trip.tripId.substring(trip.tripId.indexOf(':') + 1)
                : trip.tripId] ??=
            [])
        .add(trip.tripId);
  }
  return [
    for (final update in updates)
      ...(() {
        var ids = data.index.trips.containsKey(update.tripId)
            ? [update.tripId]
            : byNative[update.tripId] ?? <String>[];
        if (update.routeId != null) {
          ids = ids.where((id) {
            final route = data.index.trips[id]!.routeId;
            return route == update.routeId ||
                route.endsWith(':${update.routeId}');
          }).toList();
        }
        if (ids.length != 1) return <TransitTripUpdate>[];
        var stop = update.stop;
        if ((stop == null || stop.stopId.isEmpty) &&
            update.stopSequence != null) {
          final time = data.index.timesByTrip[ids.single]
              ?.where(
                (t) => int.tryParse(t.stopSequence) == update.stopSequence,
              )
              .firstOrNull;
          if (time == null || update.sourceId == null) {
            return <TransitTripUpdate>[];
          }
          final exemplar =
              data.stopReferences[time.stopId] ??
              (stop == null
                  ? null
                  : TransitStopRef(
                      region: stop.region,
                      provider: stop.provider,
                      sourceId: stop.sourceId,
                      stopId: time.stopId,
                    ));
          // Source-only updates use the planner's feed identity; no foreign stop is invented.
          if (exemplar == null) return <TransitTripUpdate>[];
          stop = exemplar;
        }
        return [remapGtfsUpdate(update, tripId: ids.single, stop: stop)];
      })(),
  ];
}

TransitTripUpdate remapGtfsUpdate(
  TransitTripUpdate u, {
  required String tripId,
  TransitStopRef? stop,
  TransitSourceId? source,
}) => TransitTripUpdate(
  tripId: tripId,
  routeId: u.routeId,
  sourceId: source ?? u.sourceId,
  stop: stop ?? u.stop,
  serviceDate: u.serviceDate,
  startTime: u.startTime,
  stopSequence: u.stopSequence,
  noData: u.noData,
  cancelled: u.cancelled,
  skipped: u.skipped,
  plannedTime: u.plannedTime,
  estimatedTime: u.estimatedTime,
  statusText: u.statusText,
  estimatedArrivalTime: u.estimatedArrivalTime,
  estimatedDepartureTime: u.estimatedDepartureTime,
  delaySeconds: u.delaySeconds,
  arrivalDelaySeconds: u.arrivalDelaySeconds,
  departureDelaySeconds: u.departureDelaySeconds,
);

/// Stale or failed realtime must never replace a valid timetable.
Future<List<TransitTripUpdate>> freshGtfsUpdates(
  GtfsData data,
  Future<RealtimeSnapshot<TransitTripUpdate>> Function()? load,
) async {
  if (load == null) return const [];
  try {
    final snapshot = await load();
    final age = DateTime.now().toUtc().difference(snapshot.fetchedAt.toUtc());
    if (snapshot.isStale ||
        age < const Duration(seconds: -5) ||
        age > const Duration(minutes: 2)) {
      return const [];
    }
    return matchGtfsUpdates(data, snapshot.items);
  } on TransitOperationCancelled {
    rethrow;
  } on Exception {
    return const [];
  }
}

List<TransitTripUpdate> gtfsInstanceUpdates(
  GtfsTimetableIndex index,
  String tripId,
  int offset,
  List<TransitTripUpdate> updates,
) {
  if (!index.frequenciesByTrip.containsKey(tripId)) return updates;
  final first = index.timesByTrip[tripId]?.firstOrNull;
  final anchor = first == null ? null : gtfsTimeSeconds(first.departureTime);
  if (anchor == null) return const [];
  return updates
      .where(
        (u) =>
            u.startTime != null &&
            gtfsTimeSeconds(u.startTime!) == anchor + offset,
      )
      .toList();
}
