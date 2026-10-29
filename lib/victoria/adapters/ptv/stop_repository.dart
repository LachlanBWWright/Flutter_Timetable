part of '../ptv_transit_adapter.dart';

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
      final query = request.query.trim().toLowerCase();
      final rows = await database.searchStops(
        query,
        limit: request.limit,
        endpoints: const ['ptv:static'],
      );
      final loaded = rows.map(_mapDatabaseStop).toList(growable: false);
      if (loaded.isNotEmpty || !SharedTransitCache.instance.isConfigured) {
        return loaded;
      }
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
      if (!_signedClient.isConfigured) return const [];
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
    if (!_signedClient.isConfigured &&
        !SharedTransitCache.instance.isConfigured) {
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
