import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/queensland/translink/translink.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/cache/feed_freshness.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_realtime_updates.dart';
import 'package:lbww_flutter/transit/gtfs/persistent_gtfs_store.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

part 'translink/adapter_helpers.dart';
part 'translink/departure_repository.dart';
part 'translink/realtime_repository.dart';
part 'translink/static_gtfs_repository.dart';
part 'translink/stop_repository.dart';

TransitRegionServices buildTranslinkRegionServices({db.AppDatabase? database}) {
  final staticData = TranslinkStaticGtfsRepository(database: database);
  final timetable = TranslinkDepartureRepository(database: database);
  return TransitRegionServices(
    region: TransitRegion.queensland,
    provider: TransitProviderId.translink,
    stops: StaticBackedStopRepository(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      sources: translinkStaticGtfsFeeds
          .map((feed) => TransitSourceId('qld:${feed.id}'))
          .toList(),
      cachedStops: TranslinkStopRepository(database: database),
      staticData: staticData,
      database: database,
    ),
    staticGtfs: staticData,
    timetableLoader: (source) =>
        timetable.loadFeed(_feedIdFromSource(source.value)),
    cancellableTimetableLoader: (source, token) => timetable.loadFeed(
      _feedIdFromSource(source.value),
      cancellation: token,
    ),
    timetableSources: translinkStaticGtfsFeeds
        .map((feed) => TransitSourceId('qld:${feed.id}'))
        .toList(),
    realtime: const TranslinkRealtimeRepository(),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      loadRealtime: (source) => const TranslinkRealtimeRepository()
          .getTripUpdates(RealtimeRequest(sourceId: source)),
      loadCancellableData: (source, token) => timetable.loadFeed(
        _feedIdFromSource(source.value),
        cancellation: token,
      ),
      loadData: (sourceId) =>
          timetable.loadFeed(_feedIdFromSource(sourceId.value)),
    ),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.translink,
      name: 'Queensland TransLink GTFS',
      licenseName: 'Queensland Open Data terms',
      url: 'https://www.data.qld.gov.au/organization/transport-and-main-roads?q=GTFS',
    ),
  );
}
