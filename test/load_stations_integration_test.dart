import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      fail('API_KEY not set in .env — integration tests require a valid API key.');
    }
  });

  test('loadStopsForMode returns Station list for train', () async {
    final stations = await NewTripService.loadStopsForMode('train');
    expect(stations, isNotNull);
    expect(stations.isNotEmpty, isTrue);
    print('First station (train): name=${stations.first.name}, id=${stations.first.id}');
  }, timeout: Timeout(Duration(seconds: 120)));

  test('loadStopsForMode returns Station list for bus', () async {
    final stations = await NewTripService.loadStopsForMode('bus');
    expect(stations, isNotNull);
    expect(stations.isNotEmpty, isTrue);
    print('First station (bus): name=${stations.first.name}, id=${stations.first.id}');
  }, timeout: Timeout(Duration(seconds: 120)));
}
