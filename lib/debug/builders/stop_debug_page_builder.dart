import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

class StopDebugPageBuilder {
  final DebugEntityResolver resolver;

  const StopDebugPageBuilder({required this.resolver});

  Future<DebugPageData> build(DebugEntityRequest request) async {
    final stopId = request.entityId;
    final apiStop = DebugExtractors.bestStopFromContext(
      stopId,
      preferredStop: request.context.apiStop,
      leg: request.context.leg,
      trip: request.context.tripJourney,
    );
    final dbStops =
        request.context.dbStops ?? await resolver.lookupDbStops(stopId);
    final endpointHints = _endpointHintsForRows(dbStops);
    final gtfsStop = await resolver.resolveGtfsStop(
      stopId: stopId,
      explicitData: request.context.gtfsData,
      explicitEndpoint: request.context.gtfsEndpoint,
      endpointHints: endpointHints,
    );
    final title =
        apiStop?.disassembledName ??
        apiStop?.name ??
        gtfsStop?.stop.stopName ??
        (dbStops.isNotEmpty ? dbStops.first.stopName : stopId);

    final routeRefs = _routeReferences(request, stopId, gtfsStop?.data);
    final tripRefs = _tripReferences(request, stopId);
    final parentRefs = _parentReferences(
      request,
      apiStop,
      dbStops,
      gtfsStop?.stop.parentStation,
    );
    final banners = <DebugStatusBannerData>[];
    if (apiStop == null && dbStops.isEmpty && gtfsStop == null) {
      banners.add(
        const DebugStatusBannerData(
          tone: DebugStatusTone.warning,
          title: 'Unresolved stop',
          message:
              'This stop could not be enriched from API, local DB, or GTFS using the current context.',
          sources: [
            DebugDataSource.api,
            DebugDataSource.localDb,
            DebugDataSource.gtfs,
          ],
        ),
      );
    }

    return DebugPageData(
      entityType: DebugEntityType.stop,
      title: title,
      canonicalId: stopId,
      aliases: DebugExtractors.dedupeStrings([
        apiStop?.parent?.id,
        gtfsStop?.stop.parentStation,
        ...dbStops.map((row) => row.stopCode),
      ], exclude: stopId),
      sourceBadges: [
        if (apiStop != null) DebugDataSource.api,
        if (dbStops.isNotEmpty) DebugDataSource.localDb,
        if (gtfsStop != null) DebugDataSource.gtfs,
        DebugDataSource.derived,
      ],
      banners: banners,
      sections: [
        DebugSectionData(
          title: 'Identity',
          sources: const [
            DebugDataSource.api,
            DebugDataSource.localDb,
            DebugDataSource.gtfs,
          ],
          fields: [
            DebugFieldRow(label: 'Stop ID', value: stopId),
            DebugFieldRow(label: 'API name', value: apiStop?.name ?? 'N/A'),
            DebugFieldRow(
              label: 'Disassembled name',
              value: apiStop?.disassembledName ?? 'N/A',
            ),
            DebugFieldRow(label: 'Type', value: apiStop?.type ?? 'N/A'),
            DebugFieldRow(
              label: 'Coordinates',
              value: apiStop?.coord == null
                  ? 'N/A'
                  : apiStop!.coord!.join(', '),
            ),
            DebugFieldRow(
              label: 'Arrival planned / estimated',
              value:
                  '${apiStop?.arrivalTimePlanned ?? 'N/A'} / ${apiStop?.arrivalTimeEstimated ?? 'N/A'}',
            ),
            DebugFieldRow(
              label: 'Departure planned / estimated',
              value:
                  '${apiStop?.departureTimePlanned ?? 'N/A'} / ${apiStop?.departureTimeEstimated ?? 'N/A'}',
            ),
          ],
        ),
        DebugSectionData(
          title: 'References',
          sources: const [DebugDataSource.api, DebugDataSource.derived],
          references: [...parentRefs, ...tripRefs, ...routeRefs],
          emptyMessage:
              'No related parent, trip, or route references could be derived for this stop.',
        ),
        DebugSectionData(
          title: 'Local DB rows',
          sources: const [DebugDataSource.localDb],
          fields: _dbFields(dbStops),
          emptyMessage: 'No local DB stop rows were found.',
        ),
        DebugSectionData(
          title: 'Derived data',
          sources: const [DebugDataSource.gtfs, DebugDataSource.derived],
          fields: [
            DebugFieldRow(
              label: 'GTFS stop name',
              value: gtfsStop?.stop.stopName ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'GTFS platform code',
              value: gtfsStop?.stop.platformCode ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'GTFS endpoint',
              value: gtfsStop?.endpoint?.key ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Serving routes derived',
              value: routeRefs.length.toString(),
            ),
          ],
        ),
        DebugSectionData(
          title: 'Raw data',
          sources: const [DebugDataSource.api],
          rawJsonBlocks: [
            DebugJsonBlock(
              title: 'API stop raw JSON',
              data: apiStop?.rawJson ?? request.context.rawPayload,
              sources: const [DebugDataSource.api],
            ),
          ],
        ),
      ],
    );
  }

