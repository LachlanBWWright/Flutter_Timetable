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
import 'package:lbww_flutter/widgets/selected_stops/selected_stops_controls.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

part 'new_trip/station_catalog.dart';
part 'new_trip/trip_selection.dart';
part 'new_trip/draft_lookups.dart';
part 'new_trip/manual_journey.dart';
part 'new_trip/station_tab_view.dart';
part 'new_trip/trip_creator_tabs.dart';
part 'new_trip/trip_form.dart';
part 'new_trip/stop_picker.dart';

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
  bool _isSavingTrip = false;
  bool _isApplyingStop = false;
  bool _pickerOpen = false;
  _StopTarget? _pickerTarget;
  bool _pickerNotificationPending = false;
  BuildContext? _pickerContext;
  final _pickerChanges = ValueNotifier(0);
  final _pickerStorage = PageStorageBucket();

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (!_pickerOpen || _pickerNotificationPending) return;
    _pickerNotificationPending = true;
    scheduleMicrotask(() {
      _pickerNotificationPending = false;
      if (mounted && _pickerOpen) _pickerChanges.value++;
    });
  }

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
    _db = AppDatabase();
    if (widget.skipInitialLoad) {
      _tabs = _buildTabs();
      for (final station in widget.initialStations) {
        switch (station.mode ?? TransportMode.train) {
          case TransportMode.train:
            _trainStationList.add(station);
          case TransportMode.lightrail:
            _lightRailStationList.add(station);
          case TransportMode.metro:
            _metroStationList.add(station);
          case TransportMode.bus:
            _busStationList.add(station);
          case TransportMode.ferry:
            _ferryStationList.add(station);
        }
      }
      _tabController = TabController(length: _tabs.length, vsync: this);
      _searchFocusNode = FocusNode();
      addListenerSafely(_tabController, _onTabChanged);
      addListenerSafely(keyController, _applySearchFilter);
      return;
    }
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
    _pickerChanges.dispose();
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

  Future<void> setStation(Station station) async {
    final picker = _pickerContext;
    if (_pickerOpen && picker == null) return;
    if (_pickerOpen && picker != null) {
      _pickerContext = null;
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(picker).pop(station);
      return;
    }
    await _selectStation(station);
  }

  @override
  Widget build(BuildContext context) => _buildTripForm();
}
