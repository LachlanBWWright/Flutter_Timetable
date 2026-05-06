import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
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
    with TickerProviderStateMixin {
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
  bool _directTripMode = false;
  SortMode _sortMode = SortMode.alphabetical;

  final keyController = TextEditingController();
  late FocusNode _searchFocusNode;
  final AppDatabase _db = AppDatabase();
  final TripLineService _tripLineService = TripLineService.instance;
  late TabController _tabController;
  late List<_TripCreatorTab> _tabs;
  _TripCreatorTabKind _currentTabKind = _TripCreatorTabKind.sydneyTrains;
  TransportMode get _currentMode => _currentTab.mode;
  _TripCreatorTab get _currentTab => _tabs[_tabController.index];

  List<StopLineMatch> _sharedLines = [];
  List<StopLineMatch> _originLineCandidates = [];
  StopLineMatch? _selectedLine;
  bool _manualBuilderEnabled = false;
  List<Station> _sameLineCandidateStations = [];
  List<Station> _interchanges = [];
  int? _pendingInterchangeInsertIndex;
  List<Station> _manualCandidateStations = [];
  final Map<String, Future<_SameLineCandidates>> _sameLineCandidateCache = {};

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    TransportPreferencesService.showNswTrainLink.addListener(
      _onTransportPreferencesChanged,
    );
    keyController.addListener(_applySearchFilter);
    _searchFocusNode = FocusNode();
    _loadAllModes();
  }

  Future<void> _loadAllModes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
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

      setState(() {
        _trainStationList = results[0];
        _nswTrainLinkStationList = results[1];
        _lightRailStationList = results[2];
        _metroStationList = results[3];
        _busStationList = results[4];
        _ferryStationList = results[5];
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No stops found in database. Please update static transport data from Settings.',
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading stations: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    TransportPreferencesService.showNswTrainLink.removeListener(
      _onTransportPreferencesChanged,
    );
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    keyController.removeListener(_applySearchFilter);
    keyController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final oldTabKind = _currentTabKind;
    _currentTabKind = _currentTab.kind;

    if (oldTabKind != _currentTabKind) {
      setState(() {});
    }
  }

  void _onTransportPreferencesChanged() {
    final previousKind = _currentTabKind;
    final nextTabs = _buildTabs();
    final nextIndex = nextTabs.indexWhere((tab) => tab.kind == previousKind);

    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tabs = nextTabs;
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: nextIndex == -1 ? 0 : nextIndex,
    );
    _currentTabKind = _tabs[_tabController.index].kind;
    _tabController.addListener(_onTabChanged);
    if (TransportPreferencesService.showNswTrainLink.value &&
        _nswTrainLinkStationList.isEmpty) {
      _loadAllModes();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setStation(String stationName, String id) async {
    final mode = await StopsService.getModeForStopId(id);
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
      setState(() {
        _originStation = station;
        _originMode = mode;
        _directTripMode = false;
        keyController.clear();
      });
      _resetManualDraft(clearSharedLines: true, keepDestination: false);
      unawaited(_loadSameLineCandidatesForOrigin());
      return;
    }

    if (_destinationStation == null) {
      setState(() {
        _destinationStation = station;
        _destinationMode = mode;
        keyController.clear();
        _showMapView = false;
      });
      await _resolveSharedLines();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
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
    setState(() {
      _originStation = null;
      _originMode = null;
    });
    _resetManualDraft(clearSharedLines: true, keepDestination: false);
  }

  void _clearDestination() {
    setState(() {
      _destinationStation = null;
      _destinationMode = null;
    });
    _resetManualDraft(clearSharedLines: true);
    _loadSameLineCandidatesForOrigin();
  }

  void _resetManualDraft({
    bool clearSharedLines = false,
    bool keepDestination = true,
  }) {
    if (!keepDestination) {
      _destinationStation = null;
      _destinationMode = null;
    }

    setState(() {
      _manualBuilderEnabled = false;
      _directTripMode = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _sameLineCandidateStations = [];
      _manualCandidateStations = [];
      if (clearSharedLines) {
        _sharedLines = [];
        _originLineCandidates = [];
        _selectedLine = null;
      }
    });
  }

  Future<void> _loadSameLineCandidatesForOrigin() async {
    final origin = _originStation;
    final originMode = _originMode;
    if (origin == null || originMode == null) {
      return;
    }

    final requestOriginId = origin.id;
    final requestOriginMode = originMode;

    setState(() {
      _isLoadingLineCandidates = true;
      _originLineCandidates = [];
      _sameLineCandidateStations = [];
    });

    try {
      final candidates = await _sameLineCandidatesForOrigin(
        originId: requestOriginId,
        mode: requestOriginMode,
      );

      if (!mounted) return;
      if (_originStation?.id != requestOriginId || _originMode != originMode) {
        return;
      }
      setState(() {
        _originLineCandidates = candidates.lines;
        _sameLineCandidateStations = candidates.stations;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load stops on the same line: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLineCandidates = false;
        });
      }
    }
  }

  Future<_SameLineCandidates> _sameLineCandidatesForOrigin({
    required String originId,
    required TransportMode mode,
  }) {
    final cacheKey = '$originId|${mode.id}';
    return _sameLineCandidateCache.putIfAbsent(cacheKey, () async {
      final lines = await _tripLineService.getLinesForStop(
        originId,
        mode: mode,
        allowBuild: true,
      );
      final lineStops = await Future.wait(
        lines.map((line) {
          return _tripLineService.getStopsForLine(
            line.lineId,
            line.mode,
            allowBuild: true,
          );
        }),
      );
      final stationsById = <String, Station>{};

      for (final stops in lineStops) {
        for (final lineStop in stops) {
          if (lineStop.stopId == originId) {
            continue;
          }
          stationsById.putIfAbsent(lineStop.stopId, () => lineStop.toStation());
        }
      }

      final stations = stationsById.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return _SameLineCandidates(lines: lines, stations: stations);
    });
  }

  void _toggleDirectTripMode(bool value) {
    setState(() {
      _directTripMode = value;
      if (!value && _destinationStation != null) {
        _destinationStation = null;
        _destinationMode = null;
        _sharedLines = [];
        _selectedLine = null;
      }
      keyController.clear();
      _showMapView = false;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Origin and destination cannot be the same stop.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    if (originMode == null ||
        destinationMode == null ||
        originMode != destinationMode) {
      setState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    setState(() {
      _isResolvingSharedLines = true;
      _sharedLines = [];
      _selectedLine = null;
      _manualBuilderEnabled = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
    });

    try {
      final sharedLines = await _tripLineService.findSharedLines(
        origin.id,
        destination.id,
        mode: originMode,
        allowBuild: true,
      );
      if (!mounted) return;

      setState(() {
        _sharedLines = sharedLines;
        _selectedLine = sharedLines.isEmpty ? null : sharedLines.first;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to resolve shared lines: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingSharedLines = false;
        });
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      if (keyController.text.isEmpty) {
        _isSearching = !_isSearching;
        if (_isSearching) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              FocusScope.of(context).requestFocus(_searchFocusNode);
            }
          });
        } else {
          _searchFocusNode.unfocus();
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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
        setState(() {
          _sortMode = SortMode.alphabetical;
        });
        return;
      }

      setState(() {
        _sortMode = SortMode.distance;
      });
    } else {
      setState(() {
        _sortMode = SortMode.alphabetical;
      });
    }

    await _applySorting();
  }

  void _openMap() {
    if (_manualBuilderEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use the list to add manual interchanges on a line.'),
        ),
      );
      return;
    }

    setState(() {
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
    if (origin == null || destination == null || selectedLine == null) {
      return;
    }
    if (validationMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationMessage)));
      }
      return;
    }

    final definition = ManualTripDefinition(
      mode: selectedLine.mode,
      lineId: selectedLine.lineId,
      lineName: selectedLine.lineName,
      legs: NewTripService.buildManualTripLegs(
        origin: origin,
        destination: destination,
        interchanges: _interchanges,
        selectedLine: selectedLine,
      ),
    );

    await _persistJourney(
      JourneysCompanion(
        origin: drift.Value(origin.name),
        originId: drift.Value(origin.id),
        destination: drift.Value(destination.name),
        destinationId: drift.Value(destination.id),
        tripType: drift.Value(SavedTripType.manualMultiLeg.storageValue),
        mode: drift.Value(selectedLine.mode.id),
        lineId: drift.Value(selectedLine.lineId),
        lineName: drift.Value(selectedLine.lineName),
        legsJson: drift.Value(definition.toLegsJson()),
      ),
      successMessage: 'Manual trip saved.',
    );
  }

  Future<void> _persistJourney(
    JourneysCompanion companion, {
    required String successMessage,
  }) async {
    try {
      await _db.insertJourney(companion);
      if (!mounted) return;

      _clearAllSelections();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving trip: $e')));
      }
    }
  }

  void _clearAllSelections() {
    setState(() {
      _originStation = null;
      _originMode = null;
      _destinationStation = null;
      _destinationMode = null;
      _sharedLines = [];
      _originLineCandidates = [];
      _selectedLine = null;
      _manualBuilderEnabled = false;
      _directTripMode = false;
      _sameLineCandidateStations = [];
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
      _showMapView = false;
    });
  }

  void _startManualBuilder() {
    final line = _selectedLine;
    if (line == null) {
      return;
    }

    _setTabForMode(line.mode);
    setState(() {
      _manualBuilderEnabled = true;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      _showMapView = false;
    });
  }

  void _cancelManualBuilder() {
    setState(() {
      _manualBuilderEnabled = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
    });
  }

  Future<void> _selectLine(StopLineMatch line) async {
    _setTabForMode(line.mode);
    setState(() {
      _selectedLine = line;
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      if (_manualBuilderEnabled) {
        _interchanges = [];
      }
    });
  }

  Future<void> _startInterchangeSelection(int insertIndex) async {
    final selectedLine = _selectedLine;
    final orderedStops = _orderedStops;
    if (selectedLine == null || orderedStops.length < 2) {
      return;
    }

    final previousStop = orderedStops[insertIndex - 1];
    final nextStop = orderedStops[insertIndex];

    setState(() {
      _pendingInterchangeInsertIndex = insertIndex;
      _isLoadingInterchangeCandidates = true;
      _manualCandidateStations = [];
      _showMapView = false;
    });

    _setTabForMode(selectedLine.mode);

    try {
      final rankedStops = await _tripLineService.rankStopsForLine(
        lineId: selectedLine.lineId,
        mode: selectedLine.mode,
        anchorStopIds: [previousStop.id, nextStop.id],
        excludedStopIds: orderedStops.map((stop) => stop.id),
        allowBuild: false,
      );

      if (!mounted) return;
      setState(() {
        _manualCandidateStations = rankedStops
            .map((lineStop) => lineStop.toStation())
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading interchange stops: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInterchangeCandidates = false;
        });
      }
    }
  }

  void _insertInterchange(Station station) {
    final selectedLine = _selectedLine;
    final insertIndex = _pendingInterchangeInsertIndex;
    if (selectedLine == null || insertIndex == null) {
      return;
    }

    final interchange = station.copyWith(
      lineId: selectedLine.lineId,
      lineName: selectedLine.lineName,
    );

    setState(() {
      _interchanges.insert(insertIndex - 1, interchange);
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
    });
  }

  void _removeInterchange(int interchangeIndex) {
    setState(() {
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

    setState(() {
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
    return _directTripMode &&
        canSaveDirectTrip(
          origin: _originStation,
          destination: _destinationStation,
        );
  }

  String? get _manualValidationMessage {
    return manualTripValidationMessage(
      manualBuilderEnabled: _manualBuilderEnabled,
      origin: _originStation,
      destination: _destinationStation,
      interchanges: _interchanges,
      selectedLine: _selectedLine,
    );
  }

  bool get _canSaveManual =>
      _manualBuilderEnabled && _manualValidationMessage == null;

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

    setState(() {
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
    if (mounted) {
      setState(() {});
    }
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
            isDirectTripMode: _directTripMode,
            isLoadingLineCandidates: _isLoadingLineCandidates,
            originLineCandidates: _originLineCandidates,
            onDirectTripModeChanged: _originStation == null
                ? null
                : _toggleDirectTripMode,
            sharedLines: _sharedLines,
            selectedLine: _selectedLine,
            interchanges: _interchanges,
            isResolvingSharedLines: _isResolvingSharedLines,
            isManualBuilderEnabled: _manualBuilderEnabled,
            pendingInterchangeInsertIndex: _pendingInterchangeInsertIndex,
            statusMessage: _statusMessage,
            manualValidationMessage: _manualValidationMessage,
            onClearOrigin: _clearOrigin,
            onClearDestination: _clearDestination,
            onLineSelected: _selectLine,
            onSaveDirect: _saveDirectTrip,
            onStartManualBuilder: _sharedLines.isNotEmpty
                ? _startManualBuilder
                : null,
            onCancelManualBuilder: _manualBuilderEnabled
                ? _cancelManualBuilder
                : null,
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
        allowedStopIds: _shouldUseSameLineCandidatesForTab(tab)
            ? _sameLineCandidatesForTab(
                tab,
              ).map((station) => station.id).toSet()
            : null,
        embedded: true,
        onStopSelected: (name, id) {
          setStation(name, id);
        },
        onClose: () {
          setState(() {
            _showMapView = false;
          });
        },
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoadingLineCandidates &&
        _originStation != null &&
        _destinationStation == null &&
        !_directTripMode &&
        mode == _originMode) {
      return const Center(child: Text('Checking static transport data...'));
    }

    final selectedLine = _selectedLine;

    if (_manualBuilderEnabled &&
        selectedLine != null &&
        mode != selectedLine.mode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Manual multi-leg editing is limited to ${selectedLine.mode.displayName} stops on ${selectedLine.lineName}.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_isLoadingInterchangeCandidates &&
        _manualBuilderEnabled &&
        _pendingInterchangeInsertIndex != null &&
        selectedLine != null &&
        mode == selectedLine.mode) {
      return const Center(child: CircularProgressIndicator());
    }

    final baseList =
        _manualBuilderEnabled &&
            _pendingInterchangeInsertIndex != null &&
            selectedLine != null &&
            mode == selectedLine.mode
        ? _manualCandidateStations
        : _shouldUseSameLineCandidatesForTab(tab)
        ? _sameLineCandidatesForTab(tab)
        : _getStationListForTab(tab);

    final displayList = filterStationsByQuery(baseList, keyController.text);

    if (displayList.isEmpty) {
      final emptyMessage =
          _manualBuilderEnabled &&
              _pendingInterchangeInsertIndex != null &&
              selectedLine != null &&
              mode == selectedLine.mode
          ? buildInterchangeEmptyMessage(selectedLine)
          : _shouldUseSameLineCandidatesForTab(tab)
          ? 'Static transport data needs updating for same-line filtering.'
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

  bool _shouldUseSameLineCandidatesForTab(_TripCreatorTab tab) {
    return _originStation != null &&
        _destinationStation == null &&
        !_directTripMode;
  }

  List<Station> _sameLineCandidatesForTab(_TripCreatorTab tab) {
    final endpointKeys = tab.endpoints.map((endpoint) => endpoint.key).toSet();
    return _sameLineCandidateStations.where((station) {
      final lineId = station.lineId;
      if (lineId == null) {
        return false;
      }
      return endpointKeys.contains(lineId.split('|').first);
    }).toList();
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

class _SameLineCandidates {
  const _SameLineCandidates({required this.lines, required this.stations});

  final List<StopLineMatch> lines;
  final List<Station> stations;
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
