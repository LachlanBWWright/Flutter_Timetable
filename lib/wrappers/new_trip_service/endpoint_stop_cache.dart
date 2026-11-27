import '../../gtfs/stop.dart';
import '../../services/stops_service.dart';

/// One endpoint's independently published static snapshot.
class EndpointStopCacheSnapshot {
  const EndpointStopCacheSnapshot({
    required this.stops,
    this.stopsUpdatedAt,
    this.lineMembershipsUpdatedAt,
    this.membershipCount = 0,
  });

  final List<Stop> stops;
  final DateTime? stopsUpdatedAt;
  final DateTime? lineMembershipsUpdatedAt;
  final int membershipCount;

  static const maxAge = Duration(hours: 24);

  bool isFresh(DateTime now) {
    if (stops.isEmpty || membershipCount <= 0) return false;
    return _fresh(stopsUpdatedAt, now) && _fresh(lineMembershipsUpdatedAt, now);
  }

  static bool _fresh(DateTime? updatedAt, DateTime now) {
    if (updatedAt == null) return false;
    final age = now.difference(updatedAt);
    return !age.isNegative && age < maxAge;
  }
}

/// Serves existing stops while completing only missing or stale endpoints.
/// Refreshes are shared between callers and run one at a time to bound memory.
class EndpointStopCacheLoader {
  EndpointStopCacheLoader({
    required this.readEndpoint,
    required this.refreshEndpoint,
    DateTime Function()? now,
    this.onError,
  }) : now = now ?? DateTime.now;

  final Future<EndpointStopCacheSnapshot> Function(StopsEndpoint) readEndpoint;
  final Future<void> Function(StopsEndpoint) refreshEndpoint;
  final DateTime Function() now;
  final void Function(StopsEndpoint, Object)? onError;
  final Map<StopsEndpoint, Future<void>> _refreshes = {};
  Future<void>? _tail;

  Future<List<Stop>> load(List<StopsEndpoint> endpoints) async {
    final selected = endpoints.toSet();
    final stops = <Stop>[];
    final pending = <Future<void>>[];
    for (final endpoint in selected) {
      final snapshot = await _read(endpoint);
      stops.addAll(snapshot.stops);
      if (!snapshot.isFresh(now())) pending.add(_refresh(endpoint));
    }
    if (stops.isNotEmpty || pending.isEmpty) return stops;

    // With no usable snapshot, the caller needs the initial download results.
    await Future.wait(pending);
    for (final endpoint in selected) {
      stops.addAll((await _read(endpoint)).stops);
    }
    return stops;
  }

  Future<EndpointStopCacheSnapshot> _read(StopsEndpoint endpoint) async {
    try {
      return await readEndpoint(endpoint);
    } catch (error) {
      _reportError(endpoint, error);
      return const EndpointStopCacheSnapshot(stops: []);
    }
  }

  void _reportError(StopsEndpoint endpoint, Object error) {
    // Diagnostics must not prevent cached reads or poison the refresh queue.
    try {
      onError?.call(endpoint, error);
    } catch (_) {}
  }

  Future<void> _refresh(StopsEndpoint endpoint) {
    final active = _refreshes[endpoint];
    if (active != null) return active;
    Future<void> run() async {
      try {
        // Another static updater may have published while this was queued.
        if (!(await _read(endpoint)).isFresh(now())) {
          await refreshEndpoint(endpoint);
        }
      } catch (error) {
        _reportError(endpoint, error);
      }
    }

    final previous = _tail;
    late final Future<void> next;
    next =
        (previous == null
                ? Future<void>.sync(run)
                : previous.then((_) => run()))
            .whenComplete(() {
              if (identical(_refreshes[endpoint], next)) {
                _refreshes.remove(endpoint);
              }
              // Drop completed futures so idle work starts in its caller's zone.
              if (identical(_tail, next)) _tail = null;
            });
    _refreshes[endpoint] = next;
    _tail = next;
    return next;
  }
}
