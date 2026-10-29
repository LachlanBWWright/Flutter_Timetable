/// A cache of stable source slots. Failed refreshes keep each slot's last
/// successful value, while valid empty payloads are stored normally.
class RealtimeSnapshotCache<T> {
  RealtimeSnapshotCache({
    DateTime Function()? clock,
    this.ttl = const Duration(seconds: 30),
    this.maxEntries = 128,
    this.fetchedAt,
    this.failureBackoff = const Duration(seconds: 3),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final int maxEntries;
  final DateTime? Function(T)? fetchedAt;
  final Duration ttl;
  final Duration failureBackoff;
  final _entries = <String, List<RealtimeCachedSource<T>>>{};
  final _completedAt = <String, DateTime>{};
  final _inflight = <String, Future<List<RealtimeCachedSource<T>>>>{};
  int _generation = 0;

  List<RealtimeCachedSource<T>> sources(String key) => _entries[key] ?? [];

  void invalidate() {
    _generation++;
    _completedAt.clear();
    // Old requests may finish for their original callers, but a refresh must
    // start new work and old completions must not replace the new snapshot.
    _inflight.clear();
  }

  bool _fresh(String key) {
    final completed = _completedAt[key];
    final previous = sources(key);
    if (completed == null || previous.isEmpty) return false;
    final now = _clock();
    if (previous.any((s) => s.failed)) {
      return now.difference(completed) < failureBackoff;
    }
    return now.difference(completed) < ttl &&
        previous.every(
          (s) => s.fetchedAt != null && now.difference(s.fetchedAt!) < ttl,
        );
  }

  void reuseFresh(String source, String target) {
    if (_fresh(source) && !_fresh(target)) {
      _entries[target] = _entries[source]!;
      _completedAt[target] = _completedAt[source]!;
      _trim();
    }
  }

  void _trim() {
    while (_entries.length > maxEntries && _entries.length > 1) {
      final oldest = _entries.keys.first;
      _entries.remove(oldest);
      _completedAt.remove(oldest);
    }
  }

  Future<List<RealtimeCachedSource<T>>> load(
    String key,
    Future<List<T?>> Function() loader,
  ) async {
    final previous = sources(key);
    if (_fresh(key)) return previous;
    final pending = _inflight[key];
    if (pending != null) return pending;
    final request = _refresh(key, previous, loader, _generation);
    _inflight[key] = request;
    try {
      return await request;
    } finally {
      if (identical(_inflight[key], request)) {
        _inflight.remove(key);
      }
    }
  }

  Future<List<RealtimeCachedSource<T>>> _refresh(
    String key,
    List<RealtimeCachedSource<T>> previous,
    Future<List<T?>> Function() loader,
    int generation,
  ) async {
    List<T?> incoming;
    try {
      incoming = await loader();
    } catch (_) {
      incoming = [];
    }
    final now = _clock();
    // An empty loader result cannot establish success: our feed groups contain
    // fixed nonempty source lists. A FeedMessage with zero entities can.
    final count = incoming.length > previous.length
        ? incoming.length
        : (previous.isEmpty ? 1 : previous.length);
    final next = List<RealtimeCachedSource<T>>.generate(count, (index) {
      final value = index < incoming.length ? incoming[index] : null;
      final old = index < previous.length ? previous[index] : null;
      return value != null
          ? RealtimeCachedSource(
              value: value,
              fetchedAt: fetchedAt?.call(value) ?? now,
            )
          : RealtimeCachedSource(
              value: old?.value,
              fetchedAt: old?.fetchedAt,
              failed: true,
            );
    });
    if (generation != _generation) return next;
    _entries[key] = next;
    _trim();
    // Failed results retain their status and use only a short retry backoff.
    // Explicit invalidation bypasses either TTL while preserving fallback data.
    _completedAt[key] = now;
    return next;
  }
}

class RealtimeCachedSource<T> {
  const RealtimeCachedSource({this.value, this.fetchedAt, this.failed = false});
  final T? value;
  final DateTime? fetchedAt;
  final bool failed;
  bool get isStale => failed && value != null;
}
