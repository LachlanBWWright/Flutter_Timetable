import 'dart:collection';

import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

class RouteDebugPageBuilder {
  final DebugEntityResolver resolver;

  const RouteDebugPageBuilder({required this.resolver});

  Future<DebugPageData> build(DebugEntityRequest request) async {
    final routeId = request.entityId;
    final transport = DebugExtractors.bestTransportationFromContext(
      routeId,
      preferredTransportation: request.context.transportation,
      leg: request.context.leg,
      trip: request.context.tripJourney,
    );
    final gtfsMatch = await resolver.resolveGtfsRoute(
      routeId: routeId,
      leg: request.context.leg,
      trip: request.context.tripJourney,
      transportation: transport,
      explicitRoute: request.context.gtfsRoute,
      explicitAgency: request.context.gtfsAgency,
      explicitData: request.context.gtfsData,
      explicitEndpoint: request.context.gtfsEndpoint,
      explicitMatchReason: request.context.gtfsMatchReason,
    );

    final vehicles = await resolver.matchVehicles(routeIds: {routeId});
    final tripUpdates = await resolver.matchTripUpdates(routeIds: {routeId});
    final servedStopRefs = _servedStopReferences(
      request,
      gtfsMatch?.data,
      routeId,
    );
    final tripRefs = _tripReferences(request, tripUpdates);
    final title =
        transport?.name ??
        transport?.disassembledName ??
        gtfsMatch?.route.routeLongName ??
        routeId;
    final aliases = DebugExtractors.dedupeStrings([
      transport?.number,
      transport?.id,
      gtfsMatch?.route.routeShortName,
      gtfsMatch?.route.routeLongName,
    ], exclude: routeId);

    final banners = <DebugStatusBannerData>[];
    if (gtfsMatch == null) {
      banners.add(
        const DebugStatusBannerData(
          tone: DebugStatusTone.warning,
          title: 'No GTFS route match',
          message:
              'The route page could not match this route against GTFS using the available stop and mode context.',
          sources: [DebugDataSource.gtfs, DebugDataSource.derived],
        ),
      );
    }

    return DebugPageData(
      entityType: DebugEntityType.route,
      title: title,
      canonicalId: routeId,
      aliases: aliases,
      sourceBadges: [
        if (transport != null) DebugDataSource.api,
        if (gtfsMatch != null) DebugDataSource.gtfs,
        if (vehicles.isNotEmpty || tripUpdates.isNotEmpty)
          DebugDataSource.realtime,
        DebugDataSource.derived,
      ],
      banners: banners,
      sections: [
        DebugSectionData(
          title: 'Identity',
          sources: const [DebugDataSource.api, DebugDataSource.gtfs],
          fields: [
            DebugFieldRow(label: 'Route ID', value: routeId),
            DebugFieldRow(
              label: 'Name',
              value:
                  transport?.name ??
                  transport?.disassembledName ??
                  gtfsMatch?.route.routeLongName ??
                  'N/A',
            ),
            DebugFieldRow(
              label: 'Number',
              value:
                  transport?.number ?? gtfsMatch?.route.routeShortName ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Description',
              value:
                  transport?.description ?? gtfsMatch?.route.routeDesc ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Operator',
              value: transport?.operator?.name ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Destination',
              value: transport?.destination?.name ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Product',
              value: transport?.product?.name ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Product class',
              value: transport?.product?.classField?.toString() ?? 'N/A',
            ),
          ],
        ),
        DebugSectionData(
          title: 'References',
          sources: const [
            DebugDataSource.api,
            DebugDataSource.realtime,
            DebugDataSource.gtfs,
          ],
          references: [
            ..._destinationStopReference(request, transport),
            ...tripRefs,
            ..._vehicleReferences(request, vehicles),
          ],
          emptyMessage:
              'No related trip, vehicle, or destination stop references were found.',
        ),
        DebugSectionData(
          title: 'Served stops',
          sources: const [DebugDataSource.gtfs, DebugDataSource.derived],
          references: servedStopRefs,
          emptyMessage:
              'Served stops could not be derived from the available GTFS data.',
        ),
        DebugSectionData(
          title: 'Derived data',
          sources: const [
            DebugDataSource.gtfs,
            DebugDataSource.realtime,
            DebugDataSource.derived,
          ],
          fields: [
            DebugFieldRow(
              label: 'GTFS endpoint',
              value: gtfsMatch?.endpoint?.key ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'GTFS match reason',
              value: gtfsMatch?.matchReason ?? 'No GTFS match',
            ),
            DebugFieldRow(
              label: 'GTFS route short name',
              value: gtfsMatch?.route.routeShortName ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'GTFS route long name',
              value: gtfsMatch?.route.routeLongName ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'GTFS agency',
              value: gtfsMatch?.agency?.agencyName ?? 'N/A',
            ),
            DebugFieldRow(
              label: 'Active trip updates',
              value: tripUpdates.length.toString(),
              sources: const [DebugDataSource.realtime],
            ),
            DebugFieldRow(
              label: 'Active vehicles',
              value: vehicles.length.toString(),
              sources: const [DebugDataSource.realtime],
            ),
            DebugFieldRow(
              label: 'Derived served stops',
              value: servedStopRefs.length.toString(),
              sources: const [DebugDataSource.gtfs, DebugDataSource.derived],
            ),
          ],
        ),
        DebugSectionData(
          title: 'Raw data',
          sources: const [DebugDataSource.api],
          rawJsonBlocks: [
            DebugJsonBlock(
              title: 'Transportation raw JSON',
              data: transport?.rawJson ?? request.context.rawPayload,
              sources: const [DebugDataSource.api],
            ),
          ],
        ),
      ],
    );
  }

