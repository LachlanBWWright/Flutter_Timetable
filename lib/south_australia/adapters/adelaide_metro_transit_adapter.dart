import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
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

class AdelaideMetroStopRepository implements StopRepository {
  const AdelaideMetroStopRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final rows = await _database.getStopsById(stop.stopId);
    final match = rows
        .where((row) => row.endpoint == stop.sourceId.value)
        .firstOrNull;
    return match == null ? null : _mapStop(match);
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final rows = await _database.getAllStops();
    return rows
        .where((row) => row.endpoint.startsWith('sa:'))
        .where((row) => row.stopName.toLowerCase().contains(query))
        .take(request.limit)
        .map(_mapStop)
        .toList(growable: false);
  }

  TransitStop _mapStop(db.Stop row) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.southAustralia,
        provider: TransitProviderId.adelaideMetro,
        sourceId: TransitSourceId(row.endpoint),
        stopId: row.stopId,
      ),
      name: row.stopName,
      latitude: row.stopLat,
      longitude: row.stopLon,
      stopCode: row.stopCode,
      platformCode: row.platformCode,
      description: row.stopDesc,
    );
  }
}

class AdelaideMetroStaticGtfsRepository implements StaticGtfsRepository {
  const AdelaideMetroStaticGtfsRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    yield const StaticImportProgress(
      sourceId: TransitSourceId('sa:static'),
      completed: 0,
      total: 1,
      message: 'Downloading Adelaide Metro static GTFS…',
    );
    final response = await AppHttpClient.get(
      Uri.parse(adelaideMetroStaticGtfsUrl),
    );
    if (response == null || response.statusCode != 200) {
      yield const StaticImportProgress(
        sourceId: TransitSourceId('sa:static'),
        completed: 0,
        total: 1,
        message: 'Failed to download Adelaide Metro GTFS.',
        error: 'The public Adelaide Metro feed was unavailable.',
      );
      return;
    }
    try {
      final stops = parseStopsOnlyFromZipBytes(
        Uint8List.fromList(response.bodyBytes),
      );
      for (final stop in stops) {
        await _database.insertStop(
          db.StopsCompanion.insert(
            stopId: stop.stopId,
            stopName: stop.stopName,
            endpoint: 'sa:static',
            stopCode: Value(stop.stopCode),
            stopDesc: Value(stop.stopDesc),
            stopLat: Value(stop.stopLat),
            stopLon: Value(stop.stopLon),
            platformCode: Value(stop.platformCode),
            wheelchairBoarding: Value(stop.wheelchairBoarding),
            parentStation: Value(stop.parentStation),
          ),
        );
      }
      yield StaticImportProgress(
        sourceId: const TransitSourceId('sa:static'),
        completed: 1,
        total: 1,
        message: 'Imported ${stops.length} Adelaide Metro stops.',
      );
    } catch (error, stackTrace) {
      safeLogWarning(
        'Adelaide Metro static import failed: $error\n$stackTrace',
      );
      yield const StaticImportProgress(
        sourceId: TransitSourceId('sa:static'),
        completed: 0,
        total: 1,
        message: 'Failed to parse Adelaide Metro GTFS.',
        error: 'The public Adelaide Metro feed could not be parsed.',
      );
    }
  }
}

class AdelaideMetroDepartureRepository implements DepartureRepository {
  final Future<GtfsData> Function() _loadData;

  AdelaideMetroDepartureRepository({Future<GtfsData> Function()? loadData})
    : _loadData = loadData ?? _loadAdelaideMetroGtfs;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final data = await _loadData();
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
                          region: TransitRegion.southAustralia,
                          provider: TransitProviderId.adelaideMetro,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _modeFromRouteType(route.routeType),
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

class AdelaideMetroRealtimeRepository implements RealtimeRepository {
  const AdelaideMetroRealtimeRepository();

