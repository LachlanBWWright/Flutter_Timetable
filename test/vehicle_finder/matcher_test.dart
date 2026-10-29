import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/vehicle_finder/matcher.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';

import 'fixtures.dart';

void main() {
  test(
    'requires three distinct moving reports before suggesting a likely match',
    () {
      final matcher = VehicleMatcher();
      for (final second in [0, 30, 60]) {
        expect(matcher.addLocation(phone(second), instant(second)), isTrue);
        final candidates = matcher.match([vehicle(second)], instant(second));
        expect(candidates.single.observations, second ~/ 30 + 1);
        expect(candidates.single.likely, second == 60);
      }
    },
  );

  test('cached messages never count as extra movement evidence', () {
    final matcher = VehicleMatcher();
    matcher.addLocation(phone(0), instant(0));
    for (var second = 0; second < 20; second++) {
      matcher.addLocation(phone(second), instant(second));
      final candidates = matcher.match([vehicle(0)], instant(second));
      expect(candidates.single.observations, 1);
      expect(candidates.single.likely, isFalse);
    }
  });

  test('aligns delayed vehicle positions with past phone locations', () {
    final matcher = VehicleMatcher();
    for (var second = 0; second <= 90; second += 5) {
      matcher.addLocation(phone(second), instant(second));
    }
    final candidates = matcher.match([vehicle(30)], instant(90));
    expect(candidates.single.distance, closeTo(0, 0.01));
    expect(candidates.single.likely, isFalse);
  });

  test('does not turn equivalent adjacent vehicles into a confident match', () {
    final matcher = VehicleMatcher();
    for (final second in [0, 30, 60]) {
      matcher.addLocation(phone(second), instant(second));
      final candidates = matcher.match([
        vehicle(second),
        vehicle(second, id: 'train-2'),
      ], instant(second));
      expect(candidates, hasLength(2));
      expect(candidates.every((candidate) => !candidate.likely), isTrue);
    }
  });

  test(
    'standing or walking beside a parked vehicle is never a likely match',
    () {
      for (final step in [0.0, 0.00001]) {
        final matcher = VehicleMatcher();
        for (final second in [0, 30, 60]) {
          matcher.addLocation(
            phone(second, longitude: 151.2 + second * step, speed: null),
            instant(second),
          );
          final candidates = matcher.match([
            vehicle(second, longitude: 151.2, speed: null),
          ], instant(second));
          expect(candidates.single.likely, isFalse);
        }
      }
    },
  );

  test(
    'opposite movement or incompatible speeds cannot produce likely matches',
    () {
      for (final mismatch in [
        vehicle(0, heading: 270),
        vehicle(0, speed: 50),
      ]) {
        final matcher = VehicleMatcher();
        for (final second in [0, 30, 60]) {
          matcher.addLocation(phone(second), instant(second));
          final candidates = matcher.match([
            vehicle(second, heading: mismatch.heading, speed: mismatch.speed),
          ], instant(second));
          expect(candidates.single.likely, isFalse);
        }
      }
    },
  );

  test(
    'missing motion fields still allow matching from measured trajectories',
    () {
      final matcher = VehicleMatcher();
      for (final second in [0, 30, 60]) {
        matcher.addLocation(
          phone(second, speed: null, heading: null),
          instant(second),
        );
        final result = matcher.match([
          vehicle(second, speed: null, heading: null),
        ], instant(second));
        expect(result.single.likely, second == 60);
      }
    },
  );

  test(
    'stale, future, invalid and temporally unaligned reports are excluded',
    () {
      final matcher = VehicleMatcher();
      matcher.addLocation(phone(120), instant(120));
      expect(
        matcher.match([
          vehicle(0),
          vehicle(150),
          vehicle(90),
          vehicle(120, longitude: double.nan),
        ], instant(120)),
        isEmpty,
      );
      expect(
        matcher.addLocation(phone(120, accuracy: 500), instant(120)),
        isFalse,
      );
      expect(matcher.addLocation(phone(100), instant(120)), isFalse);
      expect(matcher.addLocation(phone(130), instant(120)), isFalse);
      expect(matcher.match([vehicle(120)], instant(150)), isEmpty);
    },
  );

  test(
    'service changes reset evidence and mode namespaces separate vehicle IDs',
    () {
      final matcher = VehicleMatcher();
      for (final second in [0, 30, 60]) {
        matcher.addLocation(phone(second), instant(second));
        matcher.match([vehicle(second)], instant(second));
      }
      matcher.addLocation(phone(70), instant(70));
      final result = matcher.match([
        vehicle(70, trip: 'new-trip'),
        vehicle(70, trip: 'new-trip', mode: TransportMode.bus),
      ], instant(70));
      expect(result, hasLength(2));
      expect(result.every((c) => c.observations == 1 && !c.likely), isTrue);
    },
  );

  test('out-of-order reports cannot replace the newest match', () {
    final matcher = VehicleMatcher();
    matcher.addLocation(phone(0), instant(0));
    matcher.match([vehicle(0)], instant(0));
    matcher.addLocation(phone(30), instant(30));
    matcher.match([vehicle(30)], instant(30));
    expect(matcher.match([vehicle(0)], instant(30)), isEmpty);
  });

  test('high-frequency GPS preserves historical fixes for delayed reports', () {
    final matcher = VehicleMatcher();
    for (var tick = 0; tick <= 1200; tick++) {
      final seconds = tick / 10;
      final time = epoch.add(Duration(milliseconds: tick * 100));
      matcher.addLocation(
        FinderLocation(
          latitude: -33.86,
          longitude: 151.2 + seconds * 0.0001,
          timestamp: time,
          accuracy: 10,
          speed: 10,
          heading: 90,
        ),
        time,
      );
    }
    final result = matcher.match([vehicle(60)], instant(120));
    expect(result.single.distance, closeTo(0, 0.01));
    expect(
      matcher.locationCount,
      lessThanOrEqualTo(VehicleMatcher.maxLocations),
    );
  });

  test('bounds histories and returns a shortlist for a 5000-vehicle fleet', () {
    final matcher = VehicleMatcher();
    for (var second = 0; second < 1000; second++) {
      matcher.addLocation(phone(second), instant(second));
    }
    final fleet = List<FinderVehicle>.generate(
      5000,
      (index) => vehicle(999, id: '$index'),
    );
    final result = matcher.match(fleet, instant(999));
    expect(
      matcher.locationCount,
      lessThanOrEqualTo(VehicleMatcher.maxLocations),
    );
    expect(matcher.trackCount, lessThanOrEqualTo(VehicleMatcher.maxTracks));
    expect(result, hasLength(3));
    expect(result.every((candidate) => !candidate.likely), isTrue);
    matcher.clear();
    expect(matcher.locationCount, 0);
    expect(matcher.trackCount, 0);
  });
}
