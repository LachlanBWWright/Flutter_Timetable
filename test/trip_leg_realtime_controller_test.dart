import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/trip_leg_detail/controller/trip_leg_realtime_controller.dart';

void main() {
  test(
    'caches aggregate loads within a generation and reloads after refresh',
    () async {
      var vehicleLoads = 0;
      var updateLoads = 0;
      final controller = TripLegRealtimeController(
        loadVehicles: () async {
          vehicleLoads++;
          return const VehiclePositionAggregationResult(
            vehicles: [],
            breakdown: {},
          );
        },
        loadTripUpdates: () async {
          updateLoads++;
          return const TripUpdateAggregationResult(
            tripUpdates: [],
            breakdown: {},
          );
        },
      );
      final first = controller.beginGeneration();
      await Future.wait([
        controller.vehicles(first),
        controller.vehicles(first),
      ]);
      await Future.wait([
        controller.tripUpdates(first),
        controller.tripUpdates(first),
      ]);
      expect(vehicleLoads, 1);
      expect(updateLoads, 1);
      final second = controller.beginGeneration();
      await controller.vehicles(second);
      await controller.tripUpdates(second);
      expect(vehicleLoads, 2);
      expect(updateLoads, 2);
      controller.dispose();
    },
  );

  test('stale generations cannot replace the visible snapshot', () async {
    final pending = <Completer<VehiclePositionAggregationResult>>[];
    final controller = TripLegRealtimeController(
      loadVehicles: () {
        final completer = Completer<VehiclePositionAggregationResult>();
        pending.add(completer);
        return completer.future;
      },
      loadTripUpdates: () async =>
          const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
    );
    final oldGeneration = controller.beginGeneration();
    final oldRequest = controller.vehicles(oldGeneration);
    final newGeneration = controller.beginGeneration();
    final newRequest = controller.vehicles(newGeneration);
    pending[0].complete(
      const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {'old': 1},
      ),
    );
    pending[1].complete(
      const VehiclePositionAggregationResult(
        vehicles: [],
        breakdown: {'new': 1},
      ),
    );
    await Future.wait([oldRequest, newRequest]);
    expect(controller.state.generation, newGeneration);
    expect(controller.state.vehicles?.breakdown, {'new': 1});
    controller.dispose();
  });

  test(
    'obsolete vehicle failures cannot release a newer in-flight request',
    () async {
      final old = Completer<VehiclePositionAggregationResult>();
      final refreshed = Completer<VehiclePositionAggregationResult>();
      var loads = 0;
      final controller = TripLegRealtimeController(
        loadVehicles: () => ++loads == 1 ? old.future : refreshed.future,
        loadTripUpdates: () async =>
            const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
      );
      addTearDown(controller.dispose);

      final oldGeneration = controller.beginGeneration();
      final oldRequest = controller.vehicles(oldGeneration);
      final rejectedOldRequest = expectLater(oldRequest, throwsStateError);
      final currentGeneration = controller.beginGeneration();
      final currentRequest = controller.vehicles(currentGeneration);
      old.completeError(StateError('obsolete failure'));
      await rejectedOldRequest;

      expect(controller.state.loadingVehicles, isTrue);
      expect(controller.state.error, isNull);
      expect(controller.vehicles(currentGeneration), same(currentRequest));
      expect(loads, 2);
      await expectLater(controller.vehicles(oldGeneration), throwsStateError);
      expect(loads, 2);

      refreshed.complete(
        const VehiclePositionAggregationResult(
          vehicles: [],
          breakdown: {'refreshed': 1},
        ),
      );
      await currentRequest;
      expect(controller.state.loadingVehicles, isFalse);
      expect(controller.state.vehicles?.breakdown, {'refreshed': 1});
      expect(controller.state.error, isNull);
    },
  );

  test(
    'late trip updates cannot replace or invalidate refreshed cached data',
    () async {
      final old = Completer<TripUpdateAggregationResult>();
      final refreshed = Completer<TripUpdateAggregationResult>();
      var loads = 0;
      final controller = TripLegRealtimeController(
        loadVehicles: () async =>
            const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
        loadTripUpdates: () => ++loads == 1 ? old.future : refreshed.future,
      );
      addTearDown(controller.dispose);

      final oldGeneration = controller.beginGeneration();
      final oldRequest = controller.tripUpdates(oldGeneration);
      final currentGeneration = controller.beginGeneration(clearSnapshot: true);
      final currentRequest = controller.tripUpdates(currentGeneration);
      refreshed.complete(
        const TripUpdateAggregationResult(
          tripUpdates: [],
          breakdown: {'refreshed': 1},
        ),
      );
      await currentRequest;
      old.complete(
        const TripUpdateAggregationResult(
          tripUpdates: [],
          breakdown: {'obsolete': 1},
        ),
      );
      await oldRequest;

      expect(controller.state.generation, currentGeneration);
      expect(controller.state.tripUpdates?.breakdown, {'refreshed': 1});
      expect(controller.state.loadingTripUpdates, isFalse);
      expect(controller.state.error, isNull);
      final cached = await controller.tripUpdates(currentGeneration);
      expect(cached.breakdown, {'refreshed': 1});
      expect(loads, 2);
      await expectLater(
        controller.tripUpdates(oldGeneration),
        throwsStateError,
      );
      expect(loads, 2);
    },
  );

  test('synchronous loader failures update the snapshot error', () async {
    final controller = TripLegRealtimeController(
      loadVehicles: () => throw StateError('offline'),
      loadTripUpdates: () async =>
          const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
    );
    final generation = controller.beginGeneration();
    await expectLater(controller.vehicles(generation), throwsStateError);
    expect(controller.state.loadingVehicles, isFalse);
    expect(controller.state.error, contains('offline'));
    controller.dispose();
  });

  test(
    'disposed controller rejects requests and ignores pending completions',
    () async {
      final pending = Completer<VehiclePositionAggregationResult>();
      var loadCount = 0;
      var notifications = 0;
      final controller = TripLegRealtimeController(
        loadVehicles: () {
          loadCount++;
          return pending.future;
        },
        loadTripUpdates: () async =>
            const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
      );
      controller.addListener(() => notifications++);
      final generation = controller.beginGeneration();
      final request = controller.vehicles(generation);
      controller.dispose();
      pending.complete(
        const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
      );
      await request;
      await expectLater(controller.vehicles(generation), throwsStateError);
      expect(loadCount, 1);
      expect(
        notifications,
        0,
      ); // queued notifications are suppressed on dispose
    },
  );

  test('published aggregate collections cannot mutate the snapshot', () async {
    final vehicles = <VehiclePosition>[VehiclePosition()];
    final updates = <TripUpdate>[TripUpdate()];
    final vehicleCounts = <String, int>{'train': 1};
    final updateCounts = <String, int>{'train': 1};
    final failed = <String>{'failed'};
    final stale = <String>{'stale'};
    final metadata = RealtimeSnapshotMetadata(
      failedSources: failed,
      staleSources: stale,
    );
    final controller = TripLegRealtimeController(
      loadVehicles: () async => VehiclePositionAggregationResult(
        vehicles: vehicles,
        breakdown: vehicleCounts,
        metadata: metadata,
      ),
      loadTripUpdates: () async => TripUpdateAggregationResult(
        tripUpdates: updates,
        breakdown: updateCounts,
        metadata: metadata,
      ),
    );
    addTearDown(controller.dispose);
    final generation = controller.beginGeneration();
    await controller.vehicles(generation);
    await controller.tripUpdates(generation);
    vehicles.clear();
    updates.clear();
    vehicleCounts.clear();
    updateCounts.clear();
    failed.clear();
    stale.clear();

    final publishedVehicles = controller.state.vehicles!;
    final publishedUpdates = controller.state.tripUpdates!;
    expect(publishedVehicles.vehicles, hasLength(1));
    expect(publishedUpdates.tripUpdates, hasLength(1));
    for (final counts in [
      publishedVehicles.breakdown,
      publishedUpdates.breakdown,
    ]) {
      expect(counts, {'train': 1});
      expect(() => counts.clear(), throwsUnsupportedError);
    }
    for (final snapshot in [
      publishedVehicles.metadata,
      publishedUpdates.metadata,
    ]) {
      expect(snapshot.failedSources, {'failed'});
      expect(snapshot.staleSources, {'stale'});
      expect(() => snapshot.failedSources.clear(), throwsUnsupportedError);
      expect(() => snapshot.staleSources.clear(), throwsUnsupportedError);
    }
    expect(() => publishedVehicles.vehicles.clear(), throwsUnsupportedError);
    expect(() => publishedUpdates.tripUpdates.clear(), throwsUnsupportedError);
  });

  test('synchronous state changes notify once with the latest state', () async {
    final controller = TripLegRealtimeController(
      loadVehicles: () async =>
          const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
      loadTripUpdates: () async =>
          const TripUpdateAggregationResult(tripUpdates: [], breakdown: {}),
    );
    addTearDown(controller.dispose);
    final observed = <int>[];
    controller.addListener(() => observed.add(controller.state.generation));
    controller.beginGeneration();
    final latest = controller.beginGeneration(clearSnapshot: true);
    expect(observed, isEmpty);
    await Future<void>.value();
    expect(observed, [latest]);
    expect(controller.state.generation, latest);
  });
}
