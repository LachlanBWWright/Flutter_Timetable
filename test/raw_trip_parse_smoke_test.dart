// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

void main() {
  test('raw trip fixture parses', () async {
    final contents = await File('lib/trip_leg_raw_json.json').readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final trip = TripJourney.fromJson(data);

    expect(trip.legs, isNotEmpty);
    expect(trip.legs.first.transportation?.properties?.tripCode, isNotNull);
  });
}
