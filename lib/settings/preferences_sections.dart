part of '../settings.dart';

extension _SettingsPreferencesSections on _SettingsScreenState {
  Widget _buildRegionsSection() {
    final selectedRegion = _selectedRegion;
    final currentServices = _currentServices;
    final enabledRegions = AppTransitContext.instance.enabledRegions;
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transit Regions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...TransitRegion.values.map(
              (region) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(region.label),
                subtitle: Text(
                  RegionFeatureFlags.isEnabled(region)
                      ? AppTransitContext.instance
                            .servicesFor(region)
                            .attribution
                            .name
                      : 'Disabled in this build',
                ),
                value: enabledRegions.contains(region),
                onChanged:
                    !_isSavingPreference && RegionFeatureFlags.isEnabled(region)
                    ? (enabled) => _toggleRegion(region, enabled ?? false)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TransitRegion>(
              isExpanded: true,
              key: ValueKey((selectedRegion, _preferenceFormGeneration)),
              initialValue: selectedRegion,
              items: enabledRegions
                  .map(
                    (region) => DropdownMenuItem(
                      value: region,
                      child: Text(region.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _isSavingPreference
                  ? null
                  : (region) {
                      if (region == null) return;
                      _savePreference(
                        () => AppTransitContext.instance.setSelectedRegion(
                          region,
                        ),
                      );
                    },
              decoration: const InputDecoration(
                labelText: 'Primary region',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Provider: ${currentServices.attribution.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _capabilitySummary(currentServices),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: AppAppearanceService.themeMode,
              builder: (context, themeMode, child) {
                return DropdownButtonFormField<ThemeMode>(
                  isExpanded: true,
                  key: ValueKey((themeMode, _preferenceFormGeneration)),
                  initialValue: themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System default'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: _isSavingPreference
                      ? null
                      : (mode) {
                          if (mode == null) return;
                          _savePreference(
                            () => AppAppearanceService.setThemeMode(mode),
                          );
                        },
                  decoration: const InputDecoration(
                    labelText: 'Theme',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributionSection() {
    final enabledServices = AppTransitContext.instance.enabledServices;
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider Attribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...enabledServices.map(
              (services) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(services.attribution.name),
                subtitle: Text(services.attribution.licenseName),
                trailing: IconButton(
                  tooltip: 'Open ${services.attribution.name} docs',
                  onPressed: () => _openProviderUrl(services.attribution.url),
                  icon: const Icon(Icons.open_in_new),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
