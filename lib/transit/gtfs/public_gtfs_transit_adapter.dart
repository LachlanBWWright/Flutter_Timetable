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
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

class PublicGtfsFeedConfig {
  const PublicGtfsFeedConfig({
    required this.sourceId,
    required this.label,
    required this.url,
  });

  final TransitSourceId sourceId;
  final String label;
  final String url;
}

class PublicGtfsProviderConfig {
  const PublicGtfsProviderConfig({
    required this.region,
    required this.provider,
    required this.attributionName,
    required this.attributionUrl,
    required this.feeds,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final String attributionName;
  final String attributionUrl;
  final List<PublicGtfsFeedConfig> feeds;
}

TransitRegionServices buildPublicGtfsRegionServices({
  required PublicGtfsProviderConfig config,
  db.AppDatabase? database,
}) {
  final timetable = PublicGtfsDepartureRepository(config: config);
  return TransitRegionServices(
    region: config.region,
    provider: config.provider,
    stops: PublicGtfsStopRepository(config: config, database: database),
    staticGtfs: PublicGtfsStaticRepository(config: config, database: database),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: config.region,
      provider: config.provider,
      loadData: (sourceId) => timetable.loadFeed(sourceId),
    ),
    attribution: TransitProviderAttribution(
      provider: config.provider,
      name: config.attributionName,
      licenseName: 'Creative Commons Attribution 4.0 International',
      url: config.attributionUrl,
    ),
  );
}

class PublicGtfsStopRepository implements StopRepository {
  const PublicGtfsStopRepository({required this.config, this.database});

  final PublicGtfsProviderConfig config;
  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final row = (await _database.getStopsById(stop.stopId))
        .where((candidate) => candidate.endpoint == stop.sourceId.value)
        .firstOrNull;
    return row == null ? null : _mapStop(row);
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final sourceIds = config.feeds.map((feed) => feed.sourceId.value).toSet();
    return (await _database.getAllStops())
        .where((row) => sourceIds.contains(row.endpoint))
        .where((row) => row.stopName.toLowerCase().contains(query))
        .take(request.limit)
        .map(_mapStop)
        .toList(growable: false);
  }

  TransitStop _mapStop(db.Stop row) => TransitStop(
    ref: TransitStopRef(
      region: config.region,
      provider: config.provider,
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

class PublicGtfsStaticRepository implements StaticGtfsRepository {
  const PublicGtfsStaticRepository({required this.config, this.database});

  final PublicGtfsProviderConfig config;
  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final feeds = request.sourceIds == null || request.sourceIds!.isEmpty
        ? config.feeds
        : config.feeds
              .where((feed) => request.sourceIds!.contains(feed.sourceId))
              .toList(growable: false);
    var completed = 0;
    for (final feed in feeds) {
      yield StaticImportProgress(
        sourceId: feed.sourceId,
        completed: completed,
        total: feeds.length,
        message: 'Downloading ${feed.label} static GTFS…',
      );
      final response = await AppHttpClient.get(Uri.parse(feed.url));
      if (response == null || response.statusCode != 200) {
        yield StaticImportProgress(
          sourceId: feed.sourceId,
          completed: completed,
          total: feeds.length,
          message: 'Failed to download ${feed.label} GTFS.',
          error: 'The public ${feed.label} feed was unavailable.',
        );
        continue;
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
              endpoint: feed.sourceId.value,
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
        completed += 1;
        yield StaticImportProgress(
          sourceId: feed.sourceId,
          completed: completed,
          total: feeds.length,
          message: 'Imported ${stops.length} stops from ${feed.label}.',
        );
      } catch (error, stackTrace) {
        safeLogWarning(
          '${feed.label} static GTFS import failed: $error\n$stackTrace',
        );
        yield StaticImportProgress(
          sourceId: feed.sourceId,
          completed: completed,
          total: feeds.length,
          message: 'Failed to parse ${feed.label} GTFS.',
          error: 'The public ${feed.label} feed could not be parsed.',
        );
      }
    }
  }
}

class PublicGtfsDepartureRepository implements DepartureRepository {
  PublicGtfsDepartureRepository({required this.config});

  final PublicGtfsProviderConfig config;
  final Map<String, GtfsData> _cache = <String, GtfsData>{};

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final data = await loadFeed(request.stop.sourceId);
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
                          region: config.region,
                          provider: config.provider,
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

  Future<GtfsData> loadFeed(TransitSourceId sourceId) async {
    final cached = _cache[sourceId.value];
    if (cached != null) return cached;
    final feed = config.feeds.firstWhereOrNull(
      (candidate) => candidate.sourceId == sourceId,
    );
    if (feed == null) return _emptyGtfsData();
    try {
      final response = await AppHttpClient.get(Uri.parse(feed.url));
      if (response == null || response.statusCode != 200) {
        return _emptyGtfsData();
      }
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      final files = <String, String>{};
      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.txt')) {
          files[file.name] = utf8.decode(file.content as List<int>);
        }
      }
      final data = parseGtfsFiles(files);
      _cache[sourceId.value] = data;
      return data;
    } catch (error, stackTrace) {
      safeLogWarning('${feed.label} GTFS parse failed: $error\n$stackTrace');
      return _emptyGtfsData();
    }
  }
}

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
