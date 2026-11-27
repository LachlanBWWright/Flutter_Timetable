part of '../new_trip.dart';

extension _StationCatalog on _NewTripScreenState {
  Future<void> _loadAllModes() async {
    _applySearchFilter();
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
      animationDuration: Duration.zero,
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
        if (!_isSearching) clearFocus(_searchFocusNode);
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

  bool get _usesRegionalStopSearch => !widget.skipInitialLoad;

  bool get _canUseNswStopsMap =>
      _draftRegion == TransitRegion.nsw ||
      (AppTransitContext.instance.enabledRegions.length == 1 &&
          AppTransitContext.instance.selectedRegion == TransitRegion.nsw);

  void _applySearchFilter() {
    if (widget.skipInitialLoad) {
      guardedSetState(() {});
      return;
    }
    if (_showMapView && !_canUseNswStopsMap) _showMapView = false;
    _searchDebounce?.cancel();
    _stopSearchCancellation?.cancel();
    unawaited(_stopSearchSubscription?.cancel());
    final generation = ++_searchGeneration;
    final query = keyController.text.trim();
    final region = (_manualBuilderEnabled || _interchanges.isNotEmpty)
        ? _draftRegion
        : null;
    final tabKind = _currentTab.kind;
    guardedSetState(() {
      _regionalSearchResults = [];
      _isLoading = false;
      _isRegionalSearchLoading = true;
      _regionalSearchFailed = false;
      _stopSearchSnapshot = const RegionalStopSearchSnapshot(
        loading: {TransitRegion.nsw},
      );
    });
    if (_showMapView) return;
    if (query.isEmpty) {
      unawaited(_searchEnabledRegionStops(query, generation, region, tabKind));
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        unawaited(
          _searchEnabledRegionStops(query, generation, region, tabKind),
        );
      });
    }
  }

  void _retryRegionalStopSearch() => _applySearchFilter();

  void _cancelStopSearch() {
    _searchDebounce?.cancel();
    _stopSearchCancellation?.cancel();
    unawaited(_stopSearchSubscription?.cancel());
    guardedSetState(() {
      _stopSearchSnapshot = _stopSearchSnapshot.stopped();
      _isRegionalSearchLoading = false;
    });
  }

  bool _isSearchCurrent(
    String query,
    int generation,
    TransitRegion? region,
    _TripCreatorTabKind tabKind,
  ) =>
      mounted &&
      generation == _searchGeneration &&
      query == keyController.text.trim() &&
      region ==
          ((_manualBuilderEnabled || _interchanges.isNotEmpty)
              ? _draftRegion
              : null) &&
      tabKind == _currentTab.kind;

  Future<void> _searchEnabledRegionStops(
    String query,
    int generation,
    TransitRegion? region,
    _TripCreatorTabKind tabKind,
  ) async {
    if (!_isSearchCurrent(query, generation, region, tabKind)) return;
    final token = StopSearchCancellation();
    _stopSearchCancellation = token;
    final repository =
        widget.stopSearchRepository ??
        RegionalStopsSearchRepository(
          enabledServices: () => region == null
              ? AppTransitContext.instance.enabledServices
              : [AppTransitContext.instance.servicesFor(region)],
        );
    _stopSearchSubscription = repository
        .watchStops(
          query,
          browse: query.isEmpty,
          cancellation: token,
          limit: 2000,
          sourcesForRegion: (region) => region == TransitRegion.nsw
              ? _currentTab.endpoints
                    .map((endpoint) => TransitSourceId(endpoint.key))
                    .toList()
              : null,
        )
        .listen(
          (snapshot) {
            if (!_isSearchCurrent(query, generation, region, tabKind)) return;
            final stations = snapshot.stops
                .where((stop) => stop.supportsMode(_currentMode))
                .map(
                  (stop) => Station(
                    name: stop.name,
                    id: stop.ref.stopId,
                    transitRef: stop.ref,
                    mode: stop.mode ?? _currentMode,
                    stopCode: stop.stopCode,
                    stopDesc: stop.description,
                    platformCode: stop.platformCode,
                    latitude: stop.latitude,
                    longitude: stop.longitude,
                  ),
                )
                .toList();
            guardedSetState(() {
              _stopSearchSnapshot = snapshot;
              _regionalSearchResults = stations;
              _isRegionalSearchLoading = snapshot.isLoading;
              _regionalSearchFailed =
                  snapshot.errors.isNotEmpty && snapshot.stops.isEmpty;
              switch (tabKind) {
                case _TripCreatorTabKind.sydneyTrains:
                  _trainStationList = stations;
                case _TripCreatorTabKind.nswTrainLink:
                  _nswTrainLinkStationList = stations;
                case _TripCreatorTabKind.lightRail:
                  _lightRailStationList = stations;
                case _TripCreatorTabKind.metro:
                  _metroStationList = stations;
                case _TripCreatorTabKind.bus:
                  _busStationList = stations;
                case _TripCreatorTabKind.ferry:
                  _ferryStationList = stations;
              }
            });
            unawaited(_applySorting());
          },
          onError: (Object error, StackTrace stack) {
            if (!_isSearchCurrent(query, generation, region, tabKind)) return;
            if (error is! Exception) {
              Error.throwWithStackTrace(error, stack);
            }
            guardedSetState(() {
              _isRegionalSearchLoading = false;
              _regionalSearchFailed = true;
              _stopSearchSnapshot = RegionalStopSearchSnapshot(
                stops: _stopSearchSnapshot.stops,
                errors: {
                  (region ?? AppTransitContext.instance.selectedRegion): {
                    'search': error.toString(),
                  },
                },
              );
            });
          },
        );
  }
}
