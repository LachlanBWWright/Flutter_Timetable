import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/vehicle_finder/controller.dart';
import 'package:lbww_flutter/vehicle_finder/matcher.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';

import 'fixtures.dart';

// Synthetic, timestamped trajectories, not recordings of passengers or rides.
// Replay through production polling, health checks and matcher together.
void main() {
  for (final interruption in ['tunnel', 'feed outage']) {
    test(
      '$interruption clears confidence and requires new moving evidence',
      () {
        _replay(
          gps: (second) =>
              interruption == 'tunnel' && second >= 70 && second < 110
              ? null
              : phone(second),
          fleet: (second) {
            if (interruption == 'feed outage' && second == 90) {
              throw StateError('synthetic interrupted feed');
            }
            return [vehicle(second)];
          },
          inspect: (second, controller) {
            if (second == 60 || second == 180) {
              expect(controller.candidates.first.likely, isTrue);
            }
            if (second == 100) expect(controller.candidates, isEmpty);
            if (second == 120) {
              expect(controller.candidates, isNotEmpty);
              expect(controller.candidates.every((c) => !c.likely), isTrue);
            }
          },
        );
      },
    );
  }

  test('parallel services remain ambiguous throughout a moving ride', () {
    _replay(
      gps: phone,
      fleet: (second) => [
        vehicle(second),
        vehicle(second, id: 'parallel', longitude: 151.2001 + second * .0001),
      ],
      inspect: (_, controller) {
        expect(controller.candidates.every((c) => !c.likely), isTrue);
      },
    );
  });

  test('waiting beside stationary services never becomes a likely ride', () {
    _replay(
      gps: (second) => phone(second, longitude: 151.2, speed: 0),
      fleet: (second) => [vehicle(second, longitude: 151.2, speed: 0)],
      inspect: (_, controller) {
        expect(controller.candidates.every((c) => !c.likely), isTrue);
      },
    );
  });

  test('large fleet replay bounds polling, scans and retained histories', () {
    _replay(
      gps: phone,
      fleet: (second) =>
          List.generate(5000, (index) => vehicle(second, id: 'vehicle-$index')),
      inspect: (_, controller) {
        expect(controller.candidates.length, lessThanOrEqualTo(3));
        expect(controller.candidates.every((c) => !c.likely), isTrue);
        expect(
          controller.matcher.trackCount,
          lessThanOrEqualTo(VehicleMatcher.maxTracks),
        );
        expect(
          controller.matcher.locationCount,
          lessThanOrEqualTo(VehicleMatcher.maxLocations),
        );
      },
    );
  });
}

void _replay({
  required FinderLocation? Function(int) gps,
  required List<FinderVehicle> Function(int) fleet,
  required void Function(int, VehicleFinderController) inspect,
}) {
  fakeAsync((time) {
    final stream = StreamController<FinderLocation>.broadcast();
    var requests = 0;
    final controller = VehicleFinderController(
      locations: () => stream.stream,
      vehicles: (_) async {
        requests++;
        return fleet(time.elapsed.inSeconds);
      },
      clock: () => instant(time.elapsed.inSeconds),
      searchDuration: const Duration(minutes: 5),
    );
    controller.start(TransportMode.train);
    for (var second = 0; second <= 180; second++) {
      if (second > 0) time.elapse(const Duration(seconds: 1));
      if (second % 5 == 0) {
        final sample = gps(second);
        if (sample != null) stream.add(sample);
      }
      time.flushMicrotasks();
      inspect(second, controller);
    }
    expect(requests, 7, reason: 'One request at start, then every 30 seconds');
    expect(controller.evaluations, lessThanOrEqualTo(80));
    controller.stop();
    time.flushMicrotasks();
    expect(controller.matcher.trackCount, 0);
    expect(controller.matcher.locationCount, 0);
    expect(time.pendingTimers, isEmpty);
    time.elapse(const Duration(minutes: 5));
    expect(requests, 7, reason: 'No feed work after leaving the finder');
    controller.dispose();
    stream.close();
    time.flushMicrotasks();
  });
}
