import 'package:lbww_flutter/gtfs/agency.dart';
import 'package:lbww_flutter/gtfs/calendar.dart';
import 'package:lbww_flutter/gtfs/calendar_date.dart';
import 'package:lbww_flutter/gtfs/note.dart';
import 'package:lbww_flutter/gtfs/route.dart';
import 'package:lbww_flutter/gtfs/shape.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart';

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

  GtfsData({
    required this.agencies,
    required this.calendars,
    required this.calendarDates,
    required this.routes,
    required this.stops,
    required this.stopTimes,
    required this.trips,
    required this.shapes,
    required this.notes,
  });
}
