import '../services/api_key_service.dart';
import '../services/app_http_client.dart';
import '../utils/safe_value_utils.dart';
// logger removed

/// Fetches the complete GTFS timetable as JSON from Transport for NSW Open Data.
///
/// Requires API key in .env as API_KEY.
/// Returns the parsed JSON as a Map, or null on error.
Future<Map<String, dynamic>?> fetchTimetable() async {
  final resolvedApiKey = ApiKeyService.getEffectiveApiKey();
  final apiKey = resolvedApiKey.isNotEmpty ? resolvedApiKey : 'YOUR_API_KEY';
  final url = tryParseUriValue(
    'https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete/gtfs',
  );
  if (url == null) {
    return null;
  }

  final response = await AppHttpClient.get(
    url,
    headers: {'Authorization': 'apikey $apiKey', 'Accept': 'application/json'},
  );
  if (response == null || response.statusCode != 200) {
    return null;
  }

  return tryDecodeJsonMap(response.body);
}
