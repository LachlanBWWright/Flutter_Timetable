import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/preference_write_failure.dart';
import 'package:lbww_flutter/wrappers/app_preferences_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

// This tests the actual plugin persistence boundary and its optimistic cache.

class _RejectingStore extends InMemorySharedPreferencesStore {
  _RejectingStore()
    : super.withData({'flutter.name': 'original', 'flutter.flag': false});

  bool reject = true;
  bool throwOnWrite = false;
  bool throwOnRead = false;
  Completer<void>? gate;
  final List<Object> writes = [];

  Future<bool> _shouldWrite() async {
    await gate?.future;
    if (throwOnWrite) throw StateError('Persistence unavailable');
    return !reject;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    if (throwOnRead) throw StateError('Storage read unavailable');
    return super.getAll();
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes.add(value);
    if (!await _shouldWrite()) return false;
    return super.setValue(valueType, key, value);
  }

  @override
  Future<bool> remove(String key) async {
    if (!await _shouldWrite()) return false;
    return super.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _RejectingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = _RejectingStore();
    SharedPreferencesStorePlatform.instance = store;
    await AppPreferences.init();
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('rejected string save throws and restores persisted cache', () async {
    await expectLater(
      AppPreferences.setStringOrThrow('name', 'changed'),
      throwsA(isA<PreferenceWriteFailure>()),
    );
    expect(await AppPreferences.getString('name'), 'original');
    expect(
      (await SharedPreferences.getInstance()).getString('name'),
      'original',
    );
    store.reject = false;
    await AppPreferences.setStringOrThrow('name', 'saved');
    expect(await AppPreferences.getString('name'), 'saved');
  });

  test('backend exception restores boolean and permits next write', () async {
    store.throwOnWrite = true;
    await expectLater(
      AppPreferences.setBoolOrThrow('flag', true),
      throwsA(isA<PreferenceWriteFailure>()),
    );
    expect(await AppPreferences.getBool('flag'), false);
    store.throwOnWrite = false;
    store.reject = false;
    await AppPreferences.setBoolOrThrow('flag', true);
    expect(await AppPreferences.getBool('flag'), true);
  });

  test('failed removal preserves persisted value', () async {
    await expectLater(
      AppPreferences.removeOrThrow('name'),
      throwsA(isA<PreferenceWriteFailure>()),
    );
    expect(await AppPreferences.getString('name'), 'original');
    store.reject = false;
    await AppPreferences.removeOrThrow('name');
    expect(await AppPreferences.getString('name'), isNull);
  });

  test(
    'legacy write API reports false without exposing rejected cache',
    () async {
      expect(await AppPreferences.setString('name', 'changed'), false);
      expect(await AppPreferences.getString('name'), 'original');
    },
  );

  test(
    'failed rollback blocks optimistic cache until reload recovers',
    () async {
      store.throwOnRead = true;
      expect(await AppPreferences.setString('name', 'changed'), false);
      expect(await AppPreferences.getString('name'), isNull);
      store.reject = false;
      expect(await AppPreferences.setString('name', 'another'), false);
      store.throwOnRead = false;
      expect(await AppPreferences.getString('name'), 'original');
      await AppPreferences.setStringOrThrow('name', 'saved');
      expect(await AppPreferences.getString('name'), 'saved');
    },
  );

  test(
    'reads wait for confirmation before observing optimistic cache',
    () async {
      store.gate = Completer<void>();
      final write = AppPreferences.setString('name', 'changed');
      final read = AppPreferences.getString('name');
      var readFinished = false;
      read.then((_) => readFinished = true);
      await Future<void>.delayed(Duration.zero);
      expect(readFinished, false);
      store.gate!.complete();
      expect(await write, false);
      expect(await read, 'original');
    },
  );

  test('concurrent saves persist in call order before queued reads', () async {
    store.reject = false;
    store.gate = Completer<void>();
    final first = AppPreferences.setStringOrThrow('name', 'first');
    final second = AppPreferences.setStringOrThrow('name', 'second');
    final read = AppPreferences.getString('name');
    var readFinished = false;
    read.then((_) => readFinished = true);

    await Future<void>.delayed(Duration.zero);
    expect(store.writes, ['first']);
    expect(readFinished, false);

    store.gate!.complete();
    await Future.wait([first, second]);
    expect(store.writes, ['first', 'second']);
    expect(await read, 'second');
    expect((await store.getAll())['flutter.name'], 'second');
  });
}
