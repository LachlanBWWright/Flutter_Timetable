part of '../new_trip.dart';

extension _StationCatalog on _NewTripScreenState {
  Future<void> _loadAllModes() async {
    if (!mounted) return;

    guardedSetState(() {
      _isLoading = true;
    });

    final results = await Future.wait([
      loadStationsFromDbForEndpoints([StopsEndpoint.sydneytrains]),
      if (TransportPreferencesService.showNswTrainLink.value)
        loadStationsFromDbForEndpoints([StopsEndpoint.nswtrains])
      else
        Future.value(<Station>[]),
      loadStationsFromDbForEndpoints(
        NewTripService.getEndpointsForMode(TransportMode.lightrail),
      ),
      loadStationsFromDbForEndpoints(
        NewTripService.getEndpointsForMode(TransportMode.metro),
      ),
      loadStationsFromDbForEndpoints(
        NewTripService.getEndpointsForMode(TransportMode.bus),
      ),
      loadStationsFromDbForEndpoints(
        NewTripService.getEndpointsForMode(TransportMode.ferry),
      ),
    ]);

    if (!mounted) return;

    guardedSetState(() {
      _trainStationList = _stationsAtOrEmpty(results, 0);
      _nswTrainLinkStationList = _stationsAtOrEmpty(results, 1);
      _lightRailStationList = _stationsAtOrEmpty(results, 2);
      _metroStationList = _stationsAtOrEmpty(results, 3);
      _busStationList = _stationsAtOrEmpty(results, 4);
      _ferryStationList = _stationsAtOrEmpty(results, 5);
      _isLoading = false;
    });

    await _applySorting();

    final hasAnyStops =
        _trainStationList.isNotEmpty ||
        _nswTrainLinkStationList.isNotEmpty ||
        _busStationList.isNotEmpty ||
        _ferryStationList.isNotEmpty ||
        _lightRailStationList.isNotEmpty ||
        _metroStationList.isNotEmpty;

    if (!hasAnyStops && mounted) {
      showSnackBar(
        const SnackBar(
          content: Text(
            'No stops found in database. Please update static transport data from Settings.',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onTabChanged() {
    final oldTabKind = _currentTabKind;
    _currentTabKind = _currentTab.kind;

    if (oldTabKind != _currentTabKind) {
      final reloadOriginLines = _isLoadingLineCandidates;
      final reloadSharedLines = _isResolvingSharedLines;
      _invalidateDraftLookups();
      _applySearchFilter();
      _restartDraftLookups(reloadOriginLines, reloadSharedLines);
    }
  }

  void _onTransportPreferencesChanged() {
    final reloadOriginLines = _isLoadingLineCandidates;
    final reloadSharedLines = _isResolvingSharedLines;
    _invalidateDraftLookups();
    final previousKind = _currentTabKind;
    final nextTabs = _buildTabs();
    final nextIndex = nextTabs.indexWhere((tab) => tab.kind == previousKind);

    removeListenerSafely(_tabController, _onTabChanged);
    disposeChangeNotifierSafely(_tabController);
    _tabs = nextTabs;
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: nextIndex == -1 ? 0 : nextIndex,
    );
    _currentTabKind = _tabs.isNotEmpty
        ? (_itemAtOrNull(_tabs, _tabController.index)?.kind ??
              _TripCreatorTabKind.sydneyTrains)
        : _TripCreatorTabKind.sydneyTrains;
    addListenerSafely(_tabController, _onTabChanged);
    if (TransportPreferencesService.showNswTrainLink.value &&
        _nswTrainLinkStationList.isEmpty) {
      _loadAllModes();
    }

    _applySearchFilter();
    _restartDraftLookups(reloadOriginLines, reloadSharedLines);
  }

  void _toggleSearch() {
    _invalidateDraftLookups();
    guardedSetState(() {
      if (keyController.text.isEmpty) {
        _isSearching = !_isSearching;
        if (_isSearching) {
          addPostFrameCallbackSafely((_) {
            if (mounted) {
              requestFocus(_searchFocusNode);
            }
          });
        } else {
          clearFocus(_searchFocusNode);
        }
      } else {
        keyController.clear();
      }
    });
    _applySearchFilter();
  }

  Future<void> _toggleSort() async {
    if (_manualBuilderEnabled && _pendingInterchangeInsertIndex != null) {
      return;
    }

    if (_sortMode == SortMode.alphabetical) {
      final error = await LocationService.checkAndRequestLocationAvailability();
      if (error != null) {
        showSnackBar(SnackBar(content: Text(error)));
        guardedSetState(() {
          _sortMode = SortMode.alphabetical;
        });
        return;
      }

      guardedSetState(() {
        _sortMode = SortMode.distance;
      });
    } else {
      guardedSetState(() {
        _sortMode = SortMode.alphabetical;
      });
    }

    await _applySorting();
  }

  void _openMap() {
    if (!_canUseNswStopsMap) {
      showSnackBar(
        const SnackBar(
          content: Text('The stop map is available while browsing NSW stops.'),
        ),
      );
      return;
    }
    if (_manualBuilderEnabled) {
      showSnackBar(
        const SnackBar(
          content: Text('Use the list to add manual interchanges on a line.'),
        ),
      );
      return;
    }

    guardedSetState(() {
      _showMapView = !_showMapView;
    });
    _applySearchFilter();
  }

  List<Station> _getStationListForTab(_TripCreatorTab tab) {
    switch (tab.kind) {
      case _TripCreatorTabKind.sydneyTrains:
        return _trainStationList;
      case _TripCreatorTabKind.nswTrainLink:
        return _nswTrainLinkStationList;
      case _TripCreatorTabKind.lightRail:
        return _lightRailStationList;
      case _TripCreatorTabKind.metro:
        return _metroStationList;
      case _TripCreatorTabKind.bus:
        return _busStationList;
      case _TripCreatorTabKind.ferry:
        return _ferryStationList;
    }
  }

  List<Station> _getStationListForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.train:
        return [
          ..._trainStationList,
          if (TransportPreferencesService.showNswTrainLink.value)
            ..._nswTrainLinkStationList,
        ];
      case TransportMode.lightrail:
        return _lightRailStationList;
      case TransportMode.metro:
        return _metroStationList;
      case TransportMode.bus:
        return _busStationList;
      case TransportMode.ferry:
        return _ferryStationList;
    }
  }

  Future<void> _applySorting() async {
    final tab = _currentTab;
    final tabKind = tab.kind;
    final generation = (_sortGenerations[tabKind] ?? 0) + 1;
    _sortGenerations[tabKind] = generation;
    final sortMode = _sortMode;
    final stations = _getStationListForTab(tab);
    final sortedStations = sortMode == SortMode.alphabetical
        ? NewTripService.sortAlphabetically(stations)
        : await NewTripService.sortByDistance(stations);

    if (!mounted ||
        _sortGenerations[tabKind] != generation ||
        sortMode != _sortMode ||
        !identical(stations, _getStationListForTab(tab))) {
      return;
    }
    guardedSetState(() {
      switch (tabKind) {
        case _TripCreatorTabKind.sydneyTrains:
          _trainStationList = sortedStations;
          break;
        case _TripCreatorTabKind.nswTrainLink:
          _nswTrainLinkStationList = sortedStations;
          break;
        case _TripCreatorTabKind.lightRail:
          _lightRailStationList = sortedStations;
          break;
        case _TripCreatorTabKind.metro:
          _metroStationList = sortedStations;
          break;
        case _TripCreatorTabKind.bus:
          _busStationList = sortedStations;
          break;
        case _TripCreatorTabKind.ferry:
          _ferryStationList = sortedStations;
          break;
      }
    });
  }

  String _persistedStopId(Station station) =>
      station.transitRef?.storageKey ?? station.id;

  bool get _usesRegionalStopSearch =>
      AppTransitContext.instance.enabledRegions.length > 1 ||
      (_draftRegion ?? AppTransitContext.instance.selectedRegion) !=
          TransitRegion.nsw;

  bool get _canUseNswStopsMap =>
      _draftRegion == TransitRegion.nsw ||
      (AppTransitContext.instance.enabledRegions.length == 1 &&
          AppTransitContext.instance.selectedRegion == TransitRegion.nsw);

  void _applySearchFilter() {
    if (_showMapView && !_canUseNswStopsMap) {
      _showMapView = false;
    }
    _searchDebounce?.cancel();
    final generation = ++_searchGeneration;
    final query = keyController.text.trim();
    final shouldSearch =
        query.length >= 2 &&
        _isSearching &&
        !_showMapView &&
        _usesRegionalStopSearch;
    guardedSetState(() {
      _regionalSearchResults = [];
      _isRegionalSearchLoading = shouldSearch;
      _regionalSearchFailed = false;
    });
    if (!shouldSearch) return;
    final region = _draftRegion;
    final tabKind = _currentTab.kind;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_searchEnabledRegionStops(query, generation, region, tabKind));
    });
  }

  void _retryRegionalStopSearch() {
    final query = keyController.text.trim();
    if (query.length < 2 ||
        !_isSearching ||
        _showMapView ||
        !_usesRegionalStopSearch) {
      return;
    }
    _searchDebounce?.cancel();
    final generation = ++_searchGeneration;
    unawaited(
      _searchEnabledRegionStops(
        query,
        generation,
        _draftRegion,
        _currentTab.kind,
      ),
    );
  }

  bool _isSearchCurrent(
    String query,
    int generation,
    TransitRegion? region,
    _TripCreatorTabKind tabKind,
  ) =>
      mounted &&
      generation == _searchGeneration &&
      _isSearching &&
      query == keyController.text.trim() &&
      region == _draftRegion &&
      tabKind == _currentTab.kind;

  Future<void> _searchEnabledRegionStops(
    String query,
    int generation,
    TransitRegion? region,
    _TripCreatorTabKind tabKind,
  ) async {
    if (!_isSearchCurrent(query, generation, region, tabKind)) return;

    final services = region == null
        ? AppTransitContext.instance.enabledServices
        : [AppTransitContext.instance.servicesFor(region)];
    guardedSetState(() {
      _isRegionalSearchLoading = true;
      _regionalSearchFailed = false;
    });
    final results = await Future.wait(
      services.map((service) async {
        try {
          return (
            stops: await service.stops.searchStops(
              StopSearchRequest(query: query, limit: 50),
            ),
            failed: false,
          );
        } on Exception {
          return (stops: const <TransitStop>[], failed: true);
        }
      }),
    );
    if (!_isSearchCurrent(query, generation, region, tabKind)) return;
    final allProvidersFailed =
        results.isNotEmpty && results.every((result) => result.failed);
    final seen = <String>{};
    final stations =
        results
            .expand((result) => result.stops)
            .where((stop) => seen.add(stop.ref.storageKey))
            .map(
              (stop) => Station(
                name: stop.name,
                id: stop.ref.stopId,
                transitRef: stop.ref,
                mode: stop.mode,
                stopCode: stop.stopCode,
                stopDesc: stop.description,
                platformCode: stop.platformCode,
                latitude: stop.latitude,
                longitude: stop.longitude,
              ),
            )
            .toList(growable: false)
          ..sort((left, right) => left.name.compareTo(right.name));
    guardedSetState(() {
      _regionalSearchResults = stations;
      _isRegionalSearchLoading = false;
      _regionalSearchFailed = allProvidersFailed;
    });
  }
}
