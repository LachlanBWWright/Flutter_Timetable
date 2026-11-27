import 'dart:async';

import 'package:lbww_flutter/transit/transit.dart';

class RegionalStopSearchSnapshot {
  const RegionalStopSearchSnapshot({
    this.stops = const [],
    this.errors = const {},
    this.loading = const {},
    this.progress,
    this.isStale = false,
    this.cancelled = false,
  });
  final List<TransitStop> stops;
  final Map<TransitRegion, Map<String, String>> errors;
  final Set<TransitRegion> loading;
  final String? progress;
  final bool isStale;
  final bool cancelled;
  bool get isLoading => loading.isNotEmpty;
  RegionalStopSearchSnapshot stopped() => RegionalStopSearchSnapshot(
    stops: stops,
    errors: errors,
    isStale: isStale,
    cancelled: true,
  );
}

/// The same progressive regional search is used by every stop picker.
class RegionalStopsSearchRepository {
  RegionalStopsSearchRepository({required this.enabledServices});
  final List<TransitRegionServices> Function() enabledServices;

  Stream<RegionalStopSearchSnapshot> watchStops(
    String query, {
    bool browse = false,
    int limit = 500,
    StopSearchCancellation? cancellation,
    List<TransitSourceId>? Function(TransitRegion)? sourcesForRegion,
  }) {
    final token = cancellation ?? StopSearchCancellation();
    final services = enabledServices();
    final updates = <TransitRegion, StopSearchUpdate>{};
    final loading = services.map((service) => service.region).toSet();
    final active = Set.of(loading);
    final subscriptions = <StreamSubscription<StopSearchUpdate>>[];
    late final StreamController<RegionalStopSearchSnapshot> controller;
    var stopped = false;
    void emit([String? progress]) {
      if (stopped || token.isCancelled || controller.isClosed) return;
      final byId = <String, TransitStop>{};
      for (final update in updates.values) {
        for (final stop in update.stops) {
          byId[stop.ref.storageKey] = stop;
        }
      }
      final stops = byId.values.toList()
        ..sort((a, b) {
          final order = a.name.compareTo(b.name);
          return order != 0
              ? order
              : a.ref.storageKey.compareTo(b.ref.storageKey);
        });
      controller.add(
        RegionalStopSearchSnapshot(
          stops: stops.take(limit).toList(),
          errors: {
            for (final entry in updates.entries)
              if (entry.value.errors.isNotEmpty)
                entry.key: Map.of(entry.value.errors),
          },
          loading: Set.of(loading),
          progress: progress,
          isStale: updates.values.any((update) => update.isStale),
        ),
      );
    }

    void finishRegion(TransitRegion region) {
      loading.remove(region);
      active.remove(region);
      emit();
      if (active.isEmpty && !controller.isClosed) unawaited(controller.close());
    }

    controller = StreamController(
      onListen: () {
        if (services.isEmpty) {
          emit();
          unawaited(controller.close());
          return;
        }
        emit();
        for (final service in services) {
          final request = StopSearchRequest(
            query: query,
            limit: limit,
            browse: browse,
            sourceIds: sourcesForRegion?.call(service.region),
            cancellation: token,
          );
          final repository = service.stops;
          final stream = repository is ProgressiveStopRepository
              ? repository.watchStops(request)
              : Stream.fromFuture(
                  repository
                      .searchStops(request)
                      .then((stops) => StopSearchUpdate(stops: stops)),
                );
          subscriptions.add(
            stream.listen(
              (update) {
                updates[service.region] = update;
                if (!update.isLoading) {
                  loading.remove(service.region);
                } else {
                  loading.add(service.region);
                }
                emit(
                  update.progress == null
                      ? null
                      : 'Loading ${service.region.label} stops…',
                );
              },
              onError: (Object error, StackTrace stack) {
                if (error is! Exception) {
                  controller.addError(error, stack);
                  return;
                }
                updates[service.region] = StopSearchUpdate(
                  stops: updates[service.region]?.stops ?? const [],
                  errors: {'search': error.toString()},
                );
              },
              onDone: () => finishRegion(service.region),
            ),
          );
        }
      },
      onCancel: () async {
        stopped = true;
        token.cancel();
        await Future.wait(
          subscriptions.map((subscription) => subscription.cancel()),
        );
      },
    );
    unawaited(
      token.whenCancelled.then((_) async {
        if (stopped) return;
        stopped = true;
        await Future.wait(
          subscriptions.map((subscription) => subscription.cancel()),
        );
        if (!controller.isClosed) await controller.close();
      }),
    );
    return controller.stream;
  }

  Future<List<TransitStop>> searchStops(String query) async {
    RegionalStopSearchSnapshot? latest;
    await for (final snapshot in watchStops(query, limit: 50)) {
      latest = snapshot;
    }
    if (latest != null && latest.stops.isEmpty && latest.errors.isNotEmpty) {
      throw const ProviderUnavailable(message: 'Stop search unavailable');
    }
    return latest?.stops ?? const [];
  }
}
