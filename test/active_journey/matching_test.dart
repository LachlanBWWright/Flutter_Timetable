import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/active_journey/matching.dart';
import 'package:lbww_flutter/active_journey/models.dart';

import 'fixtures.dart';

void main() {
  test('matches ordered direct journeys only in the travelled direction', () {
    expect(
      matchRunningPattern(saved(), false, detected(), pattern(), now),
      isNotNull,
    );
    expect(
      matchRunningPattern(saved(), true, detected(), pattern(), now),
      isNull,
    );
    final reverse = saved(origin: 'C', destination: 'A');
    expect(
      matchRunningPattern(reverse, true, detected(), pattern(), now)?.reverse,
      isTrue,
    );
  });
  test('a shared service can fit several intended destinations', () {
    for (final stop in ['C', 'D']) {
      expect(
        matchRunningPattern(
          saved(destination: stop),
          false,
          detected(),
          pattern(),
          now,
        ),
        isNotNull,
      );
    }
  });
  test(
    'rejects express omissions, skipped stops, and positions outside the segment',
    () {
      expect(
        matchRunningPattern(
          saved(),
          false,
          detected(),
          pattern().where((s) => s.id != 'C').toList(),
          now,
        ),
        isNull,
      );
      final skipped = pattern()
          .map(
            (s) => RunningStop(
              id: s.id,
              name: s.name,
              sequence: s.sequence,
              skipped: s.id == 'C',
            ),
          )
          .toList();
      expect(
        matchRunningPattern(saved(), false, detected(), skipped, now),
        isNull,
      );
      expect(
        matchRunningPattern(
          saved(),
          false,
          detected(sequence: 4, stop: 'D'),
          pattern(),
          now,
        ),
        isNull,
      );
      expect(
        matchRunningPattern(
          saved(),
          false,
          detected(sequence: 1, stop: 'A'),
          pattern(),
          now,
        ),
        isNull,
      );
    },
  );
  test('handles station-parent aliases without stop-name guessing', () {
    final stops = pattern()
        .map(
          (s) => RunningStop(
            id: '${s.id}-platform',
            stationId: s.id,
            name: 'Same name',
            sequence: s.sequence,
          ),
        )
        .toList();
    expect(
      matchRunningPattern(saved(), false, detected(), stops, now),
      isNotNull,
    );
    expect(
      matchRunningPattern(
        saved(origin: 'Other'),
        false,
        detected(),
        stops,
        now,
      ),
      isNull,
    );
  });
  test(
    'ambiguous loop stops and manual or foreign journeys are not inferred',
    () {
      expect(
        matchRunningPattern(saved(), false, detected(), [
          ...pattern(),
          pattern().first,
        ], now),
        isNull,
      );
      expect(
        matchRunningPattern(
          saved(type: 'manualMultiLeg'),
          false,
          detected(),
          pattern(),
          now,
        ),
        isNull,
      );
      expect(
        matchRunningPattern(
          saved(origin: 'queensland|translink|qld:SEQ|A'),
          false,
          detected(),
          pattern(),
          now,
        ),
        isNull,
      );
    },
  );
}
