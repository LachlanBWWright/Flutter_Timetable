import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/models.dart';
import 'package:lbww_flutter/active_journey/progress.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';

import 'fixtures.dart';

FinderVehicle position({
  int? sequence = 2,
  String? stop = 'B',
  bool atStop = false,
}) => FinderVehicle(
  id: 'vehicle',
  mode: identity.mode,
  latitude: 0,
  longitude: 0,
  observedAt: now,
  tripKey: 'unused',
  service: identity,
  currentStopId: stop,
  currentStopSequence: sequence,
  atStop: atStop,
);

JourneyProgress progress(
  FinderVehicle vehicle, {
  bool fresh = true,
  List<RunningStop>? live,
  List<RunningStop>? selectedStops,
}) {
  final match = ActiveJourneyMatch(
    journey: saved(),
    reverse: false,
    stops: selectedStops ?? pattern().take(3).toList(),
  );
  return JourneyProgress.resolve(
    RunningService(
      vehicle: vehicle,
      stops: live ?? pattern(),
      matches: [match],
      checkedAt: now,
    ),
    match,
    fresh: fresh,
  );
}

void main() {
  test('approaching and stopped reports highlight the correct next stop', () {
    final approaching = progress(position());
    expect(approaching.nextStop!.id, 'B');
    expect(approaching.stopsRemaining, 2);
    expect(approaching.currentStop, isNull);
    final stopped = progress(position(atStop: true));
    expect(stopped.currentStop!.id, 'B');
    expect(stopped.nextStop!.id, 'C');
    expect(stopped.stopsRemaining, 1);
  });

  test('only fresh stopped-at-destination evidence establishes arrival', () {
    final atDestination = position(sequence: 3, stop: 'C', atStop: true);
    expect(progress(atDestination).arrived, isTrue);
    expect(progress(atDestination).stopsRemaining, 0);
    expect(progress(atDestination, fresh: false).arrived, isFalse);
    expect(progress(position(sequence: 3, stop: 'C')).arrived, isFalse);
    expect(
      progress(position(sequence: 4, stop: 'D', atStop: true)).arrived,
      isFalse,
    );
  });

  test('conflicting or repeated stop evidence produces no progress', () {
    expect(
      progress(position(sequence: 3, stop: 'B', atStop: true)).nextStop,
      isNull,
    );
    expect(
      progress(
        position(sequence: null, stop: 'C', atStop: true),
        live: [...pattern(), pattern()[2]],
      ).arrived,
      isFalse,
    );
  });

  test('repeated live calls cannot be mistaken for the saved destination', () {
    expect(
      progress(
        position(sequence: 3, stop: 'C', atStop: true),
        live: [
          ...pattern(),
          const RunningStop(id: 'C', name: 'Gamma', sequence: 5),
        ],
      ).arrived,
      isFalse,
    );
  });

  test('cached synthetic sequences are never compared to live sequences', () {
    final synthetic = [
      for (final entry in pattern().take(3).indexed)
        RunningStop(
          id: entry.$2.id,
          name: entry.$2.name,
          sequence: entry.$1 + 100,
        ),
    ];
    expect(
      progress(
        position(sequence: 3, stop: 'C', atStop: true),
        selectedStops: synthetic,
      ).arrived,
      isTrue,
    );
    expect(
      progress(
        position(sequence: 3, stop: 'C', atStop: true),
        live: [],
        selectedStops: synthetic,
      ).arrived,
      isFalse,
    );
  });

  test('sparse live pattern only exposes the next reported stop and count', () {
    final sparse = [pattern().first, pattern()[2]];
    final result = progress(
      position(sequence: 1, stop: 'A', atStop: true),
      live: sparse,
      selectedStops: sparse,
    );
    expect(result.nextStop!.id, 'C');
    expect(result.stopsRemaining, 1);
    expect(result.arrived, isFalse);
  });

  test('skipped stops are excluded from remaining stop count', () {
    final stops = pattern().take(3).toList();
    stops[1] = const RunningStop(
      id: 'B',
      name: 'Beta',
      sequence: 2,
      skipped: true,
    );
    final result = progress(
      position(sequence: 1, stop: 'A', atStop: true),
      selectedStops: stops,
    );
    expect(result.nextStop!.id, 'C');
    expect(result.stopsRemaining, 1);
  });
}
