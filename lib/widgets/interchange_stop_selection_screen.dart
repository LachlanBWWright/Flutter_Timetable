// ignore_for_file: catch_runtime_throw_sources, catch_inferred_throwing_calls

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

class InterchangeStopSelectionScreen extends StatefulWidget {
  const InterchangeStopSelectionScreen({
    super.key,
    required this.insertIndex,
    required this.contextLabel,
    required this.currentMode,
    required this.candidatesFuture,
  });

  final int insertIndex;
  final String contextLabel;
  final TransportMode currentMode;
  final Future<List<Station>> candidatesFuture;

  @override
  State<InterchangeStopSelectionScreen> createState() =>
      _InterchangeStopSelectionScreenState();
}

class _InterchangeStopSelectionScreenState
    extends State<InterchangeStopSelectionScreen>
    with
        SingleTickerProviderStateMixin,
        GuardedState<InterchangeStopSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  late List<_InterchangeStopTab> _tabs;
  bool _isSearching = false;
  SortMode _sortMode = SortMode.distance;

  void _disposeSearchController() {
    disposeChangeNotifierSafely(_searchController);
  }

  void _disposeSearchFocusNode() {
    disposeFocusNodeSafely(_searchFocusNode);
  }

  void _disposeTabController() {
    disposeChangeNotifierSafely(_tabController);
  }

  void _addPostFrameCallback(void Function(Duration) callback) {
    addPostFrameCallbackSafely(callback);
  }

  void _clearSearchText() {
    _searchController.clear();
  }

  void _handleSearchChanged(String _) {
    guardedSetState(() {});
  }

  _InterchangeStopTab? _tabAtOrNull(int index) {
    if (index < 0 || index >= _tabs.length) {
      return null;
    }
    return _tabs.elementAtOrNull(index);
  }

  TransportMode _currentTabMode() {
    return _tabAtOrNull(_tabController.index)?.mode ?? widget.currentMode;
  }

  void _popSelectedStation(Station station) {
    popPage(station);
  }

  @override
  void initState() {
    super.initState();
    _tabs = _buildInterchangeTabs();
    final initialIndex = _tabs.indexWhere(
      (tab) => tab.mode == widget.currentMode,
    );
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
  }

  @override
  void dispose() {
    _disposeSearchController();
    _disposeSearchFocusNode();
    _disposeTabController();
    super.dispose();
  }

  void _toggleSearch() {
    guardedSetState(() {
      if (_searchController.text.isEmpty) {
        _isSearching = !_isSearching;
        if (_isSearching) {
          _addPostFrameCallback((_) {
            if (mounted) {
              requestFocus(_searchFocusNode);
            }
          });
        } else {
          clearFocus(_searchFocusNode);
        }
      } else {
        _clearSearchText();
      }
    });
  }

  void _toggleSort() {
    guardedSetState(() {
      _sortMode = _sortMode == SortMode.alphabetical
          ? SortMode.distance
          : SortMode.alphabetical;
    });
  }

  List<Station> _filteredStations(List<Station> stations) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<Station>.from(stations)
        : stations
              .where((station) => station.name.toLowerCase().contains(query))
              .toList();

    if (_sortMode == SortMode.distance) {
      filtered.sort((a, b) {
        final aDistance =
            a.nearbyAnchorDistance ?? a.distance ?? double.infinity;
        final bDistance =
            b.nearbyAnchorDistance ?? b.distance ?? double.infinity;
        final comparison = aDistance.compareTo(bDistance);
        return comparison == 0 ? a.name.compareTo(b.name) : comparison;
      });
      return filtered;
    }

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  List<Station> _stationsForTab(List<Station> stations, TransportMode mode) {
    return stations
        .where((station) => _resolvedModeForStation(station) == mode)
        .toList();
  }

  String _emptyMessageForMode(List<Station> allStations, TransportMode mode) {
    final hasAnyForMode = allStations.any(
      (station) => _resolvedModeForStation(station) == mode,
    );
    if (!hasAnyForMode) {
      return 'No stops available for this mode.';
    }
    return 'No stops found.';
  }

  TransportMode _resolvedModeForStation(Station station) {
    return station.mode ?? widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = TransportColors.getColorByTransportMode(
      _currentTabMode(),
    );

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for a station',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _handleSearchChanged,
              )
            : const Text('Select Stop'),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: _toggleSort,
              icon: Icon(
                _sortMode == SortMode.alphabetical
                    ? Icons.sort_by_alpha
                    : Icons.near_me,
              ),
              tooltip: _sortMode == SortMode.alphabetical
                  ? 'Sort by distance'
                  : 'Sort alphabetically',
            ),
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            tooltip: _isSearching ? 'Cancel search' : 'Search',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => tab.tab).toList(),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: accentColor.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add_location_alt, color: accentColor),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.contextLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Station>>(
              future: widget.candidatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allStations = snapshot.data ?? const <Station>[];
                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final modeStations = _stationsForTab(allStations, tab.mode);
                    final stations = _filteredStations(modeStations);
                    if (stations.isEmpty) {
                      return Center(
                        child: Text(
                          _emptyMessageForMode(allStations, tab.mode),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stations.any(
                          (station) => station.isPreferredNearby,
                        ))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              12.0,
                              16.0,
                              4.0,
                            ),
                            child: Text(
                              'Best nearby',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        Expanded(
                          child: EnhancedStationList(
                            listItems: stations,
                            sortMode: _sortMode,
                            mode: tab.mode,
                            setStation: (stationName, stationId, mode) {
                              final selected = stations.firstWhereOrNull(
                                (station) => station.id == stationId,
                              );
                              if (selected != null) {
                                _popSelectedStation(selected);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InterchangeStopTab {
  const _InterchangeStopTab({required this.mode, required this.tab});

  final TransportMode mode;
  final Tab tab;
}

List<_InterchangeStopTab> _buildInterchangeTabs() {
  return const [
    _InterchangeStopTab(
      mode: TransportMode.train,
      tab: Tab(
        icon: Icon(
          Icons.directions_train,
          color: Color.fromARGB(255, 255, 97, 35),
        ),
      ),
    ),
    _InterchangeStopTab(
      mode: TransportMode.lightrail,
      tab: Tab(icon: Icon(Icons.tram, color: Color.fromARGB(255, 255, 82, 82))),
    ),
    _InterchangeStopTab(
      mode: TransportMode.metro,
      tab: Tab(icon: Icon(Icons.subway, color: TransportColors.metro)),
    ),
    _InterchangeStopTab(
      mode: TransportMode.bus,
      tab: Tab(
        icon: Icon(
          Icons.directions_bus,
          color: Color.fromARGB(255, 82, 186, 255),
        ),
      ),
    ),
    _InterchangeStopTab(
      mode: TransportMode.ferry,
      tab: Tab(
        icon: Icon(
          Icons.directions_ferry,
          color: Color.fromARGB(255, 68, 240, 91),
        ),
      ),
    ),
  ];
}
