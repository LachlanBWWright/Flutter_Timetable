part of '../ptv_transit_adapter.dart';

class PtvDisruptionRepository implements DisruptionRepository {
  PtvDisruptionRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitAlert>> getDisruptions(DisruptionRequest request) async {
    if (!_signedClient.isConfigured) {
      // The legacy signed PTV disruption API is not required for the current
      // Open Data integration. Metro and tram publish service alerts through
      // GTFS-Realtime; use those feeds when legacy credentials are absent.
      final alerts = <TransitAlert>[];
      const realtime = VictoriaRealtimeRepository();
      for (final feed in victoriaRealtimeFeedSets) {
        if (feed.alertsUrl == null) continue;
        try {
          final snapshot = await realtime.getAlerts(
            RealtimeRequest(sourceId: TransitSourceId('ptv:${feed.id}')),
          );
          alerts.addAll(snapshot.items);
        } catch (error, stackTrace) {
          safeLogWarning(
            'Victoria ${feed.id} disruption feed unavailable: '
            '$error\n$stackTrace',
          );
        }
      }
      return alerts;
    }
    if (request.stop != null) {
      final stopId = int.tryParse(request.stop!.stopId);
      if (stopId == null) return const <TransitAlert>[];
      final response = await _signedClient.client.v3DisruptionsStopStopIdGet(
        stopId: stopId,
        devid: _signedClient.developerId,
        signature: _signedClient.signatureForPath(
          '/v3/disruptions/stop/$stopId',
          const {},
        ),
      );
      final body = response.body;
      if (!response.isSuccessful || body == null) {
        throw const ProviderUnavailable(
          message: 'Failed to load PTV disruptions.',
        );
      }
      return _flattenDisruptions(body.disruptions);
    }
    final response = await _signedClient.client.v3DisruptionsGet(
      devid: _signedClient.developerId,
      signature: _signedClient.signatureForPath('/v3/disruptions', const {}),
    );
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw const ProviderUnavailable(
        message: 'Failed to load PTV disruptions.',
      );
    }
    return _flattenDisruptions(body.disruptions);
  }

  List<TransitAlert> _flattenDisruptions(V3Disruptions? disruptions) {
    if (disruptions == null) return const <TransitAlert>[];
    final items = <V3Disruption>[
      ...?disruptions.general,
      ...?disruptions.metroTrain,
      ...?disruptions.metroTram,
      ...?disruptions.metroBus,
      ...?disruptions.regionalTrain,
      ...?disruptions.regionalCoach,
      ...?disruptions.regionalBus,
      ...?disruptions.schoolBus,
      ...?disruptions.telebus,
      ...?disruptions.nightBus,
      ...?disruptions.ferry,
      ...?disruptions.interstateTrain,
      ...?disruptions.skybus,
      ...?disruptions.taxi,
    ];
    return items
        .map(
          (item) => TransitAlert(
            id: '${item.disruptionId ?? item.title ?? item.description ?? item.hashCode}',
            title: item.title ?? 'Disruption',
            description: item.description,
            severity: item.disruptionStatus,
          ),
        )
        .toList(growable: false);
  }
}
