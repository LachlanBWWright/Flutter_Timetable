import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
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

class PtvStopRepository implements StopRepository {
  PtvStopRepository({PtvSignedClient? signedClient, db.AppDatabase? database})
    : _signedClient = signedClient ?? PtvSignedClient(),
      _database = database;

  final PtvSignedClient _signedClient;
  final db.AppDatabase? _database;

  db.AppDatabase get database => _database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    if (stop.sourceId.value == 'ptv:static') {
      final rows = await database.getStopsById(stop.stopId);
      final row = rows
          .where((item) => item.endpoint == 'ptv:static')
          .firstOrNull;
      if (row == null) return null;
      return _mapDatabaseStop(row);
    }
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
    if (!_signedClient.isConfigured) {
      final rows = await database.getAllStops();
      final query = request.query.trim().toLowerCase();
      return rows
          .where((row) => row.endpoint == 'ptv:static')
          .where((row) => row.stopName.toLowerCase().contains(query))
          .take(request.limit)
          .map(_mapDatabaseStop)
          .toList(growable: false);
    }
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

  TransitStop _mapDatabaseStop(db.Stop row) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.victoria,
        provider: TransitProviderId.ptv,
        sourceId: const TransitSourceId('ptv:static'),
        stopId: row.stopId,
      ),
      name: row.stopName,
      mode: null,
      latitude: row.stopLat,
      longitude: row.stopLon,
      stopCode: row.stopCode,
      platformCode: row.platformCode,
      description: row.stopDesc,
    );
  }
}

class PtvDepartureRepository implements DepartureRepository {
  PtvDepartureRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    if (request.stop.sourceId.value == 'ptv:static') {
      return _getStaticDepartures(request);
    }
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

