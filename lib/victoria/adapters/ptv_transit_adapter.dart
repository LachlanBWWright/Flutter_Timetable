import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:lbww_flutter/victoria/services/ptv_credentials.dart';
import 'package:lbww_flutter/victoria/services/ptv_signed_client.dart';
import 'package:lbww_flutter/victoria/services/victoria_gtfs_endpoints.dart';
import 'package:lbww_flutter/victoria/services/victoria_static_gtfs_parser.dart';
import 'package:lbww_flutter/victoria/swagger_generated/ptv_timetable_v3.enums.swagger.dart'
    as enums;
import 'package:lbww_flutter/victoria/swagger_generated/ptv_timetable_v3.swagger.dart';

part 'ptv/stop_repository.dart';
part 'ptv/departure_repository.dart';
part 'ptv/disruption_repository.dart';
part 'ptv/static_gtfs_repository.dart';
part 'ptv/realtime_repository.dart';
part 'ptv/adapter_helpers.dart';

TransitRegionServices buildPtvRegionServices({db.AppDatabase? database}) {
  final hasRealtime =
      _readEnv('VICTORIA_OPEN_DATA_API_KEY').isNotEmpty ||
      (_readEnv('VICTORIA_GTFS_RT_VEHICLES_URL').isNotEmpty &&
          _readEnv('VICTORIA_GTFS_RT_TRIP_UPDATES_URL').isNotEmpty);
  return TransitRegionServices(
    region: TransitRegion.victoria,
    provider: TransitProviderId.ptv,
    stops: PtvStopRepository(database: database),
    staticGtfs: VictoriaStaticGtfsRepository(database: database),
    realtime: hasRealtime ? const VictoriaRealtimeRepository() : null,
    departures: PtvDepartureRepository(),
    journeyPlanner: GtfsJourneyPlanner(
      region: TransitRegion.victoria,
      provider: TransitProviderId.ptv,
      loadData: (_) => _loadVictoriaGtfs(),
      requiresSameSource: false,
    ),
    disruptions: PtvDisruptionRepository(),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.ptv,
      name: 'Public Transport Victoria',
      licenseName: 'PTV API terms',
      url:
          'https://www.ptv.vic.gov.au/footer/data-and-reporting/datasets/ptv-timetable-api/',
    ),
  );
}
