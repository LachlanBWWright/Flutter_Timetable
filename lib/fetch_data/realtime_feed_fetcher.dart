import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

String _effectiveApiKeyOrEmpty() => ApiKeyService.getEffectiveApiKey();

Map<String, String> buildRealtimeHeaders() {
  final apiKey = _effectiveApiKeyOrEmpty();
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchRealtimeFeed(String url, {String? logLabel}) async {
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
    );
    if (response == null || response.statusCode != 200) {
      if (logLabel != null) {
        safeLogWarning(
          'Failed to fetch $logLabel: ${response?.statusCode ?? 'network error'}, ${response?.body ?? ''}',
        );
      }
      return null;
    }

    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e, st) {
    if (logLabel != null) {
      safeLogWarning('Realtime fetch failed for $logLabel: $e\n$st');
    }
    return null;
  }
}
