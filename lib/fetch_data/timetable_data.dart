import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../gtfs/agency.dart';
import '../gtfs/calendar.dart';
import '../gtfs/calendar_date.dart';
import '../gtfs/gtfs_data.dart';
import '../gtfs/note.dart';
import '../gtfs/route.dart';
import '../gtfs/shape.dart';
import '../gtfs/stop.dart';
import '../gtfs/stop_time.dart';
import '../gtfs/trip.dart';

//V1
//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-timetables-realtime
//Metro on v2
//https://opendata.transport.nsw.gov.au/dataset/public-transport-timetables-realtime-v2

/*

The endpoints return a ZIP with the following files of CSV values, with the according headers: 

agency.txt - agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email
calendar.txt - service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
calendar_dates.txt - service_id,date,exception_type
routes.txt - route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_color,route_text_color,route_url
stops.txt - stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station,wheelchair_boarding,platform_code
stop_times.txt - trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint,stop_note
trips.txt - route_id,service_id,trip_id,shape_id,trip_headsign,direction_id,trip_short_name,block_id,wheelchair_accessible,trip_note,route_direction,bikes_allowed
shapes.txt - shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence,shape_dist_traveled
notes.txt - note_id,note_text

*/

Map<String, String> getHeaders() {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  return {
    'Authorization': 'apikey $apiKey',
    //'Accept': 'application/x-protobuf', WRONG!
  };
}

Future<GtfsData?> _fetchGtfsDataFromEndpoint(String endpoint) async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/timetable$endpoint');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) {
    print('Failed to fetch GTFS data for $endpoint: ${response.statusCode}');
    return null;
  }
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  final Map<String, String> csvFiles = {};
  for (final file in archive) {
    if (file.isFile && file.name.endsWith('.txt')) {
      csvFiles[file.name] = String.fromCharCodes(file.content as List<int>);
    }
  }
  return parseGtfsFiles(csvFiles);
}

/// Fetches the Metro GTFS schedule zip, extracts CSV files, and returns a map of filename to CSV string.
Future<Map<String, String>?> fetchMetroScheduleRealtime() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/schedule/metro');
  final response = await http.get(
    url,
    headers: getHeaders(),
  );
  if (response.statusCode != 200) {
    print('Failed to fetch Metro schedule realtime: ${response.statusCode}');
    return null;
  }

  // Unzip the response body in memory
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  final Map<String, String> csvFiles = {};
  for (final file in archive) {
    print(file.name);
    if (file.isFile && file.name.endsWith('.txt')) {
      //csvFiles[file.name] = String.fromCharCodes(file.content as List<int>);
    }
  }
  return csvFiles;
}

Future<GtfsData?> fetchBusesGtfsData() => _fetchGtfsDataFromEndpoint('/buses');
Future<GtfsData?> fetchBusesSBSC006GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/SBSC006');
Future<GtfsData?> fetchBusesGSBC001GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC001');
Future<GtfsData?> fetchBusesGSBC002GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC002');
Future<GtfsData?> fetchBusesGSBC003GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC003');
Future<GtfsData?> fetchBusesGSBC004GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC004');
Future<GtfsData?> fetchBusesGSBC007GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC007');
Future<GtfsData?> fetchBusesGSBC008GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC008');
Future<GtfsData?> fetchBusesGSBC009GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC009');
Future<GtfsData?> fetchBusesGSBC010GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC010');
Future<GtfsData?> fetchBusesGSBC014GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/GSBC014');
Future<GtfsData?> fetchBusesOSMBSC001GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC001');
Future<GtfsData?> fetchBusesOSMBSC002GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC002');
Future<GtfsData?> fetchBusesOSMBSC003GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC003');
Future<GtfsData?> fetchBusesOSMBSC004GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC004');
Future<GtfsData?> fetchBusesOMBSC006GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OMBSC006');
Future<GtfsData?> fetchBusesOMBSC007GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OMBSC007');
Future<GtfsData?> fetchBusesOSMBSC008GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC008');
Future<GtfsData?> fetchBusesOSMBSC009GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC009');
Future<GtfsData?> fetchBusesOSMBSC010GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC010');
Future<GtfsData?> fetchBusesOSMBSC011GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC011');
Future<GtfsData?> fetchBusesOSMBSC012GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/OSMBSC012');
Future<GtfsData?> fetchBusesNISC001GtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/NISC001');
Future<GtfsData?> fetchBusesReplacementBusGtfsData() =>
    _fetchGtfsDataFromEndpoint('/buses/ReplacementBus');

