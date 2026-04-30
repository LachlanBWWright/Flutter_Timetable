import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

class VehicleDebugPageBuilder {
  final DebugEntityResolver resolver;

  const VehicleDebugPageBuilder({required this.resolver});

  Future<DebugPageData> build(DebugEntityRequest request) async {
    final requestedVehicleId = request.entityId;
    final preferredVehicle = request.context.vehiclePosition;
    final vehicle = await resolver.resolveVehicle(
      preferredVehicle: preferredVehicle,
      vehicleId: requestedVehicleId,
      tripId: request.context.tripUpdate?.trip.hasTripId() == true
          ? request.context.tripUpdate!.trip.tripId
          : null,
      routeId: request.context.tripUpdate?.trip.hasRouteId() == true
          ? request.context.tripUpdate!.trip.routeId
          : null,
    );
    final vehicleId = vehicle == null
        ? requestedVehicleId
        : DebugExtractors.vehicleId(vehicle) ??
              DebugExtractors.vehicleDisplayId(vehicle);
    final tripId = vehicle?.trip.hasTripId() == true
        ? vehicle!.trip.tripId
        : null;
    final routeId = vehicle?.trip.hasRouteId() == true
        ? vehicle!.trip.routeId
        : null;
    final derivedStops = vehicle == null
        ? const DebugDerivedVehicleStops(
            reason: 'No realtime vehicle could be resolved for this request.',
          )
        : await resolver.deriveVehicleStops(
            vehicle,
            preferredTripUpdate: request.context.tripUpdate,
          );

    final banners = <DebugStatusBannerData>[];
    if (vehicle == null) {
      banners.add(
        const DebugStatusBannerData(
          tone: DebugStatusTone.warning,
          title: 'Vehicle unresolved',
          message:
              'No realtime vehicle matched this request using vehicle ID, trip ID, or route ID.',
          sources: [DebugDataSource.realtime, DebugDataSource.derived],
        ),
      );
    } else if (derivedStops.candidateTripUpdates.length > 1) {
      banners.add(
        DebugStatusBannerData(
          tone: DebugStatusTone.info,
          title: 'Multiple trip update candidates',
          message:
              'Matched ${derivedStops.candidateTripUpdates.length} trip updates; using the best candidate for current and next stop derivation.',
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
        ),
      );
    }

    return DebugPageData(
      entityType: DebugEntityType.vehicle,
      title: vehicle?.vehicle.hasLabel() == true
          ? vehicle!.vehicle.label
          : vehicleId,
      canonicalId: vehicleId,
      aliases: DebugExtractors.dedupeStrings([
        vehicle?.vehicle.hasLabel() == true ? vehicle!.vehicle.label : null,
        vehicle?.vehicle.hasLicensePlate() == true
            ? vehicle!.vehicle.licensePlate
            : null,
      ], exclude: vehicleId),
      sourceBadges: const [DebugDataSource.realtime, DebugDataSource.derived],
      banners: banners,
      sections: [
        DebugSectionData(
          title: 'Identity',
          sources: const [DebugDataSource.realtime],
          fields: [
            DebugFieldRow(label: 'Vehicle ID', value: vehicleId),
            DebugFieldRow(
              label: 'Vehicle label',
              value: vehicle?.vehicle.hasLabel() == true
                  ? vehicle!.vehicle.label
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'License plate',
              value: vehicle?.vehicle.hasLicensePlate() == true
                  ? vehicle!.vehicle.licensePlate
                  : 'N/A',
            ),
            DebugFieldRow(label: 'Trip ID', value: tripId ?? 'N/A'),
            DebugFieldRow(label: 'Route ID', value: routeId ?? 'N/A'),
            DebugFieldRow(
              label: 'Timestamp',
              value: vehicle?.hasTimestamp() == true
                  ? DateTime.fromMillisecondsSinceEpoch(
                      vehicle!.timestamp.toInt() * 1000,
                    ).toIso8601String()
                  : 'N/A',
            ),
          ],
        ),
        DebugSectionData(
          title: 'Realtime fields',
          sources: const [DebugDataSource.realtime],
          fields: [
            DebugFieldRow(
              label: 'Position',
              value:
                  vehicle?.hasPosition() == true &&
                      vehicle!.position.hasLatitude() &&
                      vehicle.position.hasLongitude()
                  ? '${vehicle.position.latitude.toStringAsFixed(6)}, ${vehicle.position.longitude.toStringAsFixed(6)}'
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'Bearing',
              value:
                  vehicle?.hasPosition() == true &&
                      vehicle!.position.hasBearing()
                  ? vehicle.position.bearing.toStringAsFixed(2)
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'Speed',
              value:
                  vehicle?.hasPosition() == true && vehicle!.position.hasSpeed()
                  ? vehicle.position.speed.toStringAsFixed(2)
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'Current stop sequence',
              value: vehicle?.hasCurrentStopSequence() == true
                  ? vehicle!.currentStopSequence.toString()
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'Current status',
              value: vehicle?.hasCurrentStatus() == true
                  ? vehicle!.currentStatus.name
                  : 'N/A',
            ),
            DebugFieldRow(
              label: 'Occupancy',
              value: vehicle?.hasOccupancyStatus() == true
                  ? vehicle!.occupancyStatus.name
                  : 'N/A',
            ),
          ],
        ),
        DebugSectionData(
          title: 'References',
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          references: [
            if (tripId != null && tripId.isNotEmpty)
              DebugEntityRef(
                entityType: DebugEntityType.trip,
                entityId: tripId,
                title: 'Trip',
                subtitle: tripId,
                sources: const [DebugDataSource.realtime],
                request: DebugEntityRequest(
                  entityType: DebugEntityType.trip,
                  entityId: tripId,
                  context: request.context.copyWith(vehiclePosition: vehicle),
                ),
              ),
            if (routeId != null && routeId.isNotEmpty)
              DebugEntityRef(
                entityType: DebugEntityType.route,
                entityId: routeId,
                title: 'Route',
                subtitle: routeId,
                sources: const [DebugDataSource.realtime],
                request: DebugEntityRequest(
                  entityType: DebugEntityType.route,
                  entityId: routeId,
                  context: request.context.copyWith(vehiclePosition: vehicle),
                ),
              ),
            ..._stopReferences(request, derivedStops),
          ],
          emptyMessage:
              'No trip, route, or stop references could be derived for this vehicle.',
        ),
        DebugSectionData(
          title: 'Derived data',
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          fields: [
            DebugFieldRow(
              label: 'Stop derivation reason',
              value: derivedStops.reason,
            ),
            DebugFieldRow(
              label: 'Trip update candidates',
              value: derivedStops.candidateTripUpdates.length.toString(),
            ),
            DebugFieldRow(
              label: 'Matched trip update trip ID',
              value: derivedStops.matchedTripUpdate?.trip.hasTripId() == true
                  ? derivedStops.matchedTripUpdate!.trip.tripId
                  : 'N/A',
            ),
          ],
        ),
        DebugSectionData(
          title: 'Raw data',
          sources: const [DebugDataSource.realtime],
          rawJsonBlocks: [
            DebugJsonBlock(
              title: 'Vehicle fields',
              data: _vehicleMap(vehicle),
              sources: const [DebugDataSource.realtime],
            ),
            DebugJsonBlock(
              title: 'Matched trip update fields',
              data: _tripUpdateMap(derivedStops.matchedTripUpdate),
              sources: const [DebugDataSource.realtime],
            ),
          ],
        ),
      ],
    );
  }

