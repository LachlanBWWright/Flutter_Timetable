import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  test('uses agency timezone and coalesces connections on one trip', () async {
    final result = await fixturePlanner(
      plannerData(),
    ).planJourney(plannerRequest());

    expect(result.journeys, hasLength(1));
    final leg = result.journeys.single.legs.single;
    expect(leg.destination.name, 'Gamma');
    expect(leg.route?.shortName, '10');
    expect(leg.departureTime, DateTime.utc(2026, 8, 13));
    expect(leg.arrivalTime, DateTime.utc(2026, 8, 13, 0, 20));
    expect(leg.departureTime!.isUtc, isTrue);
  });

  for (final transition in [
    (
      date: '20260405',
      when: DateTime.utc(2026, 4, 4, 16, 55),
      departure: DateTime.utc(2026, 4, 4, 17),
    ),
    (
      date: '20261004',
      when: DateTime.utc(2026, 10, 3, 15, 55),
      departure: DateTime.utc(2026, 10, 3, 16),
    ),
  ]) {
    test('uses service-noon anchor across DST ${transition.date}', () async {
      final data = plannerData(
        timezone: 'Australia/Sydney',
        serviceDate: transition.date,
        times:
            'T1,03:00:00,03:00:00,A,1,0,0\n'
            'T1,03:20:00,03:20:00,C,2,0,0\n',
      );
      final result = await fixturePlanner(
        data,
      ).planJourney(plannerRequest(when: transition.when));
      final leg = result.journeys.single.legs.single;
      expect(leg.departureTime, transition.departure);
      expect(
        leg.arrivalTime,
        transition.departure.add(const Duration(minutes: 20)),
      );
    });
  }

  for (final service in [
    (date: '20260812', hour: 25),
    (date: '20260811', hour: 49),
  ]) {
    test('finds prior-day service at ${service.hour}:00', () async {
      final data = plannerData(
        serviceDate: service.date,
        times:
            'T1,${service.hour}:00:00,${service.hour}:00:00,A,1,0,0\n'
            'T1,${service.hour}:20:00,${service.hour}:20:00,C,2,0,0\n',
      );
      final result = await fixturePlanner(
        data,
      ).planJourney(plannerRequest(when: DateTime.utc(2026, 8, 12, 14, 55)));
      expect(
        result.journeys.single.legs.single.departureTime,
        DateTime.utc(2026, 8, 12, 15),
      );
    });
  }

  test('finds tomorrow after the final service of today', () async {
    final result = await fixturePlanner(
      plannerData(),
    ).planJourney(plannerRequest(when: DateTime.utc(2026, 8, 13, 2)));
    expect(
      result.journeys.single.legs.single.departureTime,
      DateTime.utc(2026, 8, 14),
    );
  });

  test(
    'a successful feed with no active services yields an empty plan',
    () async {
      final result = await fixturePlanner(
        plannerData(serviceDate: '20260101'),
      ).planJourney(plannerRequest());
      expect(result.journeys, isEmpty);
    },
  );

  test('filters modes before connection scanning', () async {
    final planner = fixturePlanner(plannerData());
    final excluded = await planner.planJourney(
      plannerRequest(modes: [TransportMode.train]),
    );
    final included = await planner.planJourney(
      plannerRequest(modes: [TransportMode.bus]),
    );
    final none = await planner.planJourney(plannerRequest(modes: []));
    expect(excluded.journeys, isEmpty);
    expect(none.journeys, isEmpty);
    expect(included.journeys, hasLength(1));
  });

  for (final routeType in ['11', '209', '716', '800']) {
    test('recognizes extended bus route type $routeType', () async {
      final result = await fixturePlanner(
        plannerData(routeType: routeType),
      ).planJourney(plannerRequest(modes: [TransportMode.bus]));
      expect(result.journeys.single.legs.single.mode, TransportMode.bus);
    });
  }

  test('rejects unsupported constraints before loading a feed', () async {
    var loads = 0;
    final planner = GtfsJourneyPlanner(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      loadData: (_) async {
        loads++;
        return plannerData();
      },
    );
    for (final request in [
      plannerRequest(arrivalBased: true),
      plannerRequest(walkingLimit: const Duration(minutes: 5)),
      plannerRequest(
        accessibility: TransitAccessibility.values.firstWhere(
          (value) => value != TransitAccessibility.none,
        ),
      ),
    ]) {
      await expectLater(
        planner.planJourney(request),
        throwsA(isA<UnsupportedCapability>()),
      );
    }
    expect(loads, 0);
  });

  test('rejects a negative walking limit as invalid input', () async {
    await expectLater(
      fixturePlanner(
        plannerData(),
      ).planJourney(plannerRequest(walkingLimit: const Duration(minutes: -1))),
      throwsA(isA<InvalidJourneyRequest>()),
    );
  });
}