  static final _extensionRegistry = _buildExtensionRegistry();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(adelaideMetroServiceAlertsUrl);
    final alerts = (feed?.entity ?? const <sa_pb.FeedEntity>[])
        .where((entity) => entity.hasAlert())
        .map(
          (entity) => TransitAlert(
            id: entity.id,
            title: entity.alert.headerText.translation.isNotEmpty
                ? entity.alert.headerText.translation.first.text
                : 'Adelaide Metro alert',
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
    final feed = await _fetchFeed(adelaideMetroTripUpdatesUrl);
    final updates = (feed?.entity ?? const <sa_pb.FeedEntity>[])
        .where((entity) => entity.hasTripUpdate())
        .map(
          (entity) => TransitTripUpdate(
            tripId: entity.tripUpdate.trip.tripId,
            stop:
                entity.tripUpdate.stopTimeUpdate.isNotEmpty &&
                    entity.tripUpdate.stopTimeUpdate.first.hasStopId()
                ? TransitStopRef(
                    region: TransitRegion.southAustralia,
                    provider: TransitProviderId.adelaideMetro,
                    sourceId: const TransitSourceId('sa:adelaide'),
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
    final feed = await _fetchFeed(adelaideMetroVehiclePositionsUrl);
    final vehicles = (feed?.entity ?? const <sa_pb.FeedEntity>[])
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

  Future<sa_pb.FeedMessage?> _fetchFeed(String url) async {
    final response = await AppHttpClient.get(
      Uri.parse(url),
      headers: const {'Accept': 'application/x-google-protobuf'},
    );
    if (response == null || response.statusCode != 200) {
      safeLogWarning(
        'Adelaide Metro realtime feed unavailable: ${response?.statusCode ?? 'network error'}',
      );
      return null;
    }
    try {
      return sa_pb.FeedMessage.fromBuffer(
        response.bodyBytes,
        _extensionRegistry,
      );
    } catch (error, stackTrace) {
      safeLogWarning(
        'Adelaide Metro realtime decode failed: $error\n$stackTrace',
      );
      return null;
    }
  }
}

ExtensionRegistry _buildExtensionRegistry() {
  final registry = ExtensionRegistry();
  sa_pb.Adelaidemetro_gtfsr.registerAllExtensions(registry);
  return registry;
}

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

Future<GtfsData>? _adelaideMetroGtfs;

Future<GtfsData> _loadAdelaideMetroGtfs() => _adelaideMetroGtfs ??= () async {
  final response = await AppHttpClient.get(
    Uri.parse(adelaideMetroStaticGtfsUrl),
  );
  if (response == null || response.statusCode != 200) {
    return _emptyGtfsData();
  }
  try {
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    final files = <String, String>{};
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.txt')) {
        files[file.name] = utf8.decode(file.content as List<int>);
      }
    }
    return parseGtfsFiles(files);
  } catch (error, stackTrace) {
    safeLogWarning('Adelaide Metro GTFS parse failed: $error\n$stackTrace');
    return _emptyGtfsData();
  }
}();

GtfsData _emptyGtfsData() => GtfsData(
  agencies: const [],
  calendars: const [],
  calendarDates: const [],
  routes: const [],
  stops: const [],
  stopTimes: const [],
  trips: const [],
  shapes: const [],
  notes: const [],
);

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final date =
      '${moment.year.toString().padLeft(4, '0')}'
      '${moment.month.toString().padLeft(2, '0')}'
      '${moment.day.toString().padLeft(2, '0')}';
  final services = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final active = [
      calendar.monday,
      calendar.tuesday,
      calendar.wednesday,
      calendar.thursday,
      calendar.friday,
      calendar.saturday,
      calendar.sunday,
    ][moment.weekday - 1];
    if (active == '1') services.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates.where(
    (item) => item.date == date,
  )) {
    if (exception.exceptionType == '1') services.add(exception.serviceId);
    if (exception.exceptionType == '2') services.remove(exception.serviceId);
  }
  return services;
}

DateTime? _gtfsTimeToDateTime(DateTime date, String value) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length != 3 || parts.any((part) => part == null)) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    parts[0]! % 24,
    parts[1]!,
    parts[2]!,
  ).add(Duration(days: parts[0]! ~/ 24));
}

TransportMode? _modeFromRouteType(String routeType) {
  switch (routeType) {
    case '0':
      return TransportMode.lightrail;
    case '1':
      return TransportMode.metro;
    case '2':
      return TransportMode.train;
    case '3':
      return TransportMode.bus;
    case '4':
      return TransportMode.ferry;
    default:
      return null;
  }
}
