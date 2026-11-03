part of 'gtfs_journey_planner.dart';

class _PlanningInput {
  const _PlanningInput({
    required this.data,
    required this.request,
    required this.when,
    required this.timeZoneName,
    required this.lookbackDays,
    required this.region,
    required this.provider,
  });

  final GtfsData data;
  final JourneyPlanRequest request;
  final DateTime when;
  final String timeZoneName;
  final int lookbackDays;
  final TransitRegion region;
  final TransitProviderId provider;
}

JourneyPlan _planLoadedGtfsData(_PlanningInput input) {
  final data = input.data;
  final request = input.request;
  final region = input.region;
  final provider = input.provider;
  final when = input.when;
  _initializePlannerTimeZones();
  final location = tz.getLocation(input.timeZoneName);
  final localWhen = tz.TZDateTime.from(when, location);
  final trips = {for (final trip in data.trips) trip.tripId: trip};
  final routes = {for (final route in data.routes) route.routeId: route};
  final stops = {for (final stop in data.stops) stop.stopId: stop};
  final connections = <_Connection>[];
  for (final serviceDate in _candidateServiceDates(
    localWhen,
    input.lookbackDays,
  )) {
    final activeServices = _activeServiceIds(data, serviceDate);
    final timesByTrip = <String, List<StopTime>>{};
    for (final time in data.stopTimes) {
      final trip = trips[time.tripId];
      if (trip != null && activeServices.contains(trip.serviceId)) {
        final route = routes[trip.routeId];
        final mode = route == null ? null : _mode(route.routeType);
        if (request.enabledModes != null &&
            (mode == null || !request.enabledModes!.contains(mode))) {
          continue;
        }
        (timesByTrip[time.tripId] ??= []).add(time);
      }
    }
    for (final entry in timesByTrip.entries) {
      final times = entry.value
        ..sort((a, b) => _sequence(a).compareTo(_sequence(b)));
      for (var index = 0; index + 1 < times.length; index++) {
        final from = times[index];
        final to = times[index + 1];
        final departure = _timeOnDate(
          serviceDate,
          from.departureTime,
          location,
        );
        final arrival = _timeOnDate(serviceDate, to.arrivalTime, location);
        if (departure != null &&
            arrival != null &&
            !arrival.isBefore(departure)) {
          connections.add(
            _Connection(
              entry.key,
              serviceDate,
              from.stopId,
              to.stopId,
              departure,
              arrival,
              index,
              _allowsScheduledAccess(from.pickupType),
              _allowsScheduledAccess(to.dropOffType),
            ),
          );
        }
      }
    }
  }
  connections.sort((a, b) {
    final departureOrder = a.departure.compareTo(b.departure);
    if (departureOrder != 0) return departureOrder;
    final tripOrder = a.tripId.compareTo(b.tripId);
    if (tripOrder != 0) return tripOrder;
    final dateOrder = a.serviceDate.compareTo(b.serviceDate);
    return dateOrder != 0 ? dateOrder : a.sequence.compareTo(b.sequence);
  });

  final earliest = <String, _StopArrival>{
    request.origin.stopId: _StopArrival(when, null),
  };
  final onboard = <(String, DateTime), _ConnectionPath>{};
  for (final connection in connections) {
    final key = (connection.tripId, connection.serviceDate);
    final riding = onboard[key];
    _ConnectionPath? previous;
    if (riding != null &&
        riding.connection.sequence + 1 == connection.sequence &&
        riding.connection.toStopId == connection.fromStopId &&
        !riding.connection.arrival.isAfter(connection.departure)) {
      // Passing a no-pickup/no-dropoff stop does not force riders off.
      previous = riding;
    } else {
      final reached = earliest[connection.fromStopId];
      if (!connection.canBoard ||
          reached == null ||
          reached.time.isAfter(connection.departure)) {
        continue;
      }
      previous = reached.path;
    }
    final path = _ConnectionPath(connection, previous);
    onboard[key] = path;
    if (!connection.canAlight) continue;
    final current = earliest[connection.toStopId];
    if (current == null || connection.arrival.isBefore(current.time)) {
      earliest[connection.toStopId] = _StopArrival(connection.arrival, path);
    }
  }

  var node = earliest[request.destination.stopId]?.path;
  if (node == null) return const JourneyPlan(journeys: []);
  final path = <_Connection>[];
  while (node != null) {
    path.add(node.connection);
    node = node.previous;
  }
  final ordered = path.reversed.toList(growable: false);
  final legs = <TransitLeg>[];
  for (var start = 0; start < ordered.length;) {
    var end = start;
    while (end + 1 < ordered.length &&
        ordered[end + 1].tripId == ordered[start].tripId &&
        ordered[end + 1].serviceDate == ordered[start].serviceDate) {
      end++;
    }
    final first = ordered[start];
    final last = ordered[end];
    final trip = trips[first.tripId]!;
    final route = routes[trip.routeId];
    legs.add(
      TransitLeg(
        origin: _makeStop(
          first.fromStopId,
          request.origin.sourceId,
          stops,
          region,
          provider,
        ),
        destination: _makeStop(
          last.toStopId,
          request.origin.sourceId,
          stops,
          region,
          provider,
        ),
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

TransitStop _makeStop(
  String id,
  TransitSourceId source,
  Map<String, gtfs.Stop> stops,
  TransitRegion region,
  TransitProviderId provider,
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

int _maximumGtfsHour(GtfsData data) {
  var maximum = 0;
  for (final time in data.stopTimes) {
    for (final value in [time.arrivalTime, time.departureTime]) {
      final parts = value.split(':');
      if (parts.length == 3) {
        final hour = int.tryParse(parts.first);
        final minute = int.tryParse(parts[1]);
        final second = int.tryParse(parts[2]);
        if (hour != null &&
            hour >= 0 &&
            minute != null &&
            minute >= 0 &&
            minute <= 59 &&
            second != null &&
            second >= 0 &&
            second <= 59 &&
            hour > maximum) {
          maximum = hour;
        }
      }
    }
  }
  return maximum;
}

// Booking/driver-coordination services (2/3) need capabilities this planner
// cannot provide. Treat them as unavailable for boarding and alighting.
bool _allowsScheduledAccess(String? value) =>
    value == null || value.trim().isEmpty || value.trim() == '0';

class _StopArrival {
  const _StopArrival(this.time, this.path);
  final DateTime time;
  final _ConnectionPath? path;
}

class _ConnectionPath {
  const _ConnectionPath(this.connection, this.previous);
  final _Connection connection;
  final _ConnectionPath? previous;
}
