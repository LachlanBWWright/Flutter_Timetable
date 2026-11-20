part of '../adelaide_metro_transit_adapter.dart';

class AdelaideMetroDepartureRepository implements DepartureRepository {
  final Future<GtfsData> Function() _loadData;
  final Future<RealtimeSnapshot<TransitTripUpdate>> Function()? _loadRealtime;

  AdelaideMetroDepartureRepository({
    Future<GtfsData> Function()? loadData,
    db.AppDatabase? database,
    Future<RealtimeSnapshot<TransitTripUpdate>> Function()? loadRealtime,
  }) : _loadRealtime =
           loadRealtime ??
           (loadData == null
               ? () => const AdelaideMetroRealtimeRepository().getTripUpdates(
                   const RealtimeRequest(
                     sourceId: TransitSourceId('sa:static'),
                   ),
                 )
               : null),
       _loadData =
           loadData ?? (() => _loadAdelaideMetroGtfs(database: database));

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    validateDepartureStop(
      request.stop,
      region: TransitRegion.southAustralia,
      provider: TransitProviderId.adelaideMetro,
      acceptsSource: (source) => source.value == 'sa:static',
    );
    final data = await _loadData();
    return scheduledGtfsDepartures(
      data,
      request,
      updates: await freshGtfsUpdates(data, _loadRealtime),
    );
  }
}

Future<GtfsData> _loadAdelaideMetroGtfs({
  db.AppDatabase? database,
  bool force = false,
  bool requireTimetable = true,
  TransitCancellation? cancellation,
}) => PersistentGtfsStore(database: database).load(
  source: 'sa:static',
  requireTimetable: requireTimetable,
  parse: requireTimetable ? parseGtfsZipBytes : parseGtfsStopSnapshot,
  force: force,
  cancellation: cancellation,
  download: (cancellation) async {
    final response = await AppHttpClient.getOrThrow(
      Uri.parse(adelaideMetroStaticGtfsUrl),
      cancellation: cancellation,
    );
    return GtfsArchiveDownload.fromResponse(response);
  },
);
