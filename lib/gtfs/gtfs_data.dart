import 'agency.dart';
import 'calendar.dart';
import 'calendar_date.dart';
import 'note.dart';
import 'route.dart';
import 'shape.dart';
import 'stop.dart';
import 'stop_time.dart';
import 'trip.dart';

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
