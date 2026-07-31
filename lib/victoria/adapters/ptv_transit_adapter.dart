import 'package:drift/drift.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:lbww_flutter/victoria/services/ptv_credentials.dart';
import 'package:lbww_flutter/victoria/services/ptv_signed_client.dart';
import 'package:lbww_flutter/victoria/swagger_generated/ptv_timetable_v3.enums.swagger.dart'
    as enums;
import 'package:lbww_flutter/victoria/swagger_generated/ptv_timetable_v3.swagger.dart';

class PtvStopRepository implements StopRepository {
  PtvStopRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    _requireCredentials();
    final routeType = _parseRouteType(stop.sourceId.value);
    final stopId = int.tryParse(stop.stopId);
    if (routeType == null || stopId == null) {
      return null;
    }
    final response = await _signedClient.client
        .v3StopsStopIdRouteTypeRouteTypeGet(
          stopId: stopId,
          routeType: _stopRouteTypeEnum(routeType),
          stopLocation: true,
          stopAccessibility: true,
          stopDisruptions: true,
          devid: _signedClient.developerId,
          signature: _signedClient
              .signatureForPath('/v3/stops/$stopId/route_type/$routeType', {
                'stop_location': 'true',
                'stop_accessibility': 'true',
                'stop_disruptions': 'true',
              }),
        );
    final body = response.body;
    final stopBody = body?.stop;
    if (!response.isSuccessful || stopBody == null) {
      throw const ProviderUnavailable(
        message: 'Failed to load PTV stop details.',
      );
    }
    final gps = stopBody.stopLocation?.gps;
    return TransitStop(
      ref: stop,
      name: stopBody.stopName ?? stop.stopId,
      mode: _transportModeForRouteType(routeType),
      latitude: gps?.latitude,
      longitude: gps?.longitude,
      description: stopBody.stopLandmark ?? stopBody.stationDescription,
    );
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    _requireCredentials();
    final signature = _signedClient.signatureForPath(
      '/v3/search/${Uri.encodeComponent(request.query)}',
      const {
        'include_outlets': 'false',
        'match_stop_by_suburb': 'true',
        'match_route_by_suburb': 'true',
      },
    );
    final response = await _signedClient.client.v3SearchSearchTermGet(
      searchTerm: request.query,
      includeOutlets: false,
      matchStopBySuburb: true,
      matchRouteBySuburb: true,
      devid: _signedClient.developerId,
      signature: signature,
    );
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw const ProviderUnavailable(message: 'Failed to search PTV stops.');
    }
    return (body.stops ?? const <V3ResultStop>[])
        .take(request.limit)
        .map(
          (stop) => TransitStop(
            ref: TransitStopRef(
              region: TransitRegion.victoria,
              provider: TransitProviderId.ptv,
              sourceId: TransitSourceId(
                'ptv:route_type:${stop.routeType ?? 0}',
              ),
              stopId: '${stop.stopId ?? ''}',
            ),
            name: stop.stopName ?? 'PTV stop',
            mode: _transportModeForRouteType(stop.routeType ?? 0),
            latitude: stop.stopLatitude,
            longitude: stop.stopLongitude,
            suburb: stop.stopSuburb,
            description: stop.stopLandmark,
          ),
        )
        .where((stop) => stop.ref.stopId.isNotEmpty)
        .toList(growable: false);
  }

  void _requireCredentials() {
    if (!_signedClient.isConfigured) {
      throw const InvalidCredentials(
        message:
            'PTV credentials are not configured. Set PTV_DEV_ID and PTV_API_KEY.',
      );
    }
  }
}

