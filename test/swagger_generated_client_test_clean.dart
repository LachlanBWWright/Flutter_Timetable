// Clean consolidated tests for RealtimeTripUpdatesV1 using the swagger helper.
// These tests are skipped by default; set LIVE_API_TEST=true to enable.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';
import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';

  group('RealtimeTripUpdatesV1 clean tests', () {
    test('busesGet live', () async {
      if (!liveMode) return;
      final clientHttp = http.Client();
      final chopperClient = await createChopperClient(httpClient: clientHttp);
      final client = RealtimeTripUpdatesV1.create(client: chopperClient);
      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      // Close the underlying http client we created.
      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet live', () async {
      if (!liveMode) return;
      final clientHttp = http.Client();
      final chopperClient = await createChopperClient(httpClient: clientHttp);
      final client = RealtimeTripUpdatesV1.create(client: chopperClient);
      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
