part of '../timetable_data.dart';

List<int>? _archiveFileContent(dynamic content) {
  if (content is List<int>) {
    return content;
  }
  return null;
}

GtfsData parseGtfsFiles(
  Map<String, String> files, {
  String namespace = '',
  int maximumStopTimes = TransitResourceBudget.defaultMaximumStopTimes,
}) {
  final qualifiedValues = <String, String>{};
  List<T> read<T>(
    String csv,
    String label,
    T Function(List<String>, List<String>) parser,
  ) => _parseCsvRecords(
    csv,
    fileLabel: label,
    strict: true,
    maximumRecords: label == 'stop_times.txt' ? maximumStopTimes : null,
    shouldParseNumbers: false,
    parseRow: (header, row) {
      if (namespace.isNotEmpty) {
        const qualified = {
          'route_id',
          'service_id',
          'trip_id',
          'agency_id',
          'shape_id',
          'block_id',
          'note_id',
          'from_route_id',
          'to_route_id',
          'from_trip_id',
          'to_trip_id',
          'pathway_id',
        };
        for (
          var index = 0;
          index < header.length && index < row.length;
          index++
        ) {
          if (qualified.contains(header[index]) && row[index].isNotEmpty) {
            row[index] = qualifiedValues.putIfAbsent(
              row[index],
              () => '$namespace:${row[index]}',
            );
          }
        }
      }
      return parser(header, row);
    },
  );
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
    frequencies: _lookupTextFile(files, 'frequencies.txt') == null
        ? []
        : read(
            _lookupTextFile(files, 'frequencies.txt')!,
            'frequencies.txt',
            GtfsFrequency.fromCsv,
          ),
    transfers: _lookupTextFile(files, 'transfers.txt') == null
        ? []
        : read(
            _lookupTextFile(files, 'transfers.txt')!,
            'transfers.txt',
            GtfsTransfer.fromCsv,
          ),
    pathways: _lookupTextFile(files, 'pathways.txt') == null
        ? []
        : read(
            _lookupTextFile(files, 'pathways.txt')!,
            'pathways.txt',
            GtfsPathway.fromCsv,
          ),
    agencies: agencyFile != null
        ? read(agencyFile, 'agency.txt', Agency.fromCsv)
        : [],
    calendars: calendarFile != null
        ? read(calendarFile, 'calendar.txt', Calendar.fromCsv)
        : [],
    calendarDates: calendarDatesFile != null
        ? read(calendarDatesFile, 'calendar_dates.txt', CalendarDate.fromCsv)
        : [],
    routes: routesFile != null
        ? read(routesFile, 'routes.txt', Route.fromCsv)
        : [],
    stops: stopsFile != null ? read(stopsFile, 'stops.txt', Stop.fromCsv) : [],
    stopTimes: stopTimesFile != null
        ? read(stopTimesFile, 'stop_times.txt', StopTime.fromCsv)
        : [],
    trips: tripsFile != null ? read(tripsFile, 'trips.txt', Trip.fromCsv) : [],
    shapes: shapesFile != null
        ? read(shapesFile, 'shapes.txt', Shape.fromCsv)
        : [],
    notes: notesFile != null ? read(notesFile, 'notes.txt', Note.fromCsv) : [],
  );
}

/// Inflate and parse a full GTFS ZIP. Kept top-level for `compute` isolate use.
GtfsData parseGtfsZipBytes(
  Uint8List bytes, {
  bool includeGeometry = true,
  bool stopsOnly = false,
  int maximumStopTimes = TransitResourceBudget.defaultMaximumStopTimes,
}) {
  if (bytes.length > 512 * 1024 * 1024) {
    throw const TransitResourceLimit(message: 'Compressed feed is too large.');
  }
  final archive = ZipDecoder().decodeBytes(bytes);
  const supported = {
    'agency.txt',
    'calendar.txt',
    'calendar_dates.txt',
    'routes.txt',
    'stops.txt',
    'stop_times.txt',
    'trips.txt',
    'frequencies.txt',
    'transfers.txt',
    'pathways.txt',
    'shapes.txt',
    'notes.txt',
  };
  bool reads(ArchiveFile file) {
    final name = file.name.split('/').last.toLowerCase();
    return file.isFile &&
        supported.contains(name) &&
        (includeGeometry || !const ['shapes.txt', 'notes.txt'].contains(name));
  }

  if (archive.where(reads).fold<int>(0, (sum, file) => sum + file.size) >
      2 * 1024 * 1024 * 1024) {
    throw const TransitResourceLimit(message: 'Expanded feed is too large.');
  }
  final csvFiles = <String, String>{};
  for (final file in archive) {
    if (!reads(file)) continue;
    final content = _archiveFileContent(file.content);
    if (content == null) {
      safeLogWarning('Skipping ${file.name}: invalid archive content type');
      continue;
    }
    csvFiles[file.name] = utf8.decode(content);
    file.clear();
  }
  return stopsOnly
      ? parseGtfsStopFiles(csvFiles)
      : parseGtfsFiles(csvFiles, maximumStopTimes: maximumStopTimes);
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
  final exact = files[fileName];
  if (exact != null) return exact;
  final matches = files.entries
      .where((entry) => entry.key.split('/').last.toLowerCase() == fileName)
      .toList();
  if (matches.length > 1) {
    throw InvalidProviderResponse(
      message:
          'Multiple GTFS folders contain $fileName; select an individual feed.',
    );
  }
  return matches.firstOrNull?.value;
}

