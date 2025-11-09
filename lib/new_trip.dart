import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
// logger removed
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/location_service.dart';
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
  String _firstStation = '';
  String _firstStationId = '';
  TransportMode? _firstStationMode;
  String _secondStation = '';
  String _secondStationId = '';
  TransportMode? _secondStationMode;
  bool _isSearching = false;
  bool _isLoading = false;
  SortMode _sortMode = SortMode.alphabetical;
  final keyController = TextEditingController();
  late FocusNode _searchFocusNode;
  final AppDatabase _db = AppDatabase();
  late TabController _tabController;
  TransportMode _currentMode = TransportMode.train;

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
      
      // Check if any stops were loaded, show helpful message if not
      final hasAnyStops = _trainStationList.isNotEmpty ||
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Always update the current mode when the tab index changes. Using
    // indexIsChanging caused cases where the index wasn't reflected yet and
    // UI actions (like "Open stops map") used a stale mode. Update the
    // mode immediately and trigger a rebuild only when it actually changes.
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
      // Trigger rebuild for the new mode/tab. Per-tab filtering is handled
      // by _buildStationTab (which reads the current search text).
      setState(() {});
    }
  }

  void setStation(String station, String id) async {
    // Lookup the mode for this stop id
    final mode = await StopsService.getModeForStopId(id);

    setState(() {
      if (_firstStation == '') {
        _firstStation = station;
        _firstStationId = id;
        _firstStationMode = mode;
        keyController.text = '';
      } else {
        _secondStation = station;
        _secondStationId = id;
        _secondStationMode = mode;
        keyController.text = '';
      }
    });
    _applySearchFilter();
  }

  void _clearFirstStation() {
    setState(() {
      _firstStation = '';
      _firstStationId = '';
      _firstStationMode = null;
    });
  }

  void _clearSecondStation() {
    setState(() {
      _secondStation = '';
      _secondStationId = '';
      _secondStationMode = null;
    });
  }

  void _toggleSearch() {
    setState(() {
      if (keyController.text == '') {
        _isSearching = !_isSearching;
        if (_isSearching) {
          // Request focus for the search box after frame so the
          // TextField receives focus and the keyboard opens.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) FocusScope.of(context).requestFocus(_searchFocusNode);
          });
        } else {
          // When closing search, unfocus to hide keyboard
          _searchFocusNode.unfocus();
        }
      } else {
        keyController.text = '';
        _applySearchFilter();
      }
    });
  }

  void _toggleSort() async {
    // If switching to distance, ensure we have permission and location
    if (_sortMode == SortMode.alphabetical) {
      final error = await LocationService.checkAndRequestLocationAvailability();
      if (error != null) {
        // Show error and keep alphabetical sorting
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
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
            _firstStationMode = null;
            _secondStation = '';
            _secondStationId = '';
            _secondStationMode = null;
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
        searchFocusNode: _searchFocusNode,
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
            firstMode: _firstStationMode,
            secondMode: _secondStationMode,
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
      // Don't return an Expanded here — callers place the tab widgets inside
      // non-Flex parents (TabBarView). Returning Expanded without a Flex
      // ancestor causes a ParentDataWidget assertion (Expanded must be
      // a descendant of a Flex). Return a simple centered indicator instead.
      return const Center(child: CircularProgressIndicator());
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
