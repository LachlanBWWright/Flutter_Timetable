import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/transport_modes.dart';
import '../schema/database.dart' show Journey;
import '../vehicle_finder/models.dart';
import '../vehicle_finder/service_identity.dart';
import 'models.dart';

/// A confirmation snapshot, never permission to restart location sampling.
class ActiveJourneyRecovery {
  const ActiveJourneyRecovery({
    required this.vehicle,
    required this.match,
    required this.selectedAt,
    required this.confirmedAt,
  });
  final FinderVehicle vehicle;
  final ActiveJourneyMatch match;
  final DateTime selectedAt;
  final DateTime confirmedAt;
  String get title => match.title;

  bool validAt(DateTime now, Duration lifetime) =>
      !now.isBefore(selectedAt) && now.difference(selectedAt) < lifetime;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'selectedAt': selectedAt.toIso8601String(),
    'confirmedAt': confirmedAt.toIso8601String(),
    'journey': match.journey.toJson(),
    'reverse': match.reverse,
    'legDestinationId': match.currentLegDestinationId,
    'legDestinationName': match.currentLegDestinationName,
    'legIndex': match.currentLegIndex,
    'vehicle': {
      'id': vehicle.id,
      'mode': vehicle.mode.id,
      'observedAt': vehicle.observedAt.toIso8601String(),
      'tripKey': vehicle.tripKey,
      'label': vehicle.label,
      if (vehicle.service case final identity?)
        'identity': {
          'tripId': identity.tripId,
          'startDate': identity.startDate,
          'startTime': identity.startTime,
          'routeId': identity.routeId,
        },
    },
    // Coordinates and the phone's location history are deliberately not stored.
    'stops': [
      for (final stop in match.stops)
        {
          'id': stop.id,
          'stationId': stop.stationId,
          'name': stop.name,
          'sequence': stop.sequence,
          'arrival': stop.arrival?.toIso8601String(),
          'departure': stop.departure?.toIso8601String(),
          'skipped': stop.skipped,
        },
    ],
  };

  factory ActiveJourneyRecovery.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) throw const FormatException('Unknown version');
    final raw = json['vehicle'] as Map<String, dynamic>;
    final mode = TransportMode.values.byName(raw['mode'] as String);
    final identity = raw['identity'] as Map<String, dynamic>?;
    return ActiveJourneyRecovery(
      vehicle: FinderVehicle(
        id: raw['id'] as String,
        mode: mode,
        latitude: 0,
        longitude: 0,
        observedAt: DateTime.parse(raw['observedAt'] as String),
        tripKey: raw['tripKey'] as String,
        label: raw['label'] as String?,
        service: identity == null
            ? null
            : ServiceIdentity(
                mode: mode,
                tripId: identity['tripId'] as String,
                startDate: identity['startDate'] as String,
                startTime: identity['startTime'] as String,
                routeId: identity['routeId'] as String,
              ),
      ),
      match: ActiveJourneyMatch(
        journey: Journey.fromJson(json['journey'] as Map<String, dynamic>),
        reverse: json['reverse'] as bool,
        currentLegDestinationId: json['legDestinationId'] as String?,
        currentLegDestinationName: json['legDestinationName'] as String?,
        currentLegIndex: json['legIndex'] as int?,
        stops: [
          for (final stop
              in (json['stops'] as List).cast<Map<String, dynamic>>())
            RunningStop(
              id: stop['id'] as String,
              stationId: stop['stationId'] as String?,
              name: stop['name'] as String,
              sequence: stop['sequence'] as int,
              arrival: DateTime.tryParse(stop['arrival'] as String? ?? ''),
              departure: DateTime.tryParse(stop['departure'] as String? ?? ''),
              skipped: stop['skipped'] as bool,
            ),
        ],
      ),
      selectedAt: DateTime.parse(json['selectedAt'] as String),
      confirmedAt: DateTime.parse(json['confirmedAt'] as String),
    );
  }
}

bool sameSavedJourney(Journey a, Journey b) =>
    a.id == b.id &&
    a.originId == b.originId &&
    a.destinationId == b.destinationId &&
    a.mode == b.mode &&
    a.lineId == b.lineId &&
    a.legsJson == b.legsJson &&
    a.tripType == b.tripType;

ActiveJourneyMatch? reconcileMatch(
  ActiveJourneyMatch match,
  List<Journey> journeys,
) {
  final current = journeys.where((j) => sameSavedJourney(j, match.journey));
  if (current.isEmpty) return null;
  return ActiveJourneyMatch(
    journey: current.first,
    reverse: match.reverse,
    stops: match.stops,
    plannedTrip: match.plannedTrip,
    currentLegDestinationId: match.currentLegDestinationId,
    currentLegDestinationName: match.currentLegDestinationName,
    currentLegIndex: match.currentLegIndex,
  );
}

abstract class ActiveJourneyRecoveryStore {
  Future<ActiveJourneyRecovery?> read();
  Future<void> write(ActiveJourneyRecovery? recovery);
}

class PreferencesJourneyRecoveryStore implements ActiveJourneyRecoveryStore {
  static const key = 'active_journey_confirmation_v1';
  Future<void> _pending = Future.value();

  @override
  Future<ActiveJourneyRecovery?> read() async {
    await _pending;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      return value == null
          ? null
          : ActiveJourneyRecovery.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            );
    } catch (_) {
      // An unavailable or invalid local snapshot must never prevent startup.
      return null;
    }
  }

  @override
  Future<void> write(ActiveJourneyRecovery? recovery) {
    final encoded = recovery == null ? null : jsonEncode(recovery.toJson());
    _pending = _pending.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (encoded == null) {
          await prefs.remove(key);
        } else {
          await prefs.setString(key, encoded);
        }
      } catch (_) {
        // Recovery is optional; keep the in-memory confirmation usable.
      }
    });
    return _pending;
  }
}
