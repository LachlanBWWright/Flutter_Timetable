import 'dart:io';

import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../swagger_generated/trip_planner.swagger.dart';

const String _defaultRealtimeBase = 'https://api.transport.nsw.gov.au/';
const String defaultTripPlannerBase =
    'https://api.transport.nsw.gov.au/v1/tp';

Future<String> _resolveApiKey(String? apiKey) async {
  if (apiKey != null) return apiKey;
  try {
    await dotenv.load();
  } catch (_) {
    // dotenv may already be loaded, or may not be available in a test binary.
  }
  return dotenv.env['API_KEY'] ?? dotenv.env['TRANSPORT_API_KEY'] ?? '';
}

Future<chopper.ChopperClient> createChopperClient({
  http.Client? httpClient,
  String? baseUrl,
  String? apiKey,
}) async {
  final apiKeyFromEnv = await _resolveApiKey(apiKey);

  final baseFromArg = baseUrl;
  final baseFromEnv =
      baseFromArg ??
      dotenv.env['API_BASE_URL'] ??
      Platform.environment['API_BASE_URL'] ??
      _defaultRealtimeBase;

  final clientHttp = httpClient ?? http.Client();

  final interceptors = <chopper.Interceptor>[];
  if (apiKeyFromEnv.isNotEmpty) {
    interceptors.add(
      chopper.HeadersInterceptor({
        'Authorization': 'apikey $apiKeyFromEnv',
        'accept': 'application/x-protobuf',
      }),
    );
  } else {
    interceptors.add(
      const chopper.HeadersInterceptor({'accept': 'application/x-protobuf'}),
    );
  }

  final created = chopper.ChopperClient(
    services: [],
    client: clientHttp,
    converter: null,
    interceptors: interceptors,
    baseUrl: Uri.parse(baseFromEnv),
  );
  return created;
}

/// Creates the generated JSON Trip Planner client.
///
/// The realtime protobuf client above is retained for the feed endpoints. The
/// Trip Planner API is a separate JSON service and must use the generated
/// service's converter and the `/v1/tp` base path.
Future<TripPlanner> createTripPlannerClient({
  http.Client? httpClient,
  String? baseUrl,
  String? apiKey,
}) async {
  final resolvedApiKey = await _resolveApiKey(apiKey);
  final headers = <String, String>{'Accept': 'application/json'};
  if (resolvedApiKey.isNotEmpty) {
    headers['Authorization'] = 'apikey $resolvedApiKey';
  }

  return TripPlanner.create(
    httpClient: httpClient,
    baseUrl: Uri.parse(baseUrl ?? defaultTripPlannerBase),
    interceptors: [chopper.HeadersInterceptor(headers)],
  );
}

final Future<chopper.ChopperClient> client = createChopperClient();
