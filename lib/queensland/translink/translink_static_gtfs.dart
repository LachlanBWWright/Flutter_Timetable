import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

import 'translink_endpoints.dart';

Map<String, String> buildTranslinkStaticGtfsHeaders() {
  return const {'Accept': 'application/zip'};
}

Future<List<int>?> fetchTranslinkStaticGtfsZip(String feedId) async {
  final feed = translinkStaticFeedById(feedId);
  if (feed == null) {
    return null;
  }

  final uri = tryParseUriValue(feed.url);
  if (uri == null) {
    return null;
  }

  try {
    final response = await AppHttpClient.get(
      uri,
      headers: buildTranslinkStaticGtfsHeaders(),
    );
    if (response == null || response.statusCode != 200) {
      safeLogWarning(
        'TransLink static GTFS request failed for $feedId: '
        '${response?.statusCode ?? 'network error'}',
      );
      return null;
    }

    return response.bodyBytes;
  } catch (error, stackTrace) {
    safeLogWarning(
      'TransLink static GTFS request failed for $feedId: $error\n$stackTrace',
    );
    return null;
  }
}
