import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/preference_read_failure.dart';
import 'package:lbww_flutter/wrappers/app_preferences_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _UnreadableStore extends InMemorySharedPreferencesStore {
  _UnreadableStore() : super.withData({'flutter.count': 3});

  bool failReads = false;

  @override
  Future<Map<String, Object>> getAll() async {
    if (failReads) throw StateError('Storage read unavailable');
    return super.getAll();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _UnreadableStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = _UnreadableStore();
    SharedPreferencesStorePlatform.instance = store;
  });

  test('strict reads return null only when key is absent', () async {
    expect(await AppPreferences.getStringOrThrow('missing'), isNull);
    expect(await AppPreferences.getBoolOrThrow('missing'), isNull);
    expect(await AppPreferences.containsKeyOrThrow('missing'), isFalse);
    expect(await AppPreferences.containsKeyOrThrow('count'), isTrue);
  });

  test('strict typed read reports a stored value of another type', () async {
    await expectLater(
      AppPreferences.getStringOrThrow('count'),
      throwsA(isA<PreferenceReadFailure>()),
    );
  });

  test(
    'strict reads report backend failures while legacy reads stay nullable',
    () async {
      store.failReads = true;
      await expectLater(
        AppPreferences.getBoolOrThrow('flag'),
        throwsA(isA<PreferenceReadFailure>()),
      );
      expect(await AppPreferences.getBool('flag'), isNull);
      await expectLater(
        AppPreferences.containsKeyOrThrow('flag'),
        throwsA(isA<PreferenceReadFailure>()),
      );
    },
  );
}
