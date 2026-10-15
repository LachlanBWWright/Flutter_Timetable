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
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/new_trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

part 'new_trip/station_catalog.dart';
part 'new_trip/trip_selection.dart';
part 'new_trip/draft_lookups.dart';
part 'new_trip/manual_journey.dart';
part 'new_trip/station_tab_view.dart';
part 'new_trip/trip_creator_tabs.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({
    super.key,
    this.skipInitialLoad = false,
    this.initialStations = const [],
  });

  final bool skipInitialLoad;
  final List<Station> initialStations;

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
  List<Station> _regionalSearchResults = [];
  bool _isRegionalSearchLoading = false;
  bool _regionalSearchFailed = false;
  TransitRegion? _draftRegion;
  int _searchGeneration = 0;
  int _draftGeneration = 0;
  int _lineLookupGeneration = 0;
  int _sharedLineLookupGeneration = 0;
  int _interchangeLookupGeneration = 0;
  bool _isSavingTrip = false;
  Timer? _searchDebounce;
  final Map<_TripCreatorTabKind, int> _sortGenerations = {};

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
  late final AppDatabase _db;
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
    if (widget.skipInitialLoad) {
      _tabs = _buildTabs();
      _trainStationList = List<Station>.of(widget.initialStations);
      _tabController = TabController(length: _tabs.length, vsync: this);
      _searchFocusNode = FocusNode();
      return;
    }
    _db = AppDatabase();
    _tabs = _buildTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
    addListenerSafely(_tabController, _onTabChanged);
    addListenerSafely(
      TransportPreferencesService.showNswTrainLink,
      _onTransportPreferencesChanged,
    );
    addListenerSafely(keyController, _applySearchFilter);
    addListenerSafely(
      AppTransitContext.instance.enabledRegionsListenable,
      _applySearchFilter,
    );
    addListenerSafely(
      AppTransitContext.instance.selectedRegionListenable,
      _applySearchFilter,
    );
    _searchFocusNode = FocusNode();
    _loadAllModes();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchGeneration++;
    removeListenerSafely(
      TransportPreferencesService.showNswTrainLink,
      _onTransportPreferencesChanged,
    );
    removeListenerSafely(_tabController, _onTabChanged);
    disposeChangeNotifierSafely(_tabController);
    removeListenerSafely(
      AppTransitContext.instance.enabledRegionsListenable,
      _applySearchFilter,
    );
    removeListenerSafely(
      AppTransitContext.instance.selectedRegionListenable,
      _applySearchFilter,
    );
    removeListenerSafely(keyController, _applySearchFilter);
    disposeChangeNotifierSafely(keyController);
    disposeFocusNodeSafely(_searchFocusNode);
    try {
      super.dispose();
    } catch (_) {}
  }

  Future<void> setStation(Station station) => _selectStation(station);

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
        onOpenMap: _canUseNswStopsMap ? _openMap : null,
        onToggleSort: _toggleSort,
        sortMode: _sortMode,
        showMapView: _showMapView,
        tabController: _tabController,
        tabs: _tabs.map((tab) => tab.tab).toList(),
      ),
      body: Column(
        children: [
          if (_draftRegion case final region?)
            MaterialBanner(
              content: Text('Trip region: ${region.label}'),
              actions: const [SizedBox.shrink()],
            )
          else if (AppTransitContext.instance.enabledRegions.length > 1)
            const MaterialBanner(
              content: Text(
                'Search all enabled regions. Selecting the first stop locks this trip to that region.',
              ),
              actions: [SizedBox.shrink()],
            ),
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
}
