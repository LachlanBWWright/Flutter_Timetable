part of '../realtime_service_impl.dart';

/// Captures the source status when a loader completes, before other requests
/// can replace its cache slot. Overrides have no cache-backed fetch time.
class _LoadedRealtimeFeed {
  const _LoadedRealtimeFeed(
    this.feed, {
    this.fetchedAt,
    this.isStale = false,
    this.namespace = 'tfnsw',
  });

  factory _LoadedRealtimeFeed.fromSource(
    FeedMessage? feed,
    String key,
    int index,
    bool custom,
  ) {
    if (!custom) {
      final sources = _RealtimeFeedCache.cache.sources(key);
      if (index < sources.length) {
        final source = sources[index];
        if (identical(source.value, feed)) {
          return _LoadedRealtimeFeed(
            feed,
            fetchedAt: source.fetchedAt,
            isStale: source.isStale,
            namespace: _namespace(key),
          );
        }
      }
    }
    return _LoadedRealtimeFeed(feed, namespace: _namespace(key));
  }

  static String _namespace(String key) {
    final source = key.split('|').first.split(':').last;
    final mode = switch (source) {
      'region_buses' => 'bus',
      'ferries' => 'ferry',
      'lightrail_all' => 'lightrail',
      _ => source,
    };
    return 'tfnsw:$mode';
  }

  final String namespace;
  final FeedMessage? feed;
  final DateTime? fetchedAt;
  final bool isStale;

  _RealtimeRecord<VehiclePosition> vehicleRecord(VehiclePosition value) =>
      _RealtimeRecord(
        value,
        namespace: namespace,
        providerTimestamp: value.hasTimestamp()
            ? value.timestamp.toInt()
            : null,
        fetchedAt: fetchedAt,
        isStale: isStale,
      );

  _RealtimeRecord<TripUpdate> tripRecord(TripUpdate value) => _RealtimeRecord(
    value,
    namespace: namespace,
    providerTimestamp: value.hasTimestamp() ? value.timestamp.toInt() : null,
    fetchedAt: fetchedAt,
    isStale: isStale,
  );
}

class _RealtimeRecord<T> {
  const _RealtimeRecord(
    this.value, {
    this.providerTimestamp,
    this.namespace = 'tfnsw',
    this.fetchedAt,
    this.isStale = false,
  });

  final T value;
  final String namespace;
  final int? providerTimestamp;
  final DateTime? fetchedAt;
  final bool isStale;

  bool isNewerThan(_RealtimeRecord<T> other) {
    final timestamp = providerTimestamp;
    final previousTimestamp = other.providerTimestamp;
    if (timestamp != null &&
        previousTimestamp != null &&
        timestamp != previousTimestamp) {
      return timestamp > previousTimestamp;
    }
    if (isStale != other.isStale) return !isStale;
    final fetched = fetchedAt;
    final previousFetch = other.fetchedAt;
    if (fetched != null && previousFetch != null) {
      return fetched.isAfter(previousFetch);
    }
    return false;
  }
}
