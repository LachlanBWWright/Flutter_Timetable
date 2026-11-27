import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';

import '../../integration_test/support/performance_fixtures.dart';

void main() {
  testWidgets('viewport subtitle work is lazy, bounded, and cached on return', (
    tester,
  ) async {
    final cache = PerformanceCache(latency: const Duration(milliseconds: 20));
    TripCacheService.configureForTesting(cache.repository);
    addTearDown(TripCacheService.resetForTesting);
    final journeys = savedJourneys(20);
    await tester.pumpWidget(subtitleList(journeys));

    Future<void> drain() async {
      // Drain the production queue without advancing the 30-second refresh.
      for (var tick = 0; tick < 50; tick++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
    }

    await drain();
    expect(cache.fetches, greaterThan(0));
    expect(
      cache.fetches,
      lessThan(40),
      reason: 'Offscreen trips stay unloaded',
    );
    expect(find.byType(JourneyCard).evaluate().length, lessThan(20));
    expect(cache.peakActive, lessThanOrEqualTo(2));
    final firstFetches = cache.fetches;
    final firstReads = cache.reads;

    for (var rebuild = 0; rebuild < 10; rebuild++) {
      await tester.pumpWidget(subtitleList(journeys));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(cache.fetches, firstFetches);
    expect(cache.reads, firstReads);

    // Visit every viewport so laziness never leaves reachable trips unloaded.
    final scrollable = find.byType(Scrollable).first;
    for (var swipe = 0; swipe < 20; swipe++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await drain();
    }
    expect(cache.fetches, 40, reason: 'One request per visited direction');
    expect(cache.writes, 40);
    expect(cache.peakActive, lessThanOrEqualTo(2));
    final reads = cache.reads;
    for (var swipe = 0; swipe < 20; swipe++) {
      await tester.drag(scrollable, const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(cache.fetches, 40);
    expect(cache.reads, reads, reason: 'Warm revisits use memory');
    expect(find.textContaining('Next '), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await cache.repository.clearMemoryCache();
    await tester.pump(const Duration(seconds: 60));
    expect(cache.fetches, 40, reason: 'Disposed subtitles stop refreshing');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home keeps pinned and unpinned journeys in one lazy scrollable',
    (tester) async {
      final journeys = savedJourneys(100)
          .map((journey) => journey.copyWith(isPinned: journey.id.isEven))
          .toList();
      // Interleaved source data is grouped into pinned and unpinned slivers.
      await tester.pumpWidget(
        MaterialApp(
          home: MyHomePage(
            title: 'Home',
            skipInitialLoad: true,
            initialJourneys: journeys,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scrollable), findsOneWidget);
      expect(find.byType(JourneyCard).evaluate().length, lessThan(30));
      expect(find.text('Station 0'), findsOneWidget);
      expect(find.text('Station 2'), findsOneWidget);
      expect(find.text('Station 99'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Station 99'),
        400,
        scrollable: find.byType(Scrollable),
        maxScrolls: 100,
      );
      expect(find.text('Station 99'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
