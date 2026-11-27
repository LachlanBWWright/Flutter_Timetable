part of 'public_gtfs_transit_adapter.dart';

class PublicGtfsDepartureRepository implements DepartureRepository {
  PublicGtfsDepartureRepository({
    required this.config,
    this.database,
    this.fetcher = _fetchPublicGtfsFeed,
  });

  final db.AppDatabase? database;
  final PublicGtfsProviderConfig config;
  final PublicGtfsFetcher fetcher;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    validateDepartureStop(
      request.stop,
      region: config.region,
      provider: config.provider,
      acceptsSource: (source) =>
          config.feeds.any((feed) => feed.sourceId == source),
    );
    final data = await loadFeed(request.stop.sourceId);
    return scheduledGtfsDepartures(data, request);
  }

  Future<GtfsData> loadFeed(
    TransitSourceId sourceId, {
    TransitCancellation? cancellation,
  }) async {
    final feed = config.feeds.firstWhereOrNull(
      (candidate) => candidate.sourceId == sourceId,
    );
    if (feed == null) {
      throw const InvalidJourneyRequest(
        message: 'The requested public GTFS source is not configured.',
      );
    }
    return PersistentGtfsStore(database: database).load(
      source: sourceId.value,
      cancellation: cancellation,
      requireTimetable: true,
      download: (cancellation) async {
        final uri = Uri.parse(feed.url);
        final response = fetcher == _fetchPublicGtfsFeed
            ? await AppHttpClient.getOrThrow(uri, cancellation: cancellation)
            : await cancellation.wait(fetcher(uri));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw const ProviderUnavailable(
            message: 'The timetable is unavailable.',
          );
        }
        return GtfsArchiveDownload.fromResponse(response);
      },
    );
  }
}