  List<DebugEntityRef> _destinationStopReference(
    DebugEntityRequest request,
    api.Transportation? transportation,
  ) {
    final destinationId = transportation?.destination?.id;
    if (destinationId == null || destinationId.isEmpty) {
      return const [];
    }
    return [
      DebugEntityRef(
        entityType: DebugEntityType.stop,
        entityId: destinationId,
        title: 'Destination stop',
        subtitle: transportation?.destination?.name,
        sources: const [DebugDataSource.api],
        request: DebugEntityRequest(
          entityType: DebugEntityType.stop,
          entityId: destinationId,
          context: request.context,
        ),
      ),
    ];
  }

  List<DebugEntityRef> _tripReferences(
    DebugEntityRequest request,
    List<TripUpdate> tripUpdates,
  ) {
    final refs = <DebugEntityRef>[];
    final seenTripIds = <String>{};
    for (final update in tripUpdates) {
      final tripId = update.trip.hasTripId() ? update.trip.tripId : null;
      if (tripId == null || tripId.isEmpty || !seenTripIds.add(tripId)) {
        continue;
      }
      refs.add(
        DebugEntityRef(
          entityType: DebugEntityType.trip,
          entityId: tripId,
          title: 'Active trip',
          subtitle: update.trip.hasStartDate() ? update.trip.startDate : null,
          sources: const [DebugDataSource.realtime],
          request: DebugEntityRequest(
            entityType: DebugEntityType.trip,
            entityId: tripId,
            context: request.context.copyWith(tripUpdate: update),
          ),
        ),
      );
    }
    return refs;
  }

  List<DebugEntityRef> _vehicleReferences(
    DebugEntityRequest request,
    List<VehiclePosition> vehicles,
  ) {
    return vehicles
        .map((vehicle) {
          final vehicleId =
              DebugExtractors.vehicleId(vehicle) ??
              DebugExtractors.vehicleDisplayId(vehicle);
          return DebugEntityRef(
            entityType: DebugEntityType.vehicle,
            entityId: vehicleId,
            title: 'Active vehicle',
            subtitle: DebugExtractors.vehicleDisplayId(vehicle),
            sources: const [DebugDataSource.realtime],
            request: DebugEntityRequest(
              entityType: DebugEntityType.vehicle,
              entityId: vehicleId,
              context: request.context.copyWith(vehiclePosition: vehicle),
            ),
          );
        })
        .toList(growable: false);
  }

  List<DebugEntityRef> _servedStopReferences(
    DebugEntityRequest request,
    GtfsData? gtfsData,
    String routeId,
  ) {
    if (gtfsData == null) {
      return const [];
    }

    final trips = resolver.tripsForRoute(gtfsData, routeId);
    final tripIds = trips.map((trip) => trip.tripId).toSet();
    final stopTimes = resolver.stopTimesForTrips(gtfsData, tripIds);
    if (stopTimes.isEmpty) {
      return const [];
    }

    final stopById = {for (final stop in gtfsData.stops) stop.stopId: stop};
    final refs = <DebugEntityRef>[];
    final seen = LinkedHashSet<String>();
    for (final stopTime in stopTimes) {
      if (!seen.add(stopTime.stopId)) {
        continue;
      }
      final stop = stopById[stopTime.stopId];
      refs.add(
        DebugEntityRef(
          entityType: DebugEntityType.stop,
          entityId: stopTime.stopId,
          title: stop?.stopName ?? stopTime.stopId,
          subtitle: 'Served stop',
          sources: const [DebugDataSource.gtfs, DebugDataSource.derived],
          request: DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: stopTime.stopId,
            context: request.context.copyWith(gtfsData: gtfsData),
          ),
        ),
      );
      if (refs.length >= 50) {
        break;
      }
    }
    return refs;
  }
}
