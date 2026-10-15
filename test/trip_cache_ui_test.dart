import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart' show Journey;
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/widgets/trip_cache/age_snapshot.dart';
import 'package:lbww_flutter/widgets/trip_cache/trip_cache_banner.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13, 12);
  final response = GetTripsResponse(
    tripJourneys: const [],
    systemMessages: const SystemMessages(),
    version: 'test',
    rawJson: const {},
  );

  test('timer aging retains refresh failure even within fresh TTL', () {
    final aged = ageTripCacheSnapshot(
      TripCacheSnapshot(
        response: response,
        fetchedAt: now,
        error: 'Provider failed',
        isStale: true,
      ),
      now.add(const Duration(seconds: 30)),
    );
    expect(aged.isStale, isTrue);
    expect(aged.isFresh, isFalse);
    expect(aged.error, 'Provider failed');
  });

  test('timer aging expires an open snapshot after clock jumps backwards', () {
    final aged = ageTripCacheSnapshot(
      TripCacheSnapshot(response: response, fetchedAt: now, isFresh: true),
      now.subtract(const Duration(seconds: 1)),
    );
    expect(aged.isExpired, isTrue);
    expect(aged.response, isNull);
    expect(aged.isFresh, isFalse);
  });

  test(
    'timer aging never marks untimestamped or unavailable snapshots fresh',
    () {
      for (final snapshot in [
        TripCacheSnapshot(response: response),
        TripCacheSnapshot(fetchedAt: now),
      ]) {
        expect(ageTripCacheSnapshot(snapshot, now).isFresh, isFalse);
      }
    },
  );

  test('timer aging enforces the hard cutoff for an open snapshot', () {
    final aged = ageTripCacheSnapshot(
      TripCacheSnapshot(response: response, fetchedAt: now, isFresh: true),
      now.add(const Duration(hours: 24)),
    );
    expect(aged.isExpired, isTrue);
    expect(aged.hasUsableData, isFalse);
  });

  testWidgets('trip results display journeys without cache status controls', (
    tester,
  ) async {
    final departure = DateTime.utc(2026, 10, 13, 13);
    await tester.pumpWidget(
      MaterialApp(
        home: TripScreen(
          trip: const Journey(
            id: 1,
            origin: 'Woodford',
            originId: 'woodford',
            destination: 'Central',
            destinationId: 'central',
            tripType: 'direct',
            isPinned: false,
          ),
          skipInitialLoad: true,
          initialTrips: [
            TripJourney(
              legs: [
                Leg(
                  origin: Stop(
                    id: 'woodford',
                    name: 'Woodford',
                    type: 'stop',
                    departureTimePlanned: departure.toIso8601String(),
                  ),
                  destination: Stop(
                    id: 'central',
                    name: 'Central',
                    type: 'stop',
                    arrivalTimePlanned: departure
                        .add(const Duration(hours: 1))
                        .toIso8601String(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Woodford to Central'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);
    for (final metadata in [
      'Journey results',
      'Fetched',
      'Updated',
      'Showing saved journeys',
      'Departure times may be out of date',
      'Refresh to check',
      'could not be confirmed',
    ]) {
      expect(find.textContaining(metadata), findsNothing);
    }
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.byType(TripCacheBanner), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