class PtvDepartureRepository implements DepartureRepository {
  PtvDepartureRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    if (!_signedClient.isConfigured) {
      throw const InvalidCredentials(
        message:
            'PTV credentials are not configured. Set PTV_DEV_ID and PTV_API_KEY.',
      );
    }
    final routeType = _parseRouteType(request.stop.sourceId.value);
    final stopId = int.tryParse(request.stop.stopId);
    if (routeType == null || stopId == null) {
      return const <TransitDeparture>[];
    }
    final response = await _signedClient.client
        .v3DeparturesRouteTypeRouteTypeStopStopIdGet(
          routeType: _departureRouteTypeEnum(routeType),
          stopId: stopId,
          gtfs: true,
          dateUtc: request.when?.toUtc(),
          maxResults: 20,
          includeCancelled: true,
          devid: _signedClient.developerId,
          signature: _signedClient.signatureForPath(
            '/v3/departures/route_type/$routeType/stop/$stopId',
            {
              'gtfs': 'true',
              if (request.when != null)
                'date_utc': request.when!.toUtc().toIso8601String(),
              'max_results': '20',
              'include_cancelled': 'true',
            },
          ),
        );
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw const ProviderUnavailable(
        message: 'Failed to load PTV departures.',
      );
    }
    final routes = body.routes ?? const <String, dynamic>{};
    final runs = body.runs ?? const <String, dynamic>{};
    final directions = body.directions ?? const <String, dynamic>{};
    return (body.departures ?? const <V3Departure>[])
        .map((departure) {
          final routeJson =
              (tryReadMapValue(routes, '${departure.routeId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(routes, departure.routeId?.toString() ?? '')
                  as Map<String, dynamic>?);
          final routeName =
              tryReadStringValue(routeJson, 'route_name') ??
              tryReadStringValue(routeJson, 'route_number') ??
              'Route ${departure.routeId ?? ''}'.trim();
          final routeNumber = tryReadStringValue(routeJson, 'route_number');
          final directionJson =
              (tryReadMapValue(directions, '${departure.directionId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(
                    directions,
                    departure.directionId?.toString() ?? '',
                  )
                  as Map<String, dynamic>?);
          final runJson =
              (tryReadMapValue(runs, '${departure.runId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(runs, departure.runId?.toString() ?? '')
                  as Map<String, dynamic>?);
          return TransitDeparture(
            stop: request.stop,
            route: departure.routeId == null
                ? null
                : TransitRoute(
                    ref: TransitRouteRef(
                      region: TransitRegion.victoria,
                      provider: TransitProviderId.ptv,
                      sourceId: request.stop.sourceId,
                      routeId: '${departure.routeId}',
                    ),
                    name: routeName,
                    shortName: routeNumber,
                    mode: _transportModeForRouteType(routeType),
                  ),
            tripId: departure.runId?.toString(),
            destinationName:
                tryReadStringValue(directionJson, 'direction_name') ??
                tryReadStringValue(runJson, 'destination_name'),
            platform: departure.platformNumber,
            plannedTime: departure.scheduledDepartureUtc?.toLocal(),
            estimatedTime: departure.estimatedDepartureUtc?.toLocal(),
            cancelled: departure.flags?.contains('cancelled') ?? false,
            statusText: departure.departureNote,
          );
        })
        .toList(growable: false);
  }
}

class PtvDisruptionRepository implements DisruptionRepository {
  PtvDisruptionRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitAlert>> getDisruptions(DisruptionRequest request) async {
    if (!_signedClient.isConfigured) {
      throw const InvalidCredentials(
        message:
            'PTV credentials are not configured. Set PTV_DEV_ID and PTV_API_KEY.',
      );
    }
    if (request.stop != null) {
      final stopId = int.tryParse(request.stop!.stopId);
      if (stopId == null) return const <TransitAlert>[];
      final response = await _signedClient.client.v3DisruptionsStopStopIdGet(
        stopId: stopId,
        devid: _signedClient.developerId,
        signature: _signedClient.signatureForPath(
          '/v3/disruptions/stop/$stopId',
          const {},
        ),
      );
      final body = response.body;
      if (!response.isSuccessful || body == null) {
        throw const ProviderUnavailable(
          message: 'Failed to load PTV disruptions.',
        );
      }
      return _flattenDisruptions(body.disruptions);
    }
    final response = await _signedClient.client.v3DisruptionsGet(
      devid: _signedClient.developerId,
      signature: _signedClient.signatureForPath('/v3/disruptions', const {}),
    );
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw const ProviderUnavailable(
        message: 'Failed to load PTV disruptions.',
      );
    }
    return _flattenDisruptions(body.disruptions);
  }

  List<TransitAlert> _flattenDisruptions(V3Disruptions? disruptions) {
    if (disruptions == null) return const <TransitAlert>[];
    final items = <V3Disruption>[
      ...?disruptions.general,
      ...?disruptions.metroTrain,
      ...?disruptions.metroTram,
      ...?disruptions.metroBus,
      ...?disruptions.regionalTrain,
      ...?disruptions.regionalCoach,
      ...?disruptions.regionalBus,
      ...?disruptions.schoolBus,
      ...?disruptions.telebus,
      ...?disruptions.nightBus,
      ...?disruptions.ferry,
      ...?disruptions.interstateTrain,
      ...?disruptions.skybus,
      ...?disruptions.taxi,
    ];
    return items
        .map(
          (item) => TransitAlert(
            id: '${item.disruptionId ?? item.title ?? item.description ?? item.hashCode}',
            title: item.title ?? 'Disruption',
            description: item.description,
            severity: item.disruptionStatus,
          ),
        )
        .toList(growable: false);
  }
}

class VictoriaStaticGtfsRepository implements StaticGtfsRepository {
  VictoriaStaticGtfsRepository({PtvCredentials? credentials})
    : _credentials = credentials ?? loadPtvCredentials();

