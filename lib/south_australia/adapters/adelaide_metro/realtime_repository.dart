part of '../adelaide_metro_transit_adapter.dart';

class AdelaideMetroRealtimeRepository implements RealtimeRepository {
  const AdelaideMetroRealtimeRepository();

  static final _extensionRegistry = _buildExtensionRegistry();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(
      adelaideMetroServiceAlertsUrl,
      query: request.query,
    );
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
    return RealtimeSnapshot(items: alerts, fetchedAt: feedFetchedAt(feed));
  }

  @override
  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(
      adelaideMetroTripUpdatesUrl,
      query: request.query,
    );
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
    return RealtimeSnapshot(items: updates, fetchedAt: feedFetchedAt(feed));
  }

  @override
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(
    RealtimeRequest request,
  ) async {
    final feed = await _fetchFeed(
      adelaideMetroVehiclePositionsUrl,
      query: request.query,
    );
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
    return RealtimeSnapshot(items: vehicles, fetchedAt: feedFetchedAt(feed));
  }

  Future<sa_pb.FeedMessage?> _fetchFeed(
    String url, {
    RealtimeQuery? query,
  }) async {
    final response = await AppHttpClient.getOrThrow(
      Uri.parse(url),
      headers: const {'Accept': 'application/x-google-protobuf'},
      query: query,
    );
    try {
      return rememberFeedFetch<sa_pb.FeedMessage>(
        sa_pb.FeedMessage.fromBuffer(response.bodyBytes, _extensionRegistry),
        response,
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
