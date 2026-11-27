import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/gtfs/persistent_gtfs_store.dart';
import 'package:lbww_flutter/transit/gtfs/scheduled_gtfs_departures.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
part 'public_gtfs_departures.dart';

typedef PublicGtfsFetcher = Future<http.Response> Function(Uri uri);

Future<http.Response> _fetchPublicGtfsFeed(Uri uri) =>
    AppHttpClient.getOrThrow(uri);

class PublicGtfsFeedConfig {
  const PublicGtfsFeedConfig({
    required this.sourceId,
    required this.label,
    required this.url,
  });

  final TransitSourceId sourceId;
  final String label;
  final String url;
}

class PublicGtfsProviderConfig {
  const PublicGtfsProviderConfig({
    required this.region,
    required this.provider,
    required this.attributionName,
    required this.attributionUrl,
    required this.feeds,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final String attributionName;
  final String attributionUrl;
  final List<PublicGtfsFeedConfig> feeds;
}

TransitRegionServices buildPublicGtfsRegionServices({
  required PublicGtfsProviderConfig config,
  db.AppDatabase? database,
  PublicGtfsFetcher fetcher = _fetchPublicGtfsFeed,
}) {
  final staticData = PublicGtfsStaticRepository(
    config: config,
    database: database,
    fetcher: fetcher,
  );
  final timetable = PublicGtfsDepartureRepository(
    database: database,
    config: config,
    fetcher: fetcher,
  );
  return TransitRegionServices(
    region: config.region,
    provider: config.provider,
    stops: StaticBackedStopRepository(
      region: config.region,
      provider: config.provider,
      sources: config.feeds.map((feed) => feed.sourceId).toList(),
      cachedStops: PublicGtfsStopRepository(config: config, database: database),
      staticData: staticData,
      database: database,
    ),
    staticGtfs: staticData,
    timetableLoader: timetable.loadFeed,
    cancellableTimetableLoader: (source, token) =>
        timetable.loadFeed(source, cancellation: token),
    timetableSources: config.feeds.map((feed) => feed.sourceId).toList(),
    departures: timetable,
    journeyPlanner: GtfsJourneyPlanner(
      region: config.region,
      provider: config.provider,
      loadCancellableData: (source, token) =>
          timetable.loadFeed(source, cancellation: token),
      loadData: (sourceId) => timetable.loadFeed(sourceId),
    ),
    attribution: TransitProviderAttribution(
      provider: config.provider,
      name: config.attributionName,
      licenseName: 'Creative Commons Attribution 4.0 International',
      url: config.attributionUrl,
    ),
  );
}

class PublicGtfsStopRepository implements StopRepository {
  const PublicGtfsStopRepository({required this.config, this.database});

  final PublicGtfsProviderConfig config;
  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    if (!stop.belongsTo(config.region, config.provider) ||
        !config.feeds.any((feed) => feed.sourceId == stop.sourceId)) {
      return null;
    }
    final row = (await _database.getStopsById(stop.stopId))
        .where((candidate) => candidate.endpoint == stop.sourceId.value)
        .firstOrNull;
    return row == null ? null : _mapStop(row);
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final sourceIds = config.feeds.map((feed) => feed.sourceId.value).toSet();
    return (await _database.searchStops(
      query,
      limit: request.limit,
      endpoints: sourceIds,
    )).map(_mapStop).toList(growable: false);
  }

  TransitStop _mapStop(db.Stop row) => TransitStop(
    ref: TransitStopRef(
      region: config.region,
      provider: config.provider,
      sourceId: TransitSourceId(row.endpoint),
      stopId: row.stopId,
    ),
    name: row.stopName,
    latitude: row.stopLat,
    longitude: row.stopLon,
    stopCode: row.stopCode,
    platformCode: row.platformCode,
    description: row.stopDesc,
  );
}

class PublicGtfsStaticRepository implements StaticGtfsRepository {
  const PublicGtfsStaticRepository({
    required this.config,
    this.database,
    this.fetcher = _fetchPublicGtfsFeed,
  });

  final PublicGtfsProviderConfig config;
  final db.AppDatabase? database;
  final PublicGtfsFetcher fetcher;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final knownSources = config.feeds.map((feed) => feed.sourceId).toSet();
    if (request.sourceIds?.any((source) => !knownSources.contains(source)) ==
        true) {
      throw const InvalidJourneyRequest(
        message: 'The requested public GTFS source is not configured.',
      );
    }
    final feeds = request.sourceIds == null || request.sourceIds!.isEmpty
        ? config.feeds
        : config.feeds
              .where((feed) => request.sourceIds!.contains(feed.sourceId))
              .toList(growable: false);
    var completed = 0;
    for (final feed in feeds) {
      yield StaticImportProgress(
        sourceId: feed.sourceId,
        completed: completed,
        total: feeds.length,
        message: 'Downloading ${feed.label} static GTFS…',
      );
      try {
        final data = await PersistentGtfsStore(database: _database).load(
          source: feed.sourceId.value,
          parse: parseGtfsStopSnapshot,
          force: request.force,
          cancellation: request.cancellation,
          download: (cancellation) async {
            final uri = Uri.parse(feed.url);
            final response = fetcher == _fetchPublicGtfsFeed
                ? await AppHttpClient.getOrThrow(
                    uri,
                    cancellation: cancellation,
                  )
                : await cancellation.wait(fetcher(uri));
            if (response.statusCode < 200 || response.statusCode >= 300) {
              throw const ProviderUnavailable(
                message: 'The timetable could not be downloaded.',
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
                  endpoint: feed.sourceId.value,
                  stopCode: Value(stop.stopCode),
                  stopDesc: Value(stop.stopDesc),
                  stopLat: Value(stop.stopLat),
                  stopLon: Value(stop.stopLon),
                  platformCode: Value(stop.platformCode),
                  wheelchairBoarding: Value(stop.wheelchairBoarding),
                  parentStation: Value(stop.parentStation),
                ),
              )
              .toList(growable: false),
          feed.sourceId.value,
        );
        completed += 1;
        yield StaticImportProgress(
          sourceId: feed.sourceId,
          completed: completed,
          total: feeds.length,
          message: 'Imported ${stops.length} stops from ${feed.label}.',
        );
      } catch (error, stackTrace) {
        safeLogWarning(
          '${feed.label} static GTFS import failed: $error\n$stackTrace',
        );
        yield StaticImportProgress(
          sourceId: feed.sourceId,
          completed: completed,
          total: feeds.length,
          message: 'Failed to parse ${feed.label} GTFS.',
          error: error is TransitFailure
              ? error.message ?? error.toString()
              : 'The public ${feed.label} feed could not be parsed.',
        );
      }
    }
  }
}
