import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/debug_page_loader.dart';

import '../../constants/transport_colors.dart';
import '../../constants/transport_modes.dart';
import '../../services/new_trip_service.dart';
import '../../services/stops_service.dart';
import '../../utils/button_styles.dart';
import '../../utils/guarded_state.dart';
import '../../utils/stops_widget_utils.dart';

part 'stops_management_actions.dart';

/// Widget for managing and displaying GTFS stops data
class StopsManagementWidget extends StatefulWidget {
  final Future<int> Function()? getTotalStopsCount;
  final Future<Map<TransportMode?, Map<String, int>>> Function()?
  getStopsCountByEndpoint;
  final DebugEntityPageLoader? debugPageLoader;
  final DebugEntityListPageLoader? debugListLoader;

  const StopsManagementWidget({
    super.key,
    this.getTotalStopsCount,
    this.getStopsCountByEndpoint,
    this.debugPageLoader,
    this.debugListLoader,
  });

  @override
  State<StopsManagementWidget> createState() => _StopsManagementWidgetState();
}

class _StopsManagementWidgetState extends State<StopsManagementWidget>
    with GuardedState<StopsManagementWidget> {
  Map<String, int> _stopsCount = {};
  Map<TransportMode?, Map<String, int>> _stopsByMode = {};
  int _totalStops = 0;
  bool _isLoading = false;
  String? _error;
  late final DebugEntityPageLoader _debugPageLoader =
      widget.debugPageLoader ?? buildDebugEntityPageLoader();
  late final DebugEntityListPageLoader _debugListLoader =
      widget.debugListLoader ?? buildDebugEntityListLoader();

  Future<int> _getTotalStopsCount() async {
    final loader = widget.getTotalStopsCount;
    if (loader != null) {
      try {
        return await loader.call();
      } catch (_) {
        return 0;
      }
    }
    return StopsService.getTotalStopsCount();
  }

  Future<Map<TransportMode?, Map<String, int>>>
  _getStopsCountByEndpoint() async {
    final loader = widget.getStopsCountByEndpoint;
    if (loader != null) {
      try {
        return await loader.call();
      } catch (_) {
        return const <TransportMode?, Map<String, int>>{};
      }
    }
    return StopsService.getStopsCountByEndpoint();
  }

  Future<T?> _showSafeDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    try {
      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
    } catch (_) {
      return null;
    }
  }

  void _safePop<T>([T? result, bool rootNavigator = false]) {
    final navigator = Navigator.maybeOf(context, rootNavigator: rootNavigator);
    if (navigator?.canPop() ?? false) {
      try {
        navigator?.pop(result);
      } catch (_) {}
    }
  }

  void _updateDialogState(StateSetter? setDialogState, VoidCallback update) {
    if (setDialogState == null) {
      return;
    }
    try {
      setDialogState.call(update);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadStopsData();
  }

  Future<void> _loadStopsData() async {
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    await runAsyncGuarded(
      () async {
        final count = await _getTotalStopsCount();
        final grouped = await _getStopsCountByEndpoint();

        if (!mounted) return;

        final flattened = flattenStopsCountByEndpoint(grouped);

        guardedSetState(() {
          _totalStops = count;
          _stopsByMode = grouped;
          _stopsCount = flattened;
          _isLoading = false;
        });
      },
      onError: (error, _) {
        if (!mounted) return;
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stops Database Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadStopsData,
                  tooltip: 'Refresh data',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary card — use theme colors for improved contrast
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.save,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Stops: $_totalStops',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Endpoints: ${_stopsCount.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons — stacked and full width for better accessibility
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _updateFromApi,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Update static transport data'),
                    style: ButtonStyles.elevated(Colors.orange),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => DebugNavigation.pushBrowser(
                      context,
                      entityType: DebugEntityType.stop,
                      listLoader: _debugListLoader,
                      pageLoader: _debugPageLoader,
                    ),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Browse stop debug pages'),
                    style: ButtonStyles.elevated(Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _wipeStopsData,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Wipe All Stops Data'),
                    style: ButtonStyles.elevated(Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else if (_stopsCount.isNotEmpty)
              _buildEndpointsList()
            else
              const Text(
                'No stops data found. Load placeholder data to get started.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointsList() {
    // endpointGroups are now provided by the service as `_stopsByMode`.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stops by Transport Mode:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._stopsByMode.entries.map((group) {
          final TransportMode? modeKey = group.key;
          final endpoints = group.value;
          final totalCount = endpoints.values.fold(
            0,
            (sum, count) => sum + count,
          );

          final displayName = displayNameForStopsModeGroup(modeKey, endpoints);
          final modeColor = modeKey == null
              ? Colors.grey
              : TransportColors.getColorByTransportMode(modeKey);

          return ExpansionTile(
            leading: Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: modeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              '$displayName ($totalCount stops)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: endpoints.entries.map((endpoint) {
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                title: Text(
                  formatEndpointDisplayName(endpoint.key),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    endpoint.value.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
