part of '../debug_entity_list_loader.dart';

extension _DebugRealtimeLists on DebugEntityListLoader {
  Future<DebugEntityListPageData> _loadTripList() async {
    final tripUpdates = await resolver.tripUpdateAggregation();
    final vehicleAggregation = await resolver.vehicleAggregation();
    final vehiclesByTripId = <String, VehiclePosition>{};
    for (final vehicle in vehicleAggregation.vehicles) {
      if (vehicle.trip.hasTripId() && vehicle.trip.tripId.isNotEmpty) {
        vehiclesByTripId.putIfAbsent(vehicle.trip.tripId, () => vehicle);
      }
    }

    final items = <DebugEntityListItem>[];
    final seenTripIds = <String>{};
    for (final update in tripUpdates.tripUpdates) {
      if (!update.trip.hasTripId() || update.trip.tripId.isEmpty) {
        continue;
      }
      final tripId = update.trip.tripId;
      if (!seenTripIds.add(tripId)) {
        continue;
      }
      final routeId = update.trip.hasRouteId()
          ? update.trip.routeId
          : 'unknown';
      final timestamp = update.hasTimestamp()
          ? timestampFromUnixSeconds(update.timestamp.toInt())
          : null;
      final matchedVehicle = _mapValue(vehiclesByTripId, tripId);
      final stopIds =
          update.stopTimeUpdate
              .where(
                (stopUpdate) =>
                    stopUpdate.hasStopId() && stopUpdate.stopId.isNotEmpty,
              )
              .map((stopUpdate) => stopUpdate.stopId)
              .toSet()
              .toList()
            ..sort();
      final filterValues = <String, List<String>>{
        'route': [routeId],
        'source': [
          DebugDataSource.realtime.label,
          DebugDataSource.derived.label,
        ],
        'vehicle': [
          matchedVehicle == null ? 'no_vehicle_match' : 'matched_vehicle',
        ],
      };
      if (update.trip.hasStartDate()) {
        _putFilterValues(filterValues, 'service_date', [update.trip.startDate]);
      }
      _putFilterValues(filterValues, 'stop', stopIds);

      items.add(
        DebugEntityListItem(
          entityType: DebugEntityType.trip,
          entityId: tripId,
          title: tripId,
          subtitle: 'Route: $routeId',
          description: tripDescription(
            serviceDate: update.trip.hasStartDate()
                ? update.trip.startDate
                : null,
            stopCount: stopIds.length,
            matchedVehicleId: matchedVehicle == null
                ? null
                : DebugExtractors.vehicleDisplayId(matchedVehicle),
          ),
          sources: const [DebugDataSource.realtime, DebugDataSource.derived],
          filterValues: filterValues,
          searchTerms: [
            tripId,
            routeId,
            if (update.trip.hasStartDate()) update.trip.startDate,
            ...stopIds,
            if (matchedVehicle != null)
              DebugExtractors.vehicleDisplayId(matchedVehicle),
          ],
          timestamp: timestamp,
          request: DebugEntityRequest(
            entityType: DebugEntityType.trip,
            entityId: tripId,
            context: DebugEntityContext(
              tripUpdate: update,
              vehiclePosition: matchedVehicle,
            ),
          ),
        ),
      );
    }

    return DebugEntityListPageData(
      entityType: DebugEntityType.trip,
      title: 'Trip Debug Browser',
      description:
          'Browse active realtime trips. Each entry opens the standalone trip debug page with realtime context attached.',
      emptyMessage:
          'No active realtime trips are currently available for debugging.',
      items: items,
      sourceBadges: const [DebugDataSource.realtime, DebugDataSource.derived],
      filterGroups: _buildFilterGroups(items, const {
        'route': 'Route',
        'source': 'Source',
        'service_date': 'Service date',
        'vehicle': 'Vehicle match',
        'stop': 'Stop',
      }),
      sortOptions: const [
        DebugEntityListSort.recentFirst,
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.idAsc,
      ],
      defaultSort: DebugEntityListSort.recentFirst,
      banners: const [
        DebugStatusBannerData(
          tone: DebugStatusTone.info,
          title: 'Realtime trip catalog',
          message:
              'Trip browser results come from active realtime trip updates, so only currently published trips appear here.',
          sources: [DebugDataSource.realtime, DebugDataSource.derived],
        ),
      ],
    );
  }

  Future<DebugEntityListPageData> _loadVehicleList() async {
    final aggregation = await resolver.vehicleAggregation();
    final items = aggregation.vehicles
        .map((vehicle) {
          final vehicleId =
              DebugExtractors.vehicleId(vehicle) ??
              DebugExtractors.vehicleDisplayId(vehicle);
          final routeId = DebugExtractors.vehicleRouteId(vehicle) ?? 'unknown';
          final tripId = DebugExtractors.vehicleTripId(vehicle) ?? 'unknown';
          final occupancy = vehicle.hasOccupancyStatus()
              ? vehicle.occupancyStatus.name
              : 'unknown';
          final timestamp = vehicle.hasTimestamp()
              ? timestampFromUnixSeconds(vehicle.timestamp.toInt())
              : null;

          final filterValues = <String, List<String>>{
            'route': [routeId],
            'trip': [tripId],
            'status': [
              vehicle.hasCurrentStatus()
                  ? vehicle.currentStatus.name
                  : 'unknown',
            ],
          };
          if (occupancy != 'unknown') {
            _putFilterValues(filterValues, 'occupancy', [occupancy]);
          }

          return DebugEntityListItem(
            entityType: DebugEntityType.vehicle,
            entityId: vehicleId,
            title: DebugExtractors.vehicleDisplayId(vehicle),
            subtitle: 'Trip: $tripId • Route: $routeId',
            description: vehicle.hasCurrentStatus()
                ? 'Status: ${vehicle.currentStatus.name}'
                : 'Realtime vehicle position',
            sources: const [DebugDataSource.realtime],
            filterValues: filterValues,
            searchTerms: [
              vehicleId,
              DebugExtractors.vehicleDisplayId(vehicle),
              tripId,
              routeId,
              if (vehicle.vehicle.hasLicensePlate())
                vehicle.vehicle.licensePlate,
              if (occupancy != 'unknown') occupancy,
            ],
            timestamp: timestamp,
            request: DebugEntityRequest(
              entityType: DebugEntityType.vehicle,
              entityId: vehicleId,
              context: DebugEntityContext(vehiclePosition: vehicle),
            ),
          );
        })
        .toList(growable: false);

    return DebugEntityListPageData(
      entityType: DebugEntityType.vehicle,
      title: 'Vehicle Debug Browser',
      description:
          'Browse active realtime vehicles and open their standalone debug pages with live position context.',
      emptyMessage:
          'No active realtime vehicles are currently available for debugging.',
      items: items,
      sourceBadges: const [DebugDataSource.realtime],
      filterGroups: _buildFilterGroups(items, const {
        'route': 'Route',
        'trip': 'Trip',
        'status': 'Status',
        'occupancy': 'Occupancy',
      }),
      sortOptions: const [
        DebugEntityListSort.recentFirst,
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.idAsc,
      ],
      defaultSort: DebugEntityListSort.recentFirst,
    );
  }
}
