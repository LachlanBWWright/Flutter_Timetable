import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/wrappers/transport_api_service_impl.dart'
    as tfnsw;
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/new_trip_service.dart' as legacy_new_trip;
import 'package:lbww_flutter/services/realtime_service.dart' as legacy_realtime;
import 'package:lbww_flutter/services/stops_service.dart' as legacy_stops;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:option_result/option_result.dart';

import '../../gtfs/gtfs_data.dart';
import '../../nsw/fetch_data/timetable_data.dart' show fetchStaticGtfsSource;

class TfnswStopRepository implements StopRepository {
  const TfnswStopRepository({this.database});

  final db.AppDatabase? database;
  db.AppDatabase get _database =>
      database ?? legacy_stops.StopsService.database;

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    if (!stop.belongsTo(TransitRegion.nsw, TransitProviderId.tfnsw) ||
        !legacy_stops.StopsEndpoint.values.any(
          (endpoint) => endpoint.key == stop.sourceId.value,
        )) {
      return null;
    }
    final rows = await _database.getStopsById(stop.stopId);
    final row = rows
        .where((candidate) => candidate.endpoint == stop.sourceId.value)
        .firstOrNull;
    if (row == null) {
      return null;
    }
    return _mapDbStop(
      row.stopId,
      row.stopName,
      row.endpoint,
      row.stopLat,
      row.stopLon,
      platformCode: row.platformCode,
      stopCode: row.stopCode,
      description: row.stopDesc,
    );
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim();
    if (query.isEmpty) return const [];
    final results = await _database.searchStops(
      query,
      limit: request.limit,
      endpoints: legacy_stops.StopsEndpoint.values.map(
        (endpoint) => endpoint.key,
      ),
    );
    return results
        .map(
          (stop) => _mapDbStop(
            stop.stopId,
            stop.stopName,
            stop.endpoint,
            stop.stopLat,
            stop.stopLon,
            platformCode: stop.platformCode,
            stopCode: stop.stopCode,
            description: stop.stopDesc,
          ),
        )
        .toList(growable: false);
  }

  TransitStop _mapDbStop(
    String stopId,
    String stopName,
    String endpoint,
    double? lat,
    double? lon, {
    String? platformCode,
    String? stopCode,
    String? description,
  }) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.nsw,
        provider: TransitProviderId.tfnsw,
        sourceId: TransitSourceId(endpoint),
        stopId: stopId,
      ),
      name: stopName,
      mode: legacy_stops.StopsService.modeForEndpointKey(endpoint),
      latitude: lat,
      longitude: lon,
      platformCode: platformCode,
      stopCode: stopCode,
      description: description,
    );
  }
}

class TfnswStaticGtfsRepository implements StaticGtfsRepository {
  const TfnswStaticGtfsRepository();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final knownSources = legacy_stops.StopsEndpoint.values
        .map((endpoint) => endpoint.key)
        .toSet();
    if (request.sourceIds?.any(
          (source) => !knownSources.contains(source.value),
        ) ==
        true) {
      throw const InvalidJourneyRequest(message: 'Unknown NSW static source.');
    }
    final selectedSources = request.sourceIds?.isEmpty == true
        ? null
        : request.sourceIds;
    final endpoints = selectedSources
        ?.map(
          (sourceId) => legacy_stops.StopsEndpoint.values.firstWhere(
            (endpoint) => endpoint.key == sourceId.value,
            orElse: () => legacy_stops.StopsEndpoint.sydneytrains,
          ),
        )
        .toList();
    await for (final progress
        in legacy_new_trip.NewTripService.updateStaticTransportData(
          force: request.force,
          cancellation: request.cancellation,
          endpoints: endpoints,
        )) {
      yield StaticImportProgress(
        sourceId: progress.endpoint == null
            ? null
            : TransitSourceId(progress.endpoint!.key),
        completed: progress.completed,
        total: progress.total,
        message: progress.message ?? progress.stage.name,
        error: progress.error,
      );
    }
  }
}

