import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/wrappers/transport_api_service_impl.dart' as tfnsw;
import 'package:lbww_flutter/services/new_trip_service.dart' as legacy_new_trip;
import 'package:lbww_flutter/services/realtime_service.dart' as legacy_realtime;
import 'package:lbww_flutter/services/stops_service.dart' as legacy_stops;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:option_result/option_result.dart';

class TfnswStopRepository implements StopRepository {
  const TfnswStopRepository();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final rows = await legacy_stops.StopsService.database.getStopsById(stop.stopId);
    final row = rows.where((candidate) => candidate.endpoint == stop.sourceId.value).firstOrNull;
    if (row == null) {
      return null;
    }
    return _mapDbStop(row.stopId, row.stopName, row.endpoint, row.stopLat, row.stopLon,
        platformCode: row.platformCode, stopCode: row.stopCode, description: row.stopDesc);
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final results = await legacy_stops.StopsService.searchStops(request.query);
    return results
        .take(request.limit)
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
  Stream<StaticImportProgress> refreshStaticData(StaticImportRequest request) async* {
    final endpoints = request.sourceIds
        ?.map((sourceId) => legacy_stops.StopsEndpoint.values.firstWhere(
              (endpoint) => endpoint.key == sourceId.value,
              orElse: () => legacy_stops.StopsEndpoint.sydneytrains,
            ))
        .toList();
    await for (final progress in legacy_new_trip.NewTripService.updateStaticTransportData(
      force: request.force,
      endpoints: endpoints,
    )) {
      yield StaticImportProgress(
        sourceId: progress.endpoint == null ? null : TransitSourceId(progress.endpoint!.key),
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
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(RealtimeRequest request) async {
    return RealtimeSnapshot(items: const <TransitAlert>[], fetchedAt: DateTime.now());
  }

  @override
  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(RealtimeRequest request) async {
    final aggregate = await legacy_realtime.RealtimeService.getAllTripUpdatesAggregatedSafe();
    final items = aggregate.tripUpdates
        .map(
          (update) => TransitTripUpdate(
            tripId: update.trip.tripId,
            stop: update.stopTimeUpdate.isNotEmpty && update.stopTimeUpdate.first.hasStopId()
                ? TransitStopRef(
                    region: TransitRegion.nsw,
                    provider: TransitProviderId.tfnsw,
                    sourceId: const TransitSourceId('realtime'),
                    stopId: update.stopTimeUpdate.first.stopId,
                  )
                : null,
            plannedTime: update.stopTimeUpdate.isNotEmpty && update.stopTimeUpdate.first.departure.hasTime()
                ? DateTime.fromMillisecondsSinceEpoch(
                    update.stopTimeUpdate.first.departure.time.toInt() * 1000,
                    isUtc: true,
                  )
                : null,
            estimatedTime: update.stopTimeUpdate.isNotEmpty && update.stopTimeUpdate.first.arrival.hasTime()
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
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(RealtimeRequest request) async {
    final aggregate = await legacy_realtime.RealtimeService.getAllVehiclePositionsAggregatedSafe();
    final items = aggregate.vehicles
        .map(
          (vehicle) => TransitVehicle(
            id: vehicle.vehicle.hasId() ? vehicle.vehicle.id : vehicle.trip.tripId,
            tripId: vehicle.trip.tripId,
            latitude: vehicle.position.latitude,
            longitude: vehicle.position.longitude,
            bearing: vehicle.position.hasBearing() ? vehicle.position.bearing : null,
          ),
        )
        .toList(growable: false);
    return RealtimeSnapshot(items: items, fetchedAt: DateTime.now());
  }
}

class TfnswJourneyPlanner implements JourneyPlanner {
  const TfnswJourneyPlanner();

  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async {
    if (request.origin.region != TransitRegion.nsw || request.destination.region != TransitRegion.nsw) {
      throw const UnsupportedError('Cross-region journey planning is not supported.');
    }
    final result = await tfnsw.TransportApiService.getTrips(
      originId: request.origin.stopId,
      destinationId: request.destination.stopId,
    );
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
              name: transportation.name ?? transportation.number ?? transportation.description ?? 'Route',
              shortName: transportation.number,
              mode: _modeFromTfnswProduct(product),
            ),
      mode: _modeFromTfnswProduct(product),
      departureTime: _tryParseDateTime(leg.origin.departureTimeEstimated ?? leg.origin.departureTimePlanned),
      arrivalTime: _tryParseDateTime(leg.destination.arrivalTimeEstimated ?? leg.destination.arrivalTimePlanned),
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

TransitRegionServices buildTfnswRegionServices() {
  return const TransitRegionServices(
    region: TransitRegion.nsw,
    provider: TransitProviderId.tfnsw,
    stops: TfnswStopRepository(),
    staticGtfs: TfnswStaticGtfsRepository(),
    realtime: TfnswRealtimeRepository(),
    journeyPlanner: TfnswJourneyPlanner(),
    attribution: TransitProviderAttribution(
      provider: TransitProviderId.tfnsw,
      name: 'Transport for NSW Open Data',
      licenseName: 'TfNSW Open Data terms',
      url: 'https://opendata.transport.nsw.gov.au/',
    ),
  );
}
