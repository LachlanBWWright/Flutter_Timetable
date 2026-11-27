part of '../settings.dart';

extension _SettingsSaveActions on _SettingsScreenState {
  Future<void> _saveCredentials({
    required Future<void> Function() write,
    required VoidCallback onSuccess,
    required String failureMessage,
  }) async {
    if (_isSavingApiKey) return;
    guardedSetState(() {
      _isSavingApiKey = true;
      _apiKeyStatus = null;
    });
    try {
      await write();
      guardedSetState(onSuccess);
    } catch (_) {
      guardedSetState(() => _apiKeyStatus = failureMessage);
    } finally {
      guardedSetState(() => _isSavingApiKey = false);
    }
  }

  Future<void> _saveApiKey() async {
    if (_isSavingApiKey) return;
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      guardedSetState(() => _apiKeyStatus = 'Please enter an API key.');
      return;
    }
    await _saveCredentials(
      write: () => ApiKeyService.setUserApiKey(key),
      onSuccess: () {
        _hasUserApiKey = true;
        _apiKeyController.clear();
        _apiKeyStatus = 'Custom API key saved successfully.';
      },
      failureMessage: 'Could not save your API key. Please try again.',
    );
  }

  Future<void> _clearApiKey() => _saveCredentials(
    write: ApiKeyService.clearUserApiKey,
    onSuccess: () {
      _hasUserApiKey = false;
      _apiKeyController.clear();
      _apiKeyStatus = _resolveHasBuiltInApiKey()
          ? 'Custom key removed - using built-in API key.'
          : 'Custom key removed - no API key is configured.';
    },
    failureMessage: 'Could not remove your API key. Please try again.',
  );

  Future<void> _savePtvCredentials() async {
    if (_isSavingApiKey) return;
    final developerId = _ptvDeveloperIdController.text.trim();
    final apiKey = _ptvApiKeyController.text.trim();
    if (developerId.isEmpty || apiKey.isEmpty) {
      guardedSetState(
        () => _apiKeyStatus = 'Enter both the PTV developer ID and API key.',
      );
      return;
    }
    await _saveCredentials(
      write: () => PtvCredentialService.setUserCredentials(
        developerId: developerId,
        apiKey: apiKey,
      ),
      onSuccess: () {
        _ptvDeveloperIdController.clear();
        _ptvApiKeyController.clear();
        _apiKeyStatus = 'Custom PTV credentials saved successfully.';
      },
      failureMessage: 'Could not save your PTV credentials. Please try again.',
    );
  }

  Future<void> _clearPtvCredentials() => _saveCredentials(
    write: PtvCredentialService.clearUserCredentials,
    onSuccess: () {
      _ptvDeveloperIdController.clear();
      _ptvApiKeyController.clear();
      _apiKeyStatus = PtvCredentialService.hasBuiltInCredentials
          ? 'Custom PTV credentials removed; using built-in credentials.'
          : 'Custom PTV credentials removed.';
    },
    failureMessage: 'Could not remove your PTV credentials. Please try again.',
  );

  Future<void> _savePreference(Future<void> Function() write) async {
    if (_isSavingPreference) return;
    guardedSetState(() => _isSavingPreference = true);
    try {
      await write();
      if (mounted) _loadApiKeyState();
    } catch (_) {
      showSnackBarMessage('Could not save this setting. Please try again.');
    } finally {
      guardedSetState(() {
        _isSavingPreference = false;
        // Recreate form fields so a failed save displays the persisted value.
        _preferenceFormGeneration++;
      });
    }
  }

  Future<void> _toggleRegion(TransitRegion region, bool enabled) async {
    final regions = {...AppTransitContext.instance.enabledRegions};
    if (enabled) {
      regions.add(region);
    } else {
      if (regions.length == 1) {
        showSnackBarMessage('At least one region must be enabled.');
        return;
      }
      regions.remove(region);
    }
    await _savePreference(
      () => AppTransitContext.instance.setEnabledRegions(regions),
    );
  }

  Future<void> _toggleDebugData(bool value) =>
      _savePreference(() => DebugService.setShowDebugData(value));

  Future<void> _toggleNswTrainLink(bool value) => _savePreference(
    () => TransportPreferencesService.setShowNswTrainLink(value),
  );
}
