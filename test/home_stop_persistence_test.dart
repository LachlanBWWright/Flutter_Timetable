import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/home_stop_service.dart';
import 'package:lbww_flutter/services/preference_read_failure.dart';
import 'package:lbww_flutter/set_home_stop_screen.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const stop = HomeStop(
    name: 'Central',
    id: '200060',
    mode: TransportMode.train,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'a save stores a complete record without changing legacy fields',
    () async {
      SharedPreferences.setMockInitialValues({'home_stop_name': 'Old stop'});
      const service = HomeStopService();
      await service.save(stop);
      final preferences = await SharedPreferences.getInstance();
      expect(
        jsonDecode(preferences.getString(HomeStopService.preferenceKey)!),
        {'name': 'Central', 'id': '200060', 'mode': 'train'},
      );
      expect(preferences.getString('home_stop_name'), 'Old stop');
      final restored = await service.load();
      expect(restored?.name, stop.name);
      expect(restored?.id, stop.id);
      expect(restored?.mode, stop.mode);
    },
  );

  test(
    'reads a legacy selection until a complete new selection is saved',
    () async {
      SharedPreferences.setMockInitialValues({
        'home_stop_name': 'Circular Quay',
        'home_stop_id': 'ferry:quay',
        'home_stop_mode': 'ferry',
      });
      const service = HomeStopService();
      expect((await service.load())?.mode, TransportMode.ferry);
      await service.save(stop);
      expect((await service.load())?.id, stop.id);
    },
  );

  test(
    'partial legacy and malformed current records are not selections',
    () async {
      SharedPreferences.setMockInitialValues({'home_stop_name': 'Central'});
      const service = HomeStopService();
      expect(await service.load(), isNull);
      SharedPreferences.setMockInitialValues({
        HomeStopService.preferenceKey: '{invalid',
        'home_stop_name': 'Old stop',
        'home_stop_id': 'old',
        'home_stop_mode': 'train',
      });
      expect(await service.load(), isNull);
    },
  );

  test('invalid current records cannot restore an older legacy stop', () async {
    for (final encoded in [
      'null',
      '[]',
      '{}',
      '{"name":"Central","id":"200060","mode":"unknown"}',
      '{"name":"Central","id":"","mode":"train"}',
      '{"name":42,"id":"200060","mode":"train"}',
    ]) {
      final values = {
        HomeStopService.preferenceKey: encoded,
        'home_stop_name': 'Old stop',
        'home_stop_id': 'old',
        'home_stop_mode': 'train',
      };
      final service = HomeStopService(readString: (key) async => values[key]);
      expect(await service.load(), isNull, reason: encoded);
    }
  });

  test(
    'non-string current records cannot restore an older legacy stop',
    () async {
      SharedPreferences.setMockInitialValues({
        HomeStopService.preferenceKey: 42,
        'home_stop_name': 'Old stop',
        'home_stop_id': 'old',
        'home_stop_mode': 'train',
      });
      await expectLater(
        const HomeStopService().load(),
        throwsA(isA<PreferenceReadFailure>()),
      );
    },
  );

  test('unknown record presence cannot restore an older legacy stop', () async {
    final values = {
      'home_stop_name': 'Old stop',
      'home_stop_id': 'old',
      'home_stop_mode': 'train',
    };
    final service = HomeStopService(
      readString: (key) async => values[key],
      containsKey: (_) async => null,
    );
    expect(await service.load(), isNull);
  });

  testWidgets(
    'failed saves keep selection and can retry; pending saves disable action',
    (tester) async {
      final firstWrite = Completer<void>();
      var writes = 0;
      final service = HomeStopService(
        writeString: (key, value) async {
          writes++;
          if (writes == 1) await firstWrite.future;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SetHomeStopScreen(
                        skipInitialLoad: true,
                        homeStopService: service,
                        initialStations: const [
                          Station(name: 'Central', id: '200060'),
                          Station(name: 'Town Hall', id: '200070'),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Choose home stop'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Choose home stop'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Central'));
      await tester.pump();
      final saveFinder = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Save home stop',
      );
      final saveAction = tester.widget<IconButton>(saveFinder).onPressed!;
      await tester.tap(saveFinder);
      await tester.pump();
      final saveButton = tester.widget<IconButton>(saveFinder);
      expect(saveButton.onPressed, isNull);
      expect(writes, 1);
      saveAction();
      await tester.tap(find.text('Town Hall'));
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(writes, 1);
      expect(find.text('Selected: Central'), findsOneWidget);
      expect(find.byType(SetHomeStopScreen), findsOneWidget);
      expect(find.text('Home stop set to Central'), findsNothing);

      firstWrite.completeError(StateError('disk full'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save home stop. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Selected: Central'), findsOneWidget);
      expect(find.byType(SetHomeStopScreen), findsOneWidget);
      expect(find.text('Home stop set to Central'), findsNothing);

      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(writes, 2);
      expect(find.byType(SetHomeStopScreen), findsNothing);
      expect(find.text('Home stop set to Central'), findsOneWidget);
    },
  );
}
