import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/api_key_service.dart';
import 'package:lbww_flutter/services/app_appearance_service.dart';
import 'package:lbww_flutter/services/app_preferences.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/preference_read_failure.dart';
import 'package:lbww_flutter/services/preference_write_failure.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/victoria/services/ptv_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Exercise failures at the platform boundary, including plugin cache rollback.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Store extends InMemorySharedPreferencesStore {
  _Store(super.values) : super.withData();

  bool reject = false;
  final List<String> writes = [];

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes.add(key);
    if (reject) return false;
    return super.setValue(valueType, key, value);
  }

  @override
  Future<bool> remove(String key) async {
    writes.add(key);
    if (reject) return false;
    return super.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Store store;

  Future<void> initialize(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues({});
    store = _Store(values);
    SharedPreferencesStorePlatform.instance = store;
    await AppPreferences.init();
    await ApiKeyService.init();
    await PtvCredentialService.init();
    await AppAppearanceService.init();
    await DebugService.init();
    await TransportPreferencesService.init();
  }

  setUp(() async {
    dotenv.loadFromString(
      envString:
          'API_KEY=builtin\nPTV_DEV_ID=default-id\nPTV_API_KEY=default-key',
    );
    await initialize({});
  });

  tearDown(() => SharedPreferences.setMockInitialValues({}));

  test('failed setting writes leave all runtime state unchanged', () async {
    store.reject = true;
    final oldDebug = DebugService.showDebugData.value;
    final oldTrainLink = TransportPreferencesService.showNswTrainLink.value;
    final oldRegions = TransportPreferencesService.enabledRegions.value;
    final failingOperations = [
      () => ApiKeyService.setUserApiKey('new-key'),
      () => AppAppearanceService.setThemeMode(ThemeMode.dark),
      () => DebugService.setShowDebugData(!oldDebug),
      () => TransportPreferencesService.setShowNswTrainLink(!oldTrainLink),
      () => TransportPreferencesService.setEnabledRegions({TransitRegion.nsw}),
      () => LocationService.setSortingPreference(false),
      () => PtvCredentialService.setUserCredentials(
        developerId: 'new',
        apiKey: 'key',
      ),
    ];
    for (final save in failingOperations) {
      await expectLater(save(), throwsA(isA<PreferenceWriteFailure>()));
    }
    expect(ApiKeyService.getEffectiveApiKey(), 'builtin');
    expect(AppAppearanceService.themeMode.value, ThemeMode.system);
    expect(DebugService.showDebugData.value, oldDebug);
    expect(TransportPreferencesService.showNswTrainLink.value, oldTrainLink);
    expect(TransportPreferencesService.enabledRegions.value, oldRegions);
    expect(await LocationService.isAlphabeticalSorting(), true);
    expect(PtvCredentialService.hasUserCredentials, false);
  });

  test(
    'failed credential clear preserves override across reinitialization',
    () async {
      await ApiKeyService.setUserApiKey('override');
      await PtvCredentialService.setUserCredentials(
        developerId: 'id',
        apiKey: 'secret',
      );
      store.reject = true;
      await expectLater(
        ApiKeyService.clearUserApiKey(),
        throwsA(isA<PreferenceWriteFailure>()),
      );
      await expectLater(
        PtvCredentialService.clearUserCredentials(),
        throwsA(isA<PreferenceWriteFailure>()),
      );
      await ApiKeyService.init();
      await PtvCredentialService.init();
      expect(ApiKeyService.getEffectiveApiKey(), 'override');
      expect(PtvCredentialService.effectiveCredentials.developerId, 'id');
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'secret');
    },
  );

  test(
    'PTV pair uses one write and cleared legacy keys cannot revive',
    () async {
      await initialize({
        'flutter.ptv_user_developer_id': 'legacy-id',
        'flutter.ptv_user_api_key': 'legacy-key',
      });
      expect(
        PtvCredentialService.effectiveCredentials.developerId,
        'legacy-id',
      );
      await PtvCredentialService.setUserCredentials(
        developerId: 'new-id',
        apiKey: 'new-key',
      );
      expect(store.writes, ['flutter.ptv_user_credentials']);
      await PtvCredentialService.init();
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'new-key');
      await PtvCredentialService.clearUserCredentials();
      await PtvCredentialService.init();
      expect(PtvCredentialService.hasUserCredentials, false);
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'default-key');
    },
  );

  test(
    'region record atomically preserves selection and enabled set',
    () async {
      final regions = RegionFeatureFlags.enabledRegions;
      final chosen = regions.last;
      await TransportPreferencesService.setEnabledRegions(regions);
      await TransportPreferencesService.setSelectedRegion(chosen);
      expect(store.writes, everyElement('flutter.transit_regions_record'));
      final record =
          jsonDecode(
                (await AppPreferences.getString('transit_regions_record'))!,
              )
              as Map<String, dynamic>;
      expect(record['selected'], chosen.name);
      expect(record['enabled'], contains(chosen.name));
      await TransportPreferencesService.init();
      expect(TransportPreferencesService.selectedRegion.value, chosen);
      expect(TransportPreferencesService.enabledRegions.value, regions);
      store.reject = true;
      await expectLater(
        TransportPreferencesService.setEnabledRegions({regions.first}),
        throwsA(isA<PreferenceWriteFailure>()),
      );
      expect(TransportPreferencesService.enabledRegions.value, regions);
      expect(TransportPreferencesService.selectedRegion.value, chosen);
    },
  );

  test(
    'partial legacy PTV pair does not mix with built-in credentials',
    () async {
      await initialize({'flutter.ptv_user_developer_id': 'partial-id'});
      expect(PtvCredentialService.hasUserCredentials, false);
      expect(
        PtvCredentialService.effectiveCredentials.developerId,
        'default-id',
      );
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'default-key');
    },
  );

  test('malformed PTV records cannot revive legacy credentials', () async {
    for (final record in <Object>['{', '[]', '{"developerId":4}']) {
      await initialize({
        'flutter.ptv_user_credentials': record,
        'flutter.ptv_user_developer_id': 'legacy-id',
        'flutter.ptv_user_api_key': 'legacy-key',
      });
      expect(PtvCredentialService.hasUserCredentials, false);
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'default-key');
    }
  });

  test(
    'wrongly typed PTV record fails without replacing active credentials',
    () async {
      await PtvCredentialService.setUserCredentials(
        developerId: 'active-id',
        apiKey: 'active-key',
      );
      SharedPreferences.setMockInitialValues({'ptv_user_credentials': false});
      await AppPreferences.init();

      await expectLater(
        PtvCredentialService.init(),
        throwsA(isA<PreferenceReadFailure>()),
      );
      expect(
        PtvCredentialService.effectiveCredentials.developerId,
        'active-id',
      );
      expect(PtvCredentialService.effectiveCredentials.apiKey, 'active-key');
    },
  );

  test(
    'concurrent region writes preserve the last requested selection',
    () async {
      final regions = RegionFeatureFlags.enabledRegions;
      final first = regions.first;
      final last = regions.last;
      await TransportPreferencesService.setEnabledRegions({first});
      await Future.wait([
        TransportPreferencesService.setEnabledRegions(regions),
        TransportPreferencesService.setSelectedRegion(last),
      ]);
      expect(TransportPreferencesService.enabledRegions.value, regions);
      expect(TransportPreferencesService.selectedRegion.value, last);
      await TransportPreferencesService.init();
      expect(TransportPreferencesService.enabledRegions.value, regions);
      expect(TransportPreferencesService.selectedRegion.value, last);
    },
  );

  test('wrongly typed region records cannot revive legacy settings', () async {
    final regions = RegionFeatureFlags.enabledRegions;
    for (final record in <Object>[
      jsonEncode({'selected': regions.last.name, 'enabled': 42}),
      jsonEncode({
        'selected': regions.last.name,
        'enabled': [42],
      }),
    ]) {
      await initialize({
        'flutter.transit_regions_record': record,
        'flutter.selected_transit_region': regions.last.name,
        'flutter.enabled_transit_regions': regions
            .map((region) => region.name)
            .join(','),
      });
      expect(TransportPreferencesService.selectedRegion.value, regions.first);
      expect(TransportPreferencesService.enabledRegions.value, {regions.first});
    }
  });

  test(
    'wrongly typed region record fails without replacing active settings',
    () async {
      final regions = RegionFeatureFlags.enabledRegions;
      final selected = regions.last;
      await TransportPreferencesService.setShowNswTrainLink(true);
      await TransportPreferencesService.setEnabledRegions(regions);
      await TransportPreferencesService.setSelectedRegion(selected);
      SharedPreferences.setMockInitialValues({'transit_regions_record': false});
      await AppPreferences.init();

      await expectLater(
        TransportPreferencesService.init(),
        throwsA(isA<PreferenceReadFailure>()),
      );
      expect(TransportPreferencesService.showNswTrainLink.value, isTrue);
      expect(TransportPreferencesService.selectedRegion.value, selected);
      expect(TransportPreferencesService.enabledRegions.value, regions);
    },
  );
}
