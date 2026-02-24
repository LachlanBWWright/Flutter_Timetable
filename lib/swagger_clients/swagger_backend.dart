import 'dart:io';

import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const String _defaultRealtimeBase = 'https://api.transport.nsw.gov.au/';

Future<chopper.ChopperClient> createChopperClient({
  http.Client? httpClient,
  String? baseUrl,
  String? apiKey,
}) async {
  await dotenv.load();

  final apiKeyFromArg = apiKey;
  final apiKeyFromEnv =
      apiKeyFromArg ?? dotenv.env['API_KEY'] ?? dotenv.env['TRANSPORT_API_KEY'];

  final baseFromArg = baseUrl;
  final baseFromEnv = baseFromArg ??
      dotenv.env['API_BASE_URL'] ??
      Platform.environment['API_BASE_URL'] ??
      _defaultRealtimeBase;

  final clientHttp = httpClient ?? http.Client();

  final interceptors = <chopper.Interceptor>[];
  if (apiKeyFromEnv != null && apiKeyFromEnv.isNotEmpty) {
    interceptors.add(
        chopper.HeadersInterceptor({'Authorization': 'apikey $apiKeyFromEnv', 'accept': 'application/x-protobuf'}));
  } else {
    interceptors.add(chopper.HeadersInterceptor({'accept': 'application/x-protobuf'}));
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

final Future<chopper.ChopperClient> client = createChopperClient();
