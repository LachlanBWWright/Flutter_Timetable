import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/prefetch_scheduler.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' hide logger;
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/journey_filter_utils.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';

import 'home_controller.dart';

part 'home_sorting.dart';
part 'home_journeys_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.skipInitialLoad = false,
    this.initialJourneys = const [],
    this.database,
  });
  final String title;
  final bool skipInitialLoad;
  final List<db.Journey> initialJourneys;
  final db.AppDatabase? database;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<StopsEndpoint> _staticPrefetchEndpoints() {
  return StopsEndpoint.values.toList()..sort(
    (left, right) =>
        _staticEndpointPriority(left).compareTo(_staticEndpointPriority(right)),
  );
}

int _staticEndpointPriority(StopsEndpoint endpoint) {
  if (endpoint == StopsEndpoint.sydneytrains) return 0;
  if (endpoint == StopsEndpoint.metro) return 1;
  if (endpoint.key.startsWith('lightrail')) return 2;
  if (endpoint.key.startsWith('ferries')) return 3;
  if (endpoint.key.startsWith('buses')) return 4;
  if (endpoint == StopsEndpoint.nswtrains) return 5;
  return 6;
}

class _MyHomePageState extends State<MyHomePage> with GuardedState<MyHomePage> {
  late final HomeController _controller;
  List<db.Journey> _journeys = [];
  List<db.Journey> _filteredJourneys = [];
  bool _isEditingMode = false;
  bool _isSearching = false;
  bool _isAlphabeticalSorting = true;
  bool _isSavingSorting = false;
  bool _hasShownLocationSnackBar = false;
  bool _hasShownApiKeyWarning = false;
  String? _shownActionError;
  final TextEditingController _searchController = TextEditingController();

