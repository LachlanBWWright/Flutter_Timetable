// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/trip_stop_ranking_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  group('TripStopRankingService', () {
    // Helper to create a test station
    Station testStation(
      String id,
      String name, {
      double? latitude,
      double? longitude,
      String? lineId,
    }) {
      return Station(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        lineId: lineId,
      );
    }

    test('ranks candidates within 5km of both anchors in tier 1', () {
      // Sydney Central: -33.8688, 151.2093
      // Create nearby anchor within 5km: Redfern ~1.5km away
      final central = testStation(
        'central',
        'Central',
        latitude: -33.8688,
        longitude: 151.2093,
      );

      final redfern = testStation(
        'redfern',
        'Redfern',
        latitude: -33.8862,
        longitude: 151.2081,
      );

      // Candidate between them, close to both
      final museumstn = testStation(
        'museum',
        'Museum',
        latitude: -33.8771,
        longitude: 151.2088,
      );

      final candidates = [
        testStation('far1', 'Far Station 1', latitude: -30.0, longitude: 150.0),
        museumstn,
      ];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
        previousAnchor: central,
        nextAnchor: redfern,
      );

      expect(ranked, isNotEmpty);
      expect(ranked.first.stop.id, 'museum');
      expect(ranked.first.tier, StopRankingTier.withinBothAnchors);
      expect(ranked.first.isPreferredNearby, isTrue);
      expect(ranked.first.badgeLabel, 'Near both legs');
      expect(ranked.last.stop.id, 'far1');
    });

    test('prefers user-distance sorting when requested', () {
      final closeToUser = testStation(
        'close',
        'Close',
        latitude: -33.9,
        longitude: 151.2,
      );
      final farFromUser = testStation(
        'far',
        'Far',
        latitude: -33.91,
        longitude: 151.21,
      );

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: [farFromUser, closeToUser],
        sortMode: SortMode.distance,
      );

      expect(ranked.map((m) => m.stop.id), ['close', 'far']);
    });

    test('ranks candidates without coordinates by alphabetical order', () {
      final station1 = testStation('s1', 'Apple');
      final station2 = testStation('s2', 'Banana');
      final station3 = testStation('s3', 'Cherry');

      final candidates = [station3, station1, station2];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
      );

      expect(ranked.map((m) => m.stop.id), ['s1', 's2', 's3']);
    });

    test('handles empty candidate list', () {
      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: [],
      );

      expect(ranked, isEmpty);
    });

    test('ranks without anchors by alphabetical order', () {
      final station1 = testStation('s1', 'Charlie');
      final station2 = testStation('s2', 'Alice');
      final station3 = testStation('s3', 'Bob');

      final candidates = [station1, station2, station3];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
      );

      expect(
        ranked.map((m) => m.stop.id),
        ['s2', 's3', 's1'], // Alice, Bob, Charlie
      );
    });

    test('tier classification respects 5km threshold', () {
      final anchor = testStation(
        'anchor',
        'Anchor',
        latitude: -33.8688,
        longitude: 151.2093,
      );

      // Very close (within 5km) - Sydney to Parramatta is ~23km
      final nearby = testStation(
        'nearby',
        'Nearby',
        latitude: -33.8700, // Very close in lat/lon
        longitude: 151.2100,
      );

      final candidates = [nearby];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
        previousAnchor: anchor,
      );

      expect(ranked.first.tier, StopRankingTier.withinEitherAnchor);
      expect(ranked.first.nearestAnchorDistance, isNotNull);
      expect(ranked.first.nearestAnchorDistance! < 5.0, isTrue);
    });

    test('handles stops with missing coordinates gracefully', () {
      final anchor = testStation(
        'anchor',
        'Anchor',
        latitude: -33.8688,
        longitude: 151.2093,
      );

      final noCoords = testStation('nocoords', 'No Coordinates');
      final withCoords = testStation(
        'coords',
        'With Coordinates',
        latitude: -33.8700,
        longitude: 151.2100,
      );

      final candidates = [noCoords, withCoords];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
        previousAnchor: anchor,
      );

      // With coordinates should rank higher
      expect(ranked.first.stop.id, 'coords');
      expect(ranked.last.stop.id, 'nocoords');
    });

    test('ranks stops sharing a line in tier 3', () {
      final sameLineId = 'sydneytrains|T1';
      final anchor = testStation('anchor', 'Anchor', lineId: sameLineId);
      final sharedLine = testStation('shared', 'Shared', lineId: sameLineId);
      final different = testStation('different', 'Different', lineId: 'other');

      final candidates = [different, sharedLine];

      final ranked = TripStopRankingService.rankStopsForInterchange(
        candidates: candidates,
        previousAnchor: anchor,
      );

      // Shared line should rank higher
      expect(ranked.first.stop.id, 'shared');
      expect(ranked.first.tier, StopRankingTier.sharesLineWithAnchor);
      expect(ranked.last.tier, StopRankingTier.remaining);
    });
  });
}
