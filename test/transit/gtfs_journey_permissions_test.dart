import 'package:flutter_test/flutter_test.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  for (final restriction in ['1', '2', '3']) {
    test('cannot board at pickup restriction $restriction', () async {
      final data = plannerData(
        times:
            'T1,10:00:00,10:00:00,A,1,$restriction,0\n'
            'T1,10:20:00,10:20:00,C,2,0,0\n',
      );
      final result = await fixturePlanner(data).planJourney(plannerRequest());
      expect(result.journeys, isEmpty);
    });

    test('cannot alight at drop-off restriction $restriction', () async {
      final data = plannerData(
        times:
            'T1,10:00:00,10:00:00,A,1,0,0\n'
            'T1,10:20:00,10:20:00,C,2,0,$restriction\n',
      );
      final result = await fixturePlanner(data).planJourney(plannerRequest());
      expect(result.journeys, isEmpty);
    });
  }

  test('may stay aboard through a restricted intermediate stop', () async {
    final data = plannerData(
      times:
          'T1,10:00:00,10:00:00,A,1,0,0\n'
          'T1,10:10:00,10:11:00,B,2,1,1\n'
          'T1,10:20:00,10:20:00,C,3,0,0\n',
    );
    final result = await fixturePlanner(data).planJourney(plannerRequest());
    expect(result.journeys.single.legs, hasLength(1));
    expect(result.journeys.single.legs.single.destination.name, 'Gamma');
  });

  test('cannot transfer from a stop where alighting is forbidden', () async {
    final data = plannerData(
      tripRows: 'R1,daily,T1,Beta\nR1,daily,T2,Gamma\n',
      times:
          'T1,10:00:00,10:00:00,A,1,0,0\n'
          'T1,10:10:00,10:10:00,B,2,0,1\n'
          'T2,10:15:00,10:15:00,B,1,0,0\n'
          'T2,10:30:00,10:30:00,C,2,0,0\n',
    );
    final result = await fixturePlanner(data).planJourney(plannerRequest());
    expect(result.journeys, isEmpty);
  });

  test('cannot transfer onto a trip where boarding is forbidden', () async {
    final data = plannerData(
      tripRows: 'R1,daily,T1,Beta\nR1,daily,T2,Gamma\n',
      times:
          'T1,10:00:00,10:00:00,A,1,0,0\n'
          'T1,10:10:00,10:10:00,B,2,0,0\n'
          'T2,10:15:00,10:15:00,B,1,1,0\n'
          'T2,10:30:00,10:30:00,C,2,0,0\n',
    );
    final result = await fixturePlanner(data).planJourney(plannerRequest());
    expect(result.journeys, isEmpty);
  });

  test('supports a permitted same-stop transfer', () async {
    final data = plannerData(
      tripRows: 'R1,daily,T1,Beta\nR1,daily,T2,Gamma\n',
      times:
          'T1,10:00:00,10:00:00,A,1,0,0\n'
          'T1,10:10:00,10:10:00,B,2,0,0\n'
          'T2,10:15:00,10:15:00,B,1,0,0\n'
          'T2,10:30:00,10:30:00,C,2,0,0\n',
    );
    final result = await fixturePlanner(data).planJourney(plannerRequest());
    expect(result.journeys.single.legs, hasLength(2));
    expect(
      result.journeys.single.legs.last.arrivalTime,
      DateTime.utc(2026, 8, 13, 0, 30),
    );
  });
}
