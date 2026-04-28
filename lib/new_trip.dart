import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
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
  bool _isLoadingInterchangeCandidates = false;
  SortMode _sortMode = SortMode.alphabetical;

  final keyController = TextEditingController();
  late FocusNode _searchFocusNode;
  final AppDatabase _db = AppDatabase();
  final TripLineService _tripLineService = TripLineService.instance;
  late TabController _tabController;
  TransportMode _currentMode = TransportMode.train;

  List<StopLineMatch> _sharedLines = [];
  StopLineMatch? _selectedLine;
  bool _manualBuilderEnabled = false;
  List<Station> _interchanges = [];
  int? _pendingInterchangeInsertIndex;
  List<Station> _manualCandidateStations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
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
        loadStationsFromDbForMode(TransportMode.train),
        loadStationsFromDbForMode(TransportMode.lightrail),
        loadStationsFromDbForMode(TransportMode.metro),
        loadStationsFromDbForMode(TransportMode.bus),
        loadStationsFromDbForMode(TransportMode.ferry),
      ]);

      if (!mounted) return;

      setState(() {
        _trainStationList = results[0];
        _lightRailStationList = results[1];
        _metroStationList = results[2];
        _busStationList = results[3];
        _ferryStationList = results[4];
        _isLoading = false;
      });

      await _applySorting();

      final hasAnyStops =
          _trainStationList.isNotEmpty ||
          _busStationList.isNotEmpty ||
          _ferryStationList.isNotEmpty ||
          _lightRailStationList.isNotEmpty ||
          _metroStationList.isNotEmpty;

      if (!hasAnyStops && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No stops found in database. Please update stops data from Settings.',
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    keyController.removeListener(_applySearchFilter);
    keyController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final oldMode = _currentMode;
    switch (_tabController.index) {
      case 0:
        _currentMode = TransportMode.train;
        break;
      case 1:
        _currentMode = TransportMode.lightrail;
        break;
      case 2:
        _currentMode = TransportMode.metro;
        break;
      case 3:
        _currentMode = TransportMode.bus;
        break;
      case 4:
        _currentMode = TransportMode.ferry;
        break;
    }

    if (oldMode != _currentMode) {
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
        keyController.clear();
      });
      _resetManualDraft(clearSharedLines: true, keepDestination: false);
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
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      if (clearSharedLines) {
        _sharedLines = [];
        _selectedLine = null;
      }
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
      _selectedLine = null;
      _manualBuilderEnabled = false;
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
    final index = switch (mode) {
      TransportMode.train => 0,
      TransportMode.lightrail => 1,
      TransportMode.metro => 2,
      TransportMode.bus => 3,
      TransportMode.ferry => 4,
    };

    if (_tabController.index != index) {
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
    final origin = _originStation;
    final destination = _destinationStation;
    return origin != null &&
        destination != null &&
        origin.id.isNotEmpty &&
        destination.id.isNotEmpty &&
        origin.id != destination.id;
  }

  String? get _manualValidationMessage {
    if (!_manualBuilderEnabled) {
      return null;
    }

    return NewTripService.validateManualTrip(
      origin: _originStation,
      destination: _destinationStation,
      interchanges: _interchanges,
      selectedLine: _selectedLine,
    );
  }

  bool get _canSaveManual =>
      _manualBuilderEnabled && _manualValidationMessage == null;

  String? get _statusMessage {
    final origin = _originStation;
    final destination = _destinationStation;
    if (origin == null && destination == null) {
      return null;
    }

    if (_isResolvingSharedLines) {
      return 'Checking for shared lines...';
    }

    if (_manualBuilderEnabled && _pendingInterchangeInsertIndex != null) {
      final orderedStops = _orderedStops;
      final insertIndex = _pendingInterchangeInsertIndex!;
      if (insertIndex > 0 && insertIndex < orderedStops.length) {
        final previous = orderedStops[insertIndex - 1];
        final next = orderedStops[insertIndex];
        return 'Choose an interchange between ${previous.name} and ${next.name}. Stops on the selected line within 5 km are listed first.';
      }
    }

    if (_manualBuilderEnabled) {
      return _manualValidationMessage ??
          'Add interchanges on ${_selectedLine?.lineName ?? 'the selected line'} to split this trip into multiple legs.';
    }

    if (_canSaveDirect && _sharedLines.isEmpty) {
      if (_originMode != null &&
          _destinationMode != null &&
          _originMode != _destinationMode) {
        return 'These stops do not share a mode. You can still save them as a direct trip.';
      }
      return 'No shared line found. You can still save this as a direct trip.';
    }

    if (_sharedLines.length == 1) {
      return 'A shared line is available. Save directly or build a manual multi-leg trip.';
    }

    if (_sharedLines.length > 1) {
      return 'Multiple shared lines are available. Pick one before building a manual multi-leg trip.';
    }

    return null;
  }

  List<Station> _getCurrentStationList() {
    switch (_currentMode) {
      case TransportMode.train:
        return _trainStationList;
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

  List<Station> _getStationListForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.train:
        return _trainStationList;
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
      switch (_currentMode) {
        case TransportMode.train:
          _trainStationList = sortedStations;
          break;
        case TransportMode.lightrail:
          _lightRailStationList = sortedStations;
          break;
        case TransportMode.metro:
          _metroStationList = sortedStations;
          break;
        case TransportMode.bus:
          _busStationList = sortedStations;
          break;
        case TransportMode.ferry:
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
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStationTab(TransportMode.train),
                _buildStationTab(TransportMode.lightrail),
                _buildStationTab(TransportMode.metro),
                _buildStationTab(TransportMode.bus),
                _buildStationTab(TransportMode.ferry),
              ],
            ),
          ),
          SelectedStopsWidget(
            origin: _originStation,
            destination: _destinationStation,
            currentMode: _currentMode,
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

  Widget _buildStationTab(TransportMode mode) {
    if (_showMapView && !_manualBuilderEnabled) {
      final modeDisplayName = NewTripService.getModeDisplayName(mode);
      return StopsMapWidget(
        key: ValueKey('map_$mode'),
        transportMode: mode,
        modeDisplayName: modeDisplayName,
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

    if (_manualBuilderEnabled &&
        _selectedLine != null &&
        mode != _selectedLine!.mode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Manual multi-leg editing is limited to ${_selectedLine!.mode.displayName} stops on ${_selectedLine!.lineName}.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_isLoadingInterchangeCandidates &&
        _manualBuilderEnabled &&
        _pendingInterchangeInsertIndex != null &&
        _selectedLine != null &&
        mode == _selectedLine!.mode) {
      return const Center(child: CircularProgressIndicator());
    }

    final baseList =
        _manualBuilderEnabled &&
            _pendingInterchangeInsertIndex != null &&
            _selectedLine != null &&
            mode == _selectedLine!.mode
        ? _manualCandidateStations
        : _getStationListForMode(mode);

    final query = keyController.text.trim().toLowerCase();
    final displayList = query.isEmpty
        ? baseList
        : baseList
              .where((station) => station.name.toLowerCase().contains(query))
              .toList();

    if (displayList.isEmpty) {
      final emptyMessage =
          _manualBuilderEnabled &&
              _pendingInterchangeInsertIndex != null &&
              _selectedLine != null &&
              mode == _selectedLine!.mode
          ? 'No stops found on ${_selectedLine!.lineName} for this interchange.'
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
