part of '../settings.dart';

extension _SettingsCredentialsSection on _SettingsScreenState {
  Widget _buildProviderCredentialsCard(
    TransitRegion region, {
    required bool hasBuiltInTfnswKey,
  }) {
    final services = AppTransitContext.instance.servicesFor(region);
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${services.attribution.name} credentials',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openProviderUrl(services.attribution.url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Provider docs'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (region == TransitRegion.nsw)
              ..._buildTfnswCredentialFields(hasBuiltInTfnswKey)
            else if (region == TransitRegion.victoria)
              ..._buildPtvCredentialFields()
            else ...const [
              Text(
                'No API credentials are required for the configured Queensland open-data feeds.',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTfnswCredentialFields(bool hasBuiltInApiKey) => [
    Text(
      apiKeyUsageText(
        hasUserApiKey: _hasUserApiKey,
        hasBuiltInApiKey: hasBuiltInApiKey,
      ),
      style: TextStyle(
        color: apiKeyUsageColor(
          hasUserApiKey: _hasUserApiKey,
          hasBuiltInApiKey: hasBuiltInApiKey,
        ),
      ),
    ),
    const SizedBox(height: 12),
    TextField(
      enabled: !_isSavingApiKey,
      controller: _apiKeyController,
      obscureText: _apiKeyObscured,
      decoration: _credentialDecoration(
        label: 'TfNSW OpenData API key',
        hint: 'Paste your TfNSW API key',
      ),
    ),
    const SizedBox(height: 12),
    _buildCredentialStatus(),
    Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSavingApiKey ? null : _saveApiKey,
            icon: const Icon(Icons.save),
            label: const Text('Save key'),
          ),
        ),
        if (_hasUserApiKey) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSavingApiKey ? null : _clearApiKey,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear override'),
            ),
          ),
        ],
      ],
    ),
  ];

  List<Widget> _buildPtvCredentialFields() => [
    Text(
      PtvCredentialService.hasUserCredentials
          ? 'Using custom PTV credentials.'
          : PtvCredentialService.hasBuiltInCredentials
          ? 'Using built-in PTV credentials.'
          : 'PTV credentials are not configured.',
      style: TextStyle(
        color:
            PtvCredentialService.hasUserCredentials ||
                PtvCredentialService.hasBuiltInCredentials
            ? Colors.green
            : Colors.orange,
      ),
    ),
    const SizedBox(height: 12),
    TextField(
      enabled: !_isSavingApiKey,
      controller: _ptvDeveloperIdController,
      decoration: _credentialDecoration(
        label: 'PTV developer ID',
        hint: 'Enter your PTV developer ID',
      ),
    ),
    const SizedBox(height: 8),
    TextField(
      enabled: !_isSavingApiKey,
      controller: _ptvApiKeyController,
      obscureText: _apiKeyObscured,
      decoration: _credentialDecoration(
        label: 'PTV API key',
        hint: 'Paste your PTV API key',
      ),
    ),
    const SizedBox(height: 12),
    _buildCredentialStatus(),
    Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSavingApiKey ? null : _savePtvCredentials,
            icon: const Icon(Icons.save),
            label: const Text('Save credentials'),
          ),
        ),
        if (PtvCredentialService.hasUserCredentials) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSavingApiKey ? null : _clearPtvCredentials,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear override'),
            ),
          ),
        ],
      ],
    ),
  ];

  InputDecoration _credentialDecoration({
    required String label,
    required String hint,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
    suffixIcon: IconButton(
      icon: Icon(_apiKeyObscured ? Icons.visibility : Icons.visibility_off),
      tooltip: _apiKeyObscured ? 'Show credentials' : 'Hide credentials',
      onPressed: () =>
          guardedSetState(() => _apiKeyObscured = !_apiKeyObscured),
    ),
  );

  Widget _buildCredentialStatus() {
    final status = _apiKeyStatus;
    if (status == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        status,
        style: TextStyle(color: _apiKeyStatusColor(status), fontSize: 13),
      ),
    );
  }
}
