part of '../ptv_transit_adapter.dart';

Future<GtfsData> _loadVictoriaGtfs({
  db.AppDatabase? database,
  bool force = false,
  bool requireTimetable = true,
  TransitCancellation? cancellation,
}) => PersistentGtfsStore(database: database).load(
  source: 'ptv:static',
  force: force,
  cancellation: cancellation,
  parse: requireTimetable
      ? parseVictoriaGtfsFromZip
      : _parseVictoriaStopSnapshot,
  requireTimetable: requireTimetable,
  download: (cancellation) async {
    final override = _readEnv('VICTORIA_STATIC_GTFS_URL');
    final uri = Uri.parse(
      override.isNotEmpty ? override : victoriaStaticGtfsUrl,
    );
    final response = await AppHttpClient.getOrThrow(
      uri,
      cancellation: cancellation,
      timeout: const Duration(minutes: 3),
    );
    return GtfsArchiveDownload.fromResponse(response);
  },
);

int? _parseRouteType(String sourceId) {
  final value = sourceId.split(':').last;
  return int.tryParse(value);
}

TransportMode? _transportModeForRouteType(int routeType) {
  switch (routeType) {
    case 0:
      return TransportMode.train;
    case 1:
      return TransportMode.metro;
    case 2:
      return TransportMode.train;
    case 3:
      return TransportMode.bus;
    case 4:
      return TransportMode.ferry;
  }
  return null;
}

enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType _stopRouteTypeEnum(
  int routeType,
) {
  switch (routeType) {
    case 0:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_0;
    case 1:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_1;
    case 2:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_2;
    case 3:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_3;
    case 4:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_4;
    default:
      return enums
          .V3StopsStopIdRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
  }
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
_departureRouteTypeEnum(int routeType) {
  switch (routeType) {
    case 0:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_0;
    case 1:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_1;
    case 2:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_2;
    case 3:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_3;
    case 4:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_4;
    default:
      return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
          .swaggerGeneratedUnknown;
  }
}

String _readEnv(String key) {
  try {
    return dotenv.env[key]?.trim() ?? '';
  } catch (_) {
    return '';
  }
}

GtfsData _parseVictoriaStopSnapshot(Uint8List bytes) =>
    parseVictoriaGtfsFromZip(bytes, stopsOnly: true);