  Iterable<StopsEndpoint> _endpointHintsForRows(List<db.Stop> rows) sync* {
    final endpointByKey = {
      for (final endpoint in StopsEndpoint.values) endpoint.key: endpoint,
    };
    final seen = <String>{};
    for (final row in rows) {
      final endpoint = endpointByKey[row.endpoint];
      if (endpoint != null && seen.add(endpoint.key)) {
        yield endpoint;
      }
    }
  }

  List<DebugFieldRow> _dbFields(List<db.Stop> rows) {
    return rows
        .map((row) {
          final mode = StopsService.modeForEndpointKey(row.endpoint);
          return DebugFieldRow(
            label: row.endpoint,
            value:
                '${row.stopName} • code=${row.stopCode ?? 'N/A'} • parent=${row.parentStation ?? 'N/A'} • locality=${row.stopDesc ?? 'N/A'} • mode=${mode?.name ?? 'unknown'}',
            sources: const [DebugDataSource.localDb],
          );
        })
        .toList(growable: false);
  }

  List<DebugEntityRef> _parentReferences(
    DebugEntityRequest request,
    api.Stop? apiStop,
    List<db.Stop> dbStops,
    String? gtfsParentStation,
  ) {
    final parentIds = <String>{};
    if (apiStop?.parent?.id case final id?) {
      parentIds.add(id);
    }
    for (final row in dbStops) {
      if (row.parentStation != null && row.parentStation!.isNotEmpty) {
        parentIds.add(row.parentStation!);
      }
    }
    if (gtfsParentStation != null && gtfsParentStation.isNotEmpty) {
      parentIds.add(gtfsParentStation);
    }

    return parentIds
        .map((parentId) {
          return DebugEntityRef(
            entityType: DebugEntityType.stop,
            entityId: parentId,
            title: 'Parent stop',
            subtitle: parentId,
            sources: const [
              DebugDataSource.api,
              DebugDataSource.localDb,
              DebugDataSource.gtfs,
            ],
            request: DebugEntityRequest(
              entityType: DebugEntityType.stop,
              entityId: parentId,
              context: request.context,
            ),
          );
        })
        .toList(growable: false);
  }

  List<DebugEntityRef> _tripReferences(
    DebugEntityRequest request,
    String stopId,
  ) {
    final trip = request.context.tripJourney;
    if (trip == null) {
      return const [];
    }
    final containsStop = DebugExtractors.collectStopsForTrip(
      trip,
    ).any((stop) => stop.id == stopId);
    if (!containsStop) {
      return const [];
    }

    final tripIds = DebugExtractors.collectTripIdsForTrip(trip);
    final canonicalId = tripIds.isNotEmpty ? tripIds.first : request.entityId;
    return [
      DebugEntityRef(
        entityType: DebugEntityType.trip,
        entityId: canonicalId,
        title: 'Current trip context',
        subtitle: canonicalId,
        sources: const [DebugDataSource.api, DebugDataSource.derived],
        request: DebugEntityRequest(
          entityType: DebugEntityType.trip,
          entityId: canonicalId,
          context: request.context,
        ),
      ),
    ];
  }

  List<DebugEntityRef> _routeReferences(
    DebugEntityRequest request,
    String stopId,
    GtfsData? gtfsData,
  ) {
    final refs = <DebugEntityRef>[];
    final seenRoutes = <String>{};

    final trip = request.context.tripJourney;
    if (trip != null) {
      for (final leg in trip.legs) {
        final stops = <String>{
          leg.origin.id,
          leg.destination.id,
          ...?leg.stopSequence?.map((stop) => stop.id),
        };
        final routeId = leg.transportation?.id;
        if (routeId != null &&
            routeId.isNotEmpty &&
            stops.contains(stopId) &&
            seenRoutes.add(routeId)) {
          refs.add(
            DebugEntityRef(
              entityType: DebugEntityType.route,
              entityId: routeId,
              title: 'Route from current trip',
              subtitle: leg.transportation?.name ?? routeId,
              sources: const [DebugDataSource.api, DebugDataSource.derived],
              request: DebugEntityRequest(
                entityType: DebugEntityType.route,
                entityId: routeId,
                context: request.context.copyWith(
                  leg: leg,
                  transportation: leg.transportation,
                ),
              ),
            ),
          );
        }
      }
    }

    if (gtfsData != null) {
      final stopTimes = gtfsData.stopTimes.where(
        (stopTime) => stopTime.stopId == stopId,
      );
      final tripById = {for (final trip in gtfsData.trips) trip.tripId: trip};
      for (final stopTime in stopTimes) {
        final routeId = tripById[stopTime.tripId]?.routeId;
        if (routeId == null || routeId.isEmpty || !seenRoutes.add(routeId)) {
          continue;
        }
        refs.add(
          DebugEntityRef(
            entityType: DebugEntityType.route,
            entityId: routeId,
            title: 'GTFS serving route',
            subtitle: routeId,
            sources: const [DebugDataSource.gtfs, DebugDataSource.derived],
            request: DebugEntityRequest(
              entityType: DebugEntityType.route,
              entityId: routeId,
              context: request.context.copyWith(gtfsData: gtfsData),
            ),
          ),
        );
      }
    }

    return refs;
  }
}
