import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/home/app.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/performance_fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile saved journeys and trip results', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final cache = PerformanceCache();
    TripCacheService.configureForTesting(cache.repository);
    addTearDown(TripCacheService.resetForTesting);
    final journeys = savedJourneys(20);
    binding.reportData = {
      'metadata': {
        'mode': kProfileMode ? 'profile' : 'debug',
        'foreground_lifecycle_forced': true,
        'platform': Platform.operatingSystem,
        'dart_version': Platform.version,
        'saved_journeys': journeys.length,
        'directions': journeys.length * 2,
        'results': 60,
        'legs_per_result': 3,
        'physical_width': tester.view.physicalSize.width,
        'physical_height': tester.view.physicalSize.height,
        'device_pixel_ratio': tester.view.devicePixelRatio,
      },
    };

    Future<void> profile(String name, Future<void> Function() action) async {
      final rssBefore = ProcessInfo.currentRss;
      await binding.watchPerformance(action, reportKey: name);
      binding.reportData!['${name}_rss'] = {
        'before_bytes': rssBefore,
        'after_bytes': ProcessInfo.currentRss,
      };
      final metrics = binding.reportData![name] as Map<String, dynamic>;
      expect(metrics['frame_count'], greaterThan(0));
    }

    await profile('app_shell_mount', () async {
      await tester.pumpWidget(
        MyApp(
          home: MyHomePage(
            title: 'Home',
            skipInitialLoad: true,
            initialJourneys: journeys,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    // Profile the production list with both direction subtitles enabled.
    await profile('subtitle_cold_mount', () async {
      await tester.pumpWidget(subtitleList(journeys));
      // Desktop test windows may open unfocused. Exercise visible refresh
      // consistently rather than measuring a paused background route.
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    });
    // Traverse the lazy list before waiting for all directions to be warm.
    await _visitAll(tester);
    // Wait for all bounded background requests before measuring warm UI work.
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (cache.writes < journeys.length * 2 &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(cache.writes, journeys.length * 2);
    expect(cache.peakActive, lessThanOrEqualTo(2));
    final warmFetches = cache.fetches;
    await _scroll(tester); // Warm layout and shaders before the measured pass.
    await profile('subtitle_warm_scroll', () => _scroll(tester));
    expect(cache.fetches, warmFetches);
    binding.reportData!['cache_work'] = cache.counters;

    // Real home search, with startup services disabled to isolate UI cost.
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(
          title: 'Performance',
          skipInitialLoad: true,
          initialJourneys: savedJourneys(100),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await profile('home_search_100', () async {
      for (final query in ['Station 9', 'Station', 'Destination 2', '']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pumpAndSettle();
      }
    });
    expect(find.text('Station 0'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: TripScreen(
          trip: journeys.first,
          skipInitialLoad: true,
          initialTrips: journeyResponse(DateTime.now(), count: 60).tripJourneys,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _scroll(tester);
    await profile('trip_results_scroll_60', () => _scroll(tester));
    await profile('trip_result_expand_collapse', () async {
      for (var cycle = 0; cycle < 10; cycle++) {
        final header = find
            .descendant(
              of: find.byType(TripCard).first,
              matching: find.byType(ListTile),
            )
            .first;
        await tester.tap(header);
        await tester.pumpAndSettle();
        expect(
          find.text('Stop 0 → Stop 1'),
          cycle.isEven ? findsOneWidget : findsNothing,
        );
      }
    });
    await _profileMapAndNavigation(tester, binding, profile);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> _scroll(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  for (final direction in [-1.0, 1.0]) {
    for (var swipe = 0; swipe < 8; swipe++) {
      await tester.fling(list, Offset(0, direction * 500), 1500);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _visitAll(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  for (var step = 0; step < 100; step++) {
    final position = tester.state<ScrollableState>(list).position;
    if (position.pixels >= position.maxScrollExtent) break;
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  final position = tester.state<ScrollableState>(list).position;
  expect(position.pixels, closeTo(position.maxScrollExtent, 1));
  position.jumpTo(0);
  await tester.pumpAndSettle();
}

Future<void> _profileMapAndNavigation(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  Future<void> Function(String, Future<void> Function()) profile,
) async {
  final stops = List.generate(
    2500,
    (index) => Stop(
      stopId: 'map-$index',
      stopName: 'Map stop $index',
      stopLat: -33.99 + (index ~/ 50) * .005,
      stopLon: 151.08 + (index % 50) * .005,
      locationType: 0,
      wheelchairBoarding: 0,
    ),
  );
  Widget map() => StopsMapWidget(
    transportMode: TransportMode.train,
    modeDisplayName: 'Train',
    onStopSelected: (_, _) {},
    skipInitialLoad: true,
    showTileLayer: false,
    initialStops: stops,
  );
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigator,
      home: const Scaffold(body: Center(child: Text('Navigation baseline'))),
    ),
  );
  await tester.pumpAndSettle();
  final rssSamples = <int>[];
  await profile('map_mount_pan_2500', () async {
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => map()),
    );
    await tester.pumpAndSettle();
    for (final delta in [
      const Offset(-160, 0),
      const Offset(0, 160),
      const Offset(160, 0),
      const Offset(0, -160),
    ]) {
      await tester.drag(find.byType(StopsMapWidget), delta);
      await tester.pumpAndSettle();
    }
  });
  navigator.currentState!.pop();
  await tester.pumpAndSettle();
  await profile('map_navigation_10', () async {
    for (var cycle = 0; cycle < 10; cycle++) {
      navigator.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => map()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StopsMapWidget), findsOneWidget);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.byType(StopsMapWidget), findsNothing);
      rssSamples.add(ProcessInfo.currentRss);
    }
  });
  binding.reportData!['map_navigation_rss_samples_bytes'] = rssSamples;
  binding.reportData!['map_fixture'] = {
    'stops': stops.length,
    'tiles_enabled': false,
    'gps_enabled': false,
    'navigation_cycles': rssSamples.length,
  };
}
