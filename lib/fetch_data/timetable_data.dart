import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

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
import '../logs/logger.dart';
import '../services/api_key_service.dart';
import '../services/app_http_client.dart';
import '../utils/safe_value_utils.dart';

/// Which schedule surface to use when fetching GTFS schedule ZIPs
enum GtfsScheduleVersion { v1, v2 }

//V1
//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-timetables-realtime
//Metro on v2
//https://opendata.transport.nsw.gov.au/dataset/public-transport-timetables-realtime-v2

/*

The endpoints return a ZIP with GTFS (General Transit Feed Specification) files.
These files follow the official GTFS standard defined at https://gtfs.org/documentation/schedule/reference/

Standard GTFS files and their required/optional fields:

agency.txt - agency_name*, agency_url*, agency_timezone*, agency_id, agency_lang, agency_phone, agency_fare_url, agency_email
calendar.txt - service_id*, monday*, tuesday*, wednesday*, thursday*, friday*, saturday*, sunday*, start_date*, end_date*
calendar_dates.txt - service_id*, date*, exception_type*
routes.txt - route_id*, route_short_name*, route_long_name*, route_type*, agency_id, route_desc, route_url, route_color, route_text_color, route_sort_order
stops.txt - stop_id*, stop_name, stop_lat, stop_lon, stop_code, tts_stop_name, stop_desc, zone_id, stop_url, location_type, parent_station, stop_timezone, wheelchair_boarding, level_id, platform_code
stop_times.txt - trip_id*, arrival_time*, departure_time*, stop_id*, stop_sequence*, stop_headsign, pickup_type, drop_off_type, continuous_pickup, continuous_drop_off, shape_dist_traveled, timepoint
trips.txt - route_id*, service_id*, trip_id*, trip_headsign, trip_short_name, direction_id, block_id, shape_id, wheelchair_accessible, bikes_allowed
shapes.txt - shape_id*, shape_pt_lat*, shape_pt_lon*, shape_pt_sequence*, shape_dist_traveled

Non-standard extensions used by NSW Transport API:
- stop_times.txt: stop_note
- trips.txt: trip_note, route_direction  
- notes.txt: note_id, note_text (custom file)

* = Required field per GTFS specification

*/

Map<String, String> getHeaders() {
  final apiKey = ApiKeyService.getEffectiveApiKey();
  return {
    'Authorization': 'apikey $apiKey',
    //'Accept': 'application/x-protobuf', wrong
  };
}

Uri? _apiUri(String path) {
  return tryParseUriValue('https://api.transport.nsw.gov.au/$path');
}

List<int>? _archiveFileContent(dynamic content) {
  if (content is List<int>) {
    return content;
  }
  return null;
}

Future<FeedMessage?> _fetchRealtimeFeed(
  String versionPath,
  String endpoint, {
  required String logLabel,
}) async {
  try {
    final url = _apiUri('$versionPath/gtfs/realtime$endpoint');
    if (url == null) {
      safeLogError('Failed to build realtime URI for $endpoint');
      return null;
    }
    final response = await AppHttpClient.get(url, headers: getHeaders());
    if (response == null || response.statusCode != 200) {
      safeLogError(
        'Failed to fetch $logLabel for $endpoint: ${response?.statusCode ?? 'network error'}, ${response?.body ?? ''}',
      );
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e, st) {
    safeLogError('Error fetching $logLabel for $endpoint: $e\n$st');
    return null;
  }
}

Future<GtfsData?> _fetchGtfsDataFromEndpoint(
  String endpoint, {
  GtfsScheduleVersion version = GtfsScheduleVersion.v1,
}) async {
  try {
    final versionPath = version == GtfsScheduleVersion.v2 ? 'v2' : 'v1';
    final url = _apiUri('$versionPath/gtfs/schedule$endpoint');
    if (url == null) {
      logger.e('Failed to build GTFS URI for $endpoint (version=$versionPath)');
      return null;
    }
    final response = await AppHttpClient.get(url, headers: getHeaders());
    if (response == null || response.statusCode != 200) {
      logger.e(
        'Failed to fetch GTFS data for $endpoint (version=$versionPath): ${response?.statusCode ?? 'network error'}, ${response?.body ?? ''}',
      );
      return null;
    }
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    final Map<String, String> csvFiles = {};
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.txt')) {
        final content = _archiveFileContent(file.content);
        if (content == null) {
          safeLogWarning('Skipping ${file.name}: invalid archive content type');
          continue;
        }
        csvFiles[file.name] = utf8.decode(content);
      }
    }
    final data = parseGtfsFiles(csvFiles);
    safeLogInfo(
      'Parsed GTFS files for $endpoint: found ${csvFiles.length} CSV files, ${data.stops.length} stops',
    );
    return data;
  } catch (e, st) {
    safeLogError('Error fetching GTFS data for $endpoint: $e\n$st');
    return null;
  }
}

