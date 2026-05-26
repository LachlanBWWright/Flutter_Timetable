import 'package:http/http.dart' as http;

import '../logs/logger.dart';

class AppHttpClient {
  const AppHttpClient._();

  static Future<http.Response?> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      return await http.get(uri, headers: headers);
    } catch (error, stackTrace) {
      safeLogError(
        'HTTP GET failed for $uri',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
