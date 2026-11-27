part of '../ptv_transit_adapter.dart';

class VictoriaStaticGtfsRepository implements StaticGtfsRepository {
  VictoriaStaticGtfsRepository({PtvCredentials? credentials, this._database})
    : _credentials = credentials ?? loadPtvCredentials();

  final PtvCredentials _credentials;
  final db.AppDatabase? _database;

  db.AppDatabase get database => _database ?? db.AppDatabase();

  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    if (request.sourceIds?.any((source) => source.value != 'ptv:static') ==
        true) {
      throw const InvalidJourneyRequest(
        message: 'Unknown Victoria static source.',
      );
    }
    yield const StaticImportProgress(
      sourceId: TransitSourceId('ptv:static'),
      completed: 0,
      total: 1,
      message: 'Downloading Victoria timetable…',
    );
    final data = await _loadVictoriaGtfs(
      requireTimetable: false,
      database: database,
      force: request.force,
      cancellation: request.cancellation,
    );
    request.cancellation?.throwIfCancelled();
    final stops = data.stops;
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
              parentStation: Value(stop.parentStation),
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
