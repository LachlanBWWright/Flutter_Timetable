import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

class TripDebugPageBuilder {
  final DebugEntityResolver resolver;

  const TripDebugPageBuilder({required this.resolver});

  Future<DebugPageData> build(DebugEntityRequest request) async {
    final trip = request.context.tripJourney;
    final leg = request.context.leg;
    final tripIds = DebugExtractors.collectTripIdsForTrip(trip);
    if (tripIds.isEmpty && request.entityId.isNotEmpty) {
      tripIds.add(request.entityId);
    }

    final routeIds = DebugExtractors.collectRouteIdsForTrip(trip)
      ..addAll(
        DebugExtractors.dedupeStrings([
          leg?.transportation?.id,
          request.context.transportation?.id,
        ]),
      );
    final canonicalId = tripIds.isNotEmpty ? tripIds.first : request.entityId;
    final matchingVehicles = await resolver.matchVehicles(
      tripIds: tripIds,
      routeIds: routeIds,
    );
    final matchingTripUpdates = await resolver.matchTripUpdates(
      tripIds: tripIds,
      routeIds: routeIds,
    );

    final title = _titleForTrip(trip, canonicalId);
    final aliases = DebugExtractors.dedupeStrings(
      tripIds,
      exclude: canonicalId,
    );
    final sections = <DebugSectionData>[
      DebugSectionData(
        title: 'Identity',
        fields: [
          DebugFieldRow(label: 'Primary trip ID', value: canonicalId),
          DebugFieldRow(
            label: 'All trip IDs',
            value: tripIds.isEmpty ? 'None found' : tripIds.join(', '),
            sources: const [DebugDataSource.api, DebugDataSource.derived],
          ),
          DebugFieldRow(
            label: 'Route IDs',
            value: routeIds.isEmpty ? 'None found' : routeIds.join(', '),
            sources: const [DebugDataSource.api, DebugDataSource.derived],
          ),
          DebugFieldRow(
            label: 'Rating',
            value: trip?.rating?.toString() ?? 'N/A',
          ),
          DebugFieldRow(
            label: 'Additional trip',
            value: trip?.isAdditional?.toString() ?? 'Unknown',
          ),
          DebugFieldRow(
            label: 'Leg count',
            value: trip?.legs.length.toString() ?? (leg == null ? '0' : '1'),
          ),
        ],
        sources: const [DebugDataSource.api, DebugDataSource.derived],
      ),
      DebugSectionData(
        title: 'Leg summaries',
        fields: _buildLegSummaryFields(trip, leg),
        emptyMessage: 'No trip-leg data is available for this debug page.',
        sources: const [DebugDataSource.api],
      ),
      DebugSectionData(
        title: 'References',
        references: [
          ..._buildStopReferences(request, trip, leg),
          ..._buildRouteReferences(request, trip, leg),
          ..._buildVehicleReferences(request, matchingVehicles),
        ],
        emptyMessage: 'No related stops, routes, or vehicles could be derived.',
        sources: const [
          DebugDataSource.api,
          DebugDataSource.realtime,
          DebugDataSource.derived,
        ],
      ),
      DebugSectionData(
        title: 'Derived data',
        fields: [
          DebugFieldRow(
            label: 'Realtime trip updates',
            value: matchingTripUpdates.isEmpty
                ? 'No matching trip updates'
                : matchingTripUpdates
                      .map(
                        (update) => update.trip.hasTripId()
                            ? update.trip.tripId
                            : update.trip.hasRouteId()
                            ? 'route:${update.trip.routeId}'
                            : 'unknown',
                      )
                      .join(', '),
            sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          ),
          DebugFieldRow(
            label: 'Matched vehicles',
            value: matchingVehicles.isEmpty
                ? 'No matching vehicles'
                : matchingVehicles
                      .map(DebugExtractors.vehicleDisplayId)
                      .join(', '),
            sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          ),
        ],
        sources: const [DebugDataSource.realtime, DebugDataSource.derived],
      ),
      DebugSectionData(
        title: 'Raw data',
        rawJsonBlocks: [
          DebugJsonBlock(
            title: 'Trip raw JSON',
            data: trip?.rawJson ?? request.context.rawPayload,
            sources: const [DebugDataSource.api],
          ),
          ..._buildLegRawBlocks(trip, leg),
        ],
        sources: const [DebugDataSource.api],
      ),
    ];

    final banners = <DebugStatusBannerData>[];
    if (trip == null) {
      banners.add(
        const DebugStatusBannerData(
          tone: DebugStatusTone.warning,
          title: 'Partial trip context',
          message:
              'This page was opened without a TripJourney, so only derived realtime context can be shown.',
          sources: [DebugDataSource.derived],
        ),
      );
    }

    return DebugPageData(
      entityType: DebugEntityType.trip,
      title: title,
      canonicalId: canonicalId,
      aliases: aliases,
      sourceBadges: _sourceBadges(trip, matchingVehicles, matchingTripUpdates),
      banners: banners,
      sections: sections,
    );
  }

  String _titleForTrip(api.TripJourney? trip, String fallbackId) {
    if (trip == null || trip.legs.isEmpty) {
      return fallbackId;
    }
    final origin =
        trip.legs.first.origin.disassembledName ?? trip.legs.first.origin.name;
    final destination =
        trip.legs.last.destination.disassembledName ??
        trip.legs.last.destination.name;
    return '$origin -> $destination';
  }

