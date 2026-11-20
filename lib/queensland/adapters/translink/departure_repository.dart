part of '../translink_transit_adapter.dart';

class TranslinkDepartureRepository implements DepartureRepository {
  TranslinkDepartureRepository({this.database});
  final db.AppDatabase? database;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    validateDepartureStop(
      request.stop,
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      acceptsSource: (source) => translinkStaticGtfsFeeds.any(
        (feed) => source.value == 'qld:${feed.id}',
      ),
    );
    final data = await loadFeed(_feedIdFromSource(request.stop.sourceId.value));
    final updates = await freshGtfsUpdates(
      data,
      () => const TranslinkRealtimeRepository().getTripUpdates(
        RealtimeRequest(sourceId: request.stop.sourceId),
      ),
    );
    return scheduledGtfsDepartures(data, request, updates: updates);
  }

  Future<GtfsData> loadFeed(
    String feedId, {
    TransitCancellation? cancellation,
  }) async {
    return PersistentGtfsStore(database: database).load(
      source: 'qld:$feedId',
      cancellation: cancellation,
      requireTimetable: true,
      download: (cancellation) async {
        final response = await fetchTranslinkStaticGtfsResponse(
          feedId,
          cancellation: cancellation,
        );
        if (response == null || response.bodyBytes.isEmpty) {
          throw const ProviderUnavailable(
            message: 'TransLink feed unavailable.',
          );
        }
        return GtfsArchiveDownload.fromResponse(response);
      },
    );
  }
}
