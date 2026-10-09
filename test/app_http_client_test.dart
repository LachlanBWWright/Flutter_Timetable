// ignore_for_file: no_manual_throw

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';

void main() {
  const uri = 'https://provider.example/feed';

  test('retries a retryable response and returns the next success', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      if (requests == 1) return http.Response('busy', 503);
      return http.Response('ok', 200);
    });
    addTearDown(client.close);

    final response = await AppHttpClient.getOrThrow(
      Uri.parse(uri),
      client: client,
      retries: 1,
    );

    expect(response.statusCode, 200);
    expect(requests, 2);
  });

  test('does not retry a non-retryable response', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response('bad request', 400);
    });
    addTearDown(client.close);

    final response = await AppHttpClient.get(
      Uri.parse(uri),
      client: client,
      retries: 3,
    );

    expect(response?.statusCode, 400);
    expect(requests, 1);
  });

  test('maps provider status codes to stable failures', () async {
    for (final statusAndFailure in <(int, Type)>[
      (401, InvalidCredentials),
      (429, RateLimited),
      (503, ProviderUnavailable),
      (404, InvalidProviderResponse),
    ]) {
      final (status, failureType) = statusAndFailure;
      final client = MockClient(
        (request) async => http.Response('provider response', status),
      );
      addTearDown(client.close);

      await expectLater(
        AppHttpClient.getOrThrow(Uri.parse(uri), client: client, retries: 0),
        throwsA(
          isA<TransitFailure>().having(
            (failure) => failure.runtimeType,
            'failure type',
            failureType,
          ),
        ),
      );
    }
  });

  test('returns null after a transport failure', () async {
    final client = MockClient((request) async => throw StateError('offline'));
    addTearDown(client.close);

    final response = await AppHttpClient.get(
      Uri.parse(uri),
      client: client,
      retries: 0,
    );

    expect(response, isNull);
  });
}
