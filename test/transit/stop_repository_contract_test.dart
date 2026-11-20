import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/nsw/adapters/tfnsw_transit_adapter.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';

void main() {
  test(
    'all seven stop adapters isolate sources and reject foreign identities',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final adapters =
          <(TransitRegion, TransitProviderId, String, StopRepository)>[
            (
              TransitRegion.nsw,
              TransitProviderId.tfnsw,
              'sydneytrains',
              TfnswStopRepository(database: database),
            ),
            (
              TransitRegion.victoria,
              TransitProviderId.ptv,
              'ptv:static',
              buildPtvRegionServices(database: database).stops,
            ),
            (
              TransitRegion.queensland,
              TransitProviderId.translink,
              'qld:SEQ',
              buildTranslinkRegionServices(database: database).stops,
            ),
            (
              TransitRegion.southAustralia,
              TransitProviderId.adelaideMetro,
              'sa:static',
              buildAdelaideMetroRegionServices(database: database).stops,
            ),
            (
              TransitRegion.tasmania,
              TransitProviderId.tasmaniaPublicTransport,
              'tas:state',
              buildTasmaniaRegionServices(database: database).stops,
            ),
            (
              TransitRegion.northernTerritory,
              TransitProviderId.ntBus,
              'nt:darwin',
              buildNorthernTerritoryRegionServices(database: database).stops,
            ),
            (
              TransitRegion.westernAustralia,
              TransitProviderId.transperth,
              'wa:transperth',
              buildWesternAustraliaRegionServices(database: database).stops,
            ),
          ];
      for (final (_, _, source, _) in adapters) {
        await database.insertStop(
          db.StopsCompanion.insert(
            endpoint: source,
            stopId: 'shared',
            stopName: 'Shared Stop',
          ),
        );
      }
      for (final (_, _, ownSource, repository) in adapters) {
        if (repository is! StaticBackedStopRepository) continue;
        for (final source in repository.sources) {
          if (source.value != ownSource) {
            await database.insertStop(
              db.StopsCompanion.insert(
                endpoint: source.value,
                stopId: 'unused',
                stopName: 'Unused',
              ),
            );
          }
          await database.markStaticCacheBuildFinished(
            source.value,
            stopsUpdated: true,
            lineMembershipsUpdated: false,
          );
        }
      }
      for (final (region, provider, source, repository) in adapters) {
        final allMatches = await repository.searchStops(
          const StopSearchRequest(query: 'Shared'),
        );
        expect(allMatches.map((stop) => stop.ref.sourceId.value), [
          source,
        ], reason: '${region.name}: search isolation');
        final matches = await repository.searchStops(
          const StopSearchRequest(query: 'Shared', limit: 1),
        );
        expect(matches, hasLength(1), reason: region.name);
        expect(matches.single.ref.sourceId.value, source, reason: region.name);
        final own = TransitStopRef(
          region: region,
          provider: provider,
          sourceId: TransitSourceId(source),
          stopId: 'shared',
        );
        expect(
          (await repository.getStop(own))?.ref.storageKey,
          own.storageKey,
          reason: region.name,
        );
        final other = adapters.firstWhere((entry) => entry.$1 != region);
        expect(
          await repository.getStop(
            TransitStopRef(
              region: other.$1,
              provider: provider,
              sourceId: own.sourceId,
              stopId: 'shared',
            ),
          ),
          isNull,
          reason: '${region.name}: foreign region',
        );
        expect(
          await repository.getStop(
            TransitStopRef(
              region: region,
              provider: other.$2,
              sourceId: own.sourceId,
              stopId: 'shared',
            ),
          ),
          isNull,
          reason: '${region.name}: foreign provider',
        );
        expect(
          await repository.getStop(
            TransitStopRef(
              region: region,
              provider: provider,
              sourceId: TransitSourceId(other.$3),
              stopId: 'shared',
            ),
          ),
          isNull,
          reason: '${region.name}: foreign source',
        );
        expect(
          await repository.searchStops(const StopSearchRequest(query: '  ')),
          isEmpty,
          reason: '${region.name}: blank query',
        );
      }
    },
  );
}