  List<DebugEntityRef> _stopReferences(
    DebugEntityRequest request,
    DebugDerivedVehicleStops derivedStops,
  ) {
    final refs = <DebugEntityRef>[];
    if (derivedStops.currentStop?.hasStopId() == true) {
      refs.add(
        DebugEntityRef(
          entityType: DebugEntityType.stop,
          entityId: derivedStops.currentStop!.stopId,
          title: 'Current stop',
          subtitle: derivedStops.currentStop!.stopId,
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          request: DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: derivedStops.currentStop!.stopId,
            context: request.context.copyWith(
              tripUpdate: derivedStops.matchedTripUpdate,
            ),
          ),
        ),
      );
    }
    if (derivedStops.nextStop?.hasStopId() == true) {
      refs.add(
        DebugEntityRef(
          entityType: DebugEntityType.stop,
          entityId: derivedStops.nextStop!.stopId,
          title: 'Next stop',
          subtitle: derivedStops.nextStop!.stopId,
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          request: DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: derivedStops.nextStop!.stopId,
            context: request.context.copyWith(
              tripUpdate: derivedStops.matchedTripUpdate,
            ),
          ),
        ),
      );
    }
    return refs;
  }

  Map<String, Object?>? _vehicleMap(VehiclePosition? vehicle) {
    if (vehicle == null) {
      return null;
    }
    return {
      'vehicleId': DebugExtractors.vehicleId(vehicle),
      'vehicleLabel': vehicle.vehicle.hasLabel() ? vehicle.vehicle.label : null,
      'licensePlate': vehicle.vehicle.hasLicensePlate()
          ? vehicle.vehicle.licensePlate
          : null,
      'tripId': vehicle.trip.hasTripId() ? vehicle.trip.tripId : null,
      'routeId': vehicle.trip.hasRouteId() ? vehicle.trip.routeId : null,
      'timestamp': vehicle.hasTimestamp() ? vehicle.timestamp.toInt() : null,
      'currentStopSequence': vehicle.hasCurrentStopSequence()
          ? vehicle.currentStopSequence
          : null,
      'currentStatus': vehicle.hasCurrentStatus()
          ? vehicle.currentStatus.name
          : null,
      'occupancyStatus': vehicle.hasOccupancyStatus()
          ? vehicle.occupancyStatus.name
          : null,
      'position': vehicle.hasPosition()
          ? {
              'latitude': vehicle.position.hasLatitude()
                  ? vehicle.position.latitude
                  : null,
              'longitude': vehicle.position.hasLongitude()
                  ? vehicle.position.longitude
                  : null,
              'bearing': vehicle.position.hasBearing()
                  ? vehicle.position.bearing
                  : null,
              'speed': vehicle.position.hasSpeed()
                  ? vehicle.position.speed
                  : null,
            }
          : null,
    };
  }

  Map<String, Object?>? _tripUpdateMap(TripUpdate? tripUpdate) {
    if (tripUpdate == null) {
      return null;
    }
    return {
      'tripId': tripUpdate.trip.hasTripId() ? tripUpdate.trip.tripId : null,
      'routeId': tripUpdate.trip.hasRouteId() ? tripUpdate.trip.routeId : null,
      'startDate': tripUpdate.trip.hasStartDate()
          ? tripUpdate.trip.startDate
          : null,
      'stopTimeUpdates': tripUpdate.stopTimeUpdate
          .map(
            (stopTime) => {
              'stopId': stopTime.hasStopId() ? stopTime.stopId : null,
              'stopSequence': stopTime.hasStopSequence()
                  ? stopTime.stopSequence
                  : null,
              'scheduleRelationship': stopTime.hasScheduleRelationship()
                  ? stopTime.scheduleRelationship.name
                  : null,
            },
          )
          .toList(growable: false),
    };
  }
}
