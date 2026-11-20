import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';

void main() {
  test(
    'empty QLD, SA, and Victoria feeds cannot overwrite cached stops',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final regions = [
        (buildTranslinkRegionServices(database: database), 'qld:SEQ'),
        (buildAdelaideMetroRegionServices(database: database), 'sa:static'),
        (buildPtvRegionServices(database: database), 'ptv:static'),
      ];
      final emptyZip = ZipEncoder().encode(Archive());
      await http.runWithClient(() async {
        for (final (region, source) in regions) {
          await database.insertStop(
            db.StopsCompanion.insert(
              endpoint: source,
              stopId: 'existing',
              stopName: 'Cached stop',
            ),
          );
          var failed = false;
          try {
            await for (final progress in region.staticGtfs!.refreshStaticData(
              StaticImportRequest(sourceIds: [TransitSourceId(source)]),
            )) {
              failed |= progress.error != null;
            }
          } on TransitFailure {
            failed = true;
          }
          expect(failed, isTrue, reason: region.region.name);
          expect(
            (await database.getAllStopsForEndpoint(source)).single.stopName,
            'Cached stop',
            reason: region.region.name,
          );
        }
      }, () => MockClient((_) async => http.Response.bytes(emptyZip, 200)));
    },
  );
}
