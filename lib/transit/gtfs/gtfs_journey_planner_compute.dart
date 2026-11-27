part of 'gtfs_journey_planner.dart';

class _PlanningInput {
  const _PlanningInput({
    required this.index,
    required this.request,
    required this.when,
    required this.timeZoneName,
    required this.lookbackDays,
    required this.region,
    required this.provider,
    required this.routeTimeZones,
    required this.updates,
    required this.budget,
  });
  final GtfsTimetableIndex index;
  final JourneyPlanRequest request;
  final DateTime when;
  final String timeZoneName;
  final int lookbackDays;
  final TransitRegion region;
  final TransitProviderId provider;
  final Map<String, String> routeTimeZones;
  final List<TransitTripUpdate> updates;
  final TransitResourceBudget budget;
}

JourneyPlan _planLoadedGtfsData(_PlanningInput input) {
  final index = input.index, request = input.request;
  initializeGtfsTimeZones();
  final graph = GtfsTransferGraph(index);
  final end = request.arrivalBased
      ? input.when
      : input.when.add(const Duration(days: 2));
  final start = request.arrivalBased
      ? input.when.subtract(const Duration(days: 2))
      : input.when;
  final connections = <_Connection>[];
  final updates = <String, List<TransitTripUpdate>>{};
  for (final u in input.updates) {
    (updates[u.tripId] ??= []).add(u);
  }
  final calendarCache = <DateTime, Set<String>>{};
  bool accessibleStop(String id) {
    if (request.accessibility == TransitAccessibility.none) return true;
    final visited = <String>{};
    String? current = id;
    while (current != null && visited.add(current)) {
      final stop = index.stops[current];
      if (stop == null) return false;
      if (stop.wheelchairBoarding == 1) return true;
      if (stop.wheelchairBoarding == 2) return false;
      current = stop.parentStation;
    }
    return request.accessibility != TransitAccessibility.stepFreeOnly;
  }

  for (final trip in index.trips.values) {
    final route = index.routes[trip.routeId];
    final mode = route == null ? null : _mode(route.routeType);
    if (request.enabledModes != null &&
        (mode == null || !request.enabledModes!.contains(mode))) {
      continue;
    }
    if (request.accessibility != TransitAccessibility.none &&
        trip.wheelchairAccessible == '2') {
      continue;
    }
    if (request.accessibility == TransitAccessibility.stepFreeOnly &&
        trip.wheelchairAccessible != '1') {
      continue;
    }
    final zone = tz.getLocation(
      input.routeTimeZones[trip.routeId] ?? input.timeZoneName,
    );
    final local = tz.TZDateTime.from(start, zone);
    final date = DateTime.utc(local.year, local.month, local.day);
    final times = index.timesByTrip[trip.tripId] ?? const <StopTime>[];
    final allTripUpdates = updates[trip.tripId] ?? const <TransitTripUpdate>[];
    // Include neighbouring calendar dates for multi-zone and DST boundaries.
    for (var day = -input.lookbackDays - 1; day <= 3; day++) {
      final serviceDate = DateTime.utc(date.year, date.month, date.day + day);
      if (!(calendarCache[serviceDate] ??= index.activeServices(
        serviceDate,
      )).contains(trip.serviceId)) {
        continue;
      }
      for (final instance in gtfsTripInstances(index, trip.tripId)) {
        final tripUpdates = gtfsInstanceUpdates(
          index,
          trip.tripId,
          instance.offset,
          allTripUpdates,
        );
        for (var sequence = 0; sequence + 1 < times.length; sequence++) {
          final from = times[sequence], to = times[sequence + 1];
          final depSeconds = gtfsTimeSeconds(from.departureTime),
              arrSeconds = gtfsTimeSeconds(to.arrivalTime);
          if (depSeconds == null || arrSeconds == null) continue;
          final plannedDeparture = gtfsTimeOnDate(
            serviceDate,
            gtfsSecondsText(depSeconds + instance.offset),
            zone,
          );
          final plannedArrival = gtfsTimeOnDate(
            serviceDate,
            gtfsSecondsText(arrSeconds + instance.offset),
            zone,
          );
          if (plannedDeparture == null || plannedArrival == null) continue;
          if (tripUpdates.any(
            (u) =>
                u.cancelled &&
                gtfsUpdateApplies(u, serviceDate, plannedDeparture),
          )) {
            continue;
          }
          final estimatedDeparture = gtfsUpdatedTime(
            tripUpdates,
            from.stopId,
            plannedDeparture,
            serviceDate,
            arrival: false,
            stopTimes: times,
          );
          final estimatedArrival = gtfsUpdatedTime(
            tripUpdates,
            to.stopId,
            plannedArrival,
            serviceDate,
            arrival: true,
            stopTimes: times,
          );
          final departure = estimatedDeparture ?? plannedDeparture,
              arrival = estimatedArrival ?? plannedArrival;
          if (departure.isBefore(start) ||
              departure.isAfter(end) ||
              arrival.isBefore(departure) ||
              arrival.isAfter(end)) {
            continue;
          }
          bool skipped(String stop) => tripUpdates.any(
            (u) =>
                u.stop?.stopId == stop &&
                u.skipped &&
                gtfsUpdateApplies(u, serviceDate, plannedDeparture),
          );
          connections.add(
            _Connection(
              trip.tripId,
              serviceDate,
              from.stopId,
              to.stopId,
              departure,
              arrival,
              sequence,
              _allowsScheduledAccess(from.pickupType) &&
                  !skipped(from.stopId) &&
                  accessibleStop(from.stopId),
              _allowsScheduledAccess(to.dropOffType) &&
                  !skipped(to.stopId) &&
                  accessibleStop(to.stopId),
              instanceId: '${trip.tripId}:${instance.offset}',
              approximate: instance.approximate,
              plannedDeparture: plannedDeparture,
              plannedArrival: plannedArrival,
              realtime: estimatedDeparture != null || estimatedArrival != null,
            ),
          );
          if (connections.length > input.budget.maximumConnections) {
            throw const TransitResourceLimit(
              message: 'This search exceeds the connection budget. Narrow the search.',
            );
          }
        }
      }
    }
  }
  connections.sort((a, b) {
    final order = a.departure.compareTo(b.departure);
    if (order != 0) return order;
    final run = a.run.compareTo(b.run);
    return run == 0 ? a.sequence.compareTo(b.sequence) : run;
  });
  final reached = <String, List<_JourneyLabel>>{};
  final onboard = <(String, DateTime), List<_JourneyLabel>>{};
  bool dominates(_JourneyLabel a, _JourneyLabel b) =>
      !a.time.isAfter(b.time) &&
      a.walked <= b.walked &&
      !(a.path?.lastVehicle?.arrival ?? start).isAfter(
        b.path?.lastVehicle?.arrival ?? start,
      ) &&
      (!request.arrivalBased ||
          !(a.originDeparture ?? start).isBefore(b.originDeparture ?? start));
  String context(_JourneyLabel label) {
    final vehicle = label.path?.lastVehicle;
    return '${vehicle == null ? '' : graph.contextFor(vehicle.tripId, vehicle.toStopId)}|${label.inSeatOnly}';
  }

  DateTime? bestArrival;
  bool install(String id, _JourneyLabel label) {
    final labels = reached[id] ??= [];
    final key = context(label);
    if (labels.any(
      (known) => context(known) == key && dominates(known, label),
    )) {
      return false;
    }
    labels.removeWhere(
      (known) => context(known) == key && dominates(label, known),
    );
    labels.add(label);
    if (id == request.destination.stopId &&
        !label.inSeatOnly &&
        (bestArrival == null || label.time.isBefore(bestArrival!))) {
      bestArrival = label.time;
    }
    if (labels.length > input.budget.maximumLabelsPerStop) {
      throw const TransitResourceLimit(
        message: 'This interchange search exceeds its label budget.',
      );
    }
    return true;
  }

  void reach(String id, _JourneyLabel initial) {
    final queue = <(String, _JourneyLabel)>[(id, initial)];
    for (var cursor = 0; cursor < queue.length; cursor++) {
      final (stop, label) = queue[cursor];
      if (!install(stop, label) || label.inSeatOnly) continue;
      for (final edge in graph.outgoing[stop] ?? const <GtfsFootpath>[]) {
        if (request.walkingLimit == Duration.zero) continue;
        if (request.accessibility == TransitAccessibility.stepFreeOnly &&
            !edge.stepFree) {
          continue;
        }
        if (request.accessibility == TransitAccessibility.wheelchairPreferred &&
            !edge.stepFree &&
            !edge.estimated) {
          continue;
        }
        final walked = label.walked + Duration(seconds: edge.seconds);
        if (request.walkingLimit != null && walked > request.walkingLimit!) {
          continue;
        }
        final arrival = label.time.add(Duration(seconds: edge.seconds));
        if (arrival.isAfter(end)) continue;
        final path = _ConnectionPath(
          _Connection(
            '',
            DateTime.utc(label.time.year, label.time.month, label.time.day),
            stop,
            edge.to,
            label.time,
            arrival,
            -1,
            true,
            true,
            isWalking: true,
            approximate: edge.estimated,
          ),
          label.path,
        );
        queue.add((
          edge.to,
          _JourneyLabel(arrival, walked, path, label.originDeparture),
        ));
      }
    }
  }

  reach(request.origin.stopId, _JourneyLabel(start, Duration.zero, null, null));
  for (final c in connections) {
    if (!request.arrivalBased &&
        bestArrival != null &&
        c.departure.isAfter(bestArrival!)) {
      break;
    }
    final run = (c.run, c.serviceDate);
    final candidates = <_JourneyLabel>[];
    for (final riding in onboard[run] ?? const <_JourneyLabel>[]) {
      final last = riding.path!.connection;
      if (last.sequence + 1 == c.sequence &&
          last.toStopId == c.fromStopId &&
          !riding.time.isAfter(c.departure)) {
        candidates.add(riding);
      }
    }
    for (final label in List<_JourneyLabel>.of(
      reached[c.fromStopId] ?? const [],
    )) {
      if (label.time.isAfter(c.departure)) continue;
      final previous = label.path?.lastVehicle;
      final rule = previous == null
          ? null
          : graph.rule(
              previous.toStopId,
              c.fromStopId,
              previous.tripId,
              c.tripId,
            );
      if (rule?.type == 3 || (label.inSeatOnly && rule?.type != 4)) continue;
      final inSeat =
          rule?.type == 4 &&
          c.sequence == 0 &&
          previous != null &&
          previous.sequence ==
              (index.timesByTrip[previous.tripId]?.length ?? 0) - 2;
      if (rule?.type == 4 && !inSeat) continue;
      if (!c.canBoard && !inSeat) continue;
      if (previous != null &&
          c.departure.isBefore(
            previous.arrival.add(Duration(seconds: rule?.minimumSeconds ?? 0)),
          )) {
        continue;
      }
      candidates.add(label);
    }
    final next = <_JourneyLabel>[];
    for (final candidate in candidates) {
      var previous = candidate.path;
      final firstBoarding = previous?.lastVehicle == null;
      final originDeparture = firstBoarding
          ? c.departure.subtract(candidate.walked)
          : candidate.originDeparture;
      if (firstBoarding && request.arrivalBased && previous != null) {
        previous = previous.shiftWalks(originDeparture!.difference(start));
      }
      final label = _JourneyLabel(
        c.arrival,
        candidate.walked,
        _ConnectionPath(c, previous),
        originDeparture,
      );
      if (!next.any((l) => dominates(l, label))) {
        next.removeWhere((l) => dominates(label, l));
        next.add(label);
      }
    }
    if (next.isEmpty) continue;
    onboard[run] = next;
    for (final label in next) {
      if (c.sequence == (index.timesByTrip[c.tripId]?.length ?? 0) - 2) {
        for (final stop in graph.inSeatDestinations(c.tripId, c.toStopId)) {
          install(
            stop,
            _JourneyLabel(
              label.time,
              label.walked,
              label.path,
              label.originDeparture,
              inSeatOnly: true,
            ),
          );
        }
      }
      if (c.canAlight) {
        reach(c.toStopId, label);
      } else {
        install(
          c.toStopId,
          _JourneyLabel(
            label.time,
            label.walked,
            label.path,
            label.originDeparture,
            inSeatOnly: true,
          ),
        );
      }
    }
  }
  final results =
      List<_JourneyLabel>.of(reached[request.destination.stopId] ?? const [])
        ..removeWhere(
          (l) =>
              l.path == null ||
              l.inSeatOnly ||
              (request.arrivalBased && l.time.isAfter(input.when)),
        );
  results.sort((a, b) {
    final order = request.arrivalBased
        ? (b.originDeparture ?? start).compareTo(a.originDeparture ?? start)
        : a.time.compareTo(b.time);
    return order == 0 ? a.walked.compareTo(b.walked) : order;
  });
  if (results.isEmpty) return const JourneyPlan(journeys: []);
  final result = results.first;
  var ordered = result.path!.connections;
  if (request.arrivalBased && ordered.every((c) => c.isWalking)) {
    ordered = result.path!.shiftWalks(end.difference(result.time)).connections;
  }
  final legs = <TransitLeg>[];
  for (var begin = 0; begin < ordered.length;) {
    var finish = begin;
    while (finish + 1 < ordered.length &&
        ordered[finish + 1].isWalking == ordered[begin].isWalking &&
        (ordered[begin].isWalking ||
            (ordered[finish + 1].run == ordered[begin].run &&
                ordered[finish + 1].serviceDate ==
                    ordered[begin].serviceDate))) {
      finish++;
    }
    final first = ordered[begin], last = ordered[finish];
    final trip = index.trips[first.tripId],
        route = trip == null ? null : index.routes[trip.routeId];
    legs.add(
      TransitLeg(
        origin: _makeStop(
          first.fromStopId,
          request.origin.sourceId,
          index,
          input.region,
          input.provider,
        ),
        destination: _makeStop(
          last.toStopId,
          request.origin.sourceId,
          index,
          input.region,
          input.provider,
        ),
        route: route == null
            ? null
            : TransitRoute(
                ref:
                    index.routeReferences[route.routeId] ??
                    TransitRouteRef(
                      region: input.region,
                      provider: input.provider,
                      sourceId: request.origin.sourceId,
                      routeId: route.routeId,
                    ),
                name: route.routeLongName.isEmpty
                    ? route.routeShortName
                    : route.routeLongName,
                shortName: route.routeShortName,
                mode: _mode(route.routeType),
                color: route.routeColor,
                textColor: route.routeTextColor,
              ),
        mode: route == null ? null : _mode(route.routeType),
        departureTime: first.departure,
        arrivalTime: last.arrival,
        plannedDepartureTime: first.plannedDeparture,
        plannedArrivalTime: last.plannedArrival,
        isWalking: first.isWalking,
        isApproximate: ordered
            .sublist(begin, finish + 1)
            .any((c) => c.approximate),
        isRealtime: ordered.sublist(begin, finish + 1).any((c) => c.realtime),
        label: first.isWalking ? 'Walk between platforms' : trip?.tripHeadsign,
      ),
    );
    begin = finish + 1;
  }
  return JourneyPlan(
    journeys: [TransitJourney(legs: legs)],
    rawPayload: {
      'walkingSeconds': result.walked.inSeconds,
      'approximate': legs.any((l) => l.isApproximate),
      'realtime': legs.any((l) => l.isRealtime),
    },
  );
}

