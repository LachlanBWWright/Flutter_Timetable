import 'package:lbww_flutter/gtfs/agency.dart';
import 'package:lbww_flutter/gtfs/calendar.dart';
import 'package:lbww_flutter/gtfs/calendar_date.dart';
import 'package:lbww_flutter/gtfs/note.dart';
import 'package:lbww_flutter/gtfs/route.dart';
import 'package:lbww_flutter/gtfs/shape.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart';

import '../constants/transport_modes.dart';
import '../transit/domain/timetable_provenance.dart';
import '../transit/domain/transit_types.dart'
    show TransitStopRef, TransitRouteRef;
import 'frequency.dart';
import 'pathway.dart';
import 'timetable_index.dart';
import 'transfer.dart';

class GtfsData {
  final List<Agency> agencies;
  final List<Calendar> calendars;
  final List<CalendarDate> calendarDates;
  final List<Route> routes;
  final List<Stop> stops;
  final List<StopTime> stopTimes;
  final List<Trip> trips;
  final List<Shape> shapes;
  final List<Note> notes;

  // Feed lists are snapshot data and must not be mutated after indexing.
  final _GtfsIndexCache _indexCache;
  GtfsTimetableIndex get index =>
      _indexCache.value ??= GtfsTimetableIndex(this);
  final Map<String, Set<TransportMode>> stopModes;
  final List<GtfsFrequency> frequencies;
  final List<GtfsPathway> pathways;
  final List<GtfsTransfer> transfers;
  final Map<String, TransitStopRef> stopReferences;
  final Map<String, TransitRouteRef> routeReferences;
  final TimetableProvenance? timetable;
  final bool isStopSnapshot;

  GtfsData({
    Map<String, Set<TransportMode>> stopModes = const {},
    List<GtfsFrequency> frequencies = const [],
    List<GtfsPathway> pathways = const [],
    List<GtfsTransfer> transfers = const [],
    Map<String, TransitStopRef> stopReferences = const {},
    Map<String, TransitRouteRef> routeReferences = const {},
    this.timetable,
    this.isStopSnapshot = false,
    required List<Agency> agencies,
    required List<Calendar> calendars,
    required List<CalendarDate> calendarDates,
    required List<Route> routes,
    required List<Stop> stops,
    required List<StopTime> stopTimes,
    required List<Trip> trips,
    required List<Shape> shapes,
    required List<Note> notes,
  }) : agencies = List.unmodifiable(agencies),
       calendars = List.unmodifiable(calendars),
       calendarDates = List.unmodifiable(calendarDates),
       routes = List.unmodifiable(routes),
       stops = List.unmodifiable(stops),
       stopTimes = List.unmodifiable(stopTimes),
       trips = List.unmodifiable(trips),
       shapes = List.unmodifiable(shapes),
       notes = List.unmodifiable(notes),
       frequencies = List.unmodifiable(frequencies),
       pathways = List.unmodifiable(pathways),
       transfers = List.unmodifiable(transfers),
       stopReferences = Map.unmodifiable(stopReferences),
       routeReferences = Map.unmodifiable(routeReferences),
       stopModes = Map.unmodifiable(
         stopModes.map(
           (id, modes) => MapEntry(id, Set<TransportMode>.unmodifiable(modes)),
         ),
       ),
       _indexCache = _GtfsIndexCache();

  GtfsData._withTimetable(
    GtfsData original,
    this.timetable, {
    Map<String, Set<TransportMode>>? modes,
  }) : agencies = original.agencies,
       calendars = original.calendars,
       calendarDates = original.calendarDates,
       routes = original.routes,
       stops = original.stops,
       stopTimes = original.stopTimes,
       trips = original.trips,
       shapes = original.shapes,
       notes = original.notes,
       stopModes = modes == null
           ? original.stopModes
           : Map.unmodifiable(
               modes.map(
                 (id, values) =>
                     MapEntry(id, Set<TransportMode>.unmodifiable(values)),
               ),
             ),
       stopReferences = original.stopReferences,
       routeReferences = original.routeReferences,
       frequencies = original.frequencies,
       pathways = original.pathways,
       transfers = original.transfers,
       isStopSnapshot = original.isStopSnapshot,
       _indexCache = original._indexCache;

  GtfsData withStopModes(Map<String, Set<TransportMode>> modes) =>
      GtfsData._withTimetable(this, timetable, modes: modes);

  GtfsData withTimetable(TimetableProvenance value) =>
      GtfsData._withTimetable(this, value);
}

class _GtfsIndexCache {
  GtfsTimetableIndex? value;
}