Future<GtfsData?> fetchFerriesSydneyFerriesGtfsData() =>
    _fetchGtfsDataFromEndpoint('/ferries/sydneyferries');
Future<GtfsData?> fetchFerriesMFFGtfsData() =>
    _fetchGtfsDataFromEndpoint('/ferries/MFF');

Future<GtfsData?> fetchLightRailInnerWestGtfsData() =>
    _fetchGtfsDataFromEndpoint('/lightrail/innerwest');
Future<GtfsData?> fetchLightRailNewcastleGtfsData() =>
    _fetchGtfsDataFromEndpoint('/lightrail/newcastle');
Future<GtfsData?> fetchLightRailCbdAndSoutheastGtfsData() =>
    _fetchGtfsDataFromEndpoint('/lightrail/cbdandsoutheast');
Future<GtfsData?> fetchLightRailParramattaGtfsData() =>
    _fetchGtfsDataFromEndpoint('/lightrail/parramatta');

Future<GtfsData?> fetchNswTrainsGtfsData() =>
    _fetchGtfsDataFromEndpoint('/nswtrains');
Future<GtfsData?> fetchSydneyTrainsGtfsData() =>
    _fetchGtfsDataFromEndpoint('/sydneytrains');

Future<GtfsData?> fetchRegionBusesSouthEastTablelandsGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/southeasttablelands');
Future<GtfsData?> fetchRegionBusesSouthEastTablelands2GtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/southeasttablelands2');
Future<GtfsData?> fetchRegionBusesNorthCoastGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/northcoast');
Future<GtfsData?> fetchRegionBusesNorthCoast2GtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/northcoast2');
Future<GtfsData?> fetchRegionBusesCentralWestAndOranaGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/centralwestandorana');
Future<GtfsData?> fetchRegionBusesCentralWestAndOrana2GtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/centralwestandorana2');
Future<GtfsData?> fetchRegionBusesRiverinaMurrayGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/riverinamurray');
Future<GtfsData?> fetchRegionBusesNewEnglandNorthWestGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/newenglandnorthwest');
Future<GtfsData?> fetchRegionBusesRiverinaMurray2GtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/riverinamurray2');
Future<GtfsData?> fetchRegionBusesNorthCoast3GtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/northcoast3');
Future<GtfsData?> fetchRegionBusesSydneySurroundsGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/sydneysurrounds');
Future<GtfsData?> fetchRegionBusesNewcastleHunterGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/newcastlehunter');
Future<GtfsData?> fetchRegionBusesFarWestGtfsData() =>
    _fetchGtfsDataFromEndpoint('/regionbuses/farwest');

List<Agency> parseAgencyCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Agency.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Calendar> parseCalendarCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Calendar.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<CalendarDate> parseCalendarDatesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      CalendarDate.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Route> parseRoutesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Route.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Stop> parseStopsCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++) Stop.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<StopTime> parseStopTimesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      StopTime.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Trip> parseTripsCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++) Trip.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Shape> parseShapesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Shape.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<Note> parseNotesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++) Note.fromCsv(_parseCsvLine(lines[i]))
  ];
}

List<String> _parseCsvLine(String line) {
  // Handles quoted fields and commas inside quotes
  final List<String> result = [];
  final RegExp regExp = RegExp(r'((?:"[^"]*")|[^,]+|(?<=,)(?=,))');
  for (final match in regExp.allMatches(line)) {
    var value = match.group(0) ?? '';
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    result.add(value);
  }
  return result;
}

GtfsData parseGtfsFiles(Map<String, String> files) {
  return GtfsData(
    agencies:
        files['agency.txt'] != null ? parseAgencyCsv(files['agency.txt']!) : [],
    calendars: files['calendar.txt'] != null
        ? parseCalendarCsv(files['calendar.txt']!)
        : [],
    calendarDates: files['calendar_dates.txt'] != null
        ? parseCalendarDatesCsv(files['calendar_dates.txt']!)
        : [],
    routes:
        files['routes.txt'] != null ? parseRoutesCsv(files['routes.txt']!) : [],
    stops: files['stops.txt'] != null ? parseStopsCsv(files['stops.txt']!) : [],
    stopTimes: files['stop_times.txt'] != null
        ? parseStopTimesCsv(files['stop_times.txt']!)
        : [],
    trips: files['trips.txt'] != null ? parseTripsCsv(files['trips.txt']!) : [],
    shapes:
        files['shapes.txt'] != null ? parseShapesCsv(files['shapes.txt']!) : [],
    notes: files['notes.txt'] != null ? parseNotesCsv(files['notes.txt']!) : [],
  );
}
