import 'dart:convert';

import 'package:option_result/option_result.dart';

import '../../logs/logger.dart' as app_logger;
import '../../services/api_key_service.dart';
import '../../utils/safe_value_utils.dart';
import '../../wrappers/app_http_client_impl.dart';
import '../swagger_clients/swagger_backend.dart';
import '../swagger_generated/trip_planner.enums.swagger.dart' as enums;
import '../swagger_generated/trip_planner.swagger.dart' as generated;
import '../swagger_generated/trip_planner.swagger.dart' show TripPlanner;
import 'trip_planner_generated_mapper.dart';

part 'transport_api/journey_models.dart';
part 'transport_api/leg_model.dart';
part 'transport_api/stop_models.dart';
part 'transport_api/footpath_models.dart';
part 'transport_api/information_models.dart';
part 'transport_api/path_models.dart';
part 'transport_api/transportation_models.dart';
part 'transport_api/system_messages.dart';

final logger = app_logger.safeLogger;

// Compatibility helpers used only by the legacy display-model constructors
// below. Live API responses and persisted cache responses enter through the
// generated Trip Planner models above.
bool? _readBoolValue(Map<String, dynamic> json, String key) {
  final value = tryReadMapValue(json, key);
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

String _readStringOrEmpty(Map<String, dynamic>? json, String key) {
  return tryReadStringValue(json, key) ?? '';
}

List<T> _parseJsonList<T>(
  List<dynamic>? values,
  T? Function(Map<String, dynamic> json) parse,
) {
  return values
          ?.whereType<Map<String, dynamic>>()
          .map(parse)
          .whereType<T>()
          .toList() ??
      <T>[];
}

List<String>? _stringListOrNull(List<dynamic>? values) =>
    values?.map((value) => value.toString()).toList();

T? _firstNonNull<T>(T? primary, T? fallback) => primary ?? fallback;

Stop _unknownStop() {
  return Stop(
    id: '',
    name: 'Unknown',
    type: '',
    rawJson: const <String, dynamic>{},
  );
}

/// Service class for handling NSW Transport API requests
class TransportApiService {
  static Future<TripPlanner?> _client({
    bool validateCredentials = false,
  }) async {
    try {
      final key = ApiKeyService.getEffectiveApiKey();
      return await createTripPlannerClient(
        apiKey: key,
        httpClient: validateCredentials
            ? BoundedHttpClient(useSharedCache: false)
            : null,
      );
    } catch (e, st) {
      logger.e('Unable to create generated Trip Planner client: $e');
      logger.e(st);
      return null;
    }
  }

  /// Test if API key is valid
  static Future<bool> isApiKeyValid() async {
    try {
      final client = await _client(validateCredentials: true);
      if (client == null) return false;
      final response = await client.stopFinderGet(
        outputFormat: enums.StopFinderGetOutputFormat.rapidjson,
        typeSf: enums.StopFinderGetTypeSf.stop,
        nameSf: '200060',
        coordOutputFormat: enums.StopFinderGetCoordOutputFormat.epsg4326,
      );
      return response.statusCode == 200 && response.body != null;
    } catch (e) {
      // Error validating API key
      return false;
    }
  }

  /// Search for stations/stops
  static Future<Result<List<Map<String, dynamic>>, String>> searchStations(
    String query,
  ) async {
    try {
      final client = await _client();
      if (client == null) return const Err('Unable to create API client');
      final response = await client.stopFinderGet(
        outputFormat: enums.StopFinderGetOutputFormat.rapidjson,
        typeSf: enums.StopFinderGetTypeSf.any,
        nameSf: query,
        coordOutputFormat: enums.StopFinderGetCoordOutputFormat.epsg4326,
        tfNSWSF: enums.StopFinderGetTfNSWSF.$true,
      );
      if (response.statusCode != 200) {
        return Err('Failed to search stations: ${response.statusCode}');
      }
      final body = response.body;
      if (body == null) return const Err('Stop Finder returned no body');

      return Ok(
        (body.locations ?? const []).map((location) {
          final fallbackName = location.name ?? '';
          final name = (location.disassembledName?.isNotEmpty ?? false)
              ? location.disassembledName!
              : fallbackName;
          return {
            'name': name,
            'displayName': fallbackName,
            'id': location.id ?? '',
            'type': location.type?.value,
          };
        }).toList(),
      );
    } catch (e, st) {
      logger.e('Error searching stations: $e');
      logger.e(st);
      return Err(e.toString());
    }
  }

  /// Get trip information between two stations
  static Future<Result<GetTripsResponse, String>> getTrips({
    required String originId,
    required String destinationId,
  }) async {
    try {
      final client = await _client();
      if (client == null) return const Err('Unable to create API client');
      final response = await client.tripGet(
        outputFormat: enums.TripGetOutputFormat.rapidjson,
        coordOutputFormat: enums.TripGetCoordOutputFormat.epsg4326,
        depArrMacro: enums.TripGetDepArrMacro.dep,
        typeOrigin: enums.TripGetTypeOrigin.any,
        nameOrigin: originId,
        typeDestination: enums.TripGetTypeDestination.any,
        nameDestination: destinationId,
        calcNumberOfTrips: 20,
        excludedMeans: enums.TripGetExcludedMeans.checkbox,
        exclMOT7: enums.TripGetExclMOT7.value_1,
        exclMOT11: enums.TripGetExclMOT11.value_1,
        tfNSWTR: enums.TripGetTfNSWTR.$true,
        itOptionsActive: 0,
      );
      logger.i('Response code ${response.statusCode}');

      if (response.statusCode != 200) {
        return Err('Failed to get trips: ${response.statusCode}');
      }
      final body = response.body;
      if (body == null) return const Err('Trip Planner returned no body');
      logger.i(
        'TransportApiService.getTrips: received ${body.journeys?.length ?? 0} journeys for origin=$originId destination=$destinationId',
      );
      final parsed = getTripsResponseFromGenerated(body);
      return Ok(
        GetTripsResponse(
          tripJourneys: parsed.tripJourneys,
          systemMessages: parsed.systemMessages,
          version: parsed.version,
          rawJson: parsed.rawJson,
          fetchedAt: DateTime.tryParse(
            response.headers['x-transit-fetched-at'] ?? '',
          ),
        ),
      );
    } catch (e, st) {
      logger.e('getTrips error: $e');
      logger.e(st);
      return Err(e.toString());
    }
  }
}
