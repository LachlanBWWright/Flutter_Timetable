import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
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
  String _firstStation = '';
  String _firstStationId = '';
  String _secondStation = '';
  String _secondStationId = '';
  bool _isSearching = false;
  bool _isLoading = false;
  String _sortMode = 'alphabetical'; // 'alphabetical' or 'distance'
  final keyController = TextEditingController();
  final AppDatabase _db = AppDatabase();
  TabController? _tabController;

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
    loadStations();
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
      }
    });
  }

  Future<void> _saveTrip() async {
    if (_firstStation.isNotEmpty && _secondStation.isNotEmpty) {
      print(
          'Attempting to save trip: $_firstStation ($_firstStationId) -> $_secondStation ($_secondStationId)');
      try {
        await _db.insertJourney(JourneysCompanion(
          origin: drift.Value(_firstStation),
          originId: drift.Value(_firstStationId),
          destination: drift.Value(_secondStation),
          destinationId: drift.Value(_secondStationId),
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Saved trip from $_firstStation to $_secondStation.',
            ),
          ));
          setState(() {
            _firstStation = '';
            _firstStationId = '';
            _secondStation = '';
            _secondStationId = '';
          });
        }
      } catch (e) {
        print('Error inserting journey: $e');
      }
    }
  }

  Future<void> loadStations() async {
    if (_isSearching) return; // Don't reload if searching

    setState(() {
      _isLoading = true;
    });

    try {
      // Load stations from database/API for each transport mode
      final trainStations = await NewTripService.loadStopsForMode('train');
      final lightRailStations =
          await NewTripService.loadStopsForMode('lightrail');
      final busStations = await NewTripService.loadStopsForMode('bus');
      final ferryStations = await NewTripService.loadStopsForMode('ferry');

      // Apply sorting
      final sortedTrainStations = await _applySorting(trainStations);
      final sortedLightRailStations = await _applySorting(lightRailStations);
      final sortedBusStations = await _applySorting(busStations);
      final sortedFerryStations = await _applySorting(ferryStations);

      setState(() {
        _trainStationList = sortedTrainStations;
        _lightRailStationList = sortedLightRailStations;
        _busStationList = sortedBusStations;
        _ferryStationList = sortedFerryStations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Station>> _applySorting(List<Station> stations) async {
    if (_sortMode == 'distance') {
      return await NewTripService.sortByDistance(stations);
    } else {
      return NewTripService.sortAlphabetically(stations);
    }
  }

  void _toggleSortMode() async {
    setState(() {
      _sortMode = _sortMode == 'alphabetical' ? 'distance' : 'alphabetical';
    });
    await loadStations(); // Reload with new sorting
  }

  void loadSearchStations(String search) async {
    try {
      final results = await TransportApiService.searchStations(search);
      final stations = results
          .map((result) => Station(
                name: result.name ?? '',
                id: result.id ?? '',
              ))
          .toList();

      setState(() {
        // Update all lists with search results for consistency
        _trainStationList = stations;
        _lightRailStationList = stations;
        _busStationList = stations;
        _ferryStationList = stations;
      });
    } catch (e) {
      print('Error searching stations: $e');
    }
  }

  void _openStopsMap() {
    if (_tabController == null) return;

    final currentIndex = _tabController!.index;
    String mode;
    String displayName;

    switch (currentIndex) {
      case 0:
        mode = 'train';
        displayName = 'Train';
        break;
      case 1:
        mode = 'lightrail';
        displayName = 'Light Rail';
        break;
      case 2:
        mode = 'bus';
        displayName = 'Bus';
        break;
      case 3:
        mode = 'ferry';
        displayName = 'Ferry';
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StopsMapWidget(
          transportMode: mode,
          modeDisplayName: displayName,
          onStopSelected: setStation,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadStations();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _firstStation.isNotEmpty && _secondStation.isNotEmpty;

    return DefaultTabController(
      length: 4, // Reduced from 5 (removed map tab)
      child: Scaffold(
        appBar: NewTripAppBar(
          isSearching: _isSearching,
          searchController: keyController,
          onSearch: loadSearchStations,
          onToggleSearch: _toggleSearch,
          onSaveTrip: canSave ? _saveTrip : null,
          canSave: canSave,
          onOpenMap: _openStopsMap,
          onToggleSort: _toggleSortMode,
          sortMode: _sortMode,
          tabController: _tabController,
        ),
        body: _isLoading
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          const Text('Loading station lists...'),
                          const SizedBox(height: 8),
                          if (_firstStation.isNotEmpty)
                            Text('Selected origin: $_firstStation'),
                          if (_secondStation.isNotEmpty)
                            Text('Selected destination: $_secondStation'),
                          const SizedBox(height: 8),
                          Text(
                              'Train stations loaded: ${_trainStationList.length}'),
                          Text(
                              'Light rail stations loaded: ${_lightRailStationList.length}'),
                          Text(
                              'Bus stations loaded: ${_busStationList.length}'),
                          Text(
                              'Ferry stations loaded: ${_ferryStationList.length}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : loadStations,
                            child: const Text('Retry loading'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTrainStationTab(),
                  StationList(
                    listItems: _lightRailStationList,
                    setStation: setStation,
                  ),
                  StationList(
                    listItems: _busStationList,
                    setStation: setStation,
                  ),
                  StationList(
                    listItems: _ferryStationList,
                    setStation: setStation,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTrainStationTab() {
    return Column(
      children: [
        if (_firstStation.isNotEmpty)
          SelectedStationCard(
            label: 'First Station Selected',
            stationName: _firstStation,
            onCancel: _clearFirstStation,
          ),
        if (_secondStation.isNotEmpty)
          SelectedStationCard(
            label: 'Second Station Selected',
            stationName: _secondStation,
            onCancel: _clearSecondStation,
          ),
        Expanded(
          child: StationList(
            listItems: _trainStationList,
            setStation: setStation,
          ),
        ),
      ],
    );
  }
}
