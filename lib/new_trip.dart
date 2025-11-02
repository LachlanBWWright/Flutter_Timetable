import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
// logger removed
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';

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
  String _firstStation = '';
  String _firstStationId = '';
  String _secondStation = '';
  String _secondStationId = '';
  bool _isSearching = false;
  bool _isLoading = false;
  SortMode _sortMode = SortMode.alphabetical;
  final keyController = TextEditingController();
  final AppDatabase _db = AppDatabase();
  late TabController _tabController;
  TransportMode _currentMode = TransportMode.train;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    keyController.addListener(_applySearchFilter);
    _loadAllModes();
  }

  Future<void> _loadAllModes() async {
    // Load all modes from local database (no network fetch)
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = [
        loadStationsFromDbForMode(TransportMode.train),
        loadStationsFromDbForMode(TransportMode.lightrail),
        loadStationsFromDbForMode(TransportMode.metro),
        loadStationsFromDbForMode(TransportMode.bus),
        loadStationsFromDbForMode(TransportMode.ferry),
      ];

      final results = await Future.wait(futures);

      setState(() {
        _trainStationList = results[0];
        _lightRailStationList = results[1];
        _metroStationList = results[2];
        _busStationList = results[3];
        _ferryStationList = results[4];
        _isLoading = false;
      });

      await _applySorting();
    } catch (e) {
      // Error loading stations from DB
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stations: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Use the extracted function from services/station_loader.dart

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    keyController.removeListener(_applySearchFilter);
    keyController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final oldMode = _currentMode;
      setState(() {
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
      });

      if (oldMode != _currentMode) {
        // Trigger rebuild for the new mode/tab. Per-tab filtering is handled
        // by _buildStationTab (which reads the current search text).
        setState(() {});
      }
    }
  }

  void setStation(String station, String id) async {
    setState(() {
      if (_firstStation == '') {
        _firstStation = station;
        _firstStationId = id;
        keyController.text = '';
      } else {
        _secondStation = station;
        _secondStationId = id;
        keyController.text = '';
      }
    });
    _applySearchFilter();
  }

  void _clearFirstStation() {
    setState(() {
      _firstStation = '';
      _firstStationId = '';
    });
  }

  void _clearSecondStation() {
    setState(() {
      _secondStation = '';
      _secondStationId = '';
    });
  }

  void _toggleSearch() {
    setState(() {
      if (keyController.text == '') {
        _isSearching = !_isSearching;
      } else {
        keyController.text = '';
        _applySearchFilter();
      }
    });
  }

  void _toggleSort() async {
    setState(() {
      _sortMode = _sortMode == SortMode.alphabetical
          ? SortMode.distance
          : SortMode.alphabetical;
    });
    await _applySorting();
  }

  void _openMap() {
    final modeDisplayName = NewTripService.getModeDisplayName(_currentMode);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopsMapWidget(
          transportMode: _currentMode,
          modeDisplayName: modeDisplayName,
          onStopSelected: setStation,
        ),
      ),
    );
  }

  Future<void> _saveTrip() async {
    if (_firstStation.isNotEmpty && _secondStation.isNotEmpty) {
      // Attempting to save trip
      try {
        await _db.insertJourney(JourneysCompanion(
          origin: drift.Value(_firstStation),
          originId: drift.Value(_firstStationId),
          destination: drift.Value(_secondStation),
          destinationId: drift.Value(_secondStationId),
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip saved.')),
          );
          setState(() {
            _firstStation = '';
            _firstStationId = '';
            _secondStation = '';
            _secondStationId = '';
          });
        }
      } catch (e) {
        // Error inserting journey
      }
    }
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

  /// Get station list for an arbitrary mode (does not depend on _currentMode)
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
    List<Station> sortedStations;

    if (_sortMode == SortMode.alphabetical) {
      sortedStations = NewTripService.sortAlphabetically(stations);
    } else {
      sortedStations = await NewTripService.sortByDistance(stations);
    }

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
      // Trigger a rebuild so the tab lists reflect the new sort order.
      if (mounted) setState(() {});
    });
  }

  void _applySearchFilter() {
    // Per-tab filtering is handled by _buildStationTab which reads
    // keyController.text and the per-mode station lists. This method
    // exists as the listener target for keyController so just trigger
    // a rebuild when the search text changes.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _firstStation.isNotEmpty && _secondStation.isNotEmpty;

    return Scaffold(
      appBar: NewTripAppBar(
        isSearching: _isSearching,
        searchController: keyController,
        onSearch: (query) {
          // This will be handled by the text controller listener
        },
        onToggleSearch: _toggleSearch,
        onSaveTrip: canSave ? _saveTrip : null,
        canSave: canSave,
        onOpenMap: _openMap,
        onToggleSort: _toggleSort,
        sortMode: _sortMode,
        tabController: _tabController,
      ),
      body: Column(
        children: [
          // Main content with TabBarView
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

          // Selected stops widget at the bottom
          SelectedStopsWidget(
            firstStation: _firstStation,
            firstStationId: _firstStationId,
            secondStation: _secondStation,
            secondStationId: _secondStationId,
            currentMode: _currentMode,
            onClearFirst: _clearFirstStation,
            onClearSecond: _clearSecondStation,
          ),
        ],
      ),
    );
  }

  Widget _buildStationTab(TransportMode mode) {
    // Build the list for this specific tab mode to avoid relying on a
    // single _filteredStations list which may cause delays when switching tabs.
    final baseList = _getStationListForMode(mode);
    List<Station> displayList;

    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final query = keyController.text.trim();
    if (query.isEmpty) {
      displayList = baseList;
    } else {
      displayList = baseList
          .where((station) =>
              station.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        Expanded(
          child: EnhancedStationList(
            listItems: displayList,
            setStation: setStation,
            sortMode: _sortMode,
          ),
        ),
      ],
    );
  }
}
