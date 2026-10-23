import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';

import 'debug/debug_entity_type.dart';
import 'debug/debug_navigation.dart';
import 'debug/debug_page_loader.dart';
import 'services/api_key_service.dart';
import 'services/app_appearance_service.dart';
import 'services/app_url_launcher.dart';
import 'services/database_admin_service.dart';
import 'services/debug_service.dart';
import 'services/transport_preferences_service.dart';
import 'set_home_stop_screen.dart';
import 'transit/registry/region_feature_flags.dart';
import 'transit/transit.dart';
import 'utils/button_styles.dart';
import 'utils/color_utils.dart';
import 'utils/guarded_state.dart';
import 'utils/settings_screen_utils.dart';
import 'victoria/services/ptv_credentials.dart';
import 'widgets/realtime_map_widget.dart';
import 'widgets/realtime_widgets.dart';
import 'widgets/stops_widgets.dart';

part 'settings/credentials_section.dart';
part 'settings/data_management_section.dart';
part 'settings/navigation_sections.dart';
part 'settings/preferences_sections.dart';
part 'settings/save_actions.dart';

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
  bool _isSavingPreference = false;
  int _preferenceFormGeneration = 0;
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

  Color _apiKeyStatusColor(String status) {
    return isPositiveApiKeyStatus(status) ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegion = _selectedRegion;
    final enabledRegions = AppTransitContext.instance.enabledRegions;
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
            _buildRegionsSection(),
            _buildAppearanceSection(),
            _buildAttributionSection(),
            // Map access section
            _buildMapSection(),
            ...enabledRegions.map(
              (region) => _buildProviderCredentialsCard(
                region,
                hasBuiltInTfnswKey: hasBuiltInApiKey,
              ),
            ),
            // Home Stop section
            _buildHomeStopSection(),
            // Transport options section
            if (selectedRegion == TransitRegion.nsw)
              _buildTransportOptionsSection(),
            // Debug toggle (persisted via DebugService)
            _buildDeveloperOptionsSection(),
            widget.stopsManagementWidget ??
                StopsManagementWidget(
                  debugPageLoader: _debugPageLoader,
                  debugListLoader: _debugListLoader,
                ),
            widget.stopsSearchWidget ?? const StopsSearchWidget(),
            // Data update / management section
            _buildDataManagementSection(),
            widget.realtimeInfoWidget ?? const RealtimeInfoWidget(),
          ],
        ),
      ),
    );
  }

  Widget _settingsSection({
    required EdgeInsetsGeometry margin,
    required Widget child,
  }) {
    return Padding(padding: margin, child: child);
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
