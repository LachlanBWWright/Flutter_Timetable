part of '../realtime_map_widget.dart';

extension _RealtimeMapVehicleLoading on _RealtimeMapWidgetState {
  Future<void> _retryVehiclePositions() =>
      _loadVehiclePositions(forceRefresh: true);

  Future<void> _loadVehiclePositions({
    bool clearVehicles = false,
    bool forceRefresh = false,
  }) async {
    final generation = ++_loadGeneration;
    guardedSetState(() {
      _isLoading = true;
      if (clearVehicles) {
        _vehicles = [];
        _vehicleMarkers = null;
        _metadata = const RealtimeSnapshotMetadata();
      }
    });

    await runAsyncGuarded(
      () async {
        if (forceRefresh) {
          final onRefresh = widget.onRefresh;
          if (onRefresh != null) {
            await onRefresh();
          } else {
            RealtimeService.invalidateRealtimeCache();
          }
          if (!mounted || generation != _loadGeneration) return;
          if (!_visibleRefresh.isVisible) {
            guardedSetState(() => _isLoading = false);
            return;
          }
        }
        Map<TransportMode, FeedMessage?>? mapPositions;
        List<VehiclePosition>? aggregatedVehicles;
        var metadata = const RealtimeSnapshotMetadata();
        final getAllVehiclesAggregated = widget.getAllVehiclesAggregated;
        final getPositions = widget.getPositions;
        if (getAllVehiclesAggregated != null) {
          final agg = await getAllVehiclesAggregated.call();
          aggregatedVehicles = agg.vehicles;
          metadata = agg.metadata;
          if (metadata.fetchedAt == null && metadata.failedSources.isEmpty) {
            metadata = RealtimeSnapshotMetadata(fetchedAt: DateTime.now());
          }
        } else if (getPositions != null) {
          mapPositions = await getPositions.call();
          final selectedMode = widget.transportMode ?? widget.mode;
          final selectedEntries = mapPositions.entries.where(
            (entry) => selectedMode == null || entry.key == selectedMode,
          );
          metadata = RealtimeSnapshotMetadata(
            fetchedAt: selectedEntries.any((entry) => entry.value != null)
                ? DateTime.now()
                : null,
            failedSources: {
              for (final entry in selectedEntries)
                if (entry.value == null) entry.key.toString(),
              if (selectedEntries.isEmpty) 'positions',
            },
          );
        } else {
          if (ApiKeyService.getEffectiveApiKey().isEmpty &&
              !RealtimeService.usesSharedCache) {
            mapPositions = const <TransportMode, FeedMessage?>{};
            metadata = const RealtimeSnapshotMetadata(
              failedSources: {'positions'},
            );
          } else {
            if (RealtimeService.usesSharedCache) {
              final selected = widget.transportMode ?? widget.mode;
              final modes = selected == null
                  ? TransportMode.values
                  : [selected];
              final query = _mapQuery();
              final feeds = await Future.wait(
                modes.map(
                  (mode) async => MapEntry(
                    mode,
                    await RealtimeService.getPositionsForTransportMode(
                      mode,
                      query: query,
                    ),
                  ),
                ),
              );
              mapPositions = Map.fromEntries(feeds);
              metadata = RealtimeService.metadataForVehicleModes(
                modes,
                query: query,
              );
            } else {
              mapPositions = await RealtimeService.getAllRealtimePositions();
            }
            final selectedMode = widget.transportMode ?? widget.mode;
            if (!RealtimeService.usesSharedCache) {
              metadata = RealtimeService.metadataForVehicleModes(
                selectedMode == null ? mapPositions.keys : [selectedMode],
              );
            }
          }
        }
        if (!mounted || generation != _loadGeneration) return;
        final vehicles = <_VehicleWithMode>[];

        if (mapPositions != null) {
          for (final entry in mapPositions.entries) {
            final feedMode = entry.key;
            final mode = widget.mode;
            if (widget.transportMode != null) {
              if (feedMode != widget.transportMode) continue;
            } else if (mode != null) {
              if (feedMode != mode) continue;
            }
            final feedMessage = entry.value;
            if (feedMessage != null) {
              final vehiclePositions = RealtimeService.extractVehiclePositions(
                feedMessage,
              );
              vehicles.addAll(
                vehiclePositions.map((v) => _VehicleWithMode(v, feedMode)),
              );
            }
          }
        } else if (aggregatedVehicles != null) {
          vehicles.addAll(
            aggregatedVehicles.map(
              (v) => _VehicleWithMode(v, _modeForAggregatedVehicle(v)),
            ),
          );
        }

        if (widget.filterByLegTrip) {
          final ids =
              widget.tripIds?.where((id) => id.trim().isNotEmpty).toSet() ??
              const <String>{};
          final leg = widget.leg;
          if (ids.isNotEmpty && leg != null) {
            final matching = filterRealtimeVehiclesForLeg(
              vehicles.map((value) => value.vehicle),
              leg,
              ids,
              matchedTrip: widget.matchedTrip,
            ).toSet();
            vehicles.retainWhere((value) => matching.contains(value.vehicle));
          } else {
            // Without a leg, preserve the explicit trip-only filter API.
            vehicles.retainWhere(
              (value) => ids.contains(value.vehicle.trip.tripId),
            );
          }
        }

        if (!mounted || generation != _loadGeneration) return;
        final vehicleId = widget.vehicleId;
        if (vehicleId != null) {
          vehicles.removeWhere(
            (vw) =>
                !vw.vehicle.vehicle.hasId() ||
                vw.vehicle.vehicle.id != vehicleId,
          );

          if (vehicles.isEmpty) {
            safeLogInfo(
              'RealtimeMapWidget: vehicle id $vehicleId not found in feeds',
            );
          }
        }
        guardedSetState(() {
          // Providers can report failed fetches without throwing. Keep the
          // previous snapshot for the same filter, just as on a thrown error.
          if (metadata.isUnavailable && _metadata.fetchedAt != null) {
            _metadata = RealtimeSnapshotMetadata(
              fetchedAt: _metadata.fetchedAt,
              failedSources: metadata.failedSources,
              staleSources: {
                ...metadata.staleSources,
                ...metadata.failedSources,
              },
            );
            _isLoading = false;
            return;
          }
          _vehicles = vehicles;
          _vehicleMarkers = null;
          _metadata = metadata;
          _isLoading = false;
        });
      },
      onError: (error, stackTrace) {
        safeLogError(
          'RealtimeMapWidget: failed to load vehicle positions',
          error: error,
          stackTrace: stackTrace,
        );
        if (!mounted || generation != _loadGeneration) return;
        guardedSetState(() {
          _metadata = RealtimeSnapshotMetadata(
            fetchedAt: _metadata.fetchedAt,
            failedSources: const {'positions'},
            staleSources: _metadata.fetchedAt != null || _vehicles.isNotEmpty
                ? const {'positions'}
                : const {},
          );
          _isLoading = false;
        });
      },
    );
  }
}
