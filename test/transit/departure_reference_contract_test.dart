import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';

void main() {
  test('all departure adapters reject foreign identities and unknown sources before HTTP or storage', () async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final configured = [
      (buildTranslinkRegionServices(database: database), 'qld:SEQ'),
      (buildPtvRegionServices(database: database), 'ptv:static'),
      (buildAdelaideMetroRegionServices(database: database), 'sa:static'),
      (buildTasmaniaRegionServices(database: database), 'tas:state'),
      (buildNorthernTerritoryRegionServices(database: database), 'nt:darwin'),
      (
        buildWesternAustraliaRegionServices(database: database),
        'wa:transperth',
      ),
    ];
    var requests = 0;
    await http.runWithClient(
      () async {
        for (final (services, source) in configured) {
          for (final ref in [
            TransitStopRef(
              region: TransitRegion.nsw,
              provider: services.provider,
              sourceId: TransitSourceId(source),
              stopId: 'A',
            ),
            TransitStopRef(
              region: services.region,
              provider: TransitProviderId.tfnsw,
              sourceId: TransitSourceId(source),
              stopId: 'A',
            ),
            TransitStopRef(
              region: services.region,
              provider: services.provider,
              sourceId: const TransitSourceId('unknown'),
              stopId: 'A',
            ),
          ]) {
            await expectLater(
              services.departures!.getDepartures(DepartureRequest(stop: ref)),
              throwsA(isA<InvalidJourneyRequest>()),
              reason: services.region.name,
            );
          }
        }
      },
      () => MockClient((_) async {
        requests++;
        return http.Response('Unexpected HTTP', 401);
      }),
    );
    expect(requests, 0);
    expect(await database.select(database.gtfsFeedCaches).get(), isEmpty);
  });
}
