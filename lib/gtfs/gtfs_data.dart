import '../fetch_data/csv_types/agency.dart';
import '../fetch_data/csv_types/calendar.dart';
import '../fetch_data/csv_types/calendar_dates.dart';
import '../fetch_data/csv_types/notes.dart';
import '../fetch_data/csv_types/routes.dart';
import '../fetch_data/csv_types/shapes.dart';
import '../fetch_data/csv_types/stop_times.dart';
import '../fetch_data/csv_types/stops.dart';
import '../fetch_data/csv_types/trips.dart';

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
