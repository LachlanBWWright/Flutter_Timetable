import 'dart:convert';
import 'dart:io';

import 'package:lbww_flutter/services/transport_api_service.dart';

void main() {
  final stopwatch = Stopwatch()..start();
  final data =
      jsonDecode(File('lib/trip_leg_raw_json.json').readAsStringSync())
          as Map<String, dynamic>;
  final trip = TripJourney.fromJson(data);
  stopwatch.stop();

  print('parse_ms=${stopwatch.elapsedMilliseconds}');
  print('legs=${trip.legs.length}');
  print('first_transport_id=${trip.legs.first.transportation?.id}');
}
