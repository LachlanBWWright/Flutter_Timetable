import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';

import '../../transit/errors/transit_failure.dart';
import '../../transit/runtime/transit_resource_budget.dart';

/// Extracts stops from both ordinary GTFS ZIPs and Transport Victoria's
/// multi-mode bundle, whose mode folders may contain nested GTFS ZIPs.
List<Stop> parseVictoriaStopsFromZip(Uint8List bytes) {
  final stopsById = <String, Stop>{};

  void readArchive(List<int> archiveBytes) {
    final archive = ZipDecoder().decodeBytes(archiveBytes);
    for (final file in archive) {
      if (!file.isFile) continue;
      final lowerName = file.name.toLowerCase();
      final contents = file.content as List<int>;
      if (lowerName.endsWith('stops.txt')) {
        for (final stop in parseStopsCsv(utf8.decode(contents))) {
          stopsById[stop.stopId] = stop;
        }
      } else if (lowerName.endsWith('.zip')) {
        readArchive(contents);
      }
    }
  }

  readArchive(bytes);
  return stopsById.values.toList(growable: false);
}

/// Parses and merges every mode archive in Victoria's bundled GTFS release.
GtfsData parseVictoriaGtfsFromZip(Uint8List bytes, {bool stopsOnly = false}) {
  final feeds = <GtfsData>[];
  const supportedFiles = {
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
  };

  var expanded = 0;
  var remainingStopTimes = TransitResourceBudget.defaultMaximumStopTimes;
  void readArchive(List<int> archiveBytes, String namespace, [int depth = 0]) {
    if (depth > 8) {
      throw const InvalidProviderResponse(
        message: 'GTFS archive nesting is too deep.',
      );
    }
    final groups = <String, Map<String, String>>{};
    for (final file in ZipDecoder().decodeBytes(archiveBytes)) {
      if (!file.isFile) continue;
      final path = file.name.split('/');
      final name = path.last.toLowerCase();
      if (!name.endsWith('.zip') && !supportedFiles.contains(name)) {
        file.clear();
        continue;
      }
      expanded += file.size;
      if (expanded > 2 * 1024 * 1024 * 1024) {
        throw const TransitResourceLimit(
          message: 'Expanded Victoria feed exceeds its budget.',
        );
      }
      final contents = file.content as List<int>;
      if (name.endsWith('.zip')) {
        readArchive(contents, '$namespace/${file.name}', depth + 1);
      } else if (supportedFiles.contains(name)) {
        final folder = path.take(path.length - 1).join('/');
        (groups[folder] ??= {})[name] = utf8.decode(contents);
      }
      file.clear();
    }
    for (final entry in groups.entries) {
      // Stops remain shared across modes. Timetable IDs are local to each
      // archive; qualify them so equal trip/service IDs cannot cross-link.
      final scope = namespace.isEmpty && entry.key.isEmpty
          ? ''
          : '$namespace/${entry.key}';
      final data = stopsOnly
          ? parseGtfsStopFiles(entry.value, namespace: scope)
          : parseGtfsFiles(
              entry.value,
              namespace: scope,
              maximumStopTimes: remainingStopTimes,
            );
      remainingStopTimes -= data.stopTimes.length;
      feeds.add(data);
    }
  }

  readArchive(bytes, '');
  if (stopsOnly) {
    return GtfsData(
      agencies: [],
      calendars: [],
      calendarDates: [],
      routes: [],
      stopTimes: [],
      trips: [],
      shapes: [],
      notes: [],
      isStopSnapshot: true,
      stops: {
        for (final feed in feeds)
          for (final stop in feed.stops) stop.stopId: stop,
      }.values.toList(),
      stopModes: {
        for (final id in feeds.expand((f) => f.stopModes.keys).toSet())
          id: {for (final feed in feeds) ...?feed.stopModes[id]},
      },
    );
  }
  return GtfsData(
    frequencies: feeds.expand((feed) => feed.frequencies).toList(),
    transfers: feeds.expand((feed) => feed.transfers).toList(),
    pathways: feeds.expand((feed) => feed.pathways).toList(),
    agencies: feeds.expand((feed) => feed.agencies).toList(),
    calendars: feeds.expand((feed) => feed.calendars).toList(),
    calendarDates: feeds.expand((feed) => feed.calendarDates).toList(),
    routes: feeds.expand((feed) => feed.routes).toList(),
    stops: {
      for (final stop in feeds.expand((feed) => feed.stops).toList())
        stop.stopId: stop,
    }.values.toList(),
    stopTimes: feeds.expand((feed) => feed.stopTimes).toList(),
    trips: feeds.expand((feed) => feed.trips).toList(),
    shapes: feeds.expand((feed) => feed.shapes).toList(),
    notes: feeds.expand((feed) => feed.notes).toList(),
  );
}
