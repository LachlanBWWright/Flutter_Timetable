import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:lbww_flutter/victoria/services/ptv_credentials.dart';
import 'package:lbww_flutter/victoria/services/ptv_timetable_client.dart';

class PtvSignedClient {
  PtvSignedClient({PtvTimetableV3? client, PtvCredentials? credentials})
    : _client = client ?? PtvTimetableV3.create(),
      _credentialsOverride = credentials;

  final PtvTimetableV3 _client;
  final PtvCredentials? _credentialsOverride;
  PtvCredentials get _credentials =>
      _credentialsOverride ?? loadPtvCredentials();

  bool get isConfigured => _credentials.isConfigured;
  PtvTimetableV3 get client => _client;
  String get developerId => _credentials.developerId;

  String? signatureForPath(String path, Map<String, String?> queryParameters) {
    if (!isConfigured) {
      return null;
    }
    final merged = <String, String>{'devid': _credentials.developerId};
    queryParameters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        merged[key] = value;
      }
    });
    final sortedKeys = merged.keys.toList()..sort();
    final query = sortedKeys
        .map(
          (key) =>
              '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(merged[key]!)}',
        )
        .join('&');
    final payload = '$path?$query';
    final bytes = Hmac(
      sha1,
      utf8.encode(_credentials.apiKey),
    ).convert(utf8.encode(payload));
    return bytes.bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }
}
