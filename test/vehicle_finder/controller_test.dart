import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/vehicle_finder/controller.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';
import 'package:lbww_flutter/vehicle_finder/provider.dart';

import 'fixtures.dart';

void main() {
  test('fast GPS streams do not trigger a fleet scan for every fix', () {
    fakeAsync((async) {
      final stream = StreamController<FinderLocation>.broadcast();
      var clock = epoch;
      var requests = 0;
      final controller = VehicleFinderController(
        locations: () => stream.stream,
        vehicles: (_) async {
          requests++;
          return [vehicle(0)];
        },
        clock: () => clock,
      );
      controller.start(TransportMode.train);
      async.flushMicrotasks();
      for (var tick = 0; tick < 100; tick++) {
        clock = epoch.add(Duration(milliseconds: tick * 100));
        stream.add(
          FinderLocation(
            latitude: -33.86,
            longitude: 151.2,
            timestamp: clock,
            accuracy: 10,
          ),
        );
        async.flushMicrotasks();
      }
      expect(requests, 1);
      expect(controller.evaluations, lessThanOrEqualTo(6));
      expect(controller.matcher.locationCount, lessThanOrEqualTo(6));
      controller.dispose();
      stream.close();
      async.flushMicrotasks();
    });
  });

  test(
    'starts only on request, bounds polling, stops and clears histories',
    () {
      fakeAsync((async) {
        var fetches = 0;
        var cancelled = 0;
        final stream = StreamController<FinderLocation>.broadcast(
          onCancel: () => cancelled++,
        );
        final controller = VehicleFinderController(
          locations: () => stream.stream,
          vehicles: (_) async {
            fetches++;
            return [vehicle(0)];
          },
          clock: () => instant(async.elapsed.inSeconds),
        );
        expect(fetches, 0);
        controller.start(TransportMode.train);
        controller.start(TransportMode.bus);
        stream.add(phone(0));
        async.flushMicrotasks();
        expect(fetches, 1);
        expect(controller.mode, TransportMode.train);
        expect(controller.candidates, hasLength(1));
        async.elapse(const Duration(seconds: 29));
        expect(fetches, 1);
        expect(
          controller.candidates,
          isEmpty,
          reason: 'A lost GPS signal expires matches',
        );
        controller.stop();
        async.elapse(const Duration(minutes: 5));
        expect(fetches, 1);
        expect(cancelled, 1);
        expect(controller.matcher.locationCount, 0);
        controller.dispose();
        stream.close();
        async.flushMicrotasks();
      });
    },
  );

  test(
    'late responses cannot publish after restart and requests never overlap',
    () {
      fakeAsync((async) {
        final requests = <Completer<List<FinderVehicle>>>[];
        final stream = StreamController<FinderLocation>.broadcast();
        final controller = VehicleFinderController(
          locations: () => stream.stream,
          vehicles: (_) {
            final request = Completer<List<FinderVehicle>>();
            requests.add(request);
            return request.future;
          },
          clock: () => instant(0),
        );
        controller.start(TransportMode.train);
        controller.stop();
        controller.start(TransportMode.bus);
        stream.add(phone(0));
        async.flushMicrotasks();
        expect(requests, hasLength(1));
        requests.first.complete([vehicle(0)]);
        async.flushMicrotasks();
        expect(requests, hasLength(2));
        expect(controller.candidates, isEmpty);
        requests.last.complete([vehicle(0, mode: TransportMode.bus)]);
        async.flushMicrotasks();
        expect(controller.candidates.single.vehicle.mode, TransportMode.bus);
        controller.dispose();
        stream.close();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 5));
        expect(requests, hasLength(2));
      });
    },
  );

  test(
    'fatal feed setup errors cancel sampling instead of repeatedly polling',
    () {
      fakeAsync((async) {
        var cancelled = 0;
        var requests = 0;
        final stream = StreamController<FinderLocation>.broadcast(
          onCancel: () => cancelled++,
        );
        final controller = VehicleFinderController(
          locations: () => stream.stream,
          vehicles: (_) async {
            requests++;
            throw const VehicleFinderException(
              'Add an API key in Settings.',
              isFatal: true,
            );
          },
        );
        controller.start(TransportMode.train);
        async.flushMicrotasks();
        expect(controller.running, isFalse);
        expect(cancelled, 1);
        expect(controller.error, contains('API key'));
        async.elapse(const Duration(minutes: 5));
        expect(requests, 1);
        expect(async.pendingTimers, isEmpty);
        controller.dispose();
        stream.close();
        async.flushMicrotasks();
      });
    },
  );

  test(
    'temporary feed failures clear candidates and recover on the next poll',
    () {
      fakeAsync((async) {
        var requests = 0;
        final stream = StreamController<FinderLocation>.broadcast();
        final controller = VehicleFinderController(
          locations: () => stream.stream,
          vehicles: (_) async {
            requests++;
            if (requests == 1) throw StateError('test failure');
            return [vehicle(30)];
          },
          clock: () => instant(async.elapsed.inSeconds),
        );
        controller.start(TransportMode.train);
        stream.add(phone(0));
        async.flushMicrotasks();
        expect(controller.error, isNotNull);
        expect(controller.candidates, isEmpty);
        async.elapse(const Duration(seconds: 30));
        stream.add(phone(30));
        async.flushMicrotasks();
        expect(requests, 2);
        expect(controller.error, isNull);
        expect(controller.candidates, hasLength(1));
        controller.dispose();
        stream.close();
        async.flushMicrotasks();
      });
    },
  );

  test('denied location stops the session with an actionable error', () {
    fakeAsync((async) {
      final controller = VehicleFinderController(
        locations: () => Stream.error(
          const VehicleFinderException('Location permission denied.'),
        ),
        vehicles: (_) async => [],
      );
      controller.start(TransportMode.train);
      async.flushMicrotasks();
      expect(controller.running, isFalse);
      expect(controller.error, contains('permission denied'));
      expect(async.pendingTimers, isEmpty);
      controller.dispose();
    });
  });

  test('a search automatically stops after three minutes', () {
    fakeAsync((async) {
      var cancelled = 0;
      final stream = StreamController<FinderLocation>.broadcast(
        onCancel: () => cancelled++,
      );
      final controller = VehicleFinderController(
        locations: () => stream.stream,
        vehicles: (_) async => [],
      );
      controller.start(TransportMode.train);
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 3));
      async.flushMicrotasks();
      expect(controller.running, isFalse);
      expect(controller.status, contains('Search finished'));
      expect(cancelled, 1);
      expect(async.pendingTimers, isEmpty);
      controller.dispose();
      stream.close();
      async.flushMicrotasks();
    });
  });

  test('confirmation ends sampling and preserves only the chosen vehicle', () {
    fakeAsync((async) {
      final stream = StreamController<FinderLocation>.broadcast();
      final controller = VehicleFinderController(
        locations: () => stream.stream,
        vehicles: (_) async => [vehicle(0)],
        clock: () => instant(0),
      );
      controller.start(TransportMode.train);
      stream.add(phone(0));
      async.flushMicrotasks();
      final selected = controller.candidates.single;
      controller.confirm(selected);
      async.flushMicrotasks();
      expect(controller.confirmed, same(selected));
      expect(controller.running, isFalse);
      expect(controller.matcher.locationCount, 0);
      expect(controller.candidates, isEmpty);
      expect(async.pendingTimers, isEmpty);
      controller.dispose();
      stream.close();
      async.flushMicrotasks();
    });
  });

  test('poor accuracy clears matches until a new valid location arrives', () {
    fakeAsync((async) {
      final stream = StreamController<FinderLocation>.broadcast();
      final controller = VehicleFinderController(
        locations: () => stream.stream,
        vehicles: (_) async => [vehicle(0)],
        clock: () => instant(async.elapsed.inSeconds),
      );
      controller.start(TransportMode.train);
      stream.add(phone(0));
      async.flushMicrotasks();
      expect(controller.candidates, hasLength(1));
      async.elapse(const Duration(seconds: 1));
      stream.add(phone(1, accuracy: 500));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));
      expect(controller.candidates, isEmpty);
      expect(controller.location, isNull);
      controller.dispose();
      stream.close();
      async.flushMicrotasks();
    });
  });
}
