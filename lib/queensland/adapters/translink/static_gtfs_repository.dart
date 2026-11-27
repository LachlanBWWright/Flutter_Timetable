part of '../translink_transit_adapter.dart';

class TranslinkStaticGtfsRepository implements StaticGtfsRepository {
  const TranslinkStaticGtfsRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final knownSources = translinkStaticGtfsFeeds
        .map((feed) => 'qld:${feed.id}')
        .toSet();
    if (request.sourceIds?.any(
          (source) => !knownSources.contains(source.value),
        ) ==
        true) {
      throw const InvalidJourneyRequest(
        message: 'Unknown TransLink static source.',
      );
    }
    final selectedFeeds =
        request.sourceIds == null || request.sourceIds!.isEmpty
        ? translinkStaticGtfsFeeds
        : translinkStaticGtfsFeeds
              .where(
                (feed) => request.sourceIds!.any(
                  (sourceId) => sourceId.value == 'qld:${feed.id}',
                ),
              )
              .toList(growable: false);
    var completed = 0;
    for (final feed in selectedFeeds) {
      yield StaticImportProgress(
        sourceId: TransitSourceId('qld:${feed.id}'),
        completed: completed,
        total: selectedFeeds.length,
        message: 'Downloading ${feed.label} static GTFS…',
      );
      try {
        final data = await PersistentGtfsStore(database: _database).load(
          source: 'qld:${feed.id}',
          parse: parseGtfsStopSnapshot,
          force: request.force,
          cancellation: request.cancellation,
          download: (cancellation) async {
            final response = await fetchTranslinkStaticGtfsResponse(
              feed.id,
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
        request.cancellation?.throwIfCancelled();
        final stops = data.stops;
        await _database.insertStopsForEndpoint(
          stops
              .map(
                (stop) => db.StopsCompanion.insert(
                  stopId: stop.stopId,
                  stopName: stop.stopName,
                  endpoint: 'qld:${feed.id}',
                  stopCode: Value(stop.stopCode),
                  stopDesc: Value(stop.stopDesc),
                  stopLat: Value(stop.stopLat),
                  stopLon: Value(stop.stopLon),
                  platformCode: Value(stop.platformCode),
                  parentStation: Value(stop.parentStation),
                  wheelchairBoarding: Value(stop.wheelchairBoarding),
                ),
              )
              .toList(growable: false),
          'qld:${feed.id}',
        );
        completed += 1;
        yield StaticImportProgress(
          sourceId: TransitSourceId('qld:${feed.id}'),
          completed: completed,
          total: selectedFeeds.length,
          message: 'Imported ${stops.length} stops from ${feed.label}.',
        );
      } catch (error, stackTrace) {
        safeLogWarning(
          'TransLink static import failed for ${feed.id}: $error\n$stackTrace',
        );
        yield StaticImportProgress(
          sourceId: TransitSourceId('qld:${feed.id}'),
          completed: completed,
          total: selectedFeeds.length,
          message: 'Failed to import ${feed.label} GTFS.',
          error: 'The public TransLink feed could not be parsed.',
        );
      }
    }
  }
}
