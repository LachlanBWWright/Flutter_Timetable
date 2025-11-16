import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';
import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'https://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      if (!liveMode) return;

      final clientHttp = http.Client();
      final chopperClient = await createChopperClient(httpClient: clientHttp);
      final client = RealtimeTripUpdatesV1.create(client: chopperClient);

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
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
// (removed duplicate consolidated block)
// (duplicate block removed)
// (duplicate block removed)
// Consolidated live-only tests for generated swagger client.
// Tests are skipped by default; set LIVE_API_TEST=true to run.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';
import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';

  group('RealtimeTripUpdatesV1 live tests (consolidated)', () {
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
// Consolidated live-only tests for generated swagger client.
// Tests are skipped by default; set LIVE_API_TEST=true to run.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';

  group('RealtimeTripUpdatesV1 live tests (consolidated)', () {
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
// Consolidated live-only tests for generated swagger client.
// Tests are skipped by default; set LIVE_API_TEST=true to run.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';

  group('RealtimeTripUpdatesV1 live tests (consolidated)', () {
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
// Consolidated live-only tests for generated swagger client.
// Tests are skipped by default; set LIVE_API_TEST=true to run.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';

  group('RealtimeTripUpdatesV1 live tests (consolidated)', () {
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
// This file contains live-only tests for the generated swagger client.  
// Tests are skipped by default; set LIVE_API_TEST=true to run them.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/swagger_clients/swagger_backend.dart';
import 'package:test/test.dart';
import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  // Base URL and API key are derived by the swagger helper.
  // You can use `await client` (exported in `swagger_backend.dart`) or
  // call `createChopperClient(...)` to create a client for each test.

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
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  // By default these are skipped — set LIVE_API_TEST=true to enable.
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

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
      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  // By default these are skipped — set LIVE_API_TEST=true to enable.
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  // Live tests are skipped by default. Set LIVE_API_TEST=true to run them.
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'package:test/test.dart';

import 'package:lbww_flutter/swagger_generated/realtime_trip_updates_v1.swagger.dart';

void main() {
  final bool liveMode = Platform.environment['LIVE_API_TEST'] == 'true';
  const String defaultBase = 'http://api.transport.nsw.gov.au/v1/gtfs/realtime';

  group('RealtimeTripUpdatesV1 live tests', () {
    test('busesGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.busesGet();
      expect(response.statusCode, anyOf([200, 206, 204]));

      clientHttp.close();
    }, skip: !liveMode);

    test('nswtrainsGet calls live API', () async {
      if (!liveMode) return;

      final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBase;
      final apiKey = Platform.environment['TRANSPORT_API_KEY'];
      final clientHttp = http.Client();

      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(chopper.HeadersInterceptor({'authorization': 'apikey $apiKey'}));
      }

      final client = RealtimeTripUpdatesV1.create(
        httpClient: clientHttp,
        baseUrl: Uri.parse(baseUrl),
        interceptors: interceptors,
      );

      final response = await client.nswtrainsGet();
      expect(response.statusCode, anyOf([200, 206, 204]));
      clientHttp.close();
    }, skip: !liveMode);
  });
}
// No need for dart:async here. (Trailing duplicates cleaned in a follow-up pass)
