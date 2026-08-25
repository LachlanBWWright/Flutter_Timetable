import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/nsw/swagger_clients/swagger_backend.dart';
import 'package:lbww_flutter/nsw/swagger_generated/trip_planner.enums.swagger.dart'
    as enums;
import 'package:lbww_flutter/nsw/swagger_generated/trip_planner.swagger.dart'
    show TripPlanner;
import 'package:lbww_flutter/nsw/wrappers/transport_api_service_impl.dart'
    as app_api;
import 'package:option_result/option_result.dart';
import 'package:test/test.dart';

void main() {
  final runLiveTests = Platform.environment['RUN_NSW_API_TESTS'] == 'true';
  late TripPlanner api;

  setUpAll(() async {
    if (runLiveTests) {
      try {
        await dotenv.load();
      } catch (_) {
        // The key may instead be provided through the process environment.
      }
      final key =
          dotenv.env['API_KEY'] ?? Platform.environment['API_KEY'] ?? '';
      if (key.isEmpty) {
        throw StateError(
          'RUN_NSW_API_TESTS=true requires API_KEY in .env or the environment.',
        );
      }
      api = await createTripPlannerClient();
    }
  });

  test(
    'generated NSW Stop Finder client calls and decodes live JSON',
    () async {
      final response = await api.stopFinderGet(
        outputFormat: enums.StopFinderGetOutputFormat.rapidjson,
        typeSf: enums.StopFinderGetTypeSf.any,
        nameSf: 'Central',
        coordOutputFormat: enums.StopFinderGetCoordOutputFormat.epsg4326,
        tfNSWSF: enums.StopFinderGetTfNSWSF.$true,
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(response.body, isNotNull);
      expect(response.body!.version, isNotEmpty);
      expect(response.body!.locations, isNotEmpty);
      final sample = response.body!.locations!.first;
      print('STATE_SAMPLE NSW stop=${sample.name} id=${sample.id}');
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'generated NSW Trip Planner client calls and decodes live JSON',
    () async {
      final response = await api.tripGet(
        outputFormat: enums.TripGetOutputFormat.rapidjson,
        coordOutputFormat: enums.TripGetCoordOutputFormat.epsg4326,
        depArrMacro: enums.TripGetDepArrMacro.dep,
        typeOrigin: enums.TripGetTypeOrigin.any,
        nameOrigin: '200060',
        typeDestination: enums.TripGetTypeDestination.any,
        nameDestination: '200070',
        calcNumberOfTrips: 2,
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(response.body, isNotNull);
      expect(response.body!.version, isNotEmpty);
      expect(response.body!.journeys, isNotEmpty);
      final sample = response.body!.journeys!.first;
      print(
        'STATE_SAMPLE NSW journey legs=${sample.legs?.length ?? 0} '
        'origin=200060 destination=200070',
      );
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'generated NSW Additional Info client calls and decodes live JSON',
    () async {
      final response = await api.addInfoGet(
        outputFormat: enums.AddInfoGetOutputFormat.rapidjson,
        filterPublicationStatus:
            enums.AddInfoGetFilterPublicationStatus.current,
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(response.body, isNotNull);
      expect(response.body!.version, isNotEmpty);
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'generated NSW Coordinate client calls and decodes live JSON',
    () async {
      final response = await api.coordGet(
        outputFormat: enums.CoordGetOutputFormat.rapidjson,
        coord: '151.206290:-33.884080:EPSG:4326',
        coordOutputFormat: enums.CoordGetCoordOutputFormat.epsg4326,
        inclFilter: enums.CoordGetInclFilter.value_1,
        type1: enums.CoordGetType1.busPoint,
        radius1: 500,
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(response.body, isNotNull);
      expect(response.body!.version, isNotEmpty);
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'generated NSW Departure Monitor client calls and decodes live JSON',
    () async {
      final response = await api.departureMonGet(
        outputFormat: enums.DepartureMonGetOutputFormat.rapidjson,
        coordOutputFormat: enums.DepartureMonGetCoordOutputFormat.epsg4326,
        mode: enums.DepartureMonGetMode.direct,
        typeDm: enums.DepartureMonGetTypeDm.stop,
        nameDm: '200060',
        departureMonitorMacro: enums.DepartureMonGetDepartureMonitorMacro.$true,
        tfNSWDM: enums.DepartureMonGetTfNSWDM.$true,
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(response.body, isNotNull);
      expect(response.body!.version, isNotEmpty);
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'app NSW service uses generated models for station search and trips',
    () async {
      final stations = await app_api.TransportApiService.searchStations(
        'Central',
      );
      expect(stations, isA<Ok<List<Map<String, dynamic>>, String>>());
      final centralId = stations.unwrap().first['id'] as String;
      expect(centralId, isNotEmpty);

      final trips = await app_api.TransportApiService.getTrips(
        originId: '200060',
        destinationId: '200070',
      );
      expect(trips, isA<Ok<app_api.GetTripsResponse, String>>());
      final body = trips.unwrap();
      expect(body.version, isNotEmpty);
      expect(body.tripJourneys, isNotEmpty);
      expect(body.rawJson['journeys'], isA<List<dynamic>>());
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
