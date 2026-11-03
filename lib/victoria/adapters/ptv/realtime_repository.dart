part of '../ptv_transit_adapter.dart';

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
    final feed = await _fetchFeed(url, query: request.query);
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
    return RealtimeSnapshot(items: alerts, fetchedAt: feedFetchedAt(feed));
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
      query: request.query,
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
    return RealtimeSnapshot(items: updates, fetchedAt: feedFetchedAt(feed));
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
      query: request.query,
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
    return RealtimeSnapshot(items: vehicles, fetchedAt: feedFetchedAt(feed));
  }

  Future<FeedMessage?> _fetchFeed(String url, {RealtimeQuery? query}) async {
    final uri = tryParseUriValue(url);
    final apiKey = _readEnv('VICTORIA_OPEN_DATA_API_KEY');
    final response = uri == null
        ? null
        : await AppHttpClient.get(
            uri,
            query: query,
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
    return rememberFeedFetch<FeedMessage>(
      FeedMessage.fromBuffer(response.bodyBytes),
      response,
    );
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
