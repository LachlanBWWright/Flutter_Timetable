import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart' show Journey;
import 'package:lbww_flutter/vehicle_finder/models.dart';
import 'package:lbww_flutter/vehicle_finder/service_identity.dart';

final now = DateTime.utc(2026, 10, 20, 1);
const identity = ServiceIdentity(
  mode: TransportMode.train,
  tripId: 'trip-1',
  startDate: '20261020',
  startTime: '11:50:00',
  routeId: 'T1',
);
FinderVehicle detected({
  int sequence = 2,
  String? stop = 'B',
  String id = 'vehicle',
  DateTime? observedAt,
  ServiceIdentity service = identity,
}) => FinderVehicle(
  id: id,
  mode: TransportMode.train,
  latitude: -33.86,
  longitude: 151.2,
  observedAt: observedAt ?? now,
  tripKey: 'unused',
  service: service,
  currentStopId: stop,
  currentStopSequence: sequence,
);
Journey saved({
  int id = 1,
  String origin = 'A',
  String destination = 'C',
  String type = 'direct',
}) => Journey(
  id: id,
  origin: origin,
  originId: origin,
  destination: destination,
  destinationId: destination,
  tripType: type,
  mode: 'train',
  isPinned: false,
);
List<RunningStop> pattern() => [
  for (var index = 0; index < 4; index++)
    RunningStop(
      id: ['A', 'B', 'C', 'D'][index],
      name: ['Alpha', 'Beta', 'Gamma', 'Delta'][index],
      sequence: index + 1,
      departure: now.add(Duration(minutes: (index - 1) * 10)),
      arrival: now.add(Duration(minutes: (index - 1) * 10)),
    ),
];
RunningService running(
  FinderVehicle vehicle,
  List<Journey> journeys,
  DateTime time,
) => RunningService(
  vehicle: vehicle,
  stops: pattern(),
  checkedAt: time,
  matches: [
    for (final journey in journeys)
      ActiveJourneyMatch(
        journey: journey,
        reverse: false,
        stops: pattern().take(3).toList(),
      ),
  ],
);
