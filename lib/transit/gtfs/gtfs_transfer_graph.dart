import 'dart:convert';

import '../../gtfs/timetable_index.dart';
import '../../gtfs/transfer.dart';

class GtfsFootpath {
  const GtfsFootpath(
    this.from,
    this.to,
    this.seconds, {
    this.stepFree = false,
    this.estimated = true,
  });
  final String from, to;
  final int seconds;
  final bool stepFree, estimated;
}

/// Published paths take precedence over inferred parent/platform links.
class GtfsTransferGraph {
  GtfsTransferGraph(this.index) {
    final published = <String>{};
    for (final p in index.pathways) {
      published.add(_root(p.fromStopId));
      published.add(_root(p.toStopId));
      _add(
        GtfsFootpath(
          p.fromStopId,
          p.toStopId,
          p.traversalSeconds,
          stepFree: p.stepFree,
          estimated: p.estimated || p.seconds == null,
        ),
      );
      if (p.bidirectional) {
        _add(
          GtfsFootpath(
            p.toStopId,
            p.fromStopId,
            p.traversalSeconds,
            stepFree: p.stepFree,
            estimated: p.estimated || p.seconds == null,
          ),
        );
      }
    }
    for (final stop in index.stops.values) {
      final parent = stop.parentStation;
      if (parent == null ||
          parent.isEmpty ||
          !index.stops.containsKey(parent) ||
          published.contains(_root(stop.stopId))) {
        continue;
      }
      _add(GtfsFootpath(stop.stopId, parent, 60));
      _add(GtfsFootpath(parent, stop.stopId, 60));
    }
    for (final t in index.transfers) {
      (_rules[(t.fromStopId, t.toStopId)] ??= []).add(t);
      (_fromRules[t.fromStopId] ??= []).add(t);
      if (t.type == 4 && t.fromTripId != null && t.toTripId != null) {
        (_seatTrips[t.fromTripId!] ??= {}).add(t.toTripId!);
      }
      if (t.type <= 2 && !t.isQualified) {
        _add(GtfsFootpath(t.fromStopId, t.toStopId, t.minimumSeconds ?? 60));
      }
    }
  }
  final GtfsTimetableIndex index;
  final Map<String, Set<String>> _seatTrips = {};
  Iterable<String> inSeatDestinations(String tripId, String stopId) sync* {
    final from = index.timesByTrip[tripId];
    if (from == null || from.isEmpty || from.last.stopId != stopId) return;
    for (final toTrip in _seatTrips[tripId] ?? const <String>{}) {
      final to = index.timesByTrip[toTrip];
      if (to == null || to.isEmpty) continue;
      if (rule(stopId, to.first.stopId, tripId, toTrip)?.type == 4) {
        yield to.first.stopId;
      }
    }
  }

  final Map<(String, String), List<GtfsTransfer>> _rules = {};
  final Map<String, List<GtfsTransfer>> _fromRules = {};
  final Map<(String, String), String> _contextCache = {};
  String contextFor(String tripId, String stopId) =>
      _contextCache.putIfAbsent((tripId, stopId), () {
        final route = index.trips[tripId]?.routeId;
        final semantics = <String>{};
        for (final stop in _ancestors(stopId)) {
          for (final rule in _fromRules[stop] ?? const <GtfsTransfer>[]) {
            if (rule.fromTripId != null && rule.fromTripId != tripId) continue;
            if (rule.fromRouteId != null && rule.fromRouteId != route) continue;
            semantics.add(
              jsonEncode([
                rule.toStopId,
                rule.toRouteId,
                rule.toTripId,
                rule.type,
                rule.minimumSeconds,
                (rule.fromTripId == null ? 0 : 4) +
                    (rule.fromRouteId == null ? 0 : 1),
              ]),
            );
          }
        }
        return (semantics.toList()..sort()).join('|');
      });
  Iterable<String> _ancestors(String stop) sync* {
    final seen = <String>{};
    String? current = stop;
    while (current != null && current.isNotEmpty && seen.add(current)) {
      yield current;
      current = index.stops[current]?.parentStation;
    }
    yield '';
  }

  final Map<String, List<GtfsFootpath>> outgoing = {};
  void _add(GtfsFootpath path) {
    (outgoing[path.from] ??= []).add(path);
  }

  String _root(String id) {
    final seen = <String>{};
    while (seen.add(id)) {
      final parent = index.stops[id]?.parentStation;
      if (parent == null || parent.isEmpty) break;
      id = parent;
    }
    return id;
  }

  GtfsTransfer? rule(
    String fromStop,
    String toStop,
    String fromTrip,
    String toTrip,
  ) {
    final fromRoute = index.trips[fromTrip]?.routeId,
        toRoute = index.trips[toTrip]?.routeId;
    final candidates = <GtfsTransfer>[
      for (final from in _ancestors(fromStop))
        for (final to in _ancestors(toStop)) ...?_rules[(from, to)],
    ];
    final matching = candidates
        .where(
          (r) =>
              (r.fromTripId == null || r.fromTripId == fromTrip) &&
              (r.toTripId == null || r.toTripId == toTrip) &&
              (r.fromRouteId == null || r.fromRouteId == fromRoute) &&
              (r.toRouteId == null || r.toRouteId == toRoute),
        )
        .toList();
    int specificity(GtfsTransfer r) =>
        (r.fromTripId == null ? 0 : 4) +
        (r.toTripId == null ? 0 : 4) +
        (r.fromRouteId == null ? 0 : 1) +
        (r.toRouteId == null ? 0 : 1);
    matching.sort((a, b) {
      final order = specificity(b).compareTo(specificity(a));
      return order == 0 ? b.type.compareTo(a.type) : order;
    });
    return matching.firstOrNull;
  }
}
