part of '../adelaide_metro_transit_adapter.dart';

class AdelaideMetroStopRepository implements StopRepository {
  const AdelaideMetroStopRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final rows = await _database.getStopsById(stop.stopId);
    final match = rows
        .where((row) => row.endpoint == stop.sourceId.value)
        .firstOrNull;
    return match == null ? null : _mapStop(match);
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final rows = await _database.searchStops(
      query,
      limit: request.limit,
      endpointPrefix: 'sa:',
    );
    return rows.map(_mapStop).toList(growable: false);
  }

  TransitStop _mapStop(db.Stop row) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.southAustralia,
        provider: TransitProviderId.adelaideMetro,
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
}

class AdelaideMetroStaticGtfsRepository implements StaticGtfsRepository {
  const AdelaideMetroStaticGtfsRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    yield const StaticImportProgress(
      sourceId: TransitSourceId('sa:static'),
      completed: 0,
      total: 1,
      message: 'Downloading Adelaide Metro static GTFS…',
    );
    final response = await AppHttpClient.get(
      Uri.parse(adelaideMetroStaticGtfsUrl),
    );
    if (response == null || response.statusCode != 200) {
      yield const StaticImportProgress(
        sourceId: TransitSourceId('sa:static'),
        completed: 0,
        total: 1,
        message: 'Failed to download Adelaide Metro GTFS.',
        error: 'The public Adelaide Metro feed was unavailable.',
      );
      return;
    }
    try {
      final stops = await compute(
        parseStopsOnlyFromZipBytes,
        Uint8List.fromList(response.bodyBytes),
      );
      await _database.insertStopsForEndpoint(
        stops
            .map(
              (stop) => db.StopsCompanion.insert(
                stopId: stop.stopId,
                stopName: stop.stopName,
                endpoint: 'sa:static',
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
        'sa:static',
      );
      yield StaticImportProgress(
        sourceId: const TransitSourceId('sa:static'),
        completed: 1,
        total: 1,
        message: 'Imported ${stops.length} Adelaide Metro stops.',
      );
    } catch (error, stackTrace) {
      safeLogWarning(
        'Adelaide Metro static import failed: $error\n$stackTrace',
      );
      yield const StaticImportProgress(
        sourceId: TransitSourceId('sa:static'),
        completed: 0,
        total: 1,
        message: 'Failed to parse Adelaide Metro GTFS.',
        error: 'The public Adelaide Metro feed could not be parsed.',
      );
    }
  }
}
