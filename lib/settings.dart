import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';

import 'debug/debug_entity_type.dart';
import 'debug/debug_navigation.dart';
import 'debug/debug_page_loader.dart';
import 'services/api_key_service.dart';
import 'services/app_url_launcher.dart';
import 'services/database_admin_service.dart';
import 'services/debug_service.dart';
import 'services/transport_preferences_service.dart';
import 'set_home_stop_screen.dart';
import 'transit/transit.dart';
import 'utils/button_styles.dart';
import 'utils/color_utils.dart';
import 'utils/guarded_state.dart';
import 'utils/settings_screen_utils.dart';
import 'victoria/services/ptv_credentials.dart';
import 'widgets/realtime_map_widget.dart';
import 'widgets/realtime_widgets.dart';
import 'widgets/stops_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final DebugEntityPageLoader? debugPageLoader;
  final DebugEntityListPageLoader? debugListLoader;
  final bool? hasUserApiKey;
  final bool? hasBuiltInApiKey;
  final Widget? stopsManagementWidget;
  final Widget? stopsSearchWidget;
  final Widget? realtimeInfoWidget;

  const SettingsScreen({
    super.key,
    this.debugPageLoader,
    this.debugListLoader,
    this.hasUserApiKey,
    this.hasBuiltInApiKey,
    this.stopsManagementWidget,
    this.stopsSearchWidget,
    this.realtimeInfoWidget,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with GuardedState<SettingsScreen> {
  bool _isUpdating = false;
  String? _updateStatus;
  int _staticEndpointsUpdated = 0;
  final Map<String, String> _staticEndpointErrors = {};

  late final DebugEntityPageLoader _debugPageLoader =
      widget.debugPageLoader ?? buildDebugEntityPageLoader();
  late final DebugEntityListPageLoader _debugListLoader =
      widget.debugListLoader ?? buildDebugEntityListLoader();

  // API key card state
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _ptvDeveloperIdController =
      TextEditingController();
  final TextEditingController _ptvApiKeyController = TextEditingController();
  bool _hasUserApiKey = false;
  bool _apiKeyObscured = true;
  bool _isSavingApiKey = false;
  String? _apiKeyStatus;

  @override
  void initState() {
    super.initState();
    _loadApiKeyState();
  }

  @override
  void dispose() {
    disposeChangeNotifierSafely(_apiKeyController);
    disposeChangeNotifierSafely(_ptvDeveloperIdController);
    disposeChangeNotifierSafely(_ptvApiKeyController);
    super.dispose();
  }

  void _loadApiKeyState() {
    guardedSetState(() {
      _hasUserApiKey = _resolveHasUserApiKey();
    });
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      guardedSetState(() => _apiKeyStatus = 'Please enter an API key.');
      return;
    }
    guardedSetState(() => _isSavingApiKey = true);
    await ApiKeyService.setUserApiKey(key);
    guardedSetState(() {
      _hasUserApiKey = true;
      _apiKeyController.clear();
      _apiKeyStatus = 'Custom API key saved successfully.';
      _isSavingApiKey = false;
    });
  }

  Future<void> _clearApiKey() async {
    guardedSetState(() => _isSavingApiKey = true);
    await ApiKeyService.clearUserApiKey();
    final hasBuiltInApiKey = _resolveHasBuiltInApiKey();
    guardedSetState(() {
      _hasUserApiKey = false;
      _apiKeyController.clear();
      _apiKeyStatus = hasBuiltInApiKey
          ? 'Custom key removed - using built-in API key.'
          : 'Custom key removed - no API key is configured.';
      _isSavingApiKey = false;
    });
  }

  Future<void> _savePtvCredentials() async {
    final developerId = _ptvDeveloperIdController.text.trim();
    final apiKey = _ptvApiKeyController.text.trim();
    if (developerId.isEmpty || apiKey.isEmpty) {
      guardedSetState(
        () => _apiKeyStatus = 'Enter both the PTV developer ID and API key.',
      );
      return;
    }
    guardedSetState(() => _isSavingApiKey = true);
    await PtvCredentialService.setUserCredentials(
      developerId: developerId,
      apiKey: apiKey,
    );
    guardedSetState(() {
      _ptvDeveloperIdController.clear();
      _ptvApiKeyController.clear();
      _apiKeyStatus = 'Custom PTV credentials saved successfully.';
      _isSavingApiKey = false;
    });
  }

  Future<void> _clearPtvCredentials() async {
    guardedSetState(() => _isSavingApiKey = true);
    await PtvCredentialService.clearUserCredentials();
    guardedSetState(() {
      _ptvDeveloperIdController.clear();
      _ptvApiKeyController.clear();
      _apiKeyStatus = PtvCredentialService.hasBuiltInCredentials
          ? 'Custom PTV credentials removed; using built-in credentials.'
          : 'Custom PTV credentials removed.';
      _isSavingApiKey = false;
    });
  }

  Future<void> _toggleRegion(TransitRegion region, bool enabled) async {
    final regions = {...AppTransitContext.instance.enabledRegions};
    if (enabled) {
      regions.add(region);
    } else {
      if (regions.length == 1) {
        showSnackBar(
          const SnackBar(content: Text('At least one region must be enabled.')),
        );
        return;
      }
      regions.remove(region);
    }
    await AppTransitContext.instance.setEnabledRegions(regions);
    guardedSetState(() {});
  }

  Future<void> _openProviderUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      showSnackBar(
        const SnackBar(content: Text('Could not open developer guide URL')),
      );
      return;
    }
    final launched = await AppUrlLauncher.launchExternalUrl(uri, label: url);
    if (!launched) {
      showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  Future<void> _performUpdate({bool force = false}) async {
    final staticGtfs = _currentServices.staticGtfs;
    if (staticGtfs == null) {
      showSnackBar(
        SnackBar(
          content: Text(
            'Static data import is unavailable for ${_selectedRegion.label}.',
          ),
        ),
      );
      return;
    }
    guardedSetState(() {
      _isUpdating = true;
      _updateStatus =
          'Starting ${_currentServices.attribution.name} static data update...';
      _staticEndpointsUpdated = 0;
      _staticEndpointErrors.clear();
    });

    try {
      await for (final progress in staticGtfs.refreshStaticData(
        StaticImportRequest(force: force),
      )) {
        if (!mounted) return;
        final endpoint = progress.sourceId?.value ?? 'all sources';
        final error = progress.error;
        guardedSetState(() {
          _staticEndpointsUpdated = progress.completed;
          if (error != null && progress.sourceId != null) {
            _staticEndpointErrors.addAll({progress.sourceId!.value: error});
          }
          _updateStatus =
              '${progress.message.isNotEmpty ? progress.message : endpoint} '
              '(${progress.completed}/${progress.total})';
        });
      }
      guardedSetState(() {
        _updateStatus = _staticEndpointErrors.isEmpty
            ? 'Static transport data update completed successfully'
            : 'Static transport data update completed with '
                  '${_staticEndpointErrors.length} error(s)';
        _isUpdating = false;
      });
    } catch (error) {
      guardedSetState(() {
        _updateStatus = 'Update failed: $error';
        _isUpdating = false;
      });
    }
  }

  Future<void> _toggleDebugData(bool value) async {
    await DebugService.setShowDebugData(value);
    guardedSetState(() {});
  }

  Future<void> _toggleNswTrainLink(bool value) async {
    await TransportPreferencesService.setShowNswTrainLink(value);
    guardedSetState(() {});
  }

  Color _apiKeyStatusColor(String status) {
    return isPositiveApiKeyStatus(status) ? Colors.green : Colors.orange;
  }

  void _clearUpdateStatus() {
    guardedSetState(() {
      _updateStatus = null;
      _staticEndpointErrors.clear();
    });
  }

  Future<void> _resetDatabase() async {
    guardedSetState(() {
      _isUpdating = true;
      _updateStatus = 'Resetting database...';
    });

    final reset = await DatabaseAdminService.resetDatabase();
    if (reset) {
      showSnackBar(
        const SnackBar(
          content: Text('Database reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showSnackBar(
        const SnackBar(
          content: Text('Database reset failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
    guardedSetState(() {
      _isUpdating = false;
      _updateStatus = null;
    });
  }

  void _openDebugBrowser(DebugEntityType entityType) {
    DebugNavigation.pushBrowser(
      context,
      entityType: entityType,
      listLoader: _debugListLoader,
      pageLoader: _debugPageLoader,
    );
  }

  Future<void> _navigateToRealtimeMap() async {
    if (_selectedRegion != TransitRegion.nsw) {
      showSnackBar(
        const SnackBar(
          content: Text(
            'The detailed realtime map is currently available only for NSW.',
          ),
        ),
      );
      return;
    }
    await pushPage((context) => const RealtimeMapWidget());
  }

  Future<void> _navigateToSetHomeStop() async {
    await pushPage((context) => const SetHomeStopScreen());
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = _selectedRegion;
    final currentServices = _currentServices;
    final enabledRegions = AppTransitContext.instance.enabledRegions;
    final enabledServices = AppTransitContext.instance.enabledServices;
    final hasBuiltInApiKey = _resolveHasBuiltInApiKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: getContrastingForeground(
          Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transit Regions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...TransitRegion.values.map(
                      (region) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(region.label),
                        subtitle: Text(
                          AppTransitContext.instance
                              .servicesFor(region)
                              .attribution
                              .name,
                        ),
                        value: enabledRegions.contains(region),
                        onChanged: (enabled) =>
                            _toggleRegion(region, enabled ?? false),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TransitRegion>(
                      key: ValueKey(selectedRegion),
                      initialValue: selectedRegion,
                      items: enabledRegions
                          .map(
                            (region) => DropdownMenuItem(
                              value: region,
                              child: Text(region.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (region) async {
                        if (region == null) {
                          return;
                        }
                        await AppTransitContext.instance.setSelectedRegion(
                          region,
                        );
                        _loadApiKeyState();
                        guardedSetState(() {});
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provider Attribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...enabledServices.map(
                      (services) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(services.attribution.name),
                        subtitle: Text(services.attribution.licenseName),
                        trailing: IconButton(
                          tooltip: 'Open ${services.attribution.name} docs',
                          onPressed: () =>
                              _openProviderUrl(services.attribution.url),
                          icon: const Icon(Icons.open_in_new),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Map access card
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Transport Map',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'View real-time vehicle positions on an interactive map',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToRealtimeMap,
                        icon: const Icon(Icons.map),
                        label: const Text('Open Realtime Map'),
                        style: ButtonStyles.elevated(Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...enabledRegions.map(
              (region) => _buildProviderCredentialsCard(
                region,
                hasBuiltInTfnswKey: hasBuiltInApiKey,
              ),
            ),
            // Home Stop Card
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home Stop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set your home stop for quick trip planning',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToSetHomeStop,
                        icon: const Icon(Icons.home),
                        label: const Text('Set Home Stop'),
                        style: ButtonStyles.elevated(Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Transport options card
            if (selectedRegion == TransitRegion.nsw)
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transport Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('NSW TrainLink'),
                        subtitle: const Text(
                          'Show booked regional and interstate train services in the trip creator.',
                        ),
                        value:
                            TransportPreferencesService.showNswTrainLink.value,
                        onChanged: _toggleNswTrainLink,
                      ),
                    ],
                  ),
                ),
              ),
            // Debug toggle (persisted via DebugService)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Developer Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toggle visibility of debug information throughout the app',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: DebugService.showDebugData,
                      builder: (context, showDebug, child) {
                        return SwitchListTile(
                          title: const Text('Show debug data'),
                          value: showDebug,
                          onChanged: _toggleDebugData,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Standalone Debug Pages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openDebugBrowser(DebugEntityType.stop),
                          icon: const Icon(Icons.place),
                          label: const Text('Browse stop debug pages'),
                          style: ButtonStyles.elevated(Colors.blueGrey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openDebugBrowser(DebugEntityType.route),
                          icon: const Icon(Icons.alt_route),
                          label: const Text('Browse route debug pages'),
                          style: ButtonStyles.elevated(Colors.blueGrey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openDebugBrowser(DebugEntityType.trip),
                          icon: const Icon(Icons.route),
                          label: const Text('Browse trip debug pages'),
                          style: ButtonStyles.elevated(Colors.blueGrey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openDebugBrowser(DebugEntityType.vehicle),
                          icon: const Icon(Icons.directions_bus),
                          label: const Text('Browse vehicle debug pages'),
                          style: ButtonStyles.elevated(Colors.blueGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            widget.stopsManagementWidget ??
                StopsManagementWidget(
                  debugPageLoader: _debugPageLoader,
                  debugListLoader: _debugListLoader,
                ),
            widget.stopsSearchWidget ?? const StopsSearchWidget(),
            // Data update / management card
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Provider Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _updateStatus ?? 'No recent updates',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isUpdating)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Updating...'),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: currentServices.supportsStaticImport
                                  ? () => _performUpdate()
                                  : null,
                              icon: const Icon(Icons.download),
                              label: Text(
                                'Update ${currentServices.region.shortLabel} static data',
                              ),
                              style: ButtonStyles.elevated(Colors.green),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: currentServices.supportsStaticImport
                                  ? () => _performUpdate(force: true)
                                  : null,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Force refresh'),
                              style: ButtonStyles.elevated(Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (_staticEndpointsUpdated > 0)
                      Text(
                        'Updated $_staticEndpointsUpdated static endpoint(s).',
                      ),
                    if (_staticEndpointErrors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._staticEndpointErrors.entries.map(
                        (entry) => Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                    if (_updateStatus?.isNotEmpty == true && !_isUpdating)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _clearUpdateStatus,
                          child: const Text('Clear status'),
                        ),
                      ),

                    // Dev-only: full DB reset (delete file and recreate)
                    if (kDebugMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetDatabase,
                            icon: const Icon(Icons.restore),
                            label: const Text('Reset DB (dev)'),
                            style: ButtonStyles.elevated(Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            widget.realtimeInfoWidget ?? const RealtimeInfoWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCredentialsCard(
    TransitRegion region, {
    required bool hasBuiltInTfnswKey,
  }) {
    final services = AppTransitContext.instance.servicesFor(region);
    return Card(
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
      controller: _ptvDeveloperIdController,
      decoration: _credentialDecoration(
        label: 'PTV developer ID',
        hint: 'Enter your PTV developer ID',
      ),
    ),
    const SizedBox(height: 8),
    TextField(
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

  bool _resolveHasUserApiKey() {
    final override = widget.hasUserApiKey;
    if (override != null) {
      return override;
    }
    return ApiKeyService.hasUserApiKey();
  }

  bool _resolveHasBuiltInApiKey() {
    final override = widget.hasBuiltInApiKey;
    if (override != null) {
      return override;
    }
    return ApiKeyService.hasBuiltInApiKey();
  }

  TransitRegion get _selectedRegion =>
      TransportPreferencesService.selectedRegion.value;

  TransitRegionServices get _currentServices =>
      AppTransitContext.instance.currentServices;

  String _capabilitySummary(TransitRegionServices services) {
    final capabilities = <String>[
      'Stops',
      if (services.supportsStaticImport) 'Static GTFS',
      if (services.supportsRealtime) 'Realtime',
      if (services.supportsDepartures) 'Departures',
      if (services.supportsJourneyPlanning) 'Journey planning',
      if (services.supportsDisruptions) 'Disruptions',
    ];
    return capabilities.join(' • ');
  }
}
