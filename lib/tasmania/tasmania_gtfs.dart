import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

const tasmaniaGtfsUrl =
    'https://www.transport.tas.gov.au/__data/assets/file/0011/557615/tas_gtfs.zip';

TransitRegionServices buildTasmaniaRegionServices({db.AppDatabase? database}) {
  return buildPublicGtfsRegionServices(
    config: const PublicGtfsProviderConfig(
      region: TransitRegion.tasmania,
      provider: TransitProviderId.tasmaniaPublicTransport,
      attributionName: 'Tasmanian Public Transport',
      attributionUrl:
          'https://www.transport.tas.gov.au/public_transport/gtfs-data',
      feeds: [
        PublicGtfsFeedConfig(
          sourceId: TransitSourceId('tas:state'),
          label: 'Tasmania',
          url: tasmaniaGtfsUrl,
        ),
      ],
    ),
    database: database,
  );
}
