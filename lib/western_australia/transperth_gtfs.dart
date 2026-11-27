import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

const transperthGtfsUrl =
    'https://www.transperth.wa.gov.au/LinkClick.aspx?link=%2FTimetablePDFs%2FGoogleTransit%2FProduction%2Fgoogle_transit.zip&mid=1470&portalid=0&tabid=267';

TransitRegionServices buildWesternAustraliaRegionServices({
  db.AppDatabase? database,
}) {
  return buildPublicGtfsRegionServices(
    config: const PublicGtfsProviderConfig(
      region: TransitRegion.westernAustralia,
      provider: TransitProviderId.transperth,
      attributionName: 'Transperth',
      attributionUrl:
          'https://www.transperth.wa.gov.au/About/Spatial-Data-Access',
      feeds: [
        PublicGtfsFeedConfig(
          sourceId: TransitSourceId('wa:transperth'),
          label: 'Transperth',
          url: transperthGtfsUrl,
        ),
      ],
    ),
    database: database,
  );
}