/// Validate the complete timetable while retaining only searchable stops/modes.
GtfsData parseGtfsStopFiles(
  Map<String, String> files, {
  String namespace = '',
}) {
  final stopTimeCsv = _lookupTextFile(files, 'stop_times.txt') ?? '';
  final metadata = parseGtfsFiles({
    for (final e in files.entries)
      if (e.key.split('/').last.toLowerCase() != 'stop_times.txt')
        e.key: e.value,
  }, namespace: namespace);
  validateGtfsTimetableMetadata(metadata);
  final trips = {for (final t in metadata.trips) t.tripId: t};
  final routes = {
    for (final r in metadata.routes) r.routeId: gtfsRouteMode(r.routeType),
  };
  final parents = {for (final s in metadata.stops) s.stopId: s.parentStation};
  final modes = <String, Set<TransportMode>>{};
  // Compact integer columns preserve unsorted-row validation without retaining
  // a full StopTime object and repeated IDs for every row in every mode.
  final lastByTrip = <String, (int, int)>{};
  final unsorted = <String>{};
  final nativeTrips = {
    for (final id in trips.keys)
      namespace.isEmpty ? id : id.substring(namespace.length + 1): id,
  };
  var rows = 0;
  _parseCsvRecords<Object?>(
    stopTimeCsv,
    fileLabel: 'stop_times.txt',
    strict: true,
    retainRecords: false,
    shouldParseNumbers: false,
    parseRow: (header, row) {
      final time = StopTime.fromCsv(header, row);
      final trip = nativeTrips[time.tripId] ?? time.tripId;
      final sequence = int.tryParse(time.stopSequence);
      final arrival = gtfsTimeSeconds(time.arrivalTime),
          departure = gtfsTimeSeconds(time.departureTime);
      if (!trips.containsKey(trip) ||
          !parents.containsKey(time.stopId) ||
          sequence == null ||
          sequence < 0 ||
          (time.arrivalTime.isNotEmpty && arrival == null) ||
          (time.departureTime.isNotEmpty && departure == null)) {
        throw const InvalidProviderResponse(
          message: 'A stop-time row has invalid references, sequence, or time.',
        );
      }
      final previous = lastByTrip[trip];
      if (previous != null && sequence < previous.$1) unsorted.add(trip);
      if (previous != null && sequence == previous.$1) {
        throw const InvalidProviderResponse(
          message: 'The feed has duplicate stop sequences.',
        );
      }
      if ((arrival != null && departure != null && departure < arrival) ||
          (previous != null &&
              sequence > previous.$1 &&
              ((arrival != null && arrival < previous.$2) ||
                  (departure != null && departure < previous.$2)))) {
        throw const InvalidProviderResponse(
          message: 'Stop times are out of chronological order.',
        );
      }
      if (previous == null || sequence > previous.$1) {
        lastByTrip[trip] = (
          sequence,
          departure ?? arrival ?? previous?.$2 ?? -1,
        );
      }
      final mode = routes[trips[trip]!.routeId];
      String? stop = time.stopId;
      while (mode != null && stop != null && stop.isNotEmpty) {
        (modes[stop] ??= {}).add(mode);
        stop = parents[stop];
      }
      rows++;
      return null;
    },
  );
  if (rows == 0) {
    throw const InvalidProviderResponse(message: 'The feed has no stop times.');
  }
  final chronology = <String, List<int>>{};
  if (unsorted.isNotEmpty) {
    _parseCsvRecords<Object?>(
      stopTimeCsv,
      fileLabel: 'stop_times.txt',
      strict: true,
      retainRecords: false,
      shouldParseNumbers: false,
      parseRow: (header, row) {
        final time = StopTime.fromCsv(header, row),
            trip = nativeTrips[row[header.indexOf('trip_id')]];
        if (trip != null && unsorted.contains(trip)) {
          (chronology[trip] ??= []).addAll([
            int.parse(time.stopSequence),
            gtfsTimeSeconds(time.arrivalTime) ?? -1,
            gtfsTimeSeconds(time.departureTime) ?? -1,
          ]);
        }
        return null;
      },
    );
  }
  for (final values in chronology.values) {
    final ordered = [
      for (var i = 0; i < values.length; i += 3)
        (values[i], values[i + 1], values[i + 2]),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    int? previousSequence;
    var previous = -1;
    for (final (sequence, arrival, departure) in ordered) {
      if (sequence == previousSequence ||
          (arrival >= 0 && previous > arrival) ||
          (arrival >= 0 && departure >= 0 && departure < arrival) ||
          (departure >= 0 && previous > departure)) {
        throw const InvalidProviderResponse(
          message: 'The feed has duplicate sequences or stop times out of chronological order.',
        );
      }
      previousSequence = sequence;
      previous = departure >= 0
          ? departure
          : arrival >= 0
          ? arrival
          : previous;
    }
  }
  return gtfsStopSnapshot(metadata.stops, stopModes: modes);
}
