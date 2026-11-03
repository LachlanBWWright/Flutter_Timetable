import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/cache/feed_freshness.dart';
import 'package:lbww_flutter/transit/cache/realtime_query.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

import 'translink_endpoints.dart';

Map<String, String> buildTranslinkRealtimeHeaders() {
  return const {'Accept': 'application/x-protobuf'};
}

Future<FeedMessage?> fetchTranslinkRealtimeFeed(
  String url, {
  String? logLabel,
  RealtimeQuery? query,
}) async {
  final uri = tryParseUriValue(url);
  if (uri == null) {
    if (logLabel != null) {
      safeLogWarning('TransLink realtime fetch skipped for $logLabel: $url');
    }
    return null;
  }

  try {
    final response = await AppHttpClient.getOrThrow(
      uri,
      headers: buildTranslinkRealtimeHeaders(),
      query: query,
    );
    return rememberFeedFetch<FeedMessage>(
      FeedMessage.fromBuffer(response.bodyBytes),
      response,
    );
  } catch (e, st) {
    if (logLabel != null) {
      safeLogWarning('TransLink realtime fetch failed for $logLabel: $e\n$st');
    }
    if (e is TransitFailure) rethrow;
    return null;
  }
}

Future<FeedMessage?> fetchTranslinkTripUpdates(
  String feedSetId, {
  RealtimeQuery? query,
}) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.tripUpdatesUrl,
    logLabel: '${feedSet.label} trip updates',
    query: query,
  );
}

Future<FeedMessage?> fetchTranslinkVehiclePositions(
  String feedSetId, {
  RealtimeQuery? query,
}) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.vehiclePositionsUrl,
    logLabel: '${feedSet.label} vehicle positions',
    query: query,
  );
}

Future<FeedMessage?> fetchTranslinkAlerts(
  String feedSetId, {
  RealtimeQuery? query,
}) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.alertsUrl,
    logLabel: '${feedSet.label} alerts',
    query: query,
  );
}