  List<DebugFieldRow> _buildLegSummaryFields(
    api.TripJourney? trip,
    api.Leg? leg,
  ) {
    if (trip == null) {
      if (leg == null) {
        return const [];
      }
      return [
        DebugFieldRow(
          label: 'Active leg',
          value:
              '${leg.origin.name} (${leg.origin.id}) -> ${leg.destination.name} (${leg.destination.id}) via ${leg.transportation?.name ?? leg.transportation?.id ?? 'unknown route'}',
        ),
      ];
    }

    return trip.legs
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final currentLeg = entry.value;
          return DebugFieldRow(
            label: 'Leg ${index + 1}',
            value:
                '${currentLeg.origin.name} (${currentLeg.origin.id}) -> ${currentLeg.destination.name} (${currentLeg.destination.id}) via ${currentLeg.transportation?.name ?? currentLeg.transportation?.id ?? 'unknown route'}',
          );
        })
        .toList(growable: false);
  }

  List<DebugEntityRef> _buildStopReferences(
    DebugEntityRequest request,
    api.TripJourney? trip,
    api.Leg? activeLeg,
  ) {
    final references = <DebugEntityRef>[];
    final legs =
        trip?.legs ?? (activeLeg == null ? const <api.Leg>[] : [activeLeg]);
    for (final entry in legs.asMap().entries) {
      final legIndex = entry.key;
      final leg = entry.value;
      references.add(
        _stopRef(
          request,
          leg.origin,
          title: 'Leg ${legIndex + 1} origin',
          subtitle: leg.origin.name,
          leg: leg,
          trip: trip,
        ),
      );
      for (final stopEntry
          in (leg.stopSequence ?? const <api.Stop>[]).asMap().entries) {
        final stop = stopEntry.value;
        references.add(
          _stopRef(
            request,
            stop,
            title: 'Leg ${legIndex + 1} stop ${stopEntry.key + 1}',
            subtitle: stop.name,
            leg: leg,
            trip: trip,
          ),
        );
      }
      references.add(
        _stopRef(
          request,
          leg.destination,
          title: 'Leg ${legIndex + 1} destination',
          subtitle: leg.destination.name,
          leg: leg,
          trip: trip,
        ),
      );
    }
    return references;
  }

  List<DebugEntityRef> _buildRouteReferences(
    DebugEntityRequest request,
    api.TripJourney? trip,
    api.Leg? activeLeg,
  ) {
    final references = <DebugEntityRef>[];
    final legs =
        trip?.legs ?? (activeLeg == null ? const <api.Leg>[] : [activeLeg]);
    for (final entry in legs.asMap().entries) {
      final leg = entry.value;
      final routeId = leg.transportation?.id;
      if (routeId == null || routeId.isEmpty) {
        continue;
      }
      references.add(
        DebugEntityRef(
          entityType: DebugEntityType.route,
          entityId: routeId,
          title: 'Leg ${entry.key + 1} route',
          subtitle: leg.transportation?.name ?? leg.transportation?.number,
          sources: const [DebugDataSource.api],
          request: DebugEntityRequest(
            entityType: DebugEntityType.route,
            entityId: routeId,
            context: request.context.copyWith(
              leg: leg,
              tripJourney: trip,
              transportation: leg.transportation,
            ),
          ),
        ),
      );
    }
    return references;
  }

  List<DebugEntityRef> _buildVehicleReferences(
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
            title: 'Matched vehicle',
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

  DebugEntityRef _stopRef(
    DebugEntityRequest request,
    api.Stop stop, {
    required String title,
    required String subtitle,
    required api.Leg leg,
    required api.TripJourney? trip,
  }) {
    return DebugEntityRef(
      entityType: DebugEntityType.stop,
      entityId: stop.id,
      title: title,
      subtitle: subtitle,
      sources: const [DebugDataSource.api],
      request: DebugEntityRequest(
        entityType: DebugEntityType.stop,
        entityId: stop.id,
        context: request.context.copyWith(
          apiStop: stop,
          leg: leg,
          tripJourney: trip,
        ),
      ),
    );
  }

  List<DebugJsonBlock> _buildLegRawBlocks(api.TripJourney? trip, api.Leg? leg) {
    if (trip == null) {
      return [
        DebugJsonBlock(
          title: 'Active leg raw JSON',
          data: leg?.rawJson,
          sources: const [DebugDataSource.api],
        ),
      ];
    }
    return trip.legs
        .asMap()
        .entries
        .map(
          (entry) => DebugJsonBlock(
            title: 'Leg ${entry.key + 1} raw JSON',
            data: entry.value.rawJson,
            sources: const [DebugDataSource.api],
          ),
        )
        .toList(growable: false);
  }

  List<DebugDataSource> _sourceBadges(
    api.TripJourney? trip,
    List<VehiclePosition> vehicles,
    List<TripUpdate> tripUpdates,
  ) {
    return [
      if (trip != null) DebugDataSource.api,
      if (vehicles.isNotEmpty || tripUpdates.isNotEmpty)
        DebugDataSource.realtime,
      DebugDataSource.derived,
    ];
  }
}
