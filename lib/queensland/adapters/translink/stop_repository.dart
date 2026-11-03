part of '../translink_transit_adapter.dart';

class TranslinkStopRepository implements StopRepository {
  const TranslinkStopRepository({this.database});

  final db.AppDatabase? database;

  db.AppDatabase get _database => database ?? db.AppDatabase();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    final rows = await _database.getStopsById(stop.stopId);
    final match = rows
        .where((row) => row.endpoint == stop.sourceId.value)
        .firstOrNull;
    if (match == null) {
      return null;
    }
    return _mapStop(
      match.stopId,
      match.stopName,
      match.endpoint,
      latitude: match.stopLat,
      longitude: match.stopLon,
      platformCode: match.platformCode,
    );
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const <TransitStop>[];
    final rows = await _database.searchStops(
      query,
      limit: request.limit,
      endpointPrefix: 'qld:',
    );
    return rows
        .map(
          (row) => _mapStop(
            row.stopId,
            row.stopName,
            row.endpoint,
            latitude: row.stopLat,
            longitude: row.stopLon,
            platformCode: row.platformCode,
            stopCode: row.stopCode,
            description: row.stopDesc,
          ),
        )
        .toList(growable: false);
  }

  TransitStop _mapStop(
    String stopId,
    String stopName,
    String endpoint, {
    double? latitude,
    double? longitude,
    String? platformCode,
    String? stopCode,
    String? description,
  }) {
    return TransitStop(
      ref: TransitStopRef(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        sourceId: TransitSourceId(endpoint),
        stopId: stopId,
      ),
      name: stopName,
      mode: _modeFromStopName(stopName),
      latitude: latitude,
      longitude: longitude,
      platformCode: platformCode,
      stopCode: stopCode,
      description: description,
    );
  }
}
