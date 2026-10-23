import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

const ntDarwinGtfsUrl =
    'https://dli.nt.gov.au/data-feeds/bus-gtfs/google-transit-darwin.zip?v=0.38.2';
const ntAliceSpringsGtfsUrl =
    'https://dli.nt.gov.au/data-feeds/bus-gtfs/google-transit-alice.zip?v=0.14.0';

TransitRegionServices buildNorthernTerritoryRegionServices({
  db.AppDatabase? database,
}) {
  return buildPublicGtfsRegionServices(
    config: const PublicGtfsProviderConfig(
      region: TransitRegion.northernTerritory,
      provider: TransitProviderId.ntBus,
      attributionName: 'Northern Territory Government',
      attributionUrl:
          'https://dli.nt.gov.au/data/bus-timetable-data-and-geographic-information',
      feeds: [
        PublicGtfsFeedConfig(
          sourceId: TransitSourceId('nt:darwin'),
          label: 'Darwin',
          url: ntDarwinGtfsUrl,
        ),
        PublicGtfsFeedConfig(
          sourceId: TransitSourceId('nt:alice'),
          label: 'Alice Springs',
          url: ntAliceSpringsGtfsUrl,
        ),
      ],
    ),
    database: database,
  );
}
