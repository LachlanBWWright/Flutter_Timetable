import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/queensland/translink/translink.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

class TranslinkStopRepository implements StopRepository {
  const TranslinkStopRepository();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final rows = await db.AppDatabase().getStopsById(stop.stopId);
    final match = rows
        .where((row) => row.endpoint == stop.sourceId.value)
        .firstOrNull;
    if (match == null) {
      return null;
    }
    return _mapStop(
      match.stopId,
      match.stopName,
      match.endpoint,
      latitude: match.stopLat,
      longitude: match.stopLon,
      platformCode: match.platformCode,
    );
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final rows = await db.AppDatabase().getAllStops();
    return rows
        .where((row) => row.endpoint.startsWith('qld:'))
        .where((row) => row.stopName.toLowerCase().contains(query))
        .take(request.limit)
        .map(
          (row) => _mapStop(
            row.stopId,
            row.stopName,
            row.endpoint,
            latitude: row.stopLat,
            longitude: row.stopLon,
            platformCode: row.platformCode,
            stopCode: row.stopCode,
            description: row.stopDesc,
          ),
        )
        .toList(growable: false);
  }

  TransitStop _mapStop(
    String stopId,
    String stopName,
    String endpoint, {
    double? latitude,
    double? longitude,
    String? platformCode,
    String? stopCode,
    String? description,
  }) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        sourceId: TransitSourceId(endpoint),
        stopId: stopId,
      ),
      name: stopName,
      mode: _modeFromStopName(stopName),
      latitude: latitude,
      longitude: longitude,
      platformCode: platformCode,
      stopCode: stopCode,
      description: description,
    );
  }
}

class TranslinkStaticGtfsRepository implements StaticGtfsRepository {
  const TranslinkStaticGtfsRepository();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final selectedFeeds =
        request.sourceIds == null || request.sourceIds!.isEmpty
        ? translinkStaticGtfsFeeds
        : translinkStaticGtfsFeeds
              .where(
                (feed) => request.sourceIds!.any(
                  (sourceId) => sourceId.value == 'qld:${feed.id}',
                ),
              )
              .toList(growable: false);
    var completed = 0;
    for (final feed in selectedFeeds) {
      yield StaticImportProgress(
        sourceId: TransitSourceId('qld:${feed.id}'),
        completed: completed,
        total: selectedFeeds.length,
        message: 'Downloading ${feed.label} static GTFS…',
      );
      final bytes = await fetchTranslinkStaticGtfsZip(feed.id);
      if (bytes == null || bytes.isEmpty) {
        throw ProviderUnavailable(
          message: 'Failed to download ${feed.label} GTFS.',
        );
      }
      final stops = parseStopsOnlyFromZipBytes(Uint8List.fromList(bytes));
      final database = db.AppDatabase();
      for (final stop in stops) {
        await database.insertStop(
          db.StopsCompanion.insert(
            stopId: stop.stopId,
            stopName: stop.stopName,
            endpoint: 'qld:${feed.id}',
            stopCode: Value(stop.stopCode),
            stopDesc: Value(stop.stopDesc),
            stopLat: Value(stop.stopLat),
            stopLon: Value(stop.stopLon),
            platformCode: Value(stop.platformCode),
            parentStation: Value(stop.parentStation),
            wheelchairBoarding: Value(stop.wheelchairBoarding),
          ),
        );
      }
      completed += 1;
      yield StaticImportProgress(
        sourceId: TransitSourceId('qld:${feed.id}'),
        completed: completed,
        total: selectedFeeds.length,
        message: 'Imported ${stops.length} stops from ${feed.label}.',
      );
    }
  }
}

class TranslinkDepartureRepository implements DepartureRepository {
  TranslinkDepartureRepository();

