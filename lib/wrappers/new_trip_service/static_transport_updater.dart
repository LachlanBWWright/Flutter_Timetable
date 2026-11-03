part of '../new_trip_service_impl.dart';

class _StaticTransportUpdater {
  static Stream<StaticTransportUpdateProgress> updateStaticTransportData({
    bool force = false,
    List<StopsEndpoint>? endpoints,
  }) {
    final selectedEndpoints = _selectedEndpointsOrDefault(endpoints);
    final total = selectedEndpoints.length;
    var cancelled = false;
    late final StreamController<StaticTransportUpdateProgress> controller;
    controller = StreamController<StaticTransportUpdateProgress>(
      onListen: () {
        unawaited(
          _runUpdateStaticTransportData(
            controller: controller,
            selectedEndpoints: selectedEndpoints,
            total: total,
            force: force,
            isCancelled: () => cancelled,
          ),
        );
      },
      onCancel: () {
        cancelled = true;
      },
    );

    return controller.stream;
  }

  static Future<void> _runUpdateStaticTransportData({
    required StreamController<StaticTransportUpdateProgress> controller,
    required List<StopsEndpoint> selectedEndpoints,
    required int total,
    required bool force,
    required bool Function() isCancelled,
  }) async {
    void emit(StaticTransportUpdateProgress progress) {
      if (!isCancelled()) controller.add(progress);
    }

    var completed = 0;
    for (final endpoint in selectedEndpoints.toSet()) {
      if (isCancelled()) break;
      final release = await _EndpointUpdateQueue.acquire(endpoint);
      try {
        if (isCancelled()) break;
        final cached = await _hasValidStaticCache(endpoint);
        if (isCancelled()) break;
        if (cached && !force) {
          completed += 1;
          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.complete,
              completed: completed,
              total: total,
              message: 'Using cached ${endpoint.key}',
            ),
          );
          continue;
        }

        await StopsService.database.markStaticCacheBuildStarted(endpoint.key);
        emit(
          StaticTransportUpdateProgress(
            endpoint: endpoint,
            stage: StaticTransportUpdateStage.fetching,
            completed: completed,
            total: total,
            message: 'Fetching ${endpoint.key}',
          ),
        );

        try {
          final gtfsData = isCancelled()
              ? null
              : await _NewTripStops._loadEndpointStaticData(endpoint);
          if (isCancelled()) {
            // Leave the previous snapshot and its success timestamps intact.
            await StopsService.database.markStaticCacheBuildFinished(
              endpoint.key,
              stopsUpdated: false,
              lineMembershipsUpdated: false,
              error: 'Update cancelled',
            );
            break;
          }
          if (gtfsData == null) {
            const error = 'GTFS data unavailable';
            await StopsService.database.markStaticCacheBuildFinished(
              endpoint.key,
              stopsUpdated: false,
              lineMembershipsUpdated: false,
              error: error,
            );
            emit(
              StaticTransportUpdateProgress(
                endpoint: endpoint,
                stage: StaticTransportUpdateStage.failed,
                completed: completed,
                total: total,
                message: 'Failed ${endpoint.key}',
                error: '$error for ${endpoint.key}',
              ),
            );
            continue;
          }

          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.parsing,
              completed: completed,
              total: total,
              message: 'Parsed ${endpoint.key}',
            ),
          );

          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.storingStops,
              completed: completed,
              total: total,
              message: 'Storing stops for ${endpoint.key}',
            ),
          );

          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.storingLineMemberships,
              completed: completed,
              total: total,
              message: 'Storing line memberships for ${endpoint.key}',
            ),
          );
          await TripLineService.instance
              .publishStaticDataForEndpointWithinUpdate(endpoint, gtfsData);

          invalidateStationCacheForEndpoint(endpoint);
          completed += 1;
          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.complete,
              completed: completed,
              total: total,
              message: 'Completed ${endpoint.key}',
            ),
          );
        } catch (e) {
          await StopsService.database.markStaticCacheBuildFinished(
            endpoint.key,
            stopsUpdated: false,
            lineMembershipsUpdated: false,
            error: e.toString(),
          );
          emit(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.failed,
              completed: completed,
              total: total,
              message: 'Failed ${endpoint.key}',
              error: e.toString(),
            ),
          );
        }
      } catch (e) {
        // Defensive: catch errors in _hasValidStaticCache or other boundaries
        emit(
          StaticTransportUpdateProgress(
            endpoint: endpoint,
            stage: StaticTransportUpdateStage.failed,
            completed: completed,
            total: total,
            message: 'Failed ${endpoint.key}',
            error: e.toString(),
          ),
        );
      } finally {
        release();
      }
    }

    emit(
      StaticTransportUpdateProgress(
        endpoint: null,
        stage: StaticTransportUpdateStage.complete,
        completed: completed,
        total: total,
        message: 'Finished updating static transport data ($completed/$total)',
      ),
    );
    await controller.close();
  }

  static Future<bool> _hasValidStaticCache(StopsEndpoint endpoint) async {
    final snapshot = await _NewTripStops._readEndpointCache(endpoint);
    return snapshot.isFresh(DateTime.now());
  }

  static List<StopsEndpoint> _selectedEndpointsOrDefault(
    List<StopsEndpoint>? endpoints,
  ) {
    if (endpoints != null) {
      return endpoints.toSet().toList(growable: false);
    }
    return StopsEndpoint.values;
  }
}
