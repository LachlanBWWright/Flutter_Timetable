import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';
import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  // Live tests are skipped by default; set LIVE_API_TEST=true to run.
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  // default base intentionally removed — `createRealtimeTripUpdatesV1`
  // will use the configured base or the default when creating the client.

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      final clientHttp = http.Client();
      final chopperClient = await createChopperClient(httpClient: clientHttp);
      final client = RealtimeTripUpdatesV1.create(client: chopperClient);
      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      final clientHttp = http.Client();
      final chopperClient = await createChopperClient(httpClient: clientHttp);
      final client = RealtimeTripUpdatesV1.create(client: chopperClient);
      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
