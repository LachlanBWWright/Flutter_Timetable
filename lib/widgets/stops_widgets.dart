import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/debug_page_loader.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../gtfs/stop.dart';
import '../services/stops_service.dart';
import '../utils/button_styles.dart';
import '../utils/stops_widget_utils.dart';

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

class _StopsManagementWidgetState extends State<StopsManagementWidget> {
  Map<String, int> _stopsCount = {};
  Map<TransportMode?, Map<String, int>> _stopsByMode = {};
  int _totalStops = 0;
  bool _isLoading = false;
  String? _error;
  late final DebugEntityResolver _debugResolver = DebugEntityResolver();
  late final DebugEntityPageLoader _debugPageLoader =
      widget.debugPageLoader ??
      DebugPageLoaderCoordinator(resolver: _debugResolver).load;
  late final DebugEntityListPageLoader _debugListLoader =
      widget.debugListLoader ??
      DebugEntityListLoader(resolver: _debugResolver).load;

  @override
  void initState() {
    super.initState();
    _loadStopsData();
  }

  Future<void> _loadStopsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final count =
          await (widget.getTotalStopsCount ??
              StopsService.getTotalStopsCount)();
      final grouped =
          await (widget.getStopsCountByEndpoint ??
              StopsService.getStopsCountByEndpoint)();

      if (!mounted) return;

      final flattened = flattenStopsCountByEndpoint(grouped);

      setState(() {
        _totalStops = count;
        _stopsByMode = grouped;
        _stopsCount = flattened;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFromApi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Show warning dialog first
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update from API'),
          content: const Text(
            'This will fetch real stops data from all API endpoints and may take several minutes. '
            'This operation requires a valid API key. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show the progress dialog first, then start the stream once the
        // dialog's setState is available — this ensures no progress events
        // are silently dropped while dialogSetState is still null.
        String dialogMessage = 'Preparing update...';
        void Function(void Function())? dialogSetState;
        StreamSubscription<StopsUpdateProgress>? subscription;

        if (!mounted) return;

        // Show modal progress dialog (not dismissible)
        final dialogFuture = showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                dialogSetState = setDialogState;
                return AlertDialog(
                  title: const Text('Updating stops from API'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(dialogMessage),
                    ],
                  ),
                );
              },
            );
          },
        );

        // Wait one frame so the dialog is built and dialogSetState is populated
        // before starting the stream.
        await Future.microtask(() {});

        subscription = StopsService.updateAllStopsFromApi().listen(
          (progress) {
            final epLabel = progress.endpoint?.key ?? '';
            final text =
                '${progress.completed}/${progress.total}: ${progress.message ?? epLabel}';
            dialogSetState?.call(() {
              dialogMessage = text;
            });
          },
          onError: (e) {
            dialogSetState?.call(() {
              dialogMessage = 'Error: $e';
            });
          },
          onDone: () async {
            try {
              if (mounted) Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
            await subscription?.cancel();
          },
        );

        await dialogFuture;

        // After dialog closes, refresh counts
        await _loadStopsData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stops data updated from API successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating from API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _wipeStopsData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wipe Stops Data'),
        content: const Text(
          'This will permanently delete all stops data from the local database. '
          'You will need to reload the data from API or placeholders afterwards. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ButtonStyles.elevatedSmall(Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await StopsService.wipeAllStopsData();
        await _loadStopsData(); // Refresh the counts

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All stops data wiped successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error wiping stops data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
                    label: const Text('Update from API'),
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
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red[200] ?? Colors.red),
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

          return ExpansionTile(
            leading: Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: (() {
                  if (modeKey != null) {
                    return TransportColors.getColorByTransportMode(modeKey);
                  }
                  return Colors.grey;
                })(),
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
                    color: Colors.grey[200],
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

/// Widget for searching and displaying stops
class StopsSearchWidget extends StatefulWidget {
  const StopsSearchWidget({super.key});

  @override
  State<StopsSearchWidget> createState() => _StopsSearchWidgetState();
}

class _StopsSearchWidgetState extends State<StopsSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Stop> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchStops(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await StopsService.searchStops(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Stops',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter stop name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchStops('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchStops,
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty &&
                _searchController.text.isNotEmpty)
              const Center(
                child: Text(
                  'No stops found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (_searchResults.isNotEmpty)
              ..._buildSearchResults(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    return _searchResults.map((stop) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.stopName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${stop.stopId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (stop.stopLat != 0.0 && stop.stopLon != 0.0)
              Text(
                'Location: ${stop.stopLat.toStringAsFixed(6)}, ${stop.stopLon.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (stop.platformCode?.isNotEmpty == true)
              Text(
                'Platform: ${stop.platformCode}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
