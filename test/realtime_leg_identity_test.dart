import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/realtime_leg_match.dart';
import 'package:lbww_flutter/utils/realtime_service_date.dart';

Leg _leg({
  String departure = '2026-10-15T11:00:00',
  Map<String, dynamic>? raw,
}) => Leg(
  origin: Stop(
    id: 'origin',
    name: 'Origin',
    type: 'stop',
    departureTimePlanned: departure,
  ),
  destination: Stop(id: 'destination', name: 'Destination', type: 'stop'),
  transportation: Transportation(id: 'route'),
  rawJson: raw ?? const {},
);

TripDescriptor _descriptor({
  String id = 'trip',
  String? route = 'route',
  String date = '20261015',
  String time = '10:00:00',
}) => TripDescriptor(
  tripId: id,
  routeId: route,
  startDate: date,
  startTime: time,
);

TripUpdate _update(TripDescriptor descriptor) => TripUpdate(
  trip: descriptor,
  stopTimeUpdate: [
    TripUpdate_StopTimeUpdate(
      stopId: 'origin',
      departure: TripUpdate_StopTimeEvent(
        time: Int64(DateTime.utc(2026, 10, 15).millisecondsSinceEpoch ~/ 1000),
        delay: 0,
      ),
    ),
    TripUpdate_StopTimeUpdate(stopId: 'destination'),
  ],
);

VehiclePosition _vehicle(TripDescriptor descriptor) => VehiclePosition(
  trip: descriptor,
  vehicle: VehicleDescriptor(id: 'vehicle'),
  position: Position(latitude: -33.86, longitude: 151.20),
);

void main() {
  test('stop-time fallback requires the known route to match', () {
    final leg = _leg();
    for (final route in [null, '', 'different-route']) {
      expect(
        matchRealtimeUpdateForLeg(
          [_update(_descriptor(route: route))],
          leg,
          {},
        ),
        isNull,
        reason: 'route=$route cannot identify this leg',
      );
    }
    final update = _update(_descriptor());
    expect(matchRealtimeUpdateForLeg([update], leg, {}), same(update));
  });

  test('trip and route compatibility both constrain identified legs', () {
    final leg = _leg();
    expect(
      matchRealtimeUpdateForLeg(
        [_update(_descriptor(route: 'other-route'))],
        leg,
        {'trip'},
      ),
      isNull,
    );
    expect(
      matchRealtimeUpdateForLeg(
        [_update(_descriptor(id: 'other-trip'))],
        leg,
        {'trip'},
      ),
      isNull,
    );
  });

  test('reused trip ID does not admit a different service date', () {
    final leg = _leg();
    final current = _update(_descriptor());
    final wrongDay = _update(_descriptor(date: '20261014'));
    // Do not provide stop-time evidence for the previous service day.
    wrongDay.stopTimeUpdate.clear();
    expect(
      matchRealtimeUpdateForLeg([wrongDay, current], leg, {'trip'}),
      same(current),
    );
    expect(realtimeDescriptorMatchesLeg(wrongDay.trip, leg, {'trip'}), isFalse);
  });

  test('multiple plausible departures remain ambiguous', () {
    final leg = _leg();
    final first = _update(_descriptor(time: '09:00:00'));
    final second = _update(_descriptor(time: '10:00:00'));
    expect(matchRealtimeUpdateForLeg([first, second], leg, {'trip'}), isNull);
    final vehicles = [_vehicle(first.trip), _vehicle(second.trip)];
    expect(filterRealtimeVehiclesForLeg(vehicles, leg, {'trip'}), isEmpty);
    expect(
      filterRealtimeVehiclesForLeg(vehicles, leg, {
        'trip',
      }, matchedTrip: second.trip),
      [same(vehicles.last)],
    );
  });

  test('regional provenance cannot match TfNSW records', () {
    final leg = _leg(raw: {'provenance': 'regional_journey_planner'});
    expect(
      matchRealtimeUpdateForLeg([_update(_descriptor())], leg, {'trip'}),
      isNull,
    );
    expect(realtimeDescriptorMatchesLeg(_descriptor(), leg, {'trip'}), isFalse);
  });

  test(
    'offset-free Sydney and explicit UTC departures represent one instant',
    () {
      final local = _leg(departure: '2026-10-16T01:00:00');
      final utc = _leg(departure: '2026-10-15T14:00:00Z');
      expect(tfnswDepartureInstant(local), DateTime.utc(2026, 10, 15, 14));
      expect(tfnswDepartureInstant(utc), tfnswDepartureInstant(local));
      final overnight = _descriptor(date: '20261015', time: '25:00:00');
      expect(realtimeServiceDateMatches(overnight, local), isTrue);
      expect(realtimeServiceDateMatches(overnight, utc), isTrue);
      expect(
        realtimeServiceDateMatches(
          _descriptor(date: '20261015', time: '23:00:00'),
          local,
        ),
        isFalse,
      );
    },
  );

  test('explicit service date and invalid calendar dates fail closed', () {
    final leg = _leg(raw: {'startDate': '20261015'});
    expect(
      realtimeServiceDateMatches(_descriptor(date: '20261014'), leg),
      isFalse,
    );
    expect(
      realtimeServiceDateMatches(_descriptor(date: '20260230'), _leg()),
      isFalse,
    );
  });
}
