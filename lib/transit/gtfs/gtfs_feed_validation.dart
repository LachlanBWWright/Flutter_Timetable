import '../../constants/transport_modes.dart';
import '../../gtfs/gtfs_data.dart';
import '../../gtfs/stop_time.dart';
import '../../gtfs/timetable_index.dart' show gtfsTimeSeconds;
import '../errors/transit_failure.dart';

TransportMode? gtfsRouteMode(String value) {
  final type = int.tryParse(value);
  if (type == 0 || (type != null && type >= 900 && type < 1000)) {
    return TransportMode.lightrail;
  }
  if (type == 1 || type == 400 || type == 401 || type == 402) {
    return TransportMode.metro;
  }
  if (type == 2 || (type != null && type >= 100 && type < 200)) {
    return TransportMode.train;
  }
  if (type == 3 ||
      type == 11 ||
      (type != null &&
          ((type >= 200 && type < 300) || (type >= 700 && type < 900)))) {
    return TransportMode.bus;
  }
  if (type == 4 || type == 1000 || type == 1200) return TransportMode.ferry;
  return null;
}

void validateGtfsFeed(GtfsData data, {bool requireTimetable = true}) =>
    _validateGtfsFeed(data, requireTimetable: requireTimetable);

/// For streaming consumers which validate stop-time rows before discarding them.
void validateGtfsTimetableMetadata(GtfsData data) =>
    _validateGtfsFeed(data, stopTimesAreExternal: true);

