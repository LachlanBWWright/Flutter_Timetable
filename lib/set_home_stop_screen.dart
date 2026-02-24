import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/transport_modes.dart';
import 'services/location_service.dart';
import 'services/station_loader.dart';
import 'widgets/station_widgets.dart';

class SetHomeStopScreen extends StatefulWidget {
  const SetHomeStopScreen({super.key});

  @override
  State<SetHomeStopScreen> createState() => _SetHomeStopScreenState();
}

class _SetHomeStopScreenState extends State<SetHomeStopScreen>
    with TickerProviderStateMixin {
  List<Station> _trainStationList = [];
  List<Station> _busStationList = [];
  List<Station> _ferryStationList = [];
  List<Station> _lightRailStationList = [];
  List<Station> _metroStationList = [];
  String _selectedStationName = '';
  String _selectedStationId = '';
  TransportMode? _selectedStationMode;
  bool _isSearching = false;
  bool _isLoading = false;
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
    _tabController.addListener(_onTabChanged);
    keyController.addListener(_applySearchFilter);
    _searchFocusNode = FocusNode();
    _loadAllModes();
    _loadCurrentHomeStop();
  }

  Future<void> _loadCurrentHomeStop() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentHomeStop = prefs.getString('home_stop_name');
    });
  }

  Future<void> _loadAllModes() async {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stations: $e')));
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
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
    final searchTerm = keyController.text.toLowerCase();
    setState(() {
      _trainStationList = _trainStationList
          .where((station) => station.name.toLowerCase().contains(searchTerm))
          .toList();
      _busStationList = _busStationList
          .where((station) => station.name.toLowerCase().contains(searchTerm))
          .toList();
      _ferryStationList = _ferryStationList
          .where((station) => station.name.toLowerCase().contains(searchTerm))
          .toList();
      _lightRailStationList = _lightRailStationList
          .where((station) => station.name.toLowerCase().contains(searchTerm))
          .toList();
      _metroStationList = _metroStationList
          .where((station) => station.name.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  Future<void> _applySorting() async {
    if (_sortMode == SortMode.distance) {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        if (!mounted) return;
        setState(() {
          _trainStationList = _sortByDistance(_trainStationList, position);
          _busStationList = _sortByDistance(_busStationList, position);
          _ferryStationList = _sortByDistance(_ferryStationList, position);
          _lightRailStationList = _sortByDistance(
            _lightRailStationList,
            position,
          );
          _metroStationList = _sortByDistance(_metroStationList, position);
        });
      }
    } else {
      setState(() {
        _trainStationList.sort((a, b) => a.name.compareTo(b.name));
        _busStationList.sort((a, b) => a.name.compareTo(b.name));
        _ferryStationList.sort((a, b) => a.name.compareTo(b.name));
        _lightRailStationList.sort((a, b) => a.name.compareTo(b.name));
        _metroStationList.sort((a, b) => a.name.compareTo(b.name));
      });
    }
  }

  List<Station> _sortByDistance(List<Station> stations, Position position) {
    final stationsWithDistance = stations
        .where((s) => s.latitude != null && s.longitude != null)
        .map((station) {
          final distance = LocationService.calculateDistance(
            position.latitude,
            position.longitude,
            station.latitude!,
            station.longitude!,
          );
          return station.copyWith(distance: distance);
        })
        .toList();

    stationsWithDistance.sort((a, b) => a.distance!.compareTo(b.distance!));
    return stationsWithDistance;
  }

  void _toggleSort() async {
    setState(() {
      _sortMode = _sortMode == SortMode.alphabetical
          ? SortMode.distance
          : SortMode.alphabetical;
    });
    await _applySorting();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        keyController.clear();
        _loadAllModes(); // Reload to reset filter
      }
    });
    if (_isSearching) {
      _searchFocusNode.requestFocus();
    }
  }

  void _setStation(String stationName, String stationId) {
    setState(() {
      _selectedStationName = stationName;
      _selectedStationId = stationId;
      _selectedStationMode = _currentMode;
    });
  }

  Future<void> _saveHomeStop() async {
    if (_selectedStationName.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('home_stop_name', _selectedStationName);
    await prefs.setString('home_stop_id', _selectedStationId);
    await prefs.setString('home_stop_mode', _selectedStationMode!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Home stop set to $_selectedStationName'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
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

  Widget _buildStationTab() {
    final stationList = _getCurrentStationList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stationList.isEmpty) {
      return const Center(child: Text('No stations found'));
    }

    return Column(
      children: [
        if (_currentHomeStop != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current home stop: $_currentHomeStop',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedStationName.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: $_selectedStationName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedStationName = '';
                      _selectedStationId = '';
                      _selectedStationMode = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: EnhancedStationList(
            listItems: stationList,
            setStation: _setStation,
            sortMode: _sortMode,
          ),
        ),
      ],
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
            ),
          ] else
            IconButton(
              onPressed: _saveHomeStop,
              icon: const Icon(Icons.check),
              tooltip: 'Save home stop',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_train)),
            Tab(icon: Icon(Icons.tram)),
            Tab(icon: Icon(Icons.subway)),
            Tab(icon: Icon(Icons.directions_bus)),
            Tab(icon: Icon(Icons.directions_ferry)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStationTab(),
          _buildStationTab(),
          _buildStationTab(),
          _buildStationTab(),
          _buildStationTab(),
        ],
      ),
    );
  }
}
