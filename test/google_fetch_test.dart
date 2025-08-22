import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:chopper/chopper.dart';

// Minimal ChopperService for Google fetch
abstract class GoogleService extends ChopperService {
  static GoogleService create([ChopperClient? client]) => _GoogleServiceImpl(
      client ?? ChopperClient(baseUrl: Uri.parse('https://www.google.com')));
  Future<Response> fetch204();
  @override
  Type get definitionType => GoogleService;
}

class _GoogleServiceImpl extends GoogleService {
  final ChopperClient _client;
  _GoogleServiceImpl(this._client);
  @override
  ChopperClient get client => _client;
  @override
  Future<Response> fetch204() {
    final req = Request('GET', Uri.parse('/generate_204'), _client.baseUrl);
    return _client.send(req);
  }
}

void main() {
  test('fetch google.com returns 2xx/3xx within timeout (chopper)', () async {
    final chopper = ChopperClient(baseUrl: Uri.parse('https://www.google.com'));
    final googleService = GoogleService.create(chopper);
    try {
      final response =
          await googleService.fetch204().timeout(const Duration(seconds: 10));
      expect(response.statusCode, inInclusiveRange(200, 399),
          reason: 'Unexpected status code: ${response.statusCode}');
    } on TimeoutException {
      fail(
          'Request to google.com timed out (10s). Check WSL networking/firewall.');
    } on SocketException catch (e) {
      fail('Network error when connecting to google.com: $e');
    } catch (e) {
      fail('Unexpected error when fetching google.com: $e');
    }
  }, timeout: Timeout(Duration(seconds: 15)));
}
