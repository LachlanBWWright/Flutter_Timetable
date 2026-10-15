import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/south_australia/adelaide_metro/adelaide_metro_endpoints.dart';
import 'package:lbww_flutter/south_australia/generated/adelaidemetro_gtfsr.pb.dart'
    as sa_pb;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:protobuf/protobuf.dart';

part 'adelaide_metro/stop_repositories.dart';
part 'adelaide_metro/departure_repository.dart';
part 'adelaide_metro/realtime_repository.dart';

TransitRegionServices buildAdelaideMetroRegionServices({
  db.AppDatabase? database,
}) {
  final timetable = AdelaideMetroDepartureRepository();
  return TransitRegionServices(
    region: TransitRegion.southAustralia,
    provider: TransitProviderId.adelaideMetro,
    stops: AdelaideMetroStopRepository(database: database),
    staticGtfs: AdelaideMetroStaticGtfsRepository(database: database),
    realtime: const AdelaideMetroRealtimeRepository(),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: TransitRegion.southAustralia,
      provider: TransitProviderId.adelaideMetro,
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
