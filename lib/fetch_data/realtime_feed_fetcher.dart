import 'package:http/http.dart' as http;
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/api_key_service.dart';

String _effectiveApiKeyOrEmpty() {
  try {
    return ApiKeyService.getEffectiveApiKey();
  } catch (_) {
    return '';
  }
}

void _logWarningSafe(String message) {
  try {
    logger.w(message);
  } catch (_) {}
}

Map<String, String> buildRealtimeHeaders() {
  final apiKey = _effectiveApiKeyOrEmpty();
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchRealtimeFeed(String url, {String? logLabel}) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: buildRealtimeHeaders(),
    );
    if (response.statusCode != 200) {
      if (logLabel != null) {
        _logWarningSafe(
          'Failed to fetch $logLabel: ${response.statusCode}, ${response.body}',
        );
      }
      return null;
    }

    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e, st) {
    if (logLabel != null) {
      _logWarningSafe('Realtime fetch failed for $logLabel: $e\n$st');
    }
    return null;
  }
}
