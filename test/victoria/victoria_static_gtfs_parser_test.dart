import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/victoria/services/victoria_static_gtfs_parser.dart';

void main() {
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
