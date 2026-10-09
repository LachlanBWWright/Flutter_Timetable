import 'package:http/http.dart' as http;

import '../logs/logger.dart';
import '../transit/errors/transit_failure.dart';

class AppHttpClient {
  const AppHttpClient._();

  static const Duration _defaultTimeout = Duration(seconds: 20);
  static const int _defaultRetries = 2;
  static const Set<int> _retryableStatusCodes = {
    408,
    425,
    429,
    500,
    502,
    503,
    504,
  };

  static Future<http.Response?> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int retries = _defaultRetries,
    http.Client? client,
  }) async {
    final attempts = retries.clamp(0, 4).toInt() + 1;
    Object? lastError;
    StackTrace? lastStackTrace;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final response =
            await (client == null
                    ? http.get(uri, headers: headers)
                    : client.get(uri, headers: headers))
                .timeout(timeout);
        if (!_retryableStatusCodes.contains(response.statusCode) ||
            attempt == attempts - 1) {
          return response;
        }
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt == attempts - 1) {
          safeLogError(
            'HTTP GET failed for $uri after $attempts attempt(s)',
            error: error,
            stackTrace: stackTrace,
          );
          return null;
        }
      }
      await Future<void>.delayed(Duration(milliseconds: 250 * (1 << attempt)));
    }
    safeLogError(
      'HTTP GET failed for $uri',
      error: lastError,
      stackTrace: lastStackTrace,
    );
    return null;
  }

  /// Fetches a response while preserving a provider-specific failure reason.
  /// Use this at repository boundaries where an empty response would be
  /// indistinguishable from a valid empty feed.
  static Future<http.Response> getOrThrow(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int retries = _defaultRetries,
    http.Client? client,
  }) async {
    final response = await get(
      uri,
      headers: headers,
      timeout: timeout,
      retries: retries,
      client: client,
    );
    if (response == null) {
      throw const NetworkUnavailable(message: 'Network request failed.');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const InvalidCredentials(
        message: 'Provider credentials were rejected.',
      );
    }
    if (response.statusCode == 429) {
      throw const RateLimited(message: 'Provider rate limit exceeded.');
    }
    if (response.statusCode >= 500) {
      throw const ProviderUnavailable(
        message: 'Provider is temporarily unavailable.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InvalidProviderResponse(
        message: 'Provider returned HTTP ${response.statusCode}.',
      );
    }
    return response;
  }
}

/// HTTP client used by generated Chopper clients so they inherit the same
/// bounded request lifetime as the application client.
class BoundedHttpClient extends http.BaseClient {
  BoundedHttpClient({
    http.Client? inner,
    this.timeout = const Duration(seconds: 20),
  }) : _inner = inner ?? http.Client();

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request).timeout(timeout);

  @override
  void close() => _inner.close();
}
