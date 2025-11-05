import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../gtfs/stop.dart';
import '../services/stops_service.dart';
import '../utils/transport_display.dart';

/// Widget for managing and displaying GTFS stops data
class StopsManagementWidget extends StatefulWidget {
  const StopsManagementWidget({super.key});

  @override
  State<StopsManagementWidget> createState() => _StopsManagementWidgetState();
}

class _StopsManagementWidgetState extends State<StopsManagementWidget> {
  Map<String, int> _stopsCount = {};
  Map<TransportMode?, Map<String, int>> _stopsByMode = {};
  int _totalStops = 0;
  bool _isLoading = false;
  String? _error;

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
      final count = await StopsService.getTotalStopsCount();
      final grouped = await StopsService.getStopsCountByEndpoint();

      // Flatten grouped map for any places that still expect endpoint->count
      final flattened = <String, int>{};
      for (final grp in grouped.values) {
        for (final e in grp.entries) {
          flattened[e.key] = e.value;
        }
      }

      setState(() {
        _totalStops = count;
        _stopsByMode = grouped;
        _stopsCount = flattened;
        _isLoading = false;
      });
    } catch (e) {
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
              'This operation requires a valid API key. Continue?'),
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
        // Listen to the update stream and show a progress dialog
        String dialogMessage = 'Preparing update...';
        void Function(void Function())? dialogSetState;

        final stream = StopsService.updateAllStopsFromApi();
        late StreamSubscription subscription;

        subscription = stream.listen((progress) {
          final epLabel = progress.endpoint?.name ?? '';
          final text =
              '${progress.completed}/${progress.total}: ${progress.message ?? epLabel}';
          // Update dialog text if available
          dialogSetState?.call(() {
            dialogMessage = text;
          });
        }, onError: (e) {
          dialogSetState?.call(() {
            dialogMessage = 'Error: $e';
          });
        }, onDone: () async {
          // Close the dialog when done
          try {
            if (mounted) Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}
          await subscription.cancel();
        });

        // Show modal progress dialog (not dismissible)
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              dialogSetState = setState;
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
            });
          },
        );

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
            'Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.save,
                      color: Theme.of(context).colorScheme.primary, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Stops: $_totalStops',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Endpoints: ${_stopsCount.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // refresh button moved to title row above
              ],
            ),

            const SizedBox(height: 8),

            // Wipe data button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _wipeStopsData,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Wipe All Stops Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
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
                  border: Border.all(color: Colors.red[200]!),
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
                  'No stops data found. Load placeholder data to get started.'),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._stopsByMode.entries.map((group) {
          final TransportMode? modeKey = group.key;
          final endpoints = group.value;
          final totalCount =
              endpoints.values.fold(0, (sum, count) => sum + count);

          final displayName = (() {
            if (modeKey != null) {
              // For buses we preserve the distinction between city and regional
              // when the endpoints are exclusively one or the other.
              if (modeKey == TransportMode.bus) {
                final hasRegion =
                    endpoints.keys.any((k) => k.startsWith('regionbuses'));
                final hasCity =
                    endpoints.keys.any((k) => k.startsWith('buses'));
                if (hasRegion && !hasCity) return 'Regional Buses';
                if (hasCity && !hasRegion) return 'City Buses';
              }
              return getDisplayNameForTransportMode(modeKey);
            }
            return 'Other';
          })();

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
                  endpoint.key
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : word)
                      .join(' '),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.stopName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${stop.stopId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (stop.stopLat != 0.0 && stop.stopLon != 0.0)
              Text(
                'Location: ${stop.stopLat.toStringAsFixed(6)}, ${stop.stopLon.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (stop.platformCode != null && stop.platformCode!.isNotEmpty)
              Text(
                'Platform: ${stop.platformCode}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
