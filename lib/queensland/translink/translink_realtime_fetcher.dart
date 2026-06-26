import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

import 'translink_endpoints.dart';

Map<String, String> buildTranslinkRealtimeHeaders() {
  return const {'Accept': 'application/x-protobuf'};
}

Future<FeedMessage?> fetchTranslinkRealtimeFeed(
  String url, {
  String? logLabel,
}) async {
  final uri = tryParseUriValue(url);
  if (uri == null) {
    if (logLabel != null) {
      safeLogWarning('TransLink realtime fetch skipped for $logLabel: $url');
    }
    return null;
  }

  try {
    final response = await AppHttpClient.get(
      uri,
      headers: buildTranslinkRealtimeHeaders(),
    );
    if (response == null || response.statusCode != 200) {
      if (logLabel != null) {
        safeLogWarning(
          'Failed to fetch TransLink $logLabel: '
          '${response?.statusCode ?? 'network error'}, ${response?.body ?? ''}',
        );
      }
      return null;
    }

    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e, st) {
    if (logLabel != null) {
      safeLogWarning('TransLink realtime fetch failed for $logLabel: $e\n$st');
    }
    return null;
  }
}

Future<FeedMessage?> fetchTranslinkTripUpdates(String feedSetId) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.tripUpdatesUrl,
    logLabel: '${feedSet.label} trip updates',
  );
}

Future<FeedMessage?> fetchTranslinkVehiclePositions(String feedSetId) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.vehiclePositionsUrl,
    logLabel: '${feedSet.label} vehicle positions',
  );
}

Future<FeedMessage?> fetchTranslinkAlerts(String feedSetId) async {
  final feedSet = translinkRealtimeFeedSetById(feedSetId);
  if (feedSet == null) {
    safeLogWarning('Unknown TransLink realtime feed set: $feedSetId');
    return null;
  }
  return fetchTranslinkRealtimeFeed(
    feedSet.alertsUrl,
    logLabel: '${feedSet.label} alerts',
  );
}
