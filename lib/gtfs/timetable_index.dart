import '../transit/domain/transit_types.dart'
    show TransitStopRef, TransitRouteRef;
import 'calendar.dart';
import 'calendar_date.dart';
import 'frequency.dart';
import 'gtfs_data.dart';
import 'pathway.dart';
import 'route.dart';
import 'stop.dart';
import 'stop_time.dart';
import 'transfer.dart';
import 'trip.dart';

/// Built once per immutable feed snapshot, then shared by schedule consumers.
class GtfsTimetableIndex {
  GtfsTimetableIndex(GtfsData data)
    : stops = Map.unmodifiable({for (final s in data.stops) s.stopId: s}),
      trips = Map.unmodifiable({for (final t in data.trips) t.tripId: t}),
      routes = Map.unmodifiable({for (final r in data.routes) r.routeId: r}),
      calendars = List.unmodifiable(data.calendars),
      pathways = data.pathways,
      transfers = data.transfers,
      stopReferences = data.stopReferences,
      routeReferences = data.routeReferences {
    final byStop = <String, List<StopTime>>{};
    final byTrip = <String, List<StopTime>>{};
    final byService = <String, List<Trip>>{};
    final exceptions = <String, List<CalendarDate>>{};
    final children = <String, List<String>>{};
    final frequencies = <String, List<GtfsFrequency>>{};
    var maximum = 0;
    for (final time in data.stopTimes) {
      (byStop[time.stopId] ??= []).add(time);
      (byTrip[time.tripId] ??= []).add(time);
      for (final value in [time.departureTime, time.arrivalTime]) {
        final seconds = gtfsTimeSeconds(value);
        if (seconds != null && seconds ~/ 3600 > maximum) {
          maximum = seconds ~/ 3600;
        }
      }
    }
    for (final times in byTrip.values) {
      times.sort(
        (a, b) => (int.tryParse(a.stopSequence) ?? 0).compareTo(
          int.tryParse(b.stopSequence) ?? 0,
        ),
      );
    }
    for (final trip in data.trips) {
      (byService[trip.serviceId] ??= []).add(trip);
    }
    for (final exception in data.calendarDates) {
      (exceptions[exception.date] ??= []).add(exception);
    }
    for (final stop in data.stops) {
      final parent = stop.parentStation;
      if (parent != null &&
          parent.isNotEmpty &&
          stops.containsKey(parent) &&
          parent != stop.stopId) {
        (children[parent] ??= []).add(stop.stopId);
      }
    }
    for (final f in data.frequencies) {
      (frequencies[f.tripId] ??= []).add(f);
      final end = gtfsTimeSeconds(f.endTime);
      if (end != null && end ~/ 3600 > maximum) maximum = end ~/ 3600;
    }
    frequenciesByTrip = _freeze(frequencies);
    timesByStop = _freeze(byStop);
    timesByTrip = _freeze(byTrip);
    tripsByService = _freeze(byService);
    exceptionsByDate = _freeze(exceptions);
    childrenByStation = _freeze(children);
    maximumHour = maximum;
  }

  final Map<String, Stop> stops;
  final Map<String, Trip> trips;
  final Map<String, Route> routes;
  final List<Calendar> calendars;
  final List<GtfsPathway> pathways;
  final List<GtfsTransfer> transfers;
  final Map<String, TransitStopRef> stopReferences;
  final Map<String, TransitRouteRef> routeReferences;
  late final Map<String, List<GtfsFrequency>> frequenciesByTrip;
  late final Map<String, List<StopTime>> timesByStop;
  late final Map<String, List<StopTime>> timesByTrip;
  late final Map<String, List<Trip>> tripsByService;
  late final Map<String, List<CalendarDate>> exceptionsByDate;
  late final Map<String, List<String>> childrenByStation;
  late final int maximumHour;

  static Map<String, List<T>> _freeze<T>(Map<String, List<T>> values) =>
      Map.unmodifiable(
        values.map((key, value) => MapEntry(key, List<T>.unmodifiable(value))),
      );

  Set<String> activeServices(DateTime serviceDate) {
    final date =
        '${serviceDate.year.toString().padLeft(4, '0')}'
        '${serviceDate.month.toString().padLeft(2, '0')}${serviceDate.day.toString().padLeft(2, '0')}';
    final active = <String>{};
    for (final c in calendars) {
      if (date.compareTo(c.startDate) < 0 || date.compareTo(c.endDate) > 0) {
        continue;
      }
      if ([
            c.monday,
            c.tuesday,
            c.wednesday,
            c.thursday,
            c.friday,
            c.saturday,
            c.sunday,
          ][serviceDate.weekday - 1] ==
          '1') {
        active.add(c.serviceId);
      }
    }
    for (final exception in exceptionsByDate[date] ?? const <CalendarDate>[]) {
      if (exception.exceptionType == '1') active.add(exception.serviceId);
      if (exception.exceptionType == '2') active.remove(exception.serviceId);
    }
    return active;
  }

  /// A station board includes its platforms; a platform board remains specific.
  Set<String> boardingStops(String stopId) {
    final result = <String>{};
    void visit(String id) {
      if (!result.add(id)) return;
      for (final child in childrenByStation[id] ?? const <String>[]) {
        visit(child);
      }
    }

    visit(stopId);
    return result;
  }
}

int? gtfsTimeSeconds(String value) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length != 3 ||
      parts.any((p) => p == null) ||
      parts[0]! < 0 ||
      parts[1]! < 0 ||
      parts[1]! > 59 ||
      parts[2]! < 0 ||
      parts[2]! > 59) {
    return null;
  }
  return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
}
