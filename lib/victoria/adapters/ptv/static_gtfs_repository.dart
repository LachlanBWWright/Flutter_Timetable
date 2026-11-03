part of '../ptv_transit_adapter.dart';

class VictoriaStaticGtfsRepository implements StaticGtfsRepository {
  VictoriaStaticGtfsRepository({
    PtvCredentials? credentials,
    db.AppDatabase? database,
  }) : _credentials = credentials ?? loadPtvCredentials(),
       _database = database;

  final PtvCredentials _credentials;
  final db.AppDatabase? _database;

  db.AppDatabase get database => _database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final url = _readEnv('VICTORIA_STATIC_GTFS_URL').isNotEmpty
        ? _readEnv('VICTORIA_STATIC_GTFS_URL')
        : victoriaStaticGtfsUrl;
    yield const StaticImportProgress(
      sourceId: TransitSourceId('ptv:static'),
      completed: 0,
      total: 1,
      message: 'Downloading Victoria static GTFS…',
    );
    final uri = tryParseUriValue(url);
    final response = uri == null ? null : await AppHttpClient.get(uri);
    if (response == null || response.statusCode != 200) {
      throw const ProviderUnavailable(
        message: 'Failed to download Victoria static GTFS.',
      );
    }
    final stops = await compute(
      parseVictoriaStopsFromZip,
      Uint8List.fromList(response.bodyBytes),
    );
    await database.insertStopsForEndpoint(
      stops
          .map(
            (stop) => db.StopsCompanion.insert(
              stopId: stop.stopId,
              stopName: stop.stopName,
              endpoint: 'ptv:static',
              stopCode: Value(stop.stopCode),
              stopDesc: Value(stop.stopDesc),
              stopLat: Value(stop.stopLat),
              stopLon: Value(stop.stopLon),
              platformCode: Value(stop.platformCode),
              wheelchairBoarding: Value(stop.wheelchairBoarding),
            ),
          )
          .toList(growable: false),
      'ptv:static',
    );
    yield StaticImportProgress(
      sourceId: const TransitSourceId('ptv:static'),
      completed: 1,
      total: 1,
      message: 'Imported ${stops.length} Victoria stops.',
    );
    final _ = _credentials;
  }
}
