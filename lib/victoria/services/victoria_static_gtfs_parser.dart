import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';

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
GtfsData parseVictoriaGtfsFromZip(Uint8List bytes) {
  // Keep one merged buffer per file instead of retaining every mode's decoded
  // String and then creating a second merged copy. Victoria's schedule bundle
  // is large enough for that temporary duplication to exhaust the Flutter
  // test runner (and, on smaller devices, the application).
  final parts = <String, StringBuffer>{};

  const supportedFiles = {
    'agency.txt',
    'calendar.txt',
    'calendar_dates.txt',
    'routes.txt',
    'stops.txt',
    'stop_times.txt',
    'trips.txt',
  };

  void appendCsv(String name, List<int> content) {
    final csv = utf8.decode(content);
    final buffer = parts.putIfAbsent(name, StringBuffer.new);
    if (buffer.isNotEmpty) {
      final firstNewline = csv.indexOf('\n');
      if (firstNewline < 0) return;
      buffer.write(csv.substring(firstNewline + 1));
    } else {
      buffer.write(csv);
    }
    if (!csv.endsWith('\n')) buffer.writeln();
  }

  void readArchive(List<int> archiveBytes) {
    for (final file in ZipDecoder().decodeBytes(archiveBytes)) {
      if (!file.isFile) continue;
      final name = file.name.split('/').last.toLowerCase();
      final contents = file.content as List<int>;
      if (name.endsWith('.zip')) {
        readArchive(contents);
      } else if (supportedFiles.contains(name)) {
        appendCsv(name, contents);
      }
    }
  }

  readArchive(bytes);
  return parseGtfsFiles({
    for (final entry in parts.entries) entry.key: entry.value.toString(),
  });
}
