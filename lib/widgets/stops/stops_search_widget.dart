import 'package:flutter/material.dart';

import '../../transit/transit.dart';
import '../../utils/guarded_state.dart';
import 'stops_search_controller.dart';
import 'stops_search_repository.dart';

/// Widget for searching and displaying stops
class StopsSearchWidget extends StatefulWidget {
  const StopsSearchWidget({super.key, this.searchStops});

  /// Optional repository callback for embedding the search with another source.
  final Future<List<TransitStop>> Function(String query)? searchStops;

  @override
  State<StopsSearchWidget> createState() => _StopsSearchWidgetState();
}

class _StopsSearchWidgetState extends State<StopsSearchWidget>
    with GuardedState<StopsSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  late final RegionalStopsSearchRepository _regionalSearchRepository =
      RegionalStopsSearchRepository(
        enabledServices: () => AppTransitContext.instance.enabledServices,
      );
  late final StopsSearchController _searchStateController;

  StopsSearchState get _searchState => _searchStateController.state;

  @override
  void initState() {
    super.initState();
    _searchStateController = StopsSearchController(
      repository: widget.searchStops ?? _regionalSearchRepository.searchStops,
    )..addListener(_onSearchStateChanged);
    AppTransitContext.instance.enabledRegionsListenable.addListener(
      _onEnabledRegionsChanged,
    );
  }

  @override
  void didUpdateWidget(covariant StopsSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchStops != widget.searchStops) {
      _searchStateController.updateRepository(
        widget.searchStops ?? _regionalSearchRepository.searchStops,
        _searchController.text,
      );
    }
  }

  void _onSearchStateChanged() {
    guardedSetState(() {});
  }

  void _onEnabledRegionsChanged() {
    if (widget.searchStops == null) {
      _startSearch(_searchController.text);
    }
  }

  void _startSearch(String rawQuery) {
    _searchStateController.search(rawQuery);
  }

  void _clearSearch() {
    _searchController.clear();
    _startSearch('');
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
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: _startSearch,
            ),
            const SizedBox(height: 16),
            if (_searchState.isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchState.hasFailed)
              Center(
                child: Column(
                  children: [
                    const Text('Unable to search stops. Please try again.'),
                    TextButton(
                      onPressed: () =>
                          _searchStateController.retry(_searchController.text),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_searchState.results.isEmpty &&
                _searchController.text.isNotEmpty)
              const Center(
                child: Text(
                  'No stops found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (_searchState.results.isNotEmpty)
              ..._buildSearchResults(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    return _searchState.results.map((stop) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${stop.ref.region.shortLabel} • ${stop.ref.provider.label}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            Text(
              'ID: ${stop.ref.stopId}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'Source: ${stop.ref.sourceId.value}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (stop.latitude != null && stop.longitude != null)
              Text(
                'Location: ${stop.latitude!.toStringAsFixed(6)}, ${stop.longitude!.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            if (stop.platformCode?.isNotEmpty == true)
              Text(
                'Platform: ${stop.platformCode}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchStateController
      ..removeListener(_onSearchStateChanged)
      ..dispose();
    AppTransitContext.instance.enabledRegionsListenable.removeListener(
      _onEnabledRegionsChanged,
    );
    disposeChangeNotifierSafely(_searchController);
    super.dispose();
  }
}
