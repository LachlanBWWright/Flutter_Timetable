part of '../realtime_service_impl.dart';

/// Freshness and availability of the sources included in an aggregate.
class RealtimeSnapshotMetadata {
  const RealtimeSnapshotMetadata({
    this.fetchedAt,
    this.failedSources = const {},
    this.staleSources = const {},
  });

  /// Oldest successful local fetch among included source snapshots.
  final DateTime? fetchedAt;
  final Set<String> failedSources;
  final Set<String> staleSources;
  bool get isUnavailable => fetchedAt == null && failedSources.isNotEmpty;
  bool get isStale => staleSources.isNotEmpty;
  bool get isPartial => failedSources.isNotEmpty && !isUnavailable;
  Duration? age(DateTime now) =>
      fetchedAt == null ? null : now.difference(fetchedAt!);
}

class _SnapshotMetadataBuilder {
  DateTime? oldest;
  final failed = <String>{};
  final stale = <String>{};

  void add(
    String key, {
    DateTime? fetchedAt,
    bool failed = false,
    bool isStale = false,
  }) {
    if (fetchedAt != null && (oldest == null || fetchedAt.isBefore(oldest!))) {
      oldest = fetchedAt;
    }
    if (failed) this.failed.add(key);
    if (isStale) stale.add(key);
  }

  void addCached(String key) {
    final sources = _RealtimeFeedCache.cache.sources(key);
    for (var i = 0; i < sources.length; i++) {
      final source = sources[i];
      add(
        '$key:$i',
        fetchedAt: source.fetchedAt,
        failed: source.failed,
        isStale: source.isStale,
      );
    }
  }

  RealtimeSnapshotMetadata build() => RealtimeSnapshotMetadata(
    fetchedAt: oldest,
    failedSources: Set.unmodifiable(failed),
    staleSources: Set.unmodifiable(stale),
  );
}