class TfnswRealtimeRepository implements RealtimeRepository {
  const TfnswRealtimeRepository();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    return RealtimeSnapshot(
      items: const <TransitAlert>[],
      fetchedAt: DateTime.now(),
    );
  }

  @override
  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(
    RealtimeRequest request,
  ) async {
    final aggregate =
        await legacy_realtime.RealtimeService.getAllTripUpdatesAggregatedSafe();
    final items = aggregate.tripUpdates
        .map(
          (update) => TransitTripUpdate(
            tripId: update.trip.tripId,
            stop:
                update.stopTimeUpdate.isNotEmpty &&
                    update.stopTimeUpdate.first.hasStopId()
                ? TransitStopRef(
                    region: TransitRegion.nsw,
                    provider: TransitProviderId.tfnsw,
                    sourceId: const TransitSourceId('realtime'),
                    stopId: update.stopTimeUpdate.first.stopId,
                  )
                : null,
            plannedTime:
                update.stopTimeUpdate.isNotEmpty &&
                    update.stopTimeUpdate.first.departure.hasTime()
                ? DateTime.fromMillisecondsSinceEpoch(
                    update.stopTimeUpdate.first.departure.time.toInt() * 1000,
                    isUtc: true,
                  )
                : null,
            estimatedTime:
                update.stopTimeUpdate.isNotEmpty &&
                    update.stopTimeUpdate.first.arrival.hasTime()
                ? DateTime.fromMillisecondsSinceEpoch(
                    update.stopTimeUpdate.first.arrival.time.toInt() * 1000,
                    isUtc: true,
                  )
                : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: items, fetchedAt: DateTime.now());
  }

  @override
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(
    RealtimeRequest request,
  ) async {
    final aggregate = await legacy_realtime
        .RealtimeService.getAllVehiclePositionsAggregatedSafe();
    final items = aggregate.vehicles
        .map(
          (vehicle) => TransitVehicle(
            id: vehicle.vehicle.hasId()
                ? vehicle.vehicle.id
                : vehicle.trip.tripId,
            tripId: vehicle.trip.tripId,
            latitude: vehicle.position.latitude,
            longitude: vehicle.position.longitude,
            bearing: vehicle.position.hasBearing()
                ? vehicle.position.bearing
                : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: items, fetchedAt: DateTime.now());
  }
}

class TfnswJourneyPlanner implements CapableJourneyPlanner {
  const TfnswJourneyPlanner();
  @override
  TransitPlanningCapabilities get capabilities =>
      const TransitPlanningCapabilities(
        arriveBy: true,
        accessibility: true,
        realtime: true,
      );

  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async {
    if (request.origin.region != TransitRegion.nsw ||
        request.destination.region != TransitRegion.nsw) {
      throw UnsupportedError('Cross-region journey planning is not supported.');
    }
    request.cancellation?.throwIfCancelled();
    if (request.walkingLimit != null) {
      throw const UnsupportedCapability(
        message: 'Walking limits require local timetable planning.',
      );
    }
    if (request.enabledModes?.isEmpty == true) {
      return const JourneyPlan(journeys: []);
    }
    final future = tfnsw.TransportApiService.getTrips(
      originId: request.origin.stopId,
      destinationId: request.destination.stopId,
      when: request.when,
      arrivalBased: request.arrivalBased,
      wheelchair: request.accessibility != TransitAccessibility.none,
      enabledModes: request.enabledModes,
    );
    final result = await (request.cancellation?.wait(future) ?? future);
    return switch (result) {
      Ok(:final v) => JourneyPlan(
        journeys: v.tripJourneys.map(_mapJourney).toList(growable: false),
        rawPayload: v.rawJson,
      ),
      Err(:final e) => throw ProviderUnavailable(message: e),
    };
  }

  TransitJourney _mapJourney(tfnsw.TripJourney journey) {
    return TransitJourney(
      legs: journey.legs.map(_mapLeg).toList(growable: false),
      rawPayload: journey.rawJson,
    );
  }

  TransitLeg _mapLeg(tfnsw.Leg leg) {
    final transportation = leg.transportation;
    final product = transportation?.product?.name ?? '';
    return TransitLeg(
      origin: TransitStop(
        ref: TransitStopRef(
          region: TransitRegion.nsw,
          provider: TransitProviderId.tfnsw,
          sourceId: const TransitSourceId('journey-planner'),
          stopId: leg.origin.id,
        ),
        name: leg.origin.name,
        latitude: leg.origin.coord?.elementAtOrNull(1),
        longitude: leg.origin.coord?.elementAtOrNull(0),
      ),
      destination: TransitStop(
        ref: TransitStopRef(
          region: TransitRegion.nsw,
          provider: TransitProviderId.tfnsw,
          sourceId: const TransitSourceId('journey-planner'),
          stopId: leg.destination.id,
        ),
        name: leg.destination.name,
        latitude: leg.destination.coord?.elementAtOrNull(1),
        longitude: leg.destination.coord?.elementAtOrNull(0),
      ),
      route: transportation?.id == null
          ? null
          : TransitRoute(
              ref: TransitRouteRef(
                region: TransitRegion.nsw,
                provider: TransitProviderId.tfnsw,
                sourceId: const TransitSourceId('journey-planner'),
                routeId: transportation!.id!,
              ),
              name:
                  transportation.name ??
                  transportation.number ??
                  transportation.description ??
                  'Route',
              shortName: transportation.number,
              mode: _modeFromTfnswProduct(product),
            ),
      mode: _modeFromTfnswProduct(product),
      isWalking: leg.transportation?.product?.classField == 100,
      isRealtime: leg.isRealtimeControlled == true,
      plannedDepartureTime: _tryParseDateTime(leg.origin.departureTimePlanned),
      plannedArrivalTime: _tryParseDateTime(leg.destination.arrivalTimePlanned),
      departureTime: _tryParseDateTime(
        leg.origin.departureTimeEstimated ?? leg.origin.departureTimePlanned,
      ),
      arrivalTime: _tryParseDateTime(
        leg.destination.arrivalTimeEstimated ??
            leg.destination.arrivalTimePlanned,
      ),
      label: transportation?.destination?.name,
      rawPayload: leg.rawJson,
    );
  }

  TransportMode? _modeFromTfnswProduct(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('train')) return TransportMode.train;
    if (lower.contains('metro')) return TransportMode.metro;
    if (lower.contains('bus')) return TransportMode.bus;
    if (lower.contains('ferr')) return TransportMode.ferry;
    if (lower.contains('light')) return TransportMode.lightrail;
    return null;
  }

  DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }
}

