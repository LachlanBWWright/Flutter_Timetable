part of '../realtime_service_impl.dart';

class _RealtimeFeedCache {
  static String key(String base, RealtimeQuery? query) {
    if (!SharedTransitCache.instance.isConfigured ||
        query == null ||
        query.isEmpty) {
      return base;
    }
    final scoped = '$base|${query.cacheKey}';
    cache.reuseFresh(base, scoped);
    return scoped;
  }

  static final cache = RealtimeSnapshotCache<FeedMessage>(
    fetchedAt: sharedFeedFetchedAt,
  );

  static Future<FeedMessage?> getFeed(
    String key,
    Future<FeedMessage?> Function() loader,
  ) async {
    final sources = await cache.load(key, () async => [await loader()]);
    return sources.first.value;
  }

  static Future<List<FeedMessage?>> getFeedList(
    String key,
    Future<List<FeedMessage?>> Function() loader,
  ) async => (await cache.load(key, loader)).map((s) => s.value).toList();
}