  void _hideCurrentMessage() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }

  void _pushPage(Widget page, VoidCallback onReturn) {
    pushPage((context) => page).then((_) => runGuarded(onReturn));
  }

  void _enqueueStaticPrefetch(StopsEndpoint endpoint) {
    PrefetchScheduler.instance.enqueueStatic(
      key: endpoint.key,
      priority: _staticEndpointPriority(endpoint),
      job: () async {
        await for (final _ in NewTripService.updateStaticTransportData(
          endpoints: [endpoint],
        )) {}
      },
    );
  }

  Future<void> getTrips() async {
    await _controller.load();
    if (!mounted || _controller.state.loadFailed) return;
    final journeys = _controller.state.journeys;
    guardedSetState(() {
      _journeys = journeys;
      _filteredJourneys = _applySearchFilter(journeys);
    });
    if (AppTransitContext.instance.selectedRegion == TransitRegion.nsw) {
      TripCacheService.prefetch(journeys);
      prefetchAllStations();
      _prefetchStaticTransportData();
    }

    final isAlphabetical = await LocationService.isAlphabeticalSorting();
    if (!isAlphabetical && mounted && !_hasShownLocationSnackBar) {
      _hasShownLocationSnackBar = true;
      showSnackBar(
        const SnackBar(
          content: Text('Getting your location…'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    _hideCurrentMessage();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final actionError = _controller.state.actionError;
    if (actionError != null && actionError != _shownActionError) {
      showSnackBar(SnackBar(content: Text(actionError)));
    }
    _shownActionError = actionError;
    final journeys = _controller.state.journeys;
    guardedSetState(() {
      _journeys = journeys;
      _filteredJourneys = _applySearchFilter(journeys);
    });
  }

  void _prefetchStaticTransportData() {
    if (AppTransitContext.instance.selectedRegion != TransitRegion.nsw) {
      return;
    }
    for (final endpoint in _staticPrefetchEndpoints()) {
      _enqueueStaticPrefetch(endpoint);
    }
  }

  List<db.Journey> _applySearchFilter(List<db.Journey> journeys) {
    return filterJourneysByQuery(journeys, _searchController.text);
  }

  void _filterJourneys(String query) {
    guardedSetState(() {
      _filteredJourneys = filterJourneysByQuery(_journeys, query);
    });
  }

  Future<void> _validateApiKey({required bool notifyOnFailure}) async {
    final services = AppTransitContext.instance.currentServices;
    if (!services.supportsJourneyPlanning ||
        services.region != TransitRegion.nsw) {
      return;
    }

    final isValid = await TransportApiService.isApiKeyValid();
    if (!mounted || isValid || !notifyOnFailure || _hasShownApiKeyWarning) {
      return;
    }

    _hasShownApiKeyWarning = true;
    showSnackBar(
      SnackBar(
        content: const Text(
          'Transport API key validation failed. Journey planning may not work.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: _navigateToSettings,
        ),
      ),
    );
  }

  Future<void> deleteTrip(int tripId) => _controller.delete(tripId);

  Future<void> togglePin(int tripId, bool isPinned) =>
      _controller.togglePin(tripId, isPinned);

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      databaseProvider: () => widget.database ?? db.AppDatabase(),
      initialJourneys: widget.initialJourneys,
    )..addListener(_onControllerChanged);
    _journeys = _controller.state.journeys;
    _filteredJourneys = _applySearchFilter(_journeys);
    if (widget.skipInitialLoad) {
      return;
    }
    _loadInitialSorting();
    getTrips();
    addPostFrameCallbackSafely((_) {
      unawaited(_validateApiKey(notifyOnFailure: true));
    });
  }

  Future<void> _loadInitialSorting() async {
    final isAlphabetical = await LocationService.isAlphabeticalSorting();
    if (!mounted) return;
    guardedSetState(() {
      _isAlphabeticalSorting = isAlphabetical;
    });
  }

  void _toggleSearchMode() {
    guardedSetState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredJourneys = _journeys;
      }
    });
  }

  void _toggleEditingMode() {
    guardedSetState(() {
      _isEditingMode = !_isEditingMode;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    disposeChangeNotifierSafely(_searchController);
    super.dispose();
  }

  void _navigateToNewTrip() {
    if (!AppTransitContext.instance.currentServices.supportsJourneyPlanning) {
      showSnackBar(
        SnackBar(
          content: Text(
            'Journey planning is unavailable in ${AppTransitContext.instance.selectedRegion.label}.',
          ),
        ),
      );
      return;
    }
    _pushPage(const NewTripScreen(), getTrips);
  }

  void _navigateToSettings() {
    _pushPage(const SettingsScreen(), () {
      unawaited(_validateApiKey(notifyOnFailure: true));
    });
  }

  void _navigateToTrip(db.Journey journey) {
    TripCacheService.prefetchJourney(journey);
    _pushPage(TripScreen(trip: journey), () {});
  }

  void _navigateToReverseTrip(db.Journey journey) {
    final reversedJourney = journey.reversedPreviewJourney();
    TripCacheService.prefetchJourney(reversedJourney);
    _pushPage(TripScreen(trip: reversedJourney), () {});
  }

  @override
  Widget build(BuildContext context) {
    final sections = splitJourneySections(_filteredJourneys);
    final pinnedJourneys = sections.pinnedJourneys;
    final unpinnedJourneys = sections.unpinnedJourneys;

    return Scaffold(
      appBar: HomeAppBar(
        title:
            '${widget.title} • ${AppTransitContext.instance.selectedRegion.shortLabel}',
        canAddTrip:
            AppTransitContext.instance.currentServices.supportsJourneyPlanning,
        isSearching: _isSearching,
        isEditingMode: _isEditingMode,
        hasTrips: _journeys.isNotEmpty,
        isAlphabeticalSorting: _isAlphabeticalSorting,
        onAddTrip: _navigateToNewTrip,
        onSettings: _navigateToSettings,
        onToggleSearch: _toggleSearchMode,
        onToggleEdit: _toggleEditingMode,
        onToggleSort: _toggleSortMode,
        onSearchChanged: _filterJourneys,
        searchController: _searchController,
      ),
      body: _buildJourneysBody(context, pinnedJourneys, unpinnedJourneys),
    );
  }
}
