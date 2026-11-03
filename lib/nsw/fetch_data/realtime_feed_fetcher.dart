import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

import '../../transit/cache/realtime_query.dart';
import 'realtime_feed_parser.dart';
import 'realtime_work_limiter.dart';

export '../../transit/cache/realtime_query.dart';

final _sharedFetchedAt = Expando<DateTime>();
DateTime? sharedFeedFetchedAt(FeedMessage feed) => _sharedFetchedAt[feed];

final _realtimeWork = RealtimeWorkLimiter(4);

String _effectiveApiKeyOrEmpty() => ApiKeyService.getEffectiveApiKey();

Map<String, String> buildRealtimeHeaders() {
  final apiKey = _effectiveApiKeyOrEmpty();
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchRealtimeFeed(
  String url, {
  String? logLabel,
  RealtimeQuery? query,
}) => _realtimeWork.run(
  () => _fetchRealtimeFeed(url, logLabel: logLabel, query: query),
);

Future<FeedMessage?> _fetchRealtimeFeed(
  String url, {
  String? logLabel,
  RealtimeQuery? query,
}) async {
  final uri = tryParseUriValue(url);
  if (uri == null) {
    if (logLabel != null) {
      safeLogWarning('Realtime fetch skipped for $logLabel: invalid URL $url');
    }
    return null;
  }

  try {
    final response = await AppHttpClient.get(
      uri,
      headers: buildRealtimeHeaders(),
      query: query,
    );
    if (response == null || response.statusCode != 200) {
      if (logLabel != null) {
        safeLogWarning(
          'Failed to fetch $logLabel: ${response?.statusCode ?? 'network error'}',
        );
      }
      return null;
    }

    FeedMessage feed;
    try {
      feed = await decodeRealtimeFeed(response.bodyBytes);
    } catch (_) {
      if (response.headers['x-transit-version'] != '1') rethrow;
      final direct = await AppHttpClient.get(
        uri,
        headers: buildRealtimeHeaders(),
        useSharedCache: false,
      );
      if (direct == null || direct.statusCode != 200) return null;
      return await decodeRealtimeFeed(direct.bodyBytes);
    }
    final fetched = DateTime.tryParse(
      response.headers['x-transit-fetched-at'] ?? '',
    );
    if (fetched != null) _sharedFetchedAt[feed] = fetched;
    return feed;
  } catch (e, st) {
    if (logLabel != null) {
      safeLogWarning('Realtime fetch failed for $logLabel: $e\n$st');
    }
    return null;
  }
}
