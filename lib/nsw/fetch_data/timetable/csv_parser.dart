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
  bool strict = false,
  bool retainRecords = true,
  int? maximumRecords,
  required bool shouldParseNumbers,
  required T Function(List<String> header, List<String> row) parseRow,
}) {
  if (csv.isEmpty) return [];
  // Decode one row at a time: large stop_times files must not retain a second
  // full table of dynamic rows alongside the immutable domain snapshot.
  final lineEnd = csv.indexOf(RegExp(r'[\r\n]'));
  final firstLine = csv.substring(0, lineEnd < 0 ? csv.length : lineEnd);
  final delimiters = [',', ';', '\t', '|']
    ..sort(
      (a, b) =>
          (firstLine.split(b).length).compareTo(firstLine.split(a).length),
    );
  final decoder = CsvDecoder(
    fieldDelimiter: delimiters.first,
    fieldTransform: shouldParseNumbers
        ? (field, _, _) => num.tryParse(field.toString()) ?? field
        : null,
  );
  final records = <T>[];
  List<String>? header;
  var rowIndex = 0;
  final interned = <String, String>{};
  List<int> sharedColumns = [];
  final sink = decoder.startChunkedConversion(
    _CsvRowSink((raw) {
      final row = _rowToStrings(raw, stripLeadingBom: header == null);
      if (header == null) {
        header = row;
        const shared = {
          'trip_id',
          'route_id',
          'stop_id',
          'service_id',
          'agency_id',
          'parent_station',
          'stop_sequence',
          'arrival_time',
          'departure_time',
        };
        sharedColumns = [
          for (var i = 0; i < row.length; i++)
            if (shared.contains(row[i])) i,
        ];
        return;
      }
      rowIndex++;
      if (maximumRecords != null && rowIndex > maximumRecords) {
        throw const TransitResourceLimit(
          message: 'This timetable exceeds the stop-time memory budget.',
        );
      }
      for (final i in sharedColumns) {
        if (i < row.length) {
          final value = row[i];
          row[i] = interned[value] ?? value;
          if (interned.length < 100000) {
            interned.putIfAbsent(value, () => value);
          }
        }
      }
      try {
        final record = parseRow(header!, row);
        if (retainRecords) records.add(record);
      } catch (e, st) {
        if (strict) rethrow;
        safeLogWarning('Skipping malformed $fileLabel row #$rowIndex: $e\n$st');
      }
    }),
  );
  try {
    const chunkSize = 64 * 1024;
    for (var offset = 0; offset < csv.length; offset += chunkSize) {
      sink.add(
        csv.substring(offset, (offset + chunkSize).clamp(0, csv.length)),
      );
    }
    sink.close();
  } catch (e, st) {
    if (strict) rethrow;
    safeLogWarning('Failed to parse $fileLabel: $e\n$st');
    return [];
  }
  return records;
}

class _CsvRowSink implements Sink<List<dynamic>> {
  _CsvRowSink(this.onRow);
  final void Function(List<dynamic>) onRow;
  @override
  void add(List<dynamic> row) => onRow(row);
  @override
  void close() {}
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
