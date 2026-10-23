part of '../timetable_data.dart';

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
    final value = _cellToString(cell, stripBom: stripLeadingBom && isFirstCell);
    values.add(stripLeadingBom ? value.trim() : value);
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
