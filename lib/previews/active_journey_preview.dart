import 'package:flutter/material.dart';

import '../active_journey/models.dart';
import '../active_journey/screen.dart';
import '../active_journey/session.dart';
import '../constants/transport_modes.dart';
import '../vehicle_finder/models.dart';
import '../vehicle_finder/service_identity.dart';
import 'preview_fixtures.dart';

Widget runningServicePagePreview() {
  final now = DateTime.utc(2026, 10, 20, 1);
  final vehicle = FinderVehicle(
    id: '17',
    mode: TransportMode.train,
    latitude: -33.88,
    longitude: 151.2,
    observedAt: now,
    tripKey: 'train-17',
    currentStopId: previewJourney.destinationId,
    currentStopSequence: 2,
    service: const ServiceIdentity(
      mode: TransportMode.train,
      tripId: '17',
      startDate: '20261020',
      routeId: 'T1',
    ),
  );
  final stops = [
    RunningStop(
      id: previewJourney.originId,
      name: previewJourney.origin,
      sequence: 1,
      arrival: now.subtract(const Duration(minutes: 4)),
    ),
    RunningStop(
      id: previewJourney.destinationId,
      name: previewJourney.destination,
      sequence: 2,
      arrival: now.add(const Duration(minutes: 4)),
    ),
  ];
  final service = RunningService(
    vehicle: vehicle,
    stops: stops,
    checkedAt: now,
    matches: [
      ActiveJourneyMatch(journey: previewJourney, reverse: false, stops: stops),
    ],
  );
  final session =
      ActiveJourneySession(
          clock: () => now,
          resolve: (v, j, n, p) async => service,
          vehicles: (v) async => [vehicle],
        )
        ..vehicle = vehicle
        ..service = service
        ..selectedAt = now
        ..confirmedAt = now
        ..selectedKey = '${previewJourney.id}:false';
  return ActiveJourneyScreen(
    journeys: const [previewJourney],
    session: session,
  );
}
