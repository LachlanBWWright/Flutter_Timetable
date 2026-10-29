part of '../translink_transit_adapter.dart';

class TranslinkRealtimeRepository implements RealtimeRepository {
  const TranslinkRealtimeRepository();

  @override
  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  ) async {
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkAlerts(feedSetId, query: request.query);
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
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkTripUpdates(
      feedSetId,
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
                    region: TransitRegion.queensland,
                    provider: TransitProviderId.translink,
                    sourceId: TransitSourceId('qld:$feedSetId'),
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
    final feedSetId = _feedIdFromSource(request.sourceId?.value ?? 'qld:SEQ');
    final feed = await fetchTranslinkVehiclePositions(
      feedSetId,
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
}
