import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/queensland/translink/translink.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/cache/feed_freshness.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

part 'translink/stop_repository.dart';
part 'translink/static_gtfs_repository.dart';
part 'translink/departure_repository.dart';
part 'translink/realtime_repository.dart';
part 'translink/adapter_helpers.dart';

TransitRegionServices buildTranslinkRegionServices({db.AppDatabase? database}) {
  final timetable = TranslinkDepartureRepository();
  return TransitRegionServices(
    region: TransitRegion.queensland,
    provider: TransitProviderId.translink,
    stops: TranslinkStopRepository(database: database),
    staticGtfs: TranslinkStaticGtfsRepository(database: database),
    realtime: const TranslinkRealtimeRepository(),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      loadData: (sourceId) =>
          timetable.loadFeed(_feedIdFromSource(sourceId.value)),
    ),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.translink,
      name: 'Queensland TransLink GTFS',
      licenseName: 'Queensland Open Data terms',
      url:
          'https://www.data.qld.gov.au/organization/transport-and-main-roads?q=GTFS',
    ),
  );
}
