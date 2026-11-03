import 'dart:math';

import 'package:http/http.dart' as http;

/// Retry timing shared by application HTTP GETs.
class AppHttpRetryPolicy {
  AppHttpRetryPolicy._();

  static const Duration _baseDelay = Duration(milliseconds: 250);
  static const Duration _maxBackoff = Duration(seconds: 5);
  static const Duration _maxRetryAfter = Duration(seconds: 30);
  static final Random _random = Random();

  static const Set<int> retryableStatusCodes = {
    408,
    425,
    429,
    500,
    502,
    503,
    504,
  };

  static Duration backoffDelay(int attempt) {
    final exponent = 1 << attempt.clamp(0, 8).toInt();
    final exponentialMs = min(
      _baseDelay.inMilliseconds * exponent,
      _maxBackoff.inMilliseconds,
    ).toInt();
    final jitteredMs = min(
      _maxBackoff.inMilliseconds,
      (exponentialMs * (0.5 + _random.nextDouble())).round(),
    ).toInt();
    return Duration(milliseconds: jitteredMs);
  }

  /// Returns null when the provider asks us to wait longer than our cap.
  static Duration? delayFor(int attempt, http.Response response) {
    final backoff = backoffDelay(attempt);
    final retryAfter = _retryAfter(response);
    if (retryAfter?.overLimit == true) return null;
    final serverDelay = retryAfter?.delay;
    if (serverDelay == null || serverDelay <= backoff) return backoff;
    return serverDelay;
  }

  static ({Duration? delay, bool overLimit})? _retryAfter(
    http.Response response,
  ) {
    if (response.statusCode != 429 && response.statusCode != 503) return null;
    String? value;
    for (final entry in response.headers.entries) {
      if (entry.key.toLowerCase() == 'retry-after') {
        value = entry.value.trim();
        break;
      }
    }
    if (value == null || value.isEmpty) return null;

    final seconds = int.tryParse(value);
    if (seconds != null) {
      if (seconds <= 0) return (delay: Duration.zero, overLimit: false);
      if (seconds > _maxRetryAfter.inSeconds) {
        return (delay: null, overLimit: true);
      }
      return (delay: Duration(seconds: seconds), overLimit: false);
    }

    final retryAt = _parseHttpDate(value);
    if (retryAt == null) return null;
    final delay = retryAt.difference(DateTime.now().toUtc());
    if (delay <= Duration.zero) {
      return (delay: Duration.zero, overLimit: false);
    }
    if (delay > _maxRetryAfter) return (delay: null, overLimit: true);
    return (delay: delay, overLimit: false);
  }

  static DateTime? _parseHttpDate(String value) {
    final match = RegExp(
      r'^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) '
      r'(\d{2}):(\d{2}):(\d{2}) GMT$',
    ).firstMatch(value);
    if (match == null) return null;

    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final month = months[match.group(2)];
    if (month == null) return null;

    return DateTime.utc(
      int.parse(match.group(3)!),
      month,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }
}
