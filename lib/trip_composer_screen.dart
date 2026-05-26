import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/utils/button_styles.dart';
import 'package:lbww_flutter/widgets/selected_stops/selected_stops_helpers.dart';
import 'package:lbww_flutter/widgets/selected_stops/selected_stops_parts.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

typedef InterchangeCandidateLoader =
    Future<List<Station>> Function(int insertIndex);
typedef InterchangeInserter = void Function(int insertIndex, Station station);

class TripComposerScreen extends StatefulWidget {
  const TripComposerScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentMode,
    required this.originMode,
    required this.destinationMode,
    required this.selectedLine,
    required this.interchanges,
    required this.manualValidationMessage,
    required this.canSaveManual,
    required this.onLoadInterchangeCandidates,
    required this.onInsertInterchange,
    required this.onRemoveInterchange,
    required this.onMoveInterchange,
    required this.onSaveManual,
  });

  final Station origin;
  final Station destination;
  final TransportMode currentMode;
  final TransportMode? originMode;
  final TransportMode? destinationMode;
  final StopLineMatch? selectedLine;
  final List<Station> interchanges;
  final String? manualValidationMessage;
  final bool canSaveManual;
  final InterchangeCandidateLoader onLoadInterchangeCandidates;
  final InterchangeInserter onInsertInterchange;
  final void Function(int interchangeIndex) onRemoveInterchange;
  final void Function(int interchangeIndex, int delta) onMoveInterchange;
  final VoidCallback onSaveManual;

  @override
  State<TripComposerScreen> createState() => _TripComposerScreenState();
}

class _TripComposerScreenState extends State<TripComposerScreen> {
  late Station _origin;
  late Station _destination;
  late List<Station> _interchanges;