Future<GtfsData> _loadTfnswTimetable(
  TransitSourceId source, {
  TransitCancellation? cancellation,
}) async {
  final endpoint = legacy_stops.StopsEndpoint.values.firstWhereOrNull(
    (e) => e.key == source.value,
  );
  if (endpoint == null) {
    throw const InvalidJourneyRequest(message: 'Unknown NSW timetable source.');
  }
  final data = await fetchStaticGtfsSource(
    endpoint,
    cancellation: cancellation,
  );
  if (data == null) {
    throw const ProviderUnavailable(message: 'NSW timetable unavailable.');
  }
  return data;
}

TransitRegionServices buildTfnswRegionServices() {
  const staticData = TfnswStaticGtfsRepository();
  return TransitRegionServices(
    region: TransitRegion.nsw,
    provider: TransitProviderId.tfnsw,
    stops: StaticBackedStopRepository(
      region: TransitRegion.nsw,
      provider: TransitProviderId.tfnsw,
      sources: legacy_stops.StopsEndpoint.values
          .map((endpoint) => TransitSourceId(endpoint.key))
          .toList(),
      modeForSource: (source) =>
          legacy_stops.StopsService.modeForEndpointKey(source.value),
      cachedStops: const TfnswStopRepository(),
      staticData: staticData,
    ),
    staticGtfs: staticData,
    timetableSources: legacy_stops.StopsEndpoint.values
        .map((e) => TransitSourceId(e.key))
        .toList(),
    cancellableTimetableLoader: (source, token) =>
        _loadTfnswTimetable(source, cancellation: token),
    timetableLoader: _loadTfnswTimetable,
    realtime: const TfnswRealtimeRepository(),
    journeyPlanner: const TfnswJourneyPlanner(),
    attribution: const TransitProviderAttribution(
      provider: TransitProviderId.tfnsw,
      name: 'Transport for NSW Open Data',
      licenseName: 'TfNSW Open Data terms',
      url: 'https://opendata.transport.nsw.gov.au/',
    ),
  );
}
