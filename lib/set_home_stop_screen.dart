import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'constants/transport_modes.dart';
import 'home_stop/home_stop_mode_tabs.dart';
import 'home_stop/home_stop_station_tab.dart';
import 'services/home_stop_service.dart';
import 'services/location_service.dart';
import 'services/preference_read_failure.dart';
import 'services/station_loader.dart';
import 'utils/guarded_state.dart';
import 'widgets/station_widgets.dart';

class SetHomeStopScreen extends StatefulWidget {
  const SetHomeStopScreen({
    super.key,
    this.skipInitialLoad = false,
    this.initialStations = const [],
    this.initialHomeStop,
    this.homeStopService = const HomeStopService(),
  });

  final bool skipInitialLoad;
  final List<Station> initialStations;
  final String? initialHomeStop;
  final HomeStopService homeStopService;

  @override
  State<SetHomeStopScreen> createState() => _SetHomeStopScreenState();
}

class _SetHomeStopScreenState extends State<SetHomeStopScreen>
    with TickerProviderStateMixin, GuardedState<SetHomeStopScreen> {
  final Map<TransportMode, List<Station>> _stationCatalog = {};
  int _sortGeneration = 0;
  int _loadGeneration = 0;
  String _selectedStationName = '';
  String _selectedStationId = '';
  TransportMode? _selectedStationMode;
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isSaving = false;
  SortMode _sortMode = SortMode.alphabetical;
  final keyController = TextEditingController();
  late FocusNode _searchFocusNode;
  late TabController _tabController;
  TransportMode _currentMode = TransportMode.train;
  String? _currentHomeStop;

  List<Station> _stationsAtOrEmpty(List<List<Station>> results, int index) {
    return results.skip(index).firstOrNull ?? const <Station>[];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    addListenerSafely(_tabController, _onTabChanged);
    addListenerSafely(keyController, _applySearchFilter);

    _searchFocusNode = FocusNode();
    if (widget.skipInitialLoad) {
      _stationCatalog[TransportMode.train] = List<Station>.unmodifiable(
        widget.initialStations,
      );
      _currentHomeStop = widget.initialHomeStop;
      return;
    }
    _loadAllModes();
    _loadCurrentHomeStop();
  }

  Future<void> _loadCurrentHomeStop() async {
    try {
      final homeStop = await widget.homeStopService.load();
      guardedSetState(() {
        _currentHomeStop = homeStop?.name;
      });
    } on PreferenceReadFailure {
      if (!mounted) return;
      showSnackBar(
        const SnackBar(content: Text('Could not load your saved home stop.')),
      );
    }
  }

  Future<void> _loadAllModes() async {
    final generation = ++_loadGeneration;
    guardedSetState(() {
      _isLoading = true;
    });

    final results = await Future.wait([
      loadStationsFromDbForMode(TransportMode.train),
      loadStationsFromDbForMode(TransportMode.lightrail),
      loadStationsFromDbForMode(TransportMode.metro),
      loadStationsFromDbForMode(TransportMode.bus),
      loadStationsFromDbForMode(TransportMode.ferry),
    ]);

    if (!mounted || generation != _loadGeneration) return;

    guardedSetState(() {
      for (var index = 0; index < 5; index++) {
        _stationCatalog[_getTransportModeForIndex(index)] =
            List<Station>.unmodifiable(_stationsAtOrEmpty(results, index));
      }
      _isLoading = false;
    });

    await _applySorting();
  }

  @override
  void dispose() {
    removeListenerSafely(_tabController, _onTabChanged);
    disposeChangeNotifierSafely(_tabController);
    removeListenerSafely(keyController, _applySearchFilter);
    disposeChangeNotifierSafely(keyController);
    disposeFocusNodeSafely(_searchFocusNode);
    try {
      super.dispose();
    } catch (_) {}
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      guardedSetState(() {
        _currentMode = _getTransportModeForIndex(_tabController.index);
      });
      _applySearchFilter();
    }
  }

  TransportMode _getTransportModeForIndex(int index) {
    switch (index) {
      case 0:
        return TransportMode.train;
      case 1:
        return TransportMode.lightrail;
      case 2:
        return TransportMode.metro;
      case 3:
        return TransportMode.bus;
      case 4:
        return TransportMode.ferry;
      default:
        return TransportMode.train;
    }
  }

  void _applySearchFilter() {
    // Filtering is derived from the complete catalog at build time.
    guardedSetState(() {});
  }

  Future<void> _applySorting() async {
    final generation = ++_sortGeneration;
    final requestedMode = _sortMode;
    final position = requestedMode == SortMode.distance
        ? await LocationService.getCurrentLocation()
        : null;
    if (!mounted || generation != _sortGeneration) return;

    guardedSetState(() {
      for (final mode in _stationCatalog.keys.toList()) {
        final stations = _stationCatalog[mode]!;
        final sorted = requestedMode == SortMode.distance && position != null
            ? _sortByDistance(stations, position)
            : (List<Station>.of(stations)
                ..sort((a, b) => a.name.compareTo(b.name)));
        _stationCatalog[mode] = List<Station>.unmodifiable(sorted);
      }
    });
  }

  List<Station> _sortByDistance(List<Station> stations, Position position) {
    final sorted = stations.map((station) {
      final lat = station.latitude;
      final lon = station.longitude;
      if (lat == null || lon == null || !lat.isFinite || !lon.isFinite) {
        return station;
      }
      return station.copyWith(
        distance: LocationService.calculateDistance(
          position.latitude,
          position.longitude,
          lat,
          lon,
        ),
      );
    }).toList();
    double distanceFor(Station station) {
      final lat = station.latitude;
      final lon = station.longitude;
      if (lat == null || lon == null || !lat.isFinite || !lon.isFinite) {
        return double.infinity;
      }
      return station.distance ?? double.infinity;
    }

    sorted.sort((a, b) {
      final distance = distanceFor(a).compareTo(distanceFor(b));
      return distance != 0 ? distance : a.name.compareTo(b.name);
    });
    return sorted;
  }

  void _toggleSort() async {
    guardedSetState(() {
      _sortMode = _sortMode == SortMode.alphabetical
          ? SortMode.distance
          : SortMode.alphabetical;
    });
    await _applySorting();
  }

  void _toggleSearch() {
    guardedSetState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        keyController.clear();
      }
    });
    if (_isSearching) {
      requestFocus(_searchFocusNode);
    }
  }

  void _setStation(Station station) {
    if (_isSaving) return;
    guardedSetState(() {
      _selectedStationName = station.name;
      _selectedStationId = station.transitRef?.storageKey ?? station.id;
      _selectedStationMode = station.mode ?? _currentMode;
    });
  }

  Future<void> _saveHomeStop() async {
    if (_isSaving || _selectedStationName.isEmpty) {
      return;
    }
    final selectedMode = _selectedStationMode;
    if (selectedMode == null) {
      return;
    }

    guardedSetState(() => _isSaving = true);
    try {
      await widget.homeStopService.save(
        HomeStop(
          name: _selectedStationName,
          id: _selectedStationId,
          mode: selectedMode,
        ),
      );
    } catch (_) {
      if (mounted) {
        showSnackBar(
          const SnackBar(
            content: Text('Could not save home stop. Please try again.'),
          ),
        );
      }
      return;
    } finally {
      guardedSetState(() => _isSaving = false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showSnackBar(
        SnackBar(
          content: Text('Home stop set to $_selectedStationName'),
          backgroundColor: Colors.green,
        ),
      );
      popPage();
    }
  }

  List<Station> _getCurrentStationList() {
    final stations = _stationCatalog[_currentMode] ?? const <Station>[];
    final query = keyController.text.trim().toLowerCase();
    return query.isEmpty
        ? stations
        : stations
              .where((station) => station.name.toLowerCase().contains(query))
              .toList(growable: false);
  }

  Widget _buildStationTab() {
    return HomeStopStationTab(
      stationList: _getCurrentStationList(),
      isLoading: _isLoading,
      currentHomeStop: _currentHomeStop,
      selectedStationName: _selectedStationName,
      sortMode: _sortMode,
      onStationSelected: _setStation,
      onClearSelection: () {
        if (_isSaving) return;
        guardedSetState(() {
          _selectedStationName = '';
          _selectedStationId = '';
          _selectedStationMode = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                focusNode: _searchFocusNode,
                controller: keyController,
                decoration: const InputDecoration(
                  hintText: 'Search for a station',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Set Home Stop'),
        actions: [
          if (_selectedStationName.isEmpty) ...[
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
              tooltip: _isSearching ? 'Cancel search' : 'Search stations',
            ),
          ] else
            IconButton(
              onPressed: _isSaving ? null : _saveHomeStop,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              tooltip: 'Save home stop',
            ),
        ],
        bottom: TabBar(controller: _tabController, tabs: homeStopModeTabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (_) => _buildStationTab()),
      ),
    );
  }
}
