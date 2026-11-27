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
    if (request.sourceId?.value == 'ptv:static') {
      final snapshots = await Future.wait(
        victoriaRealtimeFeedSets.map((set) async {
          try {
            return await getTripUpdates(
              RealtimeRequest(
                sourceId: TransitSourceId('ptv:${set.id}'),
                query: request.query,
              ),
            );
          } on Exception {
            return null;
          }
        }),
      );
      final available = snapshots
          .whereType<RealtimeSnapshot<TransitTripUpdate>>()
          .toList();
      if (available.isEmpty) {
        throw const ProviderUnavailable(
          message: 'Victoria live updates unavailable.',
        );
      }
      final fetched = available
          .map((s) => s.fetchedAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return RealtimeSnapshot(
        items: [
          for (final snapshot in available)
            ...snapshot.items.map(
              (u) => remapGtfsUpdate(
                u,
                tripId: u.tripId,
                source: const TransitSourceId('ptv:static'),
                stop: u.stop == null
                    ? null
                    : TransitStopRef(
                        region: TransitRegion.victoria,
                        provider: TransitProviderId.ptv,
                        sourceId: const TransitSourceId('ptv:static'),
                        stopId: u.stop!.stopId,
                      ),
              ),
            ),
        ],
        fetchedAt: fetched,
        isStale:
            available.length != victoriaRealtimeFeedSets.length ||
            available.any((s) => s.isStale),
      );
    }
    final legacyUrl = _readEnv('VICTORIA_GTFS_RT_TRIP_UPDATES_URL');
    final feed = await _fetchFeed(
      legacyUrl.isNotEmpty
          ? legacyUrl
          : _feedSet(request.sourceId).tripUpdatesUrl,
      query: request.query,
    );
    return RealtimeSnapshot(
      items: gtfsRealtimeUpdates(
        feed,
        region: TransitRegion.victoria,
        provider: TransitProviderId.ptv,
        source: request.sourceId ?? const TransitSourceId('ptv:metro'),
      ),
      fetchedAt: feedFetchedAt(feed),
    );
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