/// Fetches the Metro GTFS-realtime trip updates feed (protobuf) and
/// returns a parsed [FeedMessage]. The previous implementation returned a
/// CSV map from a schedule ZIP; the tests expect a realtime FeedMessage so
/// this function now calls the realtime endpoint.
Future<FeedMessage?> fetchMetroScheduleRealtime() async {
  return _fetchRealtimeFeed('v2', '/metro', logLabel: 'Metro realtime');
}

/// Fetches a GTFS-realtime feed from the v1 realtime surface and parses it
/// into a [FeedMessage]. Append the endpoint path (for example '/metro' or
/// '/sydneytrains') to the base URL when calling.
Future<FeedMessage?> fetchGtfsRealtimeDataFromEndpointV1(
  String endpoint,
) async {
  return _fetchRealtimeFeed('v1', endpoint, logLabel: 'GTFS realtime (v1)');
}

/// Fetches a GTFS-realtime feed from the v2 realtime surface and parses it
/// into a [FeedMessage]. Append the endpoint path (for example '/metro' or
/// '/sydneytrains') to the base URL when calling.
Future<FeedMessage?> fetchGtfsRealtimeDataFromEndpointV2(
  String endpoint,
) async {
  return _fetchRealtimeFeed('v2', endpoint, logLabel: 'GTFS realtime (v2)');
}

/// Fetch Metro schedule GTFS using the v2 schedule surface
Future<GtfsData?> fetchMetroGtfsData() =>
    _fetchGtfsDataFromEndpoint('/metro', version: GtfsScheduleVersion.v2);

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
  return _parseCsvRecords(
    csv,
    fileLabel: 'agency.txt',
    shouldParseNumbers: false,
    parseRow: Agency.fromCsv,
  );
}

List<Calendar> parseCalendarCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'calendar.txt',
    shouldParseNumbers: false,
    parseRow: Calendar.fromCsv,
  );
}

List<CalendarDate> parseCalendarDatesCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'calendar_dates.txt',
    shouldParseNumbers: false,
    parseRow: CalendarDate.fromCsv,
  );
}

List<Route> parseRoutesCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'routes.txt',
    shouldParseNumbers: false,
    parseRow: Route.fromCsv,
  );
}

List<Stop> parseStopsCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'stops.txt',
    shouldParseNumbers: true,
    parseRow: Stop.fromCsv,
  );
}

List<StopTime> parseStopTimesCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'stop_times.txt',
    shouldParseNumbers: false,
    parseRow: StopTime.fromCsv,
  );
}

List<Trip> parseTripsCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'trips.txt',
    shouldParseNumbers: false,
    parseRow: Trip.fromCsv,
  );
}

List<Shape> parseShapesCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'shapes.txt',
    shouldParseNumbers: false,
    parseRow: Shape.fromCsv,
  );
}

List<Note> parseNotesCsv(String csv) {
  return _parseCsvRecords(
    csv,
    fileLabel: 'notes.txt',
    shouldParseNumbers: false,
    parseRow: Note.fromCsv,
  );
}

List<T> _parseCsvRecords<T>(
  String csv, {
  required String fileLabel,
  required bool shouldParseNumbers,
  required T Function(List<String> header, List<String> row) parseRow,
}) {
  final rows = _csvToRows(csv, shouldParseNumbers: shouldParseNumbers);
  if (rows.isEmpty) {
    safeLogWarning('$fileLabel is empty');
    return [];
  }
  if (rows.length < 2) {
    final sample = csv.length > 500 ? csv.substring(0, 500) : csv;
    safeLogWarning(
      '$fileLabel contains less than 2 rows; using fallback empty list; sample="$sample"',
    );
    return [];
  }

  final rowIterator = rows.iterator;
  if (!rowIterator.moveNext()) {
    safeLogWarning('$fileLabel did not expose a readable header row');
    return [];
  }

  final List<String> header;
  try {
    header = _rowToStrings(rowIterator.current, stripLeadingBom: true);
  } catch (e, st) {
    safeLogWarning('Failed to parse $fileLabel header row: $e\n$st');
    return [];
  }

  final records = <T>[];
  var rowIndex = 1;
  for (final row in rows.skip(1)) {
    try {
      records.add(parseRow(header, _rowToStrings(row)));
    } catch (e, st) {
      safeLogWarning('Skipping malformed $fileLabel row #$rowIndex: $e\n$st');
    }
    rowIndex++;
  }
  return records;
}

// Note: custom CSV line parser removed in favor of package:csv

