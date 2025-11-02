import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
// logger removed
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
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
  List<Station> _filteredStations = [];
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
  String _currentMode = 'train';

  @override
  void initState() {
    super.initState();
  _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    keyController.addListener(_applySearchFilter);
    _loadAllModes();
  }

  Future<void> _loadAllModes() async {
    // Load all modes in parallel for better user experience
    final futures = [
      NewTripService.loadStopsForMode('train'),
      NewTripService.loadStopsForMode('lightrail'),
      NewTripService.loadStopsForMode('bus'),
      NewTripService.loadStopsForMode('ferry'),
      NewTripService.loadStopsForMode('metro'),
    ];

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait(futures);
      setState(() {
        _trainStationList = results[0];
        _lightRailStationList = results[1];
        _busStationList = results[2];
        _ferryStationList = results[3];
        _metroStationList = results[4];
        _filteredStations = _getCurrentStationList();
        _isLoading = false;
      });

      await _applySorting();
    } catch (e) {
      // Error loading stations
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
            _currentMode = 'train';
            break;
          case 1:
            _currentMode = 'lightrail';
            break;
          case 2:
            _currentMode = 'bus';
            break;
          case 3:
            _currentMode = 'ferry';
            break;
          case 4:
            _currentMode = 'metro';
            break;
        }
      });

      if (oldMode != _currentMode) {
        setState(() {
          _filteredStations = _getCurrentStationList();
        });
        _applySearchFilter();
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
      case 'train':
        return _trainStationList;
      case 'lightrail':
        return _lightRailStationList;
      case 'metro':
        return _metroStationList;
      case 'bus':
        return _busStationList;
      case 'ferry':
        return _ferryStationList;
      default:
        return [];
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
        case 'train':
          _trainStationList = sortedStations;
          break;
        case 'lightrail':
          _lightRailStationList = sortedStations;
          break;
        case 'metro':
          _metroStationList = sortedStations;
          break;
        case 'bus':
          _busStationList = sortedStations;
          break;
        case 'ferry':
          _ferryStationList = sortedStations;
          break;
      }
      _filteredStations = sortedStations;
      _applySearchFilter();
    });
  }

  void _applySearchFilter() {
    final currentStations = _getCurrentStationList();
    if (keyController.text.isEmpty) {
      setState(() {
        _filteredStations = currentStations;
      });
    } else {
      final filtered = currentStations
          .where((station) => station.name
              .toLowerCase()
              .contains(keyController.text.toLowerCase()))
          .toList();
      setState(() {
        _filteredStations = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _firstStation.isNotEmpty && _secondStation.isNotEmpty;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
                    _buildStationTab('train'),
                    _buildStationTab('lightrail'),
                    _buildStationTab('bus'),
                    _buildStationTab('ferry'),
                    _buildStationTab('metro'),
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
      ),
    );
  }

  Widget _buildStationTab(String mode) {
    return Column(
      children: [
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: EnhancedStationList(
              listItems: _filteredStations,
              setStation: setStation,
              sortMode: _sortMode,
            ),
          ),
      ],
    );
  }
}
