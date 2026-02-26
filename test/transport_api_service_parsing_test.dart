import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

void main() {
  test(
    'TripJourney.fromJson preserves rawJson on trip, leg, and stops',
    () async {
      final file = File('lib/trip_leg_raw_json.json');
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      final trip = TripJourney.fromJson(data);
      expect(trip.rawJson, isNotNull);
      expect(trip.rawJson!['rating'], equals(0));
      // Verify we parsed at least one leg and that parsed count does not
      // exceed the count in the raw JSON (malformed legs may be skipped).
      final rawLegs = (data['legs'] as List?) ?? [];
      expect(trip.legs.isNotEmpty, isTrue);
      expect(trip.legs.length, lessThanOrEqualTo(rawLegs.length));

      final leg = trip.legs.first;
      expect(leg.rawJson, isNotNull);
      expect(leg.rawJson!['isRealtimeControlled'], equals(true));

      final origin = leg.origin;
      expect(origin.rawJson, isNotNull);
      expect(origin.rawJson!['isGlobalId'], equals(true));
      expect(origin.rawJson!['niveau'], equals(1));

      final dest = leg.destination;
      expect(dest.rawJson, isNotNull);
      expect(dest.rawJson!['isGlobalId'], equals(true));
      expect(dest.rawJson!['niveau'], equals(-1));

      final trans = leg.transportation;
      expect(trans, isNotNull);
      expect(trans?.rawJson, isNotNull);
      expect(
        (trans?.rawJson?['properties'] as Map<String, dynamic>?)?['RealtimeTripId'],
        isNotNull,
      );
    },
  );
}