  final Map<String, GtfsData> _cache = <String, GtfsData>{};

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final feedId = _feedIdFromSource(request.stop.sourceId.value);
    final data = await _loadFeed(feedId);
    final now = request.when ?? DateTime.now();
    final activeServiceIds = _activeServiceIds(data, now);
    final tripsById = {for (final trip in data.trips) trip.tripId: trip};
    final routesById = {for (final route in data.routes) route.routeId: route};
    final departures =
        data.stopTimes
            .where((stopTime) => stopTime.stopId == request.stop.stopId)
            .where(
              (stopTime) => activeServiceIds.contains(
                tripsById[stopTime.tripId]?.serviceId,
              ),
            )
            .map((stopTime) {
              final departureTime = _gtfsTimeToDateTime(
                now,
                stopTime.departureTime,
              );
              final trip = tripsById[stopTime.tripId];
              final route = trip == null ? null : routesById[trip.routeId];
              return TransitDeparture(
                stop: request.stop,
                route: route == null
                    ? null
                    : TransitRoute(
                        ref: TransitRouteRef(
                          region: TransitRegion.queensland,
                          provider: TransitProviderId.translink,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _modeFromRouteType(route.routeType),
                      ),
                tripId: stopTime.tripId,
                destinationName: trip?.tripHeadsign,
                plannedTime: departureTime,
                estimatedTime: departureTime,
                platform: null,
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

  Future<GtfsData> _loadFeed(String feedId) async {
    final cached = _cache[feedId];
    if (cached != null) {
      return cached;
    }
    final bytes = await fetchTranslinkStaticGtfsZip(feedId);
    if (bytes == null || bytes.isEmpty) {
      throw ProviderUnavailable(
        message: 'Failed to download TransLink static GTFS for $feedId.',
      );
    }
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <String, String>{};
    for (final file in archive) {
      if (!file.isFile) continue;
      try {
        files[file.name] = utf8.decode(file.content as List<int>);
      } catch (_) {}
    }
    final parsed = parseGtfsFiles(files);
    _cache[feedId] = parsed;
    return parsed;
  }
}

class TranslinkRealtimeRepository implements RealtimeRepository {
  const TranslinkRealtimeRepository();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkAlerts(feedSetId);
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
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkTripUpdates(feedSetId);
    final updates = (feed?.entity ?? const <FeedEntity>[])
        .where((entity) => entity.hasTripUpdate())
        .map(
          (entity) => TransitTripUpdate(
            tripId: entity.tripUpdate.trip.tripId,
            stop:
                entity.tripUpdate.stopTimeUpdate.isNotEmpty &&
                    entity.tripUpdate.stopTimeUpdate.first.hasStopId()
                ? TransitStopRef(
                    region: TransitRegion.queensland,
                    provider: TransitProviderId.translink,
                    sourceId: TransitSourceId('qld:$feedSetId'),
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
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkVehiclePositions(feedSetId);
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
}

TransitRegionServices buildTranslinkRegionServices() {
  return TransitRegionServices(
    region: TransitRegion.queensland,
    provider: TransitProviderId.translink,
    stops: const TranslinkStopRepository(),
    staticGtfs: const TranslinkStaticGtfsRepository(),
    realtime: const TranslinkRealtimeRepository(),
    departures: TranslinkDepartureRepository(),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.translink,
      name: 'Queensland TransLink GTFS',
      licenseName: 'Queensland Open Data terms',
      url:
          'https://www.data.qld.gov.au/organization/transport-and-main-roads?q=GTFS',
    ),
  );
}

String _feedIdFromSource(String sourceId) => sourceId.replaceFirst('qld:', '');

TransportMode? _modeFromStopName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('ferry')) return TransportMode.ferry;
  if (lower.contains('tram')) return TransportMode.lightrail;
  if (lower.contains('bus')) return TransportMode.bus;
  if (lower.contains('station')) return TransportMode.train;
  return null;
}

TransportMode? _modeFromRouteType(String routeType) {
  switch (routeType) {
    case '0':
    case '1':
      return TransportMode.train;
    case '3':
      return TransportMode.bus;
    case '4':
      return TransportMode.ferry;
    default:
      return null;
  }
}

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final yyyymmdd =
      '${moment.year.toString().padLeft(4, '0')}${moment.month.toString().padLeft(2, '0')}${moment.day.toString().padLeft(2, '0')}';
  final services = <String>{};
  for (final calendar in data.calendars) {
    if (yyyymmdd.compareTo(calendar.startDate) < 0 ||
        yyyymmdd.compareTo(calendar.endDate) > 0) {
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
    if (enabled) {
      services.add(calendar.serviceId);
    }
  }
  for (final exception in data.calendarDates.where(
    (entry) => entry.date == yyyymmdd,
  )) {
    if (exception.exceptionType == '1') {
      services.add(exception.serviceId);
    } else if (exception.exceptionType == '2') {
      services.remove(exception.serviceId);
    }
  }
  return services;
}

DateTime? _gtfsTimeToDateTime(DateTime anchor, String value) {
  final parts = value.split(':');
  if (parts.length != 3) return null;
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  final seconds = int.tryParse(parts[2]);
  if (hours == null || minutes == null || seconds == null) return null;
  final dayOffset = hours ~/ 24;
  final normalizedHours = hours % 24;
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day + dayOffset,
    normalizedHours,
    minutes,
    seconds,
  );
}
