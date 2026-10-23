part of '../trip_line_service_impl.dart';

extension TripLineStaticImport on TripLineService {
  /// Prepare every table before touching the previously published endpoint.
  Future<void> publishStaticDataForEndpoint(
    StopsEndpoint endpoint,
    GtfsData data, {
    db.AppDatabase? database,
  }) async {
    final release = await EndpointStaticUpdateQueue.acquire(endpoint);
    try {
      await publishStaticDataForEndpointWithinUpdate(
        endpoint,
        data,
        database: database,
      );
    } finally {
      release();
    }
  }

  /// Use while holding [EndpointStaticUpdateQueue] across fetch and publication.
  Future<void> publishStaticDataForEndpointWithinUpdate(
    StopsEndpoint endpoint,
    GtfsData data, {
    db.AppDatabase? database,
  }) async {
    await _prepareAndPublishStaticData(endpoint, data, database: database);
  }

  Future<_EndpointLineIndex> _prepareAndPublishStaticData(
    StopsEndpoint endpoint,
    GtfsData data, {
    db.AppDatabase? database,
  }) async {
    final mode = StopsService.modeForEndpointKey(endpoint.key);
    if (mode == null) throw ArgumentError('Unknown mode for ${endpoint.key}');
    final prepared = await compute(
      _prepareStaticFeed,
      _EndpointLineIndexBuildRequest(
        endpointKey: endpoint.key,
        mode: mode,
        data: data,
      ),
    );
    await (database ?? StopsService.database).replaceStaticDataForEndpoint(
      endpoint: endpoint.key,
      stopRows: prepared.stops,
      routeRows: prepared.routes,
      memberships: prepared.memberships,
    );
    _endpointIndexCache[endpoint.key] = Future.value(prepared.index);
    invalidateStationCacheForEndpoint(endpoint);
    StopsService.clearModeCache();
    return prepared.index;
  }
}

void _validateStaticFeed(GtfsData data) {
  Set<String> ids(Iterable<String> values, String kind) {
    final result = <String>{};
    for (final id in values) {
      if (id.isEmpty || id != id.trim() || !result.add(id)) {
        throw FormatException('Invalid or duplicate $kind ID: $id');
      }
    }
    if (result.isEmpty) throw FormatException('Static feed has no $kind');
    return result;
  }

  final stops = ids(data.stops.map((stop) => stop.stopId), 'stops');
  final routes = ids(data.routes.map((route) => route.routeId), 'routes');
  final trips = ids(data.trips.map((trip) => trip.tripId), 'trips');
  if (data.trips.any((trip) => !routes.contains(trip.routeId)) ||
      data.stopTimes.isEmpty ||
      data.stopTimes.any(
        (time) => !trips.contains(time.tripId) || !stops.contains(time.stopId),
      )) {
    throw const FormatException(
      'Static feed has missing trip/route/stop references',
    );
  }
}

/// Shared queue for scheduled updates and on-demand index imports.
class EndpointStaticUpdateQueue {
  static final Map<StopsEndpoint, Future<void>> _pending = {};

  static Future<void Function()> acquire(StopsEndpoint endpoint) async {
    final previous = _pending[endpoint];
    final completion = Completer<void>();
    _pending[endpoint] = completion.future;
    if (previous != null) await previous;
    return () {
      if (identical(_pending[endpoint], completion.future)) {
        _pending.remove(endpoint);
      }
      completion.complete();
    };
  }
}

class _PreparedStaticFeed {
  const _PreparedStaticFeed(
    this.index,
    this.stops,
    this.routes,
    this.memberships,
  );
  final _EndpointLineIndex index;
  final List<db.StopsCompanion> stops;
  final List<db.RoutesCompanion> routes;
  final List<db.StopLineMembershipsCompanion> memberships;
}

_PreparedStaticFeed _prepareStaticFeed(_EndpointLineIndexBuildRequest request) {
  final data = request.data;
  _validateStaticFeed(data);
  final index = _buildEndpointLineIndex(request);
  final endpoint = StopsEndpoint.values.firstWhere(
    (e) => e.key == request.endpointKey,
  );
  final stopRows = data.stops
      .map(
        (stop) => db.StopsCompanion.insert(
          endpoint: endpoint.key,
          stopId: stop.stopId,
          stopName: stop.stopName,
          stopCode: drift.Value(stop.stopCode),
          ttsStopName: drift.Value(stop.ttsStopName),
          stopDesc: drift.Value(stop.stopDesc),
          zoneId: drift.Value(stop.zoneId),
          stopUrl: drift.Value(stop.stopUrl),
          stopTimezone: drift.Value(stop.stopTimezone),
          levelId: drift.Value(stop.levelId),
          stopLat: drift.Value(stop.stopLat),
          stopLon: drift.Value(stop.stopLon),
          locationType: drift.Value(stop.locationType),
          parentStation: drift.Value(stop.parentStation),
          wheelchairBoarding: drift.Value(stop.wheelchairBoarding),
          platformCode: drift.Value(stop.platformCode),
        ),
      )
      .toList(growable: false);
  return _PreparedStaticFeed(
    index,
    stopRows,
    _routeRowsForEndpoint(endpoint, data),
    _membershipRowsForEndpoint(endpoint.key, index),
  );
}

List<db.StopLineMembershipsCompanion> _membershipRowsForEndpoint(
  String endpointKey,
  _EndpointLineIndex index,
) {
  final memberships = <db.StopLineMembershipsCompanion>[];
  for (final stops in index.lineStops.values) {
    for (final stop in stops) {
      memberships.add(
        db.StopLineMembershipsCompanion.insert(
          endpoint: endpointKey,
          stopId: stop.stopId,
          stopName: stop.stopName,
          lineId: stop.lineId,
          lineName: stop.lineName,
          mode: stop.mode.id,
          stopOrder: stop.stopOrder,
          stopLat: drift.Value(stop.latitude),
          stopLon: drift.Value(stop.longitude),
        ),
      );
    }
  }
  return memberships;
}

List<db.RoutesCompanion> _routeRowsForEndpoint(
  StopsEndpoint endpoint,
  GtfsData data,
) {
  final routeRows = data.routes
      .where((route) => route.routeId.trim().isNotEmpty)
      .map(
        (route) => db.RoutesCompanion.insert(
          endpoint: endpoint.key,
          routeId: route.routeId.trim(),
          lineId: '${endpoint.key}|${route.routeId.trim()}',
          routeShortName: drift.Value(route.routeShortName),
          routeLongName: drift.Value(route.routeLongName),
          routeDesc: drift.Value(route.routeDesc),
          routeType: drift.Value(route.routeType),
          routeColor: drift.Value(route.routeColor),
          routeTextColor: drift.Value(route.routeTextColor),
          routeSortOrder: drift.Value(route.routeSortOrder),
        ),
      )
      .toList(growable: false);
  return routeRows;
}
