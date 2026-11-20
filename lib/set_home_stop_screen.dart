import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'constants/transport_modes.dart';
import 'home_stop/home_stop_mode_tabs.dart';
import 'home_stop/home_stop_station_tab.dart';
import 'nsw/wrappers/gtfs_endpoint_catalog.dart';
import 'services/home_stop_service.dart';
import 'services/location_service.dart';
import 'services/preference_read_failure.dart';
import 'services/transport_preferences_service.dart';
import 'transit/transit.dart';
import 'utils/guarded_state.dart';
import 'widgets/station_widgets.dart';
import 'widgets/stops/stop_search_status.dart';
import 'widgets/stops/stops_search_repository.dart';

class SetHomeStopScreen extends StatefulWidget {
  const SetHomeStopScreen({
    super.key,
    this.skipInitialLoad = false,
    this.initialStations = const [],
    this.initialHomeStop,
    this.homeStopService = const HomeStopService(),
    this.stopSearchRepository,
  });

  final bool skipInitialLoad;
  final List<Station> initialStations;
  final String? initialHomeStop;
  final HomeStopService homeStopService;
  final RegionalStopsSearchRepository? stopSearchRepository;

  @override
  State<SetHomeStopScreen> createState() => _SetHomeStopScreenState();
}

class _SetHomeStopScreenState extends State<SetHomeStopScreen>
    with TickerProviderStateMixin, GuardedState<SetHomeStopScreen> {
  final Map<TransportMode, List<Station>> _stationCatalog = {};
  int _sortGeneration = 0;
  int _loadGeneration = 0;
  Timer? _searchDebounce;
  StreamSubscription<RegionalStopSearchSnapshot>? _searchSubscription;
  StopSearchCancellation? _searchCancellation;
  RegionalStopSearchSnapshot _searchSnapshot =
      const RegionalStopSearchSnapshot();
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
    addListenerSafely(
      AppTransitContext.instance.enabledRegionsListenable,
      _applySearchFilter,
    );
    addListenerSafely(
      AppTransitContext.instance.selectedRegionListenable,
      _applySearchFilter,
    );
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
    _applySearchFilter();
  }

  void _cancelLoading() {
    _searchDebounce?.cancel();
    _searchCancellation?.cancel();
    unawaited(_searchSubscription?.cancel());
    guardedSetState(() {
      _isLoading = false;
      _searchSnapshot = _searchSnapshot.stopped();
    });
  }

  void _startLoading(int generation) {
    if (!mounted || generation != _loadGeneration) return;
    final token = StopSearchCancellation();
    _searchCancellation = token;
    final mode = _currentMode;
    final query = keyController.text.trim();
    final repository =
        widget.stopSearchRepository ??
        RegionalStopsSearchRepository(
          enabledServices: () => AppTransitContext.instance.enabledServices,
        );
    _searchSubscription = repository
        .watchStops(
          query,
          browse: query.isEmpty,
          limit: 2000,
          cancellation: token,
          sourcesForRegion: (region) => region == TransitRegion.nsw
              ? NswGtfsEndpointCatalog.endpointsForMode(
                  mode,
                  includeTrainLink:
                      TransportPreferencesService.showNswTrainLink.value,
                ).map((endpoint) => TransitSourceId(endpoint.key)).toList()
              : null,
        )
        .listen(
          (snapshot) {
            if (!mounted || generation != _loadGeneration) return;
            final stations = snapshot.stops
                .where((stop) => stop.supportsMode(mode))
                .map(
                  (stop) => Station(
                    name: stop.name,
                    id: stop.ref.stopId,
                    transitRef: stop.ref,
                    mode: stop.mode ?? mode,
                    stopCode: stop.stopCode,
                    stopDesc: stop.description,
                    latitude: stop.latitude,
                    longitude: stop.longitude,
                  ),
                )
                .toList();
            guardedSetState(() {
              _stationCatalog[mode] = stations;
              _isLoading = snapshot.isLoading;
              _searchSnapshot = snapshot;
            });
            unawaited(_applySorting());
          },
          onError: (Object error, StackTrace stack) {
            if (!mounted || generation != _loadGeneration) return;
            if (error is! Exception) Error.throwWithStackTrace(error, stack);
            guardedSetState(() {
              _isLoading = false;
              _searchSnapshot = RegionalStopSearchSnapshot(
                stops: _searchSnapshot.stops,
                errors: {
                  AppTransitContext.instance.selectedRegion: {
                    'search': error.toString(),
                  },
                },
              );
            });
          },
        );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCancellation?.cancel();
    unawaited(_searchSubscription?.cancel());
    removeListenerSafely(
      AppTransitContext.instance.enabledRegionsListenable,
      _applySearchFilter,
    );
    removeListenerSafely(
      AppTransitContext.instance.selectedRegionListenable,
      _applySearchFilter,
    );
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
    if (widget.skipInitialLoad) {
      guardedSetState(() {});
      return;
    }
    _searchDebounce?.cancel();
    _searchCancellation?.cancel();
    unawaited(_searchSubscription?.cancel());
    final generation = ++_loadGeneration;
    guardedSetState(() {
      _isLoading = true;
      _searchSnapshot = const RegionalStopSearchSnapshot(
        loading: {TransitRegion.nsw},
      );
    });
    if (keyController.text.trim().isEmpty) {
      _startLoading(generation);
    } else {
      _searchDebounce = Timer(
        const Duration(milliseconds: 300),
        () => _startLoading(generation),
      );
    }
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
      isLoading: _isLoading && _getCurrentStationList().isEmpty,
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
      body: Column(
        children: [
          StopSearchStatus(
            snapshot: _searchSnapshot,
            onCancel: _cancelLoading,
            onRetry: _applySearchFilter,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(5, (_) => _buildStationTab()),
            ),
          ),
        ],
      ),
    );
  }
}
