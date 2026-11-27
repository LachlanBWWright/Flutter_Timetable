import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lbww_flutter/home/home_page.dart';
import 'package:lbww_flutter/main.dart' as app;
import 'package:lbww_flutter/services/app_bootstrap_service.dart';

/// Opt-in native startup measurement using installed preferences/database.
/// Keep separate from deterministic CI: invokes the real bootstrap and may
/// contact configured providers. Never logs credentials or journey contents.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const enabled = bool.fromEnvironment('RUN_REAL_STARTUP_PROFILE');
  testWidgets(
    'profile actual Dart startup to settled Home',
    (tester) async {
      binding.reportData = {
        'metadata': {
          'mode': kProfileMode ? 'profile' : 'debug',
          'platform': Platform.operatingSystem,
          'dart_version': Platform.version,
          'real_bootstrap': true,
          'fixtures_used': false,
          'includes_engine_process_launch': false,
        },
      };
      final startup = Stopwatch()..start();
      final rssBefore = ProcessInfo.currentRss;
      await binding.watchPerformance(() async {
        await app.main();
        binding.reportData!['app_main_complete_ms'] =
            startup.elapsedMilliseconds;
        expect(
          AppBootstrapService.report.value.hasFailures,
          isFalse,
          reason: 'A failed bootstrap stage is not a successful startup',
        );
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        expect(find.byType(MyHomePage), findsOneWidget);
        binding.reportData!['first_home_frame_ms'] =
            startup.elapsedMilliseconds;
        final homeReady = find.byKey(const ValueKey('home-journeys-ready'));
        final loadDeadline = startup.elapsed + const Duration(seconds: 60);
        while (homeReady.evaluate().isEmpty && startup.elapsed < loadDeadline) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
          homeReady,
          findsOneWidget,
          reason: 'Startup must finish loading saved journeys successfully',
        );
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 60),
        );
        binding.reportData!['settled_home_ms'] = startup.elapsedMilliseconds;
      }, reportKey: 'actual_startup');
      startup.stop();
      binding.reportData!['startup_rss'] = {
        'before_bytes': rssBefore,
        'after_bytes': ProcessInfo.currentRss,
      };
      final metrics =
          binding.reportData!['actual_startup'] as Map<String, dynamic>;
      expect(metrics['frame_count'], greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 3)),
    skip: !enabled,
  );
}
