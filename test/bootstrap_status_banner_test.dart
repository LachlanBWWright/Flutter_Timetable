import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/app_bootstrap_service.dart';
import 'package:lbww_flutter/services/home_stop_service.dart';
import 'package:lbww_flutter/services/preference_read_failure.dart';
import 'package:lbww_flutter/widgets/bootstrap_status_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingStore extends InMemorySharedPreferencesStore {
  _FailingStore() : super.withData({});

  @override
  Future<Map<String, Object>> getAll() async =>
      throw StateError('read unavailable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('home stop default initializer exposes typed read failure', () async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesStorePlatform.instance = _FailingStore();
    await expectLater(
      const HomeStopService().load(),
      throwsA(isA<PreferenceReadFailure>()),
    );
  });

  testWidgets('bootstrap warning is visible and retry clears it', (
    tester,
  ) async {
    AppBootstrapService.report.value = BootstrapReport(const [
      BootstrapStageFailure('appearance settings'),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: Text('Home')),
        builder: (context, child) => Column(
          children: [
            BootstrapStatusBanner(
              onRetry: () async {
                AppBootstrapService.report.value = BootstrapReport(const []);
              },
            ),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      ),
    );
    expect(
      find.textContaining('Could not load appearance settings'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not load appearance settings'),
      findsNothing,
    );
  });
}