  Future<List<TransitDeparture>> _getStaticDepartures(
    DepartureRequest request,
  ) async {
    final data = await _loadVictoriaGtfs();
    final now = request.when ?? DateTime.now();
    final activeServices = _activeServiceIds(data, now);
    final trips = {for (final trip in data.trips) trip.tripId: trip};
    final routes = {for (final route in data.routes) route.routeId: route};
    final departures =
        data.stopTimes
            .where((time) => time.stopId == request.stop.stopId)
            .where(
              (time) => activeServices.contains(trips[time.tripId]?.serviceId),
            )
            .map((time) {
              final trip = trips[time.tripId];
              final route = trip == null ? null : routes[trip.routeId];
              final planned = _gtfsTimeToDateTime(now, time.departureTime);
              return TransitDeparture(
                stop: request.stop,
                route: route == null
                    ? null
                    : TransitRoute(
                        ref: TransitRouteRef(
                          region: TransitRegion.victoria,
                          provider: TransitProviderId.ptv,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _transportModeForRouteType(
                          int.tryParse(route.routeType) ?? -1,
                        ),
                      ),
                tripId: time.tripId,
                destinationName: trip?.tripHeadsign,
                plannedTime: planned,
                estimatedTime: planned,
              );
            })
            .where((departure) => departure.plannedTime != null)
            .where(
              (departure) => !departure.plannedTime!.isBefore(
                now.subtract(const Duration(minutes: 1)),
              ),
            )
            .toList(growable: false)
          ..sort(
            (left, right) => left.plannedTime!.compareTo(right.plannedTime!),
          );
    return departures.take(20).toList(growable: false);
  }
}

class PtvDisruptionRepository implements DisruptionRepository {
  PtvDisruptionRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitAlert>> getDisruptions(DisruptionRequest request) async {
    if (!_signedClient.isConfigured) {
      // The legacy signed PTV disruption API is not required for the current
      // Open Data integration. Metro and tram publish service alerts through
      // GTFS-Realtime; use those feeds when legacy credentials are absent.
      final alerts = <TransitAlert>[];
      const realtime = VictoriaRealtimeRepository();
      for (final feed in victoriaRealtimeFeedSets) {
        if (feed.alertsUrl == null) continue;
        try {
          final snapshot = await realtime.getAlerts(
            RealtimeRequest(sourceId: TransitSourceId('ptv:${feed.id}')),
          );
          alerts.addAll(snapshot.items);
        } catch (error, stackTrace) {
          safeLogWarning(
            'Victoria ${feed.id} disruption feed unavailable: '
            '$error\n$stackTrace',
          );
        }
      }
      return alerts;
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
  VictoriaStaticGtfsRepository({
    PtvCredentials? credentials,
    db.AppDatabase? database,
  }) : _credentials = credentials ?? loadPtvCredentials(),
       _database = database;

  final PtvCredentials _credentials;
  final db.AppDatabase? _database;

  db.AppDatabase get database => _database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final url = _readEnv('VICTORIA_STATIC_GTFS_URL').isNotEmpty
        ? _readEnv('VICTORIA_STATIC_GTFS_URL')
        : victoriaStaticGtfsUrl;
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
    final stops = parseVictoriaStopsFromZip(
      Uint8List.fromList(response.bodyBytes),
    );
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
    final feedSet = _feedSet(request.sourceId);
    final legacyUrl = _readEnv('VICTORIA_GTFS_RT_ALERTS_URL');
    final url = legacyUrl.isNotEmpty ? legacyUrl : feedSet.alertsUrl;
    if (url == null) {
      return RealtimeSnapshot(items: const [], fetchedAt: DateTime.now());
    }
    final feed = await _fetchFeed(url);
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
    final legacyUrl = _readEnv('VICTORIA_GTFS_RT_TRIP_UPDATES_URL');
    final feed = await _fetchFeed(
      legacyUrl.isNotEmpty
          ? legacyUrl
          : _feedSet(request.sourceId).tripUpdatesUrl,
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
                    sourceId: TransitSourceId(
                      'ptv:${_feedSet(request.sourceId).id}',
                    ),
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
    final legacyUrl = _readEnv('VICTORIA_GTFS_RT_VEHICLES_URL');
    final feed = await _fetchFeed(
      legacyUrl.isNotEmpty
          ? legacyUrl
          : _feedSet(request.sourceId).vehiclePositionsUrl,
    );
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
    final uri = tryParseUriValue(url);
    final apiKey = _readEnv('VICTORIA_OPEN_DATA_API_KEY');
    final response = uri == null
        ? null
        : await AppHttpClient.get(
            uri,
            headers: {
              'Accept': 'application/x-protobuf',
              if (apiKey.isNotEmpty) 'KeyID': apiKey,
            },
          );
    if (response == null || response.statusCode != 200) {
      throw const ProviderUnavailable(
        message: 'Failed to fetch Victoria realtime feed.',
      );
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  }

  VictoriaRealtimeFeedSet _feedSet(TransitSourceId? sourceId) {
    final id = sourceId?.value.split(':').last ?? 'metro';
    final feed = victoriaRealtimeFeedSetById(id);
    if (feed == null) {
      throw UnsupportedCapability(
        message: 'Unknown Victoria realtime source: $id.',
      );
    }
    return feed;
  }
}

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

Future<GtfsData>? _victoriaGtfs;

Future<GtfsData> _loadVictoriaGtfs() => _victoriaGtfs ??= () async {
  final override = _readEnv('VICTORIA_STATIC_GTFS_URL');
  final uri = Uri.parse(override.isNotEmpty ? override : victoriaStaticGtfsUrl);
  final response = await AppHttpClient.get(uri);
  if (response == null || response.statusCode != 200) {
    throw const ProviderUnavailable(
      message: 'Failed to download Victoria GTFS for journey planning.',
    );
  }
  return parseVictoriaGtfsFromZip(Uint8List.fromList(response.bodyBytes));
}();

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

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final date =
      '${moment.year.toString().padLeft(4, '0')}'
      '${moment.month.toString().padLeft(2, '0')}'
      '${moment.day.toString().padLeft(2, '0')}';
  final active = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final enabled = switch (moment.weekday) {
      DateTime.monday => calendar.monday == '1',
      DateTime.tuesday => calendar.tuesday == '1',
      DateTime.wednesday => calendar.wednesday == '1',
      DateTime.thursday => calendar.thursday == '1',
      DateTime.friday => calendar.friday == '1',
      DateTime.saturday => calendar.saturday == '1',
      DateTime.sunday => calendar.sunday == '1',
      _ => false,
    };
    if (enabled) active.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates) {
    if (exception.date != date) continue;
    if (exception.exceptionType == '1') {
      active.add(exception.serviceId);
    } else if (exception.exceptionType == '2') {
      active.remove(exception.serviceId);
    }
  }
  return active;
}

DateTime? _gtfsTimeToDateTime(DateTime date, String value) {
  final parts = value.split(':');
  if (parts.length != 3) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  final second = int.tryParse(parts[2]);
  if (hour == null || minute == null || second == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).add(Duration(hours: hour, minutes: minute, seconds: second));
}
