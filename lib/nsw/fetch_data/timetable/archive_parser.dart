part of '../timetable_data.dart';

List<int>? _archiveFileContent(dynamic content) {
  if (content is List<int>) {
    return content;
  }
  return null;
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

/// Inflate and parse a full GTFS ZIP. Kept top-level for `compute` isolate use.
GtfsData parseGtfsZipBytes(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final csvFiles = <String, String>{};
  for (final file in archive) {
    if (!file.isFile || !file.name.endsWith('.txt')) continue;
    final content = _archiveFileContent(file.content);
    if (content == null) {
      safeLogWarning('Skipping ${file.name}: invalid archive content type');
      continue;
    }
    csvFiles[file.name] = utf8.decode(content);
  }
  return parseGtfsFiles(csvFiles);
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
