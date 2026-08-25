import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';

typedef GtfsDataLoader = Future<GtfsData> Function(TransitSourceId sourceId);

/// Earliest-arrival connection-scan router for a single GTFS feed.
/// Supports any number of scheduled transfers at the same stop.
class GtfsJourneyPlanner implements JourneyPlanner {
  GtfsJourneyPlanner({
    required this.region,
    required this.provider,
    required this.loadData,
    this.requiresSameSource = true,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final GtfsDataLoader loadData;
  final bool requiresSameSource;

  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async {
    if (request.origin.region != region ||
        request.destination.region != region) {
      throw const UnsupportedCapability(
        message: 'Cross-region journey planning is not supported.',
      );
    }
    if (requiresSameSource &&
        request.origin.sourceId != request.destination.sourceId) {
      throw const UnsupportedCapability(
        message:
            'Journeys between separate provider feed areas are not supported.',
      );
    }
    if (request.arrivalBased) {
      throw const UnsupportedCapability(
        message: 'Arrival-based local GTFS planning is not yet supported.',
      );
    }

    final data = await loadData(request.origin.sourceId);
    final when = request.when ?? DateTime.now();
    final activeServices = _activeServiceIds(data, when);
    final trips = {for (final trip in data.trips) trip.tripId: trip};
    final routes = {for (final route in data.routes) route.routeId: route};
    final stops = {for (final stop in data.stops) stop.stopId: stop};
    final timesByTrip = <String, List<StopTime>>{};
    for (final time in data.stopTimes) {
      final trip = trips[time.tripId];
      if (trip != null && activeServices.contains(trip.serviceId)) {
        (timesByTrip[time.tripId] ??= []).add(time);
      }
    }

    final connections = <_Connection>[];
    for (final entry in timesByTrip.entries) {
      final times = entry.value
        ..sort((a, b) => _sequence(a).compareTo(_sequence(b)));
      for (var index = 0; index + 1 < times.length; index++) {
        final from = times[index];
        final to = times[index + 1];
        final departure = _timeOnDate(when, from.departureTime);
        final arrival = _timeOnDate(when, to.arrivalTime);
        if (departure != null && arrival != null) {
          connections.add(
            _Connection(entry.key, from.stopId, to.stopId, departure, arrival),
          );
        }
      }
    }
    connections.sort((a, b) => a.departure.compareTo(b.departure));

    final earliest = <String, DateTime>{request.origin.stopId: when};
    final previous = <String, _Connection>{};
    for (final connection in connections) {
      final reached = earliest[connection.fromStopId];
      if (reached == null || reached.isAfter(connection.departure)) continue;
      final current = earliest[connection.toStopId];
      if (current == null || connection.arrival.isBefore(current)) {
        earliest[connection.toStopId] = connection.arrival;
        previous[connection.toStopId] = connection;
      }
    }

    if (!previous.containsKey(request.destination.stopId)) {
      return const JourneyPlan(journeys: []);
    }
    final path = <_Connection>[];
    var stopId = request.destination.stopId;
    while (stopId != request.origin.stopId) {
      final connection = previous[stopId];
      if (connection == null) return const JourneyPlan(journeys: []);
      path.add(connection);
      stopId = connection.fromStopId;
    }
    final ordered = path.reversed.toList(growable: false);
    final legs = <TransitLeg>[];
    for (var start = 0; start < ordered.length;) {
      var end = start;
      while (end + 1 < ordered.length &&
          ordered[end + 1].tripId == ordered[start].tripId) {
        end++;
      }
      final first = ordered[start];
      final last = ordered[end];
      final trip = trips[first.tripId]!;
      final route = routes[trip.routeId];
      legs.add(
        TransitLeg(
          origin: _stop(first.fromStopId, request.origin.sourceId, stops),
          destination: _stop(last.toStopId, request.origin.sourceId, stops),
          route: route == null
              ? null
              : TransitRoute(
                  ref: TransitRouteRef(
                    region: region,
                    provider: provider,
                    sourceId: request.origin.sourceId,
                    routeId: route.routeId,
                  ),
                  name: route.routeLongName.isNotEmpty
                      ? route.routeLongName
                      : route.routeShortName,
                  shortName: route.routeShortName,
                  mode: _mode(route.routeType),
                  color: route.routeColor,
                  textColor: route.routeTextColor,
                ),
          mode: route == null ? null : _mode(route.routeType),
          departureTime: first.departure,
          arrivalTime: last.arrival,
          label: trip.tripHeadsign,
        ),
      );
      start = end + 1;
    }
    return JourneyPlan(journeys: [TransitJourney(legs: legs)]);
  }

  TransitStop _stop(
    String id,
    TransitSourceId source,
    Map<String, gtfs.Stop> stops,
  ) {
    final stop = stops[id];
    return TransitStop(
      ref: TransitStopRef(
        region: region,
        provider: provider,
        sourceId: source,
        stopId: id,
      ),
      name: stop?.stopName ?? id,
      latitude: stop?.stopLat,
      longitude: stop?.stopLon,
      platformCode: stop?.platformCode,
    );
  }
}

class _Connection {
  const _Connection(
    this.tripId,
    this.fromStopId,
    this.toStopId,
    this.departure,
    this.arrival,
  );
  final String tripId;
  final String fromStopId;
  final String toStopId;
  final DateTime departure;
  final DateTime arrival;
}

int _sequence(StopTime time) => int.tryParse(time.stopSequence) ?? 0;

DateTime? _timeOnDate(DateTime date, String value) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length != 3 || parts.any((part) => part == null)) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    parts[0]! % 24,
    parts[1]!,
    parts[2]!,
  ).add(Duration(days: parts[0]! ~/ 24));
}

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final date =
      '${moment.year.toString().padLeft(4, '0')}'
      '${moment.month.toString().padLeft(2, '0')}'
      '${moment.day.toString().padLeft(2, '0')}';
  final result = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final active =
        [
          calendar.monday,
          calendar.tuesday,
          calendar.wednesday,
          calendar.thursday,
          calendar.friday,
          calendar.saturday,
          calendar.sunday,
        ][moment.weekday - 1] ==
        '1';
    if (active) result.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates.where(
    (item) => item.date == date,
  )) {
    if (exception.exceptionType == '1') result.add(exception.serviceId);
    if (exception.exceptionType == '2') result.remove(exception.serviceId);
  }
  return result;
}

TransportMode? _mode(String value) => switch (value) {
  '0' => TransportMode.lightrail,
  '1' || '2' => TransportMode.train,
  '3' => TransportMode.bus,
  '4' => TransportMode.ferry,
  _ => null,
};
