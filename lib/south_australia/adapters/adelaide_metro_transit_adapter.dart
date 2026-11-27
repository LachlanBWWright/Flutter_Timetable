import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart'
    show parseGtfsZipBytes;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart'
    as common_pb;
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/south_australia/adelaide_metro/adelaide_metro_endpoints.dart';
import 'package:lbww_flutter/south_australia/generated/adelaidemetro_gtfsr.pb.dart'
    as sa_pb;
import 'package:lbww_flutter/transit/cache/feed_freshness.dart';
import 'package:lbww_flutter/transit/cache/realtime_query.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_realtime_updates.dart';
import 'package:lbww_flutter/transit/gtfs/persistent_gtfs_store.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:protobuf/protobuf.dart';

part 'adelaide_metro/departure_repository.dart';
part 'adelaide_metro/realtime_repository.dart';
part 'adelaide_metro/stop_repositories.dart';

TransitRegionServices buildAdelaideMetroRegionServices({
  db.AppDatabase? database,
}) {
  final staticData = AdelaideMetroStaticGtfsRepository(database: database);
  final timetable = AdelaideMetroDepartureRepository(database: database);
  return TransitRegionServices(
    region: TransitRegion.southAustralia,
    provider: TransitProviderId.adelaideMetro,
    stops: StaticBackedStopRepository(
      region: TransitRegion.southAustralia,
      provider: TransitProviderId.adelaideMetro,
      sources: const [TransitSourceId('sa:static')],
      cachedStops: AdelaideMetroStopRepository(database: database),
      staticData: staticData,
      database: database,
    ),
    staticGtfs: staticData,
    cancellableTimetableLoader: (_, token) =>
        _loadAdelaideMetroGtfs(database: database, cancellation: token),
    timetableLoader: (_) => timetable._loadData(),
    timetableSources: const [TransitSourceId('sa:static')],
    realtime: const AdelaideMetroRealtimeRepository(),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: TransitRegion.southAustralia,
      provider: TransitProviderId.adelaideMetro,
      loadRealtime: (source) => const AdelaideMetroRealtimeRepository()
          .getTripUpdates(RealtimeRequest(sourceId: source)),
      loadCancellableData: (_, token) =>
          _loadAdelaideMetroGtfs(database: database, cancellation: token),
      loadData: (_) => timetable._loadData(),
    ),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.adelaideMetro,
      name: 'Adelaide Metro',
      licenseName: 'Creative Commons Attribution',
      url: 'https://www.adelaidemetro.com.au/developer-info',
    ),
  );
}