void _validateGtfsFeed(
  GtfsData data, {
  bool requireTimetable = true,
  bool stopTimesAreExternal = false,
}) {
  Never invalid(String message) =>
      throw InvalidProviderResponse(message: message);
  Set<String> ids(Iterable<String> values, String label) {
    final list = values.toList();
    final unique = list.toSet();
    if (unique.contains('') || unique.length != list.length) {
      invalid('The feed has invalid or duplicate $label.');
    }
    return unique;
  }

  final stops = ids(data.stops.map((s) => s.stopId), 'stops');
  if (stops.isEmpty) invalid('The feed has no stops.');
  if (!requireTimetable) return;
  final routes = ids(data.routes.map((r) => r.routeId), 'routes');
  final trips = ids(data.trips.map((t) => t.tripId), 'trips');
  ids(data.calendars.map((c) => c.serviceId), 'service calendars');
  final services = {
    ...data.calendars.map((c) => c.serviceId),
    ...data.calendarDates.map((c) => c.serviceId),
  };
  if (routes.isEmpty ||
      trips.isEmpty ||
      (data.stopTimes.isEmpty && !stopTimesAreExternal) ||
      services.isEmpty) {
    invalid('The feed has incomplete timetable data.');
  }
  bool date(String value) {
    if (!RegExp(r'^\d{8}$').hasMatch(value)) return false;
    final parsed = DateTime.tryParse(
      '${value.substring(0, 4)}-${value.substring(4, 6)}-${value.substring(6)}',
    );
    return parsed != null &&
        '${parsed.year.toString().padLeft(4, '0')}${parsed.month.toString().padLeft(2, '0')}${parsed.day.toString().padLeft(2, '0')}' ==
            value;
  }

  final exceptions = <String>{};
  for (final c in data.calendarDates) {
    if (c.serviceId.isEmpty ||
        !date(c.date) ||
        !const ['1', '2'].contains(c.exceptionType) ||
        !exceptions.add('${c.serviceId}|${c.date}')) {
      invalid('The feed has invalid service exceptions.');
    }
  }
  for (final c in data.calendars) {
    if (!date(c.startDate) ||
        !date(c.endDate) ||
        c.startDate.compareTo(c.endDate) > 0 ||
        [
          c.monday,
          c.tuesday,
          c.wednesday,
          c.thursday,
          c.friday,
          c.saturday,
          c.sunday,
        ].any((v) => v != '0' && v != '1')) {
      invalid('The feed has invalid service calendars.');
    }
  }
  for (final t in data.trips) {
    if (!routes.contains(t.routeId) || !services.contains(t.serviceId)) {
      invalid('A trip refers to a missing route or service.');
    }
  }
  final sequences = <String>{};
  for (final t in data.stopTimes) {
    final sequence = int.tryParse(t.stopSequence);
    if (!trips.contains(t.tripId) ||
        !stops.contains(t.stopId) ||
        sequence == null ||
        sequence < 0 ||
        !sequences.add('${t.tripId}|$sequence')) {
      invalid('A stop time has an invalid trip, stop, or sequence.');
    }
  }
  final byTrip = <String, List<StopTime>>{};
  for (final time in data.stopTimes) {
    for (final value in [time.arrivalTime, time.departureTime]) {
      if (value.isNotEmpty && gtfsTimeSeconds(value) == null) {
        invalid('A stop time is malformed.');
      }
    }
    (byTrip[time.tripId] ??= []).add(time);
  }
  for (final times in byTrip.values) {
    times.sort(
      (a, b) => int.parse(a.stopSequence).compareTo(int.parse(b.stopSequence)),
    );
    int? previous;
    for (final time in times) {
      final arrival = gtfsTimeSeconds(time.arrivalTime);
      final departure = gtfsTimeSeconds(time.departureTime);
      if ((arrival != null && previous != null && arrival < previous) ||
          (departure != null && arrival != null && departure < arrival) ||
          (departure != null && previous != null && departure < previous)) {
        invalid('The feed has stop times out of chronological order.');
      }
      previous = departure ?? arrival ?? previous;
    }
  }
  final parents = {for (final s in data.stops) s.stopId: s.parentStation};
  final checked = <String>{};
  for (final id in parents.keys) {
    final chain = <String>{};
    String? next = id;
    while (next != null && next.isNotEmpty && !checked.contains(next)) {
      if (!chain.add(next)) invalid('The feed has a parent-station cycle.');
      next = parents[next];
    }
    checked.addAll(chain);
  }
  for (final route in data.routes) {
    final type = int.tryParse(route.routeType);
    if (type == null || type < 0) {
      invalid('The feed has an invalid route type.');
    }
  }
  for (final f in data.frequencies) {
    final start = gtfsTimeSeconds(f.startTime),
        end = gtfsTimeSeconds(f.endTime);
    if (!trips.contains(f.tripId) ||
        start == null ||
        end == null ||
        start >= end ||
        f.headwaySeconds <= 0) {
      invalid('The feed has an invalid frequency period.');
    }
  }
  for (final id in data.frequencies.map((f) => f.tripId).toSet()) {
    final periods = data.frequencies.where((f) => f.tripId == id).toList()
      ..sort(
        (a, b) =>
            gtfsTimeSeconds(a.startTime)!
                .compareTo(gtfsTimeSeconds(b.startTime)!),
      );
    for (var i = 1; i < periods.length; i++) {
      if (gtfsTimeSeconds(periods[i].startTime)! <
          gtfsTimeSeconds(periods[i - 1].endTime)!) {
        invalid('Frequency periods overlap.');
      }
    }
  }
  for (final t in data.transfers) {
    if (t.type < 0 ||
        t.type > 5 ||
        (t.fromStopId.isNotEmpty && !stops.contains(t.fromStopId)) ||
        (t.toStopId.isNotEmpty && !stops.contains(t.toStopId)) ||
        (t.type < 4 && (t.fromStopId.isEmpty || t.toStopId.isEmpty)) ||
        (t.type >= 4 && (t.fromTripId == null || t.toTripId == null)) ||
        (t.minimumSeconds != null && t.minimumSeconds! < 0) ||
        (t.type == 2 && t.minimumSeconds == null) ||
        (t.fromRouteId != null && !routes.contains(t.fromRouteId)) ||
        (t.toRouteId != null && !routes.contains(t.toRouteId)) ||
        (t.fromTripId != null && !trips.contains(t.fromTripId)) ||
        (t.toTripId != null && !trips.contains(t.toTripId))) {
      invalid('The feed has an invalid transfer rule.');
    }
  }
  ids(data.pathways.map((p) => p.id), 'pathways');
  for (final p in data.pathways) {
    if (!stops.contains(p.fromStopId) ||
        !stops.contains(p.toStopId) ||
        p.mode < 1 ||
        p.mode > 7 ||
        (p.seconds != null && p.seconds! < 0) ||
        (p.length != null && (!p.length!.isFinite || p.length! < 0))) {
      invalid('The feed has an invalid station pathway.');
    }
  }
  for (final s in data.stops) {
    if (s.parentStation != null &&
        s.parentStation!.isNotEmpty &&
        (!stops.contains(s.parentStation) || s.parentStation == s.stopId)) {
      invalid('A stop refers to an invalid parent station.');
    }
  }
}

Map<String, Set<TransportMode>> deriveGtfsStopModes(GtfsData data) {
  final routes = {
    for (final r in data.routes) r.routeId: gtfsRouteMode(r.routeType),
  };
  final trips = {for (final t in data.trips) t.tripId: routes[t.routeId]};
  final parents = {for (final s in data.stops) s.stopId: s.parentStation};
  final result = <String, Set<TransportMode>>{};
  for (final time in data.stopTimes) {
    final mode = trips[time.tripId];
    if (mode == null) continue;
    String? stop = time.stopId;
    final visited = <String>{};
    while (stop != null && stop.isNotEmpty && visited.add(stop)) {
      (result[stop] ??= {}).add(mode);
      stop = parents[stop];
    }
  }
  return result;
}