TransitStop _makeStop(
  String id,
  TransitSourceId source,
  GtfsTimetableIndex index,
  TransitRegion region,
  TransitProviderId provider,
) {
  final stop = index.stops[id];
  return TransitStop(
    ref:
        index.stopReferences[id] ??
        TransitStopRef(
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

bool _allowsScheduledAccess(String? value) =>
    value == null || value.trim().isEmpty || value.trim() == '0';

class _JourneyLabel {
  const _JourneyLabel(
    this.time,
    this.walked,
    this.path,
    this.originDeparture, {
    this.inSeatOnly = false,
  });
  final DateTime time;
  final Duration walked;
  final _ConnectionPath? path;
  final DateTime? originDeparture;
  final bool inSeatOnly;
}

class _ConnectionPath {
  const _ConnectionPath(this.connection, this.previous);
  final _Connection connection;
  final _ConnectionPath? previous;
  _Connection? get lastVehicle {
    _ConnectionPath? p = this;
    while (p != null) {
      if (!p.connection.isWalking) return p.connection;
      p = p.previous;
    }
    return null;
  }

  List<_Connection> get connections {
    final values = <_Connection>[];
    _ConnectionPath? p = this;
    while (p != null) {
      values.add(p.connection);
      p = p.previous;
    }
    return values.reversed.toList();
  }

  _ConnectionPath shiftWalks(Duration offset) {
    _ConnectionPath? result;
    for (final c in connections) {
      result = _ConnectionPath(
        _Connection(
          c.tripId,
          c.serviceDate,
          c.fromStopId,
          c.toStopId,
          c.departure.add(offset),
          c.arrival.add(offset),
          c.sequence,
          c.canBoard,
          c.canAlight,
          isWalking: c.isWalking,
          approximate: c.approximate,
        ),
        result,
      );
    }
    return result!;
  }
}
