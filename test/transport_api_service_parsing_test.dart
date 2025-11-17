import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

void main() {
  test('TripJourney.fromJson parses trip, leg, and stops correctly',
      () async {
    final file = File('lib/trip_leg_raw_json.json');
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;

    final trip = TripJourney.fromJson(data);
    final tripJson = trip.toJson();
    expect(tripJson, isNotNull);
    expect(tripJson['rating'], equals(0));
    expect(trip.legs?.length, equals(1));

    final leg = trip.legs!.first;
    final legJson = leg.toJson();
    expect(legJson, isNotNull);
    expect(legJson['isRealtimeControlled'], equals(true));

    final origin = leg.origin;
    expect(origin, isNotNull);
    final originJson = origin!.toJson();
    expect(originJson['isGlobalId'], equals(true));
    expect(originJson['niveau'], equals(1));

    final dest = leg.destination;
    expect(dest, isNotNull);
    final destJson = dest!.toJson();
    expect(destJson['isGlobalId'], equals(true));
    expect(destJson['niveau'], equals(-1));

    final trans = leg.transportation;
    expect(trans, isNotNull);
    final transJson = trans?.toJson();
    expect(transJson?['properties']?['RealtimeTripId'], isNotNull);
  });
}