  final PtvCredentials _credentials;

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final url = _readEnv('VICTORIA_STATIC_GTFS_URL');
    if (url.isEmpty) {
      throw const UnsupportedCapability(
        message:
            'Victoria static GTFS import requires VICTORIA_STATIC_GTFS_URL.',
      );
    }
    yield const StaticImportProgress(
      sourceId: TransitSourceId('ptv:static'),
      completed: 0,
      total: 1,
      message: 'Downloading Victoria static GTFS…',
    );
    final uri = tryParseUriValue(url);
    final response = uri == null ? null : await AppHttpClient.get(uri);
    if (response == null || response.statusCode != 200) {
      throw const ProviderUnavailable(
        message: 'Failed to download Victoria static GTFS.',
      );
    }
    final stops = _parseStopsOnly(Uint8List.fromList(response.bodyBytes));
    final database = db.AppDatabase();
    for (final stop in stops) {
      await database.insertStop(
        db.StopsCompanion.insert(
          stopId: stop.stopId,
          stopName: stop.stopName,
          endpoint: 'ptv:static',
          stopCode: Value(stop.stopCode),
          stopDesc: Value(stop.stopDesc),
          stopLat: Value(stop.stopLat),
          stopLon: Value(stop.stopLon),
          platformCode: Value(stop.platformCode),
          wheelchairBoarding: Value(stop.wheelchairBoarding),
        ),
      );
    }
    yield StaticImportProgress(
      sourceId: const TransitSourceId('ptv:static'),
      completed: 1,
      total: 1,
      message: 'Imported ${stops.length} Victoria stops.',
    );
    final _ = _credentials;
  }
}

class VictoriaRealtimeRepository implements RealtimeRepository {
  const VictoriaRealtimeRepository();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(_readEnv('VICTORIA_GTFS_RT_ALERTS_URL'));
    final alerts = (feed?.entity ?? const <FeedEntity>[])
        .where((entity) => entity.hasAlert())
        .map(
          (entity) => TransitAlert(
            id: entity.id,
            title: entity.alert.headerText.translation.isNotEmpty
                ? entity.alert.headerText.translation.first.text
                : 'Alert',
            description: entity.alert.descriptionText.translation.isNotEmpty
                ? entity.alert.descriptionText.translation.first.text
                : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: alerts, fetchedAt: DateTime.now());
  }

  @override
  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(
      _readEnv('VICTORIA_GTFS_RT_TRIP_UPDATES_URL'),
    );
    final updates = (feed?.entity ?? const <FeedEntity>[])
        .where((entity) => entity.hasTripUpdate())
        .map(
          (entity) => TransitTripUpdate(
            tripId: entity.tripUpdate.trip.tripId,
            stop:
                entity.tripUpdate.stopTimeUpdate.isNotEmpty &&
                    entity.tripUpdate.stopTimeUpdate.first.hasStopId()
                ? TransitStopRef(
                    region: TransitRegion.victoria,
                    provider: TransitProviderId.ptv,
                    sourceId: const TransitSourceId('ptv:realtime'),
                    stopId: entity.tripUpdate.stopTimeUpdate.first.stopId,
                  )
                : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: updates, fetchedAt: DateTime.now());
  }

  @override
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(_readEnv('VICTORIA_GTFS_RT_VEHICLES_URL'));
    final vehicles = (feed?.entity ?? const <FeedEntity>[])
        .where((entity) => entity.hasVehicle())
        .map(
          (entity) => TransitVehicle(
            id: entity.vehicle.vehicle.id,
            tripId: entity.vehicle.trip.tripId,
            latitude: entity.vehicle.position.latitude,
            longitude: entity.vehicle.position.longitude,
            bearing: entity.vehicle.position.hasBearing()
                ? entity.vehicle.position.bearing
                : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: vehicles, fetchedAt: DateTime.now());
  }

  Future<FeedMessage?> _fetchFeed(String url) async {
    if (url.isEmpty) {
      throw const UnsupportedCapability(
        message: 'Victoria GTFS-realtime URLs are not configured.',
      );
    }
    final uri = tryParseUriValue(url);
    final response = uri == null ? null : await AppHttpClient.get(uri);
    if (response == null || response.statusCode != 200) {
      throw const ProviderUnavailable(
        message: 'Failed to fetch Victoria realtime feed.',
      );
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  }
}

TransitRegionServices buildPtvRegionServices() {
  final hasStaticGtfs = _readEnv('VICTORIA_STATIC_GTFS_URL').isNotEmpty;
  final hasRealtime =
      _readEnv('VICTORIA_GTFS_RT_VEHICLES_URL').isNotEmpty &&
      _readEnv('VICTORIA_GTFS_RT_TRIP_UPDATES_URL').isNotEmpty &&
      _readEnv('VICTORIA_GTFS_RT_ALERTS_URL').isNotEmpty;
  return TransitRegionServices(
    region: TransitRegion.victoria,
    provider: TransitProviderId.ptv,
    stops: PtvStopRepository(),
    staticGtfs: hasStaticGtfs ? VictoriaStaticGtfsRepository() : null,
    realtime: hasRealtime ? const VictoriaRealtimeRepository() : null,
    departures: PtvDepartureRepository(),
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

List<gtfs.Stop> _parseStopsOnly(Uint8List bytes) {
  return parseStopsOnlyFromZipBytes(bytes);
}