/// Convert a raw CSV string to rows while trying to autodetect EOL and field
/// delimiter. This works around feeds that use different line endings or
/// separators so the entire file isn't interpreted as a single row.
List<List<dynamic>> _csvToRows(String csv, {bool shouldParseNumbers = false}) {
  if (csv.isEmpty) return [];

  // Detect end-of-line sequence: prefer CRLF, then LF, then CR.
  String eol;
  if (csv.contains('\r\n')) {
    eol = '\r\n';
  } else if (csv.contains('\n')) {
    eol = '\n';
  } else if (csv.contains('\r')) {
    eol = '\r';
  } else {
    eol = '\n';
  }

  // Pick a likely field delimiter by checking the first non-empty line
  final lines = csv.split(eol);
  var firstLine = '';
  for (final l in lines) {
    if (l.trim().isNotEmpty) {
      firstLine = l;
      break;
    }
  }
  if (firstLine.isEmpty && lines.isNotEmpty) firstLine = lines.first;

  final delimiters = [',', ';', '\t', '|'];
  var fieldDelimiter = ',';
  var bestCount = -1;
  for (final d in delimiters) {
    final count = firstLine.split(d).length - 1;
    if (count > bestCount) {
      bestCount = count;
      fieldDelimiter = d;
    }
  }

  try {
    return CsvToListConverter(
      shouldParseNumbers: shouldParseNumbers,
    ).convert(csv, fieldDelimiter: fieldDelimiter, eol: eol);
  } catch (e) {
    safeLogWarning(
      'CsvToListConverter failed with eol="$eol" fieldDelimiter="$fieldDelimiter": $e',
    );
    // Fallback: try with a simple LF eol
    try {
      return CsvToListConverter(
        shouldParseNumbers: shouldParseNumbers,
      ).convert(csv, eol: '\n');
    } catch (e2) {
      safeLogWarning('CSV parsing fallback failed: $e2');
      return [];
    }
  }
}

List<String> _rowToStrings(List<dynamic> row, {bool stripLeadingBom = false}) {
  final values = <String>[];
  var isFirstCell = true;
  for (final cell in row) {
    values.add(_cellToString(cell, stripBom: stripLeadingBom && isFirstCell));
    isFirstCell = false;
  }
  return values;
}

String _cellToString(dynamic cell, {bool stripBom = false}) {
  var value = cell == null ? '' : cell.toString();
  if (stripBom) {
    value = value
        .replaceFirst('\uFEFF', '')
        .replaceFirst(RegExp('^\u00EF\u00BB\u00BF'), '');
  }
  return value;
}

GtfsData parseGtfsFiles(Map<String, String> files) {
  final agencyFile = _lookupTextFile(files, 'agency.txt');
  final calendarFile = _lookupTextFile(files, 'calendar.txt');
  final calendarDatesFile = _lookupTextFile(files, 'calendar_dates.txt');
  final routesFile = _lookupTextFile(files, 'routes.txt');
  final stopsFile = _lookupTextFile(files, 'stops.txt');
  final stopTimesFile = _lookupTextFile(files, 'stop_times.txt');
  final tripsFile = _lookupTextFile(files, 'trips.txt');
  final shapesFile = _lookupTextFile(files, 'shapes.txt');
  final notesFile = _lookupTextFile(files, 'notes.txt');
  if (stopsFile == null) {
    safeLogError('Stops.txt is missing');
  }
  return GtfsData(
    agencies: agencyFile != null ? parseAgencyCsv(agencyFile) : [],
    calendars: calendarFile != null ? parseCalendarCsv(calendarFile) : [],
    calendarDates: calendarDatesFile != null
        ? parseCalendarDatesCsv(calendarDatesFile)
        : [],
    routes: routesFile != null ? parseRoutesCsv(routesFile) : [],
    stops: stopsFile != null ? parseStopsCsv(stopsFile) : [],
    stopTimes: stopTimesFile != null ? parseStopTimesCsv(stopTimesFile) : [],
    trips: tripsFile != null ? parseTripsCsv(tripsFile) : [],
    shapes: shapesFile != null ? parseShapesCsv(shapesFile) : [],
    notes: notesFile != null ? parseNotesCsv(notesFile) : [],
  );
}

/// Decode a GTFS ZIP and return only the stops from stops.txt, ignoring all
/// other files (stop_times.txt, trips.txt, shapes.txt etc. can be very large).
///
/// This is a top-level function so it can be passed to [compute] and run in
/// a background isolate, keeping the UI thread free.
List<Stop> parseStopsOnlyFromZipBytes(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    if (file.isFile && file.name == 'stops.txt') {
      try {
        final csv = utf8.decode(file.content as List<int>);
        return parseStopsCsv(csv);
      } catch (e, st) {
        safeLogWarning('Failed to decode stops.txt from ZIP: $e\n$st');
        return [];
      }
    }
  }
  return [];
}

String? _lookupTextFile(Map<String, String> files, String fileName) {
  try {
    return files[fileName];
  } catch (e, st) {
    safeLogWarning('Failed to look up $fileName: $e\n$st');
    return null;
  }
}
