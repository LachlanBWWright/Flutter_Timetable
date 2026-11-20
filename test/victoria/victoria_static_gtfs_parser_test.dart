import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_feed_validation.dart';
import 'package:lbww_flutter/victoria/services/victoria_static_gtfs_parser.dart';

void main() {
  test('mode archives may reuse timetable IDs while sharing an interchange', () {
    final outer = Archive();
    for (final mode in ['0', '4']) {
      final files = {
        'stops.txt':
            'stop_id,stop_name,stop_lat,stop_lon\nA,Interchange,-37,145\n',
        'routes.txt':
            'route_id,route_short_name,route_long_name,route_type\nR,1,Route,$mode\n',
        'trips.txt': 'route_id,service_id,trip_id\nR,S,T\n',
        'calendar_dates.txt': 'service_id,date,exception_type\nS,20261106,1\n',
        'stop_times.txt': 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,10:00:00,10:00:00,A,1\n',
      };
      final archive = Archive();
      files.forEach(
        (name, text) => archive.addFile(ArchiveFile.string(name, text)),
      );
      final nested = ZipEncoder().encode(archive);
      outer.addFile(
        ArchiveFile('$mode/google_transit.zip', nested.length, nested),
      );
    }
    final data = parseVictoriaGtfsFromZip(
      Uint8List.fromList(ZipEncoder().encode(outer)),
    );
    validateGtfsFeed(data);
    expect(data.trips.map((t) => t.tripId).toSet(), hasLength(2));
    expect(data.stops.single.stopId, 'A');
    expect(deriveGtfsStopModes(data)['A'], {
      TransportMode.lightrail,
      TransportMode.ferry,
    });
  });

  test('parses stops from nested mode archives', () {
    final modeArchive = Archive()
      ..addFile(
        ArchiveFile.string(
          'stops.txt',
          'stop_id,stop_name,stop_lat,stop_lon\n1,Flinders Street,-37.8183,144.9671\n',
        ),
      );
    final nestedBytes = ZipEncoder().encode(modeArchive);
    final outerArchive = Archive()
      ..addFile(
        ArchiveFile('2/google_transit.zip', nestedBytes.length, nestedBytes),
      );
    final bytes = Uint8List.fromList(ZipEncoder().encode(outerArchive));

    final stops = parseVictoriaStopsFromZip(bytes);

    expect(stops, hasLength(1));
    expect(stops.single.stopName, 'Flinders Street');
  });
}
