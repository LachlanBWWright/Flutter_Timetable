import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/stops_service.dart' show StopsEndpoint;
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    // Load API key from project .env (there is a .env in repo root)
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      fail('API_KEY not set in .env. Aborting integration tests.');
    }
  });

  test(
    'fetchGtfsDataForEndpoint - nswtrains (integration)',
    () async {
      // This test calls the real endpoint. Allow generous timeout for network.
      final data = await NewTripService.fetchGtfsDataForEndpoint(
        StopsEndpoint.nswtrains,
      );
      expect(data, isNotNull);
      // At least one agency or stop should be present in a successful feed
      expect((data!.agencies.isNotEmpty || data.stops.isNotEmpty), isTrue);
    },
    timeout: const Timeout(Duration(seconds: 60)),
    skip: 'Requires live API key',
  );

  test(
    'fetchGtfsDataForEndpoint - buses (integration)',
    () async {
      final data = await NewTripService.fetchGtfsDataForEndpoint(
        StopsEndpoint.buses,
      );
      expect(data, isNotNull);
      expect((data!.stops.isNotEmpty || data.routes.isNotEmpty), isTrue);
    },
    timeout: const Timeout(Duration(seconds: 60)),
    skip: 'Requires live API key',
  );
}