  void _safeSetState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    try {
      setState(update);
    } catch (_) {}
  }

  Future<T?> _pushPageSafe<T>(Route<T> route) async {
    try {
      return await Navigator.of(context).push<T>(route);
    } catch (_) {
      return null;
    }
  }

  Future<List<Station>> _loadInterchangeCandidates(int insertIndex) async {
    try {
      return await widget.onLoadInterchangeCandidates(insertIndex);
    } catch (_) {
      return const <Station>[];
    }
  }

  void _insertInterchange(int insertIndex, Station station) {
    try {
      widget.onInsertInterchange(insertIndex, station);
    } catch (_) {}
  }

  void _notifyRemoveInterchange(int interchangeIndex) {
    try {
      widget.onRemoveInterchange(interchangeIndex);
    } catch (_) {}
  }

  void _notifyMoveInterchange(int interchangeIndex, int delta) {
    try {
      widget.onMoveInterchange(interchangeIndex, delta);
    } catch (_) {}
  }

  Station? _stationAtOrNull(List<Station> stations, int index) {
    if (index < 0 || index >= stations.length) {
      return null;
    }
    try {
      return stations[index];
    } catch (_) {
      return null;
    }
  }

  String _contextLabelSafe(int insertIndex) {
    try {
      return _contextLabel(insertIndex);
    } catch (_) {
      return 'Adding stop';
    }
  }

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    _destination = widget.destination;
    _interchanges = List<Station>.from(widget.interchanges);
  }

  List<Station> get _orderedStops {
    return buildOrderedStops(
      origin: _origin,
      destination: _destination,
      interchanges: _interchanges,
    );
  }

  List<SequenceStopDescriptor> get _descriptors {
    return buildSequenceDescriptors(
      orderedStops: _orderedStops,
      interchangeCount: _interchanges.length,
    );
  }

  bool get _canSaveManual {
    return _interchanges.isNotEmpty && _validationMessage == null;
  }

  String? get _validationMessage {
    if (_interchanges.isEmpty) {
      return 'A manual multi-leg trip needs at least one interchange.';
    }
    return NewTripService.validateManualTrip(
      origin: _origin,
      destination: _destination,
      interchanges: _interchanges,
      fallbackMode: widget.currentMode,
    );
  }

  Future<void> _openStopSelectionPage(int insertIndex) async {
    final selectedStation = await _pushPageSafe<Station>(
      MaterialPageRoute(
        builder: (context) => _InterchangeStopSelectionScreen(
          insertIndex: insertIndex,
          contextLabel: _contextLabelSafe(insertIndex),
          currentMode: widget.currentMode,
          candidatesFuture: _loadInterchangeCandidates(insertIndex),
        ),
      ),
    );

    if (!mounted || selectedStation == null) {
      return;
    }

    _insertInterchange(insertIndex, selectedStation);

    _safeSetState(() {
      if (insertIndex == 0) {
        _interchanges.insert(0, _origin);
        _origin = selectedStation;
      } else if (insertIndex >= _orderedStops.length) {
        _interchanges.add(_destination);
        _destination = selectedStation;
      } else {
        _interchanges.insert(insertIndex - 1, selectedStation);
      }
    });
  }

  void _removeInterchange(int interchangeIndex) {
    _notifyRemoveInterchange(interchangeIndex);
    _safeSetState(() {
      _interchanges.removeAt(interchangeIndex);
    });
  }

  void _moveInterchange(int interchangeIndex, int delta) {
    final newIndex = interchangeIndex + delta;
    if (newIndex < 0 || newIndex >= _interchanges.length) {
      return;
    }
    _notifyMoveInterchange(interchangeIndex, delta);
    _safeSetState(() {
      final updated = List<Station>.from(_interchanges);
      final station = updated.removeAt(interchangeIndex);
      updated.insert(newIndex, station);
      _interchanges = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentMode = resolveAccentMode(
      fallbackMode: widget.currentMode,
      selectedLine: null,
    );
    final accentColor = TransportColors.getColorByTransportMode(accentMode);

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Composer')),
      body: Column(
        children: [
          SelectedStopsSummaryBar(
            origin: _origin,
            destination: _destination,
            currentMode: widget.currentMode,
            originMode: widget.originMode,
            destinationMode: widget.destinationMode,
            selectedLine: null,
            isLoadingLineCandidates: false,
            originLineCount: 0,
            statusMessage: 'Multi-mode manual trip ready',
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onOpenComposer: () {},
            canSaveDirect: false,
            canComposeManual: false,
            allowClearing: false,
          ),
          Expanded(child: _buildSequenceEditor(accentColor)),
          _ComposerActions(
            accentColor: accentColor,
            validationMessage: _validationMessage,
            canSave: _canSaveManual,
            onSave: widget.onSaveManual,
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceEditor(Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual stop chain',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12.0),
          StopSequenceSection(
            descriptors: _descriptors,
            accentColor: accentColor,
            allowAddingInterchanges: true,
            pendingInterchangeInsertIndex: null,
            onAddInterchange: _openStopSelectionPage,
            onRemoveInterchange: _removeInterchange,
            onMoveInterchange: _moveInterchange,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Derived legs',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8.0),
          DerivedLegsSection(
            origin: _origin,
            destination: _destination,
            interchanges: _interchanges,
            fallbackMode: widget.currentMode,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  String _contextLabel(int insertIndex) {
    final orderedStops = _orderedStops;
    final previousStop = _stationAtOrNull(orderedStops, insertIndex - 1);
    final nextStop = _stationAtOrNull(orderedStops, insertIndex);
    if (insertIndex == 0 && orderedStops.isNotEmpty) {
      return 'Adding before ${orderedStops.first.name}';
    }
    if (insertIndex >= orderedStops.length && orderedStops.isNotEmpty) {
      return 'Adding after ${orderedStops.last.name}';
    }
    if (previousStop != null && nextStop != null) {
      return 'Adding between ${previousStop.name} and ${nextStop.name}';
    }
    return 'Adding stop';
  }
}

class _InterchangeStopSelectionScreen extends StatefulWidget {
  const _InterchangeStopSelectionScreen({
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
  State<_InterchangeStopSelectionScreen> createState() =>
      _InterchangeStopSelectionScreenState();
}

class _InterchangeStopSelectionScreenState
    extends State<_InterchangeStopSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  late List<_InterchangeStopTab> _tabs;
  bool _isSearching = false;
  SortMode _sortMode = SortMode.distance;

  void _safeSetState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    try {
      setState(update);
    } catch (_) {}
  }

  void _disposeSearchController() {
    try {
      _searchController.dispose();
    } catch (_) {}
  }

  void _disposeSearchFocusNode() {
    try {
      _searchFocusNode.dispose();
    } catch (_) {}
  }

  void _disposeTabController() {
    try {
      _tabController.dispose();
    } catch (_) {}
  }

  void _addPostFrameCallback(void Function(Duration) callback) {
    try {
      WidgetsBinding.instance.addPostFrameCallback(callback);
    } catch (_) {}
  }

  void _requestSearchFocus() {
    try {
      _searchFocusNode.requestFocus();
    } catch (_) {}
  }

  void _clearSearchFocus() {
    try {
      _searchFocusNode.unfocus();
    } catch (_) {}
  }

  void _clearSearchText() {
    try {
      _searchController.clear();
    } catch (_) {}
  }

  void _handleSearchChanged(String _) {
    _safeSetState(() {});
  }

  _InterchangeStopTab? _tabAtOrNull(int index) {
    if (index < 0 || index >= _tabs.length) {
      return null;
    }
    try {
      return _tabs[index];
    } catch (_) {
      return null;
    }
  }

  TransportMode _currentTabMode() {
    return _tabAtOrNull(_tabController.index)?.mode ?? widget.currentMode;
  }

  void _popSelectedStation(Station station) {
    try {
      Navigator.of(context).pop(station);
    } catch (_) {}
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
    try {
      _disposeSearchController();
      _disposeSearchFocusNode();
      _disposeTabController();
      try {
        super.dispose();
      } catch (_) {}
    } finally {}
  }

  void _toggleSearch() {
    _safeSetState(() {
      if (_searchController.text.isEmpty) {
        _isSearching = !_isSearching;
        if (_isSearching) {
          _addPostFrameCallback((_) {
            if (mounted) {
              _requestSearchFocus();
            }
          });
        } else {
          _clearSearchFocus();
        }
      } else {
        _clearSearchText();
      }
    });
  }

  void _toggleSort() {
    _safeSetState(() {
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

class _ComposerActions extends StatelessWidget {
  const _ComposerActions({
    required this.accentColor,
    required this.validationMessage,
    required this.canSave,
    required this.onSave,
  });

  final Color accentColor;
  final String? validationMessage;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: accentColor.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validationMessage != null) ...[
              Text(
                validationMessage ?? '',
                style: TextStyle(color: Colors.orange.shade300),
              ),
              const SizedBox(height: 10.0),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSave ? onSave : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Trip'),
                style: ButtonStyles.elevated(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
