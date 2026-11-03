import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Start each test with a clean SharedPreferences store and no dotenv key.
    SharedPreferences.setMockInitialValues({});
    // initialize dotenv with an empty map (optional to avoid errors)
    dotenv.loadFromString(envString: '', isOptional: true);
    await ApiKeyService.init();
  });

  group('ApiKeyService', () {
    test(
      'getEffectiveApiKey returns empty string when nothing is configured',
      () async {
        // No dotenv loaded and no user key — should return empty string.
        expect(ApiKeyService.getEffectiveApiKey(), equals(''));
      },
    );

    test(
      'setUserApiKey persists the key and is reflected in getEffectiveApiKey',
      () async {
        await ApiKeyService.setUserApiKey('my-test-key');
        expect(ApiKeyService.getEffectiveApiKey(), equals('my-test-key'));
        expect(ApiKeyService.hasUserApiKey(), isTrue);
      },
    );

    test('setUserApiKey trims whitespace', () async {
      await ApiKeyService.setUserApiKey('  trimmed-key  ');
      expect(ApiKeyService.getEffectiveApiKey(), equals('trimmed-key'));
    });

    test('clearUserApiKey removes the override', () async {
      await ApiKeyService.setUserApiKey('my-test-key');
      await ApiKeyService.clearUserApiKey();
      expect(ApiKeyService.hasUserApiKey(), isFalse);
    });

    test('clearUserApiKey reverts to dotenv key when present', () async {
      // Simulate a built-in key via dotenv.
      dotenv.loadFromString(envString: 'API_KEY=builtin-key');
      await ApiKeyService.setUserApiKey('user-key');
      expect(ApiKeyService.getEffectiveApiKey(), equals('user-key'));
      await ApiKeyService.clearUserApiKey();
      expect(ApiKeyService.getEffectiveApiKey(), equals('builtin-key'));
    });

    test('hasBuiltInApiKey returns false when dotenv has no key', () {
      expect(ApiKeyService.hasBuiltInApiKey(), isFalse);
    });

    test('hasBuiltInApiKey returns true when dotenv has a key', () {
      dotenv.loadFromString(envString: 'API_KEY=some-key');
      expect(ApiKeyService.hasBuiltInApiKey(), isTrue);
    });

    test(
      'init loads a previously persisted user key from SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_api_key': 'persisted-key',
        });
        await ApiKeyService.init();
        expect(ApiKeyService.getEffectiveApiKey(), equals('persisted-key'));
        expect(ApiKeyService.hasUserApiKey(), isTrue);
      },
    );

    test('setUserApiKey with empty string is treated as clear', () async {
      await ApiKeyService.setUserApiKey('some-key');
      await ApiKeyService.setUserApiKey('');
      expect(ApiKeyService.hasUserApiKey(), isFalse);
    });
  });
}
