import 'package:archive/archive.dart';
import 'dart:convert';
// For LineSplitter
import 'package:lbww_flutter/backends/RealtimeTimetablesV1Api.dart';
import 'package:lbww_flutter/backends/RealtimeTimetablesV2Api.dart';

import 'csv_types/agency.dart';
import 'csv_types/calendar.dart';
import 'csv_types/calendar_dates.dart';
import 'csv_types/notes.dart';
import 'csv_types/routes.dart';
import 'csv_types/shapes.dart';
import 'csv_types/stops.dart';
import 'csv_types/stop_times.dart';
import 'csv_types/trips.dart';

// If you have a GtfsData class, update its import accordingly, or keep as is if unchanged
import '../gtfs/gtfs_data.dart';
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

Future<GtfsData?> _fetchGtfsDataFromApi(Future apiCall) async {
  try {
    final res = await apiCall;
    if (!res.isSuccessful || res.body == null) {
      print('Failed to fetch GTFS data: ${res.statusCode}');
      return null;
    }
    final archive = ZipDecoder().decodeBytes(res.body!);
    final Map<String, String> csvFiles = {};
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.txt')) {
        csvFiles[file.name] = String.fromCharCodes(file.content as List<int>);
      }
    }
    return parseGtfsFiles(csvFiles);
  } catch (e) {
    print('Error fetching GTFS data: $e');
    return null;
  }
}

/// Fetches the Metro GTFS schedule zip, extracts CSV files, and returns a map of filename to CSV string.
Future<Map<String, String>?> fetchMetroScheduleRealtime() async {
  try {
    final res = await realtimeTimetablesV2Api.metroGet();
    if (!res.isSuccessful || res.body == null) {
      print('Failed to fetch Metro schedule realtime: \\${res.statusCode}');
      return null;
    }
    // Unzip the response body in memory
    final archive = ZipDecoder().decodeBytes(res.body!);
    final Map<String, String> csvFiles = {};
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.txt')) {
        csvFiles[file.name] = String.fromCharCodes(file.content as List<int>);
      }
    }
    return csvFiles;
  } catch (e) {
    print('Error fetching Metro schedule realtime: $e');
    return null;
  }
}

Future<GtfsData?> fetchBusesGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGet());
Future<GtfsData?> fetchBusesSBSC006GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesSBSC006Get());
Future<GtfsData?> fetchBusesGSBC001GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC001Get());
Future<GtfsData?> fetchBusesGSBC002GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC002Get());
Future<GtfsData?> fetchBusesGSBC003GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC003Get());
Future<GtfsData?> fetchBusesGSBC004GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC004Get());
Future<GtfsData?> fetchBusesGSBC007GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC007Get());
Future<GtfsData?> fetchBusesGSBC008GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC008Get());
Future<GtfsData?> fetchBusesGSBC009GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC009Get());
Future<GtfsData?> fetchBusesGSBC010GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC010Get());
Future<GtfsData?> fetchBusesGSBC014GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesGSBC014Get());
Future<GtfsData?> fetchBusesOSMBSC001GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC001Get());
Future<GtfsData?> fetchBusesOSMBSC002GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC002Get());
Future<GtfsData?> fetchBusesOSMBSC003GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC003Get());
Future<GtfsData?> fetchBusesOSMBSC004GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC004Get());
Future<GtfsData?> fetchBusesOMBSC006GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOMBSC006Get());
Future<GtfsData?> fetchBusesOMBSC007GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOMBSC007Get());
Future<GtfsData?> fetchBusesOSMBSC008GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC008Get());
Future<GtfsData?> fetchBusesOSMBSC009GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC009Get());
Future<GtfsData?> fetchBusesOSMBSC010GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC010Get());
Future<GtfsData?> fetchBusesOSMBSC011GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC011Get());
Future<GtfsData?> fetchBusesOSMBSC012GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesOSMBSC012Get());
Future<GtfsData?> fetchBusesNISC001GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesNISC001Get());
Future<GtfsData?> fetchBusesReplacementBusGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.busesReplacementBusGet());

Future<GtfsData?> fetchFerriesSydneyFerriesGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.ferriesSydneyferriesGet());
Future<GtfsData?> fetchFerriesMFFGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.ferriesMFFGet());

Future<GtfsData?> fetchLightRailInnerWestGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.lightrailInnerwestGet());
Future<GtfsData?> fetchLightRailNewcastleGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.lightrailNewcastleGet());
Future<GtfsData?> fetchLightRailCbdAndSoutheastGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.lightrailCbdandsoutheastGet());
Future<GtfsData?> fetchLightRailParramattaGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.lightrailParramattaGet());

Future<GtfsData?> fetchNswTrainsGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.nswtrainsGet());
Future<GtfsData?> fetchSydneyTrainsGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.sydneytrainsGet());

Future<GtfsData?> fetchRegionBusesSouthEastTablelandsGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesSoutheasttablelandsGet());
Future<GtfsData?> fetchRegionBusesSouthEastTablelands2GtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesSoutheasttablelands2Get());
Future<GtfsData?> fetchRegionBusesNorthCoastGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.regionbusesNorthcoastGet());
Future<GtfsData?> fetchRegionBusesNorthCoast2GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.regionbusesNorthcoast2Get());
Future<GtfsData?> fetchRegionBusesCentralWestAndOranaGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesCentralwestandoranaGet());
Future<GtfsData?> fetchRegionBusesCentralWestAndOrana2GtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesCentralwestandorana2Get());
Future<GtfsData?> fetchRegionBusesRiverinaMurrayGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesRiverinamurrayGet());
Future<GtfsData?> fetchRegionBusesNewEnglandNorthWestGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesNewenglandnorthwestGet());
Future<GtfsData?> fetchRegionBusesRiverinaMurray2GtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesRiverinamurray2Get());
Future<GtfsData?> fetchRegionBusesNorthCoast3GtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.regionbusesNorthcoast3Get());
Future<GtfsData?> fetchRegionBusesSydneySurroundsGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesSydneysurroundsGet());
Future<GtfsData?> fetchRegionBusesNewcastleHunterGtfsData() =>
    _fetchGtfsDataFromApi(
        realtimeTimetablesV1Api.regionbusesNewcastlehunterGet());
Future<GtfsData?> fetchRegionBusesFarWestGtfsData() =>
    _fetchGtfsDataFromApi(realtimeTimetablesV1Api.regionbusesFarwestGet());

List<Agency> parseAgencyCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Agency.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Calendar> parseCalendarCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Calendar.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<CalendarDate> parseCalendarDatesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      CalendarDate.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Route> parseRoutesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Route.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Stop> parseStopsCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Stop.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<StopTime> parseStopTimesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      StopTime.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Trip> parseTripsCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Trip.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Shape> parseShapesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Shape.fromCsvRow(_parseCsvLine(lines[i]))
  ];
}

List<Note> parseNotesCsv(String csv) {
  final lines = LineSplitter.split(csv).toList();
  return [
    for (var i = 1; i < lines.length; i++)
      Note.fromCsvRow(_parseCsvLine(lines[i]))
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
