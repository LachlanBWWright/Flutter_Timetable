// ignore_for_file: catch_inferred_throwing_calls, catch_async_error_sources, catch_runtime_throw_sources

import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/new_trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen>
    with TickerProviderStateMixin, GuardedState<NewTripScreen> {
  T? _itemAtOrNull<T>(List<T> items, int index) {
    if (index < 0 || index >= items.length) {
      return null;
    }
    return items.skip(index).firstOrNull;
  }

  List<Station> _stationsAtOrEmpty(List<dynamic> results, int index) {
    final value = _itemAtOrNull(results, index);
    return value is List<Station> ? value : const <Station>[];
  }

  List<Station> _trainStationList = [];
  List<Station> _nswTrainLinkStationList = [];
  List<Station> _busStationList = [];
  List<Station> _ferryStationList = [];
  List<Station> _lightRailStationList = [];
  List<Station> _metroStationList = [];

  Station? _originStation;
  TransportMode? _originMode;
  Station? _destinationStation;
  TransportMode? _destinationMode;

  bool _isSearching = false;
  bool _isLoading = false;
  bool _showMapView = false;
  bool _isResolvingSharedLines = false;
  bool _isLoadingLineCandidates = false;
  bool _isLoadingInterchangeCandidates = false;
  bool _filterDestinationsToSameLine = false;
  SortMode _sortMode = SortMode.alphabetical;

  final keyController = TextEditingController();
  late FocusNode _searchFocusNode;
  final AppDatabase _db = AppDatabase();
  final TripLineService _tripLineService = TripLineService.instance;
  late TabController _tabController;
  late List<_TripCreatorTab> _tabs;
  _TripCreatorTabKind _currentTabKind = _TripCreatorTabKind.sydneyTrains;
  TransportMode get _currentMode => _currentTab.mode;
  _TripCreatorTab get _currentTab {
    return _itemAtOrNull(_tabs, _tabController.index) ??
        (_tabs.isNotEmpty ? _tabs.first : _fallbackTripCreatorTab);
  }

  List<StopLineMatch> _sharedLines = [];
  List<StopLineMatch> _originLineCandidates = [];
  List<Station> _sameLineDestinationStations = [];
  StopLineMatch? _selectedLine;
  bool _manualBuilderEnabled = false;
  List<Station> _interchanges = [];
  int? _pendingInterchangeInsertIndex;
  List<Station> _manualCandidateStations = [];

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
    addListenerSafely(_tabController, _onTabChanged);
    addListenerSafely(
      TransportPreferencesService.showNswTrainLink,
      _onTransportPreferencesChanged,
    );
    addListenerSafely(keyController, _applySearchFilter);
    _searchFocusNode = FocusNode();
    _loadAllModes();
  }

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
      loadStationsFromDbForMode(TransportMode.lightrail),
      loadStationsFromDbForMode(TransportMode.metro),
      loadStationsFromDbForMode(TransportMode.bus),
      loadStationsFromDbForMode(TransportMode.ferry),
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

  @override
  void dispose() {
    removeListenerSafely(
      TransportPreferencesService.showNswTrainLink,
      _onTransportPreferencesChanged,
    );
    removeListenerSafely(_tabController, _onTabChanged);
    disposeChangeNotifierSafely(_tabController);
    removeListenerSafely(keyController, _applySearchFilter);
    disposeChangeNotifierSafely(keyController);
    disposeFocusNodeSafely(_searchFocusNode);
    super.dispose();
  }

  void _onTabChanged() {
    final oldTabKind = _currentTabKind;
    _currentTabKind = _currentTab.kind;

    if (oldTabKind != _currentTabKind) {
      guardedSetState(() {});
      if (_filterDestinationsToSameLine &&
          _originStation != null &&
          _destinationStation == null) {
        _loadSameLineDestinationStations();
      }
    }
  }

  void _onTransportPreferencesChanged() {
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

    guardedSetState(() {});
  }

  Future<void> setStation(
    String stationName,
    String id,
    TransportMode? selectedMode,
  ) async {
    final mode = await StopsService.resolveModeForStopId(
      id,
      preferredMode: selectedMode,
    );
    if (!mounted || mode == null) {
      return;
    }

    final station = _resolveStation(id, stationName, mode);
    if (station == null) {
      return;
    }

    if (_manualBuilderEnabled && _pendingInterchangeInsertIndex != null) {
      _insertInterchange(station);
      return;
    }

    if (_originStation == null) {
      guardedSetState(() {
        _originStation = station;
        _originMode = mode;
        keyController.clear();
      });
      _resetManualDraft(clearSharedLines: true, keepDestination: false);
      await _loadOriginLineCandidates();
      return;
    }

    if (_destinationStation == null) {
      guardedSetState(() {
        _destinationStation = station;
        _destinationMode = mode;
        keyController.clear();
        _showMapView = false;
      });
      await _resolveSharedLines();
      return;
    }

    if (!mounted) return;
    showSnackBar(
      const SnackBar(
        content: Text('Clear a selected stop before choosing another one.'),
      ),
    );
  }

  Station? _resolveStation(String id, String stationName, TransportMode mode) {
    for (final station in _getStationListForMode(mode)) {
      if (station.id == id) {
        return station;
      }
    }

    return Station(name: stationName, id: id);
  }

  void _clearOrigin() {
    guardedSetState(() {
      _originStation = null;
      _originMode = null;
    });
    _resetManualDraft(clearSharedLines: true, keepDestination: false);
  }

  void _clearDestination() {
    guardedSetState(() {
      _destinationStation = null;
      _destinationMode = null;
    });
    _resetManualDraft(clearSharedLines: true);
  }

  void _resetManualDraft({
    bool clearSharedLines = false,
    bool keepDestination = true,
  }) {
    if (!keepDestination) {
      _destinationStation = null;
      _destinationMode = null;
    }

    guardedSetState(() {
      _manualBuilderEnabled = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      _filterDestinationsToSameLine = false;
      _sameLineDestinationStations = [];
      if (clearSharedLines) {
        _sharedLines = [];
        _originLineCandidates = [];
        _selectedLine = null;
      }
    });
  }

  Future<void> _loadOriginLineCandidates() async {
    final origin = _originStation;
    final originMode = _originMode;
    if (origin == null || originMode == null) {
      return;
    }

    guardedSetState(() {
      _isLoadingLineCandidates = true;
      _originLineCandidates = [];
      _sameLineDestinationStations = [];
    });

    final lines = await _tripLineService.getLinesForStop(
      origin.id,
      mode: originMode,
      allowBuild: true,
    );
    if (!mounted) return;
    guardedSetState(() {
      _originLineCandidates = lines;
      _isLoadingLineCandidates = false;
    });
    if (_filterDestinationsToSameLine) {
      await _loadSameLineDestinationStations();
    }
  }

  Future<void> _toggleSameLineDestinationFilter(bool value) async {
    guardedSetState(() {
      _filterDestinationsToSameLine = value;
      if (!value) {
        _sameLineDestinationStations = [];
      }
      keyController.clear();
    });

    if (value) {
      await _loadSameLineDestinationStations();
    }
  }

  Future<void> _loadSameLineDestinationStations() async {
    final origin = _originStation;
    if (origin == null || _originLineCandidates.isEmpty) {
      guardedSetState(() {
        _sameLineDestinationStations = [];
      });
      return;
    }

    guardedSetState(() {
      _isLoadingLineCandidates = true;
      _sameLineDestinationStations = [];
    });

    final tabEndpointKeys = _currentTab.endpoints
        .map((endpoint) => endpoint.key)
        .toSet();
    final matchingLines = _originLineCandidates.where((line) {
      return line.mode == _currentMode &&
          tabEndpointKeys.contains(line.endpointKey);
    });
    final stopsById = <String, Station>{};

    for (final line in matchingLines) {
      final lineStops = await _tripLineService.getStopsForLine(
        line.lineId,
        line.mode,
        allowBuild: true,
      );
      for (final lineStop in lineStops) {
        if (lineStop.stopId == origin.id) {
          continue;
        }
        stopsById.addAll({lineStop.stopId: lineStop.toStation()});
      }
    }

    if (!mounted) return;
    final stations = stopsById.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    guardedSetState(() {
      _sameLineDestinationStations = stations;
      _isLoadingLineCandidates = false;
    });
  }

  Future<void> _resolveSharedLines() async {
    final origin = _originStation;
    final destination = _destinationStation;
    final originMode = _originMode;
    final destinationMode = _destinationMode;

    if (origin == null || destination == null) {
      return;
    }

    if (origin.id == destination.id) {
      showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same stop.'),
          backgroundColor: Colors.orange,
        ),
      );
      guardedSetState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    if (originMode == null ||
        destinationMode == null ||
        originMode != destinationMode) {
      guardedSetState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    guardedSetState(() {
      _isResolvingSharedLines = true;
      _sharedLines = [];
      _selectedLine = null;
      _manualBuilderEnabled = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
    });

    final sharedLines = await _tripLineService.findSharedLines(
      origin.id,
      destination.id,
      mode: originMode,
      allowBuild: true,
    );
    if (!mounted) return;

    guardedSetState(() {
      _sharedLines = sharedLines;
      _selectedLine = sharedLines.isEmpty ? null : sharedLines.first;
      _isResolvingSharedLines = false;
    });
  }

  void _toggleSearch() {
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
        _applySearchFilter();
      }
    });
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
  }

  Future<void> _saveDirectTrip() async {
    final origin = _originStation;
    final destination = _destinationStation;
    if (origin == null || destination == null || origin.id == destination.id) {
      return;
    }

    final sharedMode = _originMode != null && _originMode == _destinationMode
        ? _originMode
        : null;

    await _persistJourney(
      JourneysCompanion(
        origin: drift.Value(origin.name),
        originId: drift.Value(origin.id),
        destination: drift.Value(destination.name),
        destinationId: drift.Value(destination.id),
        tripType: drift.Value(SavedTripType.direct.storageValue),
        mode: sharedMode != null
            ? drift.Value(sharedMode.id)
            : const drift.Value.absent(),
      ),
      successMessage: 'Trip saved.',
    );
  }

  Future<void> _saveManualTrip() async {
    final origin = _originStation;
    final destination = _destinationStation;
    final selectedLine = _selectedLine;
    final validationMessage = _manualValidationMessage;
    if (origin == null || destination == null) {
      return;
    }
    if (validationMessage != null) {
      showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    final definition = ManualTripDefinition(
      legs: await NewTripService.buildManualTripLegsWithResolvedMetadata(
        origin: origin,
        destination: destination,
        interchanges: _interchanges,
        fallbackMode: _originMode ?? _currentMode,
      ),
    );

    final firstLeg = definition.legs.isNotEmpty ? definition.legs.first : null;
    final firstLegLineId = firstLeg?.lineId;
    final firstLegLineName = firstLeg?.lineName;
    final selectedLineId = selectedLine?.lineId;
    final selectedLineName = selectedLine?.lineName;

    await _persistJourney(
      JourneysCompanion(
        origin: drift.Value(origin.name),
        originId: drift.Value(origin.id),
        destination: drift.Value(destination.name),
        destinationId: drift.Value(destination.id),
        tripType: drift.Value(SavedTripType.manualMultiLeg.storageValue),
        mode: drift.Value(
          firstLeg?.mode.id ?? selectedLine?.mode.id ?? _currentMode.id,
        ),
        lineId: firstLegLineId != null
            ? drift.Value(firstLegLineId)
            : selectedLineId != null
            ? drift.Value(selectedLineId)
            : const drift.Value.absent(),
        lineName: firstLegLineName != null
            ? drift.Value(firstLegLineName)
            : selectedLineName != null
            ? drift.Value(selectedLineName)
            : const drift.Value.absent(),
        legsJson: drift.Value(definition.toLegsJson()),
      ),
      successMessage: 'Manual trip saved.',
    );
  }

  Future<void> _persistJourney(
    JourneysCompanion companion, {
    required String successMessage,
  }) async {
    final inserted = await JourneyService.insertJourney(_db, companion);
    if (!mounted) return;
    if (inserted) {
      _clearAllSelections();
      showSnackBar(SnackBar(content: Text(successMessage)));
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    showSnackBar(const SnackBar(content: Text('Error saving trip')));
  }

  void _clearAllSelections() {
    guardedSetState(() {
      _originStation = null;
      _originMode = null;
      _destinationStation = null;
      _destinationMode = null;
      _sharedLines = [];
      _originLineCandidates = [];
      _sameLineDestinationStations = [];
      _selectedLine = null;
      _manualBuilderEnabled = false;
      _filterDestinationsToSameLine = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
      _showMapView = false;
    });
  }

  Future<void> _startInterchangeSelection(int insertIndex) async {
    final selectedLine = _selectedLine;
    final orderedStops = _orderedStops;
    if (selectedLine == null || orderedStops.length < 2) {
      return;
    }
    if (insertIndex <= 0 || insertIndex >= orderedStops.length) {
      return;
    }

    final previousStop = _itemAtOrNull(orderedStops, insertIndex - 1);
    final nextStop = _itemAtOrNull(orderedStops, insertIndex);
    if (previousStop == null || nextStop == null) {
      return;
    }

    guardedSetState(() {
      _pendingInterchangeInsertIndex = insertIndex;
      _isLoadingInterchangeCandidates = true;
      _manualCandidateStations = [];
      _showMapView = false;
    });

    _setTabForMode(selectedLine.mode);

    final rankedStops = await _tripLineService.rankStopsForLine(
      lineId: selectedLine.lineId,
      mode: selectedLine.mode,
      anchorStopIds: [previousStop.id, nextStop.id],
      excludedStopIds: orderedStops.map((stop) => stop.id),
      allowBuild: false,
    );

    if (!mounted) return;
    guardedSetState(() {
      _manualCandidateStations = rankedStops
          .map((lineStop) => lineStop.toStation())
          .toList();
      _isLoadingInterchangeCandidates = false;
    });
  }

  void _insertInterchange(Station station) {
    final selectedLine = _selectedLine;
    final insertIndex = _pendingInterchangeInsertIndex;
    if (selectedLine == null || insertIndex == null) {
      return;
    }
    final orderedStops = _orderedStops;
    if (insertIndex <= 0 || insertIndex >= orderedStops.length) {
      return;
    }

    final interchange = station.copyWith(
      lineId: selectedLine.lineId,
      lineName: selectedLine.lineName,
    );

    guardedSetState(() {
      _interchanges.insert(insertIndex - 1, interchange);
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
    });
  }

  void _removeInterchange(int interchangeIndex) {
    guardedSetState(() {
      _interchanges.removeAt(interchangeIndex);
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
    });
  }

  void _moveInterchange(int interchangeIndex, int delta) {
    final newIndex = interchangeIndex + delta;
    if (newIndex < 0 || newIndex >= _interchanges.length) {
      return;
    }

    guardedSetState(() {
      final updated = List<Station>.from(_interchanges);
      final station = updated.removeAt(interchangeIndex);
      updated.insert(newIndex, station);
      _interchanges = updated;
    });
  }

  void _setTabForMode(TransportMode mode) {
    final index = _tabs.indexWhere((tab) => tab.mode == mode);

    if (index != -1 && _tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  List<Station> get _orderedStops {
    final origin = _originStation;
    final destination = _destinationStation;
    if (origin == null || destination == null) {
      return const [];
    }
    return NewTripService.buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: _interchanges,
    );
  }

  bool get _canSaveDirect {
    return canSaveDirectTrip(
      origin: _originStation,
      destination: _destinationStation,
    );
  }

  String? get _manualValidationMessage {
    return manualTripValidationMessage(
      manualBuilderEnabled: _manualBuilderEnabled || _interchanges.isNotEmpty,
      origin: _originStation,
      destination: _destinationStation,
      interchanges: _interchanges,
      fallbackMode: _originMode ?? _currentMode,
    );
  }

  bool get _canSaveManual =>
      _interchanges.isNotEmpty && _manualValidationMessage == null;

  List<StopLineMatch> get _currentTabOriginLineCandidates {
    final tabEndpointKeys = _currentTab.endpoints
        .map((endpoint) => endpoint.key)
        .toSet();
    return _originLineCandidates.where((line) {
      return line.mode == _currentMode &&
          tabEndpointKeys.contains(line.endpointKey);
    }).toList();
  }

  Future<void> _saveTrip() async {
    if (_interchanges.isEmpty) {
      await _saveDirectTrip();
      return;
    }

    await _saveManualTrip();
  }

  String? get _statusMessage {
    return buildNewTripStatusMessage(
      origin: _originStation,
      destination: _destinationStation,
      isResolvingSharedLines: _isResolvingSharedLines,
      manualBuilderEnabled: _manualBuilderEnabled,
      pendingInterchangeInsertIndex: _pendingInterchangeInsertIndex,
      orderedStops: _orderedStops,
      manualValidationMessage: _manualValidationMessage,
      selectedLine: _selectedLine,
      canSaveDirect: _canSaveDirect,
      sharedLines: _sharedLines,
      originMode: _originMode,
      destinationMode: _destinationMode,
    );
  }

  List<Station> _getCurrentStationList() {
    return _getStationListForTab(_currentTab);
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
    final stations = _getCurrentStationList();
    final sortedStations = _sortMode == SortMode.alphabetical
        ? NewTripService.sortAlphabetically(stations)
        : await NewTripService.sortByDistance(stations);

    guardedSetState(() {
      switch (_currentTab.kind) {
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

  void _applySearchFilter() {
    guardedSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewTripAppBar(
        isSearching: _isSearching,
        searchController: keyController,
        searchFocusNode: _searchFocusNode,
        onSearch: (_) {},
        onToggleSearch: _toggleSearch,
        onSaveTrip: null,
        canSave: false,
        onOpenMap: _openMap,
        onToggleSort: _toggleSort,
        sortMode: _sortMode,
        showMapView: _showMapView,
        tabController: _tabController,
        tabs: _tabs.map((tab) => tab.tab).toList(),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map(_buildStationTab).toList(),
            ),
          ),
          SelectedStopsWidget(
            origin: _originStation,
            destination: _destinationStation,
            currentMode: _currentMode,
            originMode: _originMode,
            destinationMode: _destinationMode,
            isLoadingLineCandidates: _isLoadingLineCandidates,
            originLineCandidates: _currentTabOriginLineCandidates,
            isSameLineFilterEnabled: _filterDestinationsToSameLine,
            onSameLineFilterChanged: _originStation == null
                ? null
                : _toggleSameLineDestinationFilter,
            selectedLine: _selectedLine,
            interchanges: _interchanges,
            isResolvingSharedLines: _isResolvingSharedLines,
            isManualBuilderEnabled: _manualBuilderEnabled,
            pendingInterchangeInsertIndex: _pendingInterchangeInsertIndex,
            statusMessage: _statusMessage,
            manualValidationMessage: _manualValidationMessage,
            onClearOrigin: _clearOrigin,
            onClearDestination: _clearDestination,
            onSaveDirect: _saveTrip,
            onSaveManual: _canSaveManual ? _saveManualTrip : null,
            onAddInterchange: _startInterchangeSelection,
            onRemoveInterchange: _removeInterchange,
            onMoveInterchange: _moveInterchange,
            canSaveDirect: _canSaveDirect,
            canSaveManual: _canSaveManual,
          ),
        ],
      ),
    );
  }

  Widget _buildStationTab(_TripCreatorTab tab) {
    final mode = tab.mode;
    if (_showMapView && !_manualBuilderEnabled) {
      final modeDisplayName = NewTripService.getModeDisplayName(mode);
      return StopsMapWidget(
        key: ValueKey('map_${tab.kind}'),
        transportMode: mode,
        modeDisplayName: modeDisplayName,
        endpoints: tab.endpoints,
        embedded: true,
        onStopSelected: (name, id) {
          setStation(name, id, mode);
        },
        onClose: () {
          guardedSetState(() {
            _showMapView = false;
          });
        },
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedLine = _selectedLine;

    if (_isLoadingInterchangeCandidates &&
        _manualBuilderEnabled &&
        _pendingInterchangeInsertIndex != null &&
        selectedLine != null &&
        mode == selectedLine.mode) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSelectingSameLineDestination =
        !_manualBuilderEnabled &&
        _filterDestinationsToSameLine &&
        _originStation != null &&
        _destinationStation == null;
    final baseList =
        _manualBuilderEnabled &&
            _pendingInterchangeInsertIndex != null &&
            selectedLine != null &&
            mode == selectedLine.mode
        ? _manualCandidateStations
        : isSelectingSameLineDestination
        ? _sameLineDestinationStations
        : _getStationListForTab(tab);

    final displayList = filterStationsByQuery(baseList, keyController.text);

    if (displayList.isEmpty) {
      final emptyMessage =
          _manualBuilderEnabled &&
              _pendingInterchangeInsertIndex != null &&
              selectedLine != null &&
              mode == selectedLine.mode
          ? buildInterchangeEmptyMessage()
          : isSelectingSameLineDestination
          ? 'No same-line stops found.'
          : 'No stops found.';
      return Center(child: Text(emptyMessage));
    }

    return Column(
      children: [
        Expanded(
          child: EnhancedStationList(
            listItems: displayList,
            setStation: setStation,
            sortMode: _sortMode,
            mode: mode,
          ),
        ),
      ],
    );
  }
}

enum _TripCreatorTabKind {
  sydneyTrains,
  nswTrainLink,
  lightRail,
  metro,
  bus,
  ferry,
}

class _TripCreatorTab {
  const _TripCreatorTab({
    required this.kind,
    required this.mode,
    required this.tab,
    required this.endpoints,
  });

  final _TripCreatorTabKind kind;
  final TransportMode mode;
  final Tab tab;
  final List<StopsEndpoint> endpoints;
}

const _TripCreatorTab _fallbackTripCreatorTab = _TripCreatorTab(
  kind: _TripCreatorTabKind.sydneyTrains,
  mode: TransportMode.train,
  endpoints: <StopsEndpoint>[StopsEndpoint.sydneytrains],
  tab: Tab(
    icon: Icon(Icons.directions_train, color: Color.fromARGB(255, 255, 97, 35)),
  ),
);

List<_TripCreatorTab> _buildTabs() {
  return [
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.sydneyTrains,
      mode: TransportMode.train,
      endpoints: [StopsEndpoint.sydneytrains],
      tab: Tab(
        icon: Icon(
          Icons.directions_train,
          color: Color.fromARGB(255, 255, 97, 35),
        ),
      ),
    ),
    if (TransportPreferencesService.showNswTrainLink.value)
      const _TripCreatorTab(
        kind: _TripCreatorTabKind.nswTrainLink,
        mode: TransportMode.train,
        endpoints: [StopsEndpoint.nswtrains],
        tab: Tab(
          icon: Icon(Icons.confirmation_number, color: Colors.deepOrange),
        ),
      ),
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.lightRail,
      mode: TransportMode.lightrail,
      endpoints: [
        StopsEndpoint.lightrailInnerwest,
        StopsEndpoint.lightrailNewcastle,
        StopsEndpoint.lightrailCbdandsoutheast,
        StopsEndpoint.lightrailParramatta,
      ],
      tab: Tab(icon: Icon(Icons.tram, color: Color.fromARGB(255, 255, 82, 82))),
    ),
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.metro,
      mode: TransportMode.metro,
      endpoints: [StopsEndpoint.metro],
      tab: Tab(icon: Icon(Icons.subway, color: TransportColors.metro)),
    ),
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.bus,
      mode: TransportMode.bus,
      endpoints: [
        StopsEndpoint.buses,
        StopsEndpoint.busesSbsc006,
        StopsEndpoint.busesGbsc001,
        StopsEndpoint.busesGsbc002,
        StopsEndpoint.busesGsbc003,
        StopsEndpoint.busesGsbc004,
        StopsEndpoint.busesGsbc007,
        StopsEndpoint.busesGsbc008,
        StopsEndpoint.busesGsbc009,
        StopsEndpoint.busesGsbc010,
        StopsEndpoint.busesGsbc014,
        StopsEndpoint.busesOsmbsc001,
        StopsEndpoint.busesOsmbsc002,
        StopsEndpoint.busesOsmbsc003,
        StopsEndpoint.busesOsmbsc004,
        StopsEndpoint.busesOmbsc006,
        StopsEndpoint.busesOmbsc007,
        StopsEndpoint.busesOsmbsc008,
        StopsEndpoint.busesOsmbsc009,
        StopsEndpoint.busesOsmbsc010,
        StopsEndpoint.busesOsmbsc011,
        StopsEndpoint.busesOsmbsc012,
        StopsEndpoint.busesNisc001,
        StopsEndpoint.busesReplacementBus,
      ],
      tab: Tab(
        icon: Icon(
          Icons.directions_bus,
          color: Color.fromARGB(255, 82, 186, 255),
        ),
      ),
    ),
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.ferry,
      mode: TransportMode.ferry,
      endpoints: [StopsEndpoint.ferriesSydneyFerries, StopsEndpoint.ferriesMff],
      tab: Tab(
        icon: Icon(
          Icons.directions_ferry,
          color: Color.fromARGB(255, 68, 240, 91),
        ),
      ),
    ),
  ];
}
