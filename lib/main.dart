// ignore_for_file: catch_inferred_throwing_calls

import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/app_constants.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/app_bootstrap_service.dart';
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/prefetch_scheduler.dart';
import 'package:lbww_flutter/services/station_loader.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' hide logger;
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/journey_filter_utils.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrapService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _safeTheme(Brightness brightness) {
    return ThemeData(primarySwatch: Colors.blue, brightness: brightness);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: _safeTheme(Brightness.light),
      darkTheme: _safeTheme(Brightness.dark),
      themeMode: ThemeMode.dark, // Use dark mode throughout the application
      onGenerateRoute: DebugNavigation.onGenerateRoute,
      home: const MyHomePage(title: AppConstants.appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

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
  List<db.Journey> _journeys = [];
  List<db.Journey> _filteredJourneys = [];
  bool _hasApiKey = false;
  bool _isEditingMode = false;
  bool _isSearching = false;
  bool _isAlphabeticalSorting = true;
  bool _hasShownLocationSnackBar = false;
  final TextEditingController _searchController = TextEditingController();
  // Single database instance for this stateful widget
  final db.AppDatabase _database = db.AppDatabase();

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
    final result = await JourneyService.loadJourneys(_database);
    final pinnedJourneys = result.pinnedJourneys;
    final unpinnedJourneys = result.unpinnedJourneys;

    final initialJourneys = result.allJourneys;
    if (!mounted) return;
    guardedSetState(() {
      _journeys = initialJourneys;
      _filteredJourneys = _applySearchFilter(initialJourneys);
    });

    TripCacheService.prefetch(initialJourneys);
    prefetchAllStations();
    _prefetchStaticTransportData();

    ScaffoldMessengerState? messenger;
    final isAlphabetical = await LocationService.isAlphabeticalSorting();
    if (!isAlphabetical && mounted && !_hasShownLocationSnackBar) {
      _hasShownLocationSnackBar = true;
      messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Getting your location…'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    final sortedUnpinned = await LocationService.sortJourneys(unpinnedJourneys);

    _hideCurrentMessage();

    final sortedJourneys = [...pinnedJourneys, ...sortedUnpinned];
    if (!mounted) return;
    guardedSetState(() {
      _journeys = sortedJourneys;
      _filteredJourneys = _applySearchFilter(sortedJourneys);
    });
  }

  void _prefetchStaticTransportData() {
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

  Future<void> deleteTrip(int tripId) async {
    final deleted = await JourneyService.deleteJourney(_database, tripId);
    if (deleted) {
      getTrips();
    }
  }

  Future<void> togglePin(int tripId, bool isPinned) async {
    final toggled = await JourneyService.toggleJourneyPin(
      _database,
      tripId,
      isPinned,
    );
    if (toggled) {
      getTrips();
    }
  }

  Future<void> checkApiKey() async {
    final isValid = await TransportApiService.isApiKeyValid();
    if (!mounted) return;
    guardedSetState(() {
      _hasApiKey = isValid;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInitialSorting();
    getTrips();
    checkApiKey();
  }

  Future<void> _loadInitialSorting() async {
    final isAlphabetical = await LocationService.isAlphabeticalSorting();
    if (!mounted) return;
    guardedSetState(() {
      _isAlphabeticalSorting = isAlphabetical;
    });
  }

  Future<void> _toggleSortMode() async {
    final newValue = !_isAlphabeticalSorting;
    await LocationService.setSortingPreference(newValue);
    if (!mounted) return;
    guardedSetState(() {
      _isAlphabeticalSorting = newValue;
    });
    // Re-sort with the new preference
    await getTrips();
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
    disposeChangeNotifierSafely(_searchController);
    super.dispose();
  }

  void _navigateToNewTrip() {
    _pushPage(const NewTripScreen(), getTrips);
  }

  void _navigateToSettings() {
    _pushPage(const SettingsScreen(), checkApiKey);
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
        title: widget.title,
        hasApiKey: _hasApiKey,
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
      body: RefreshIndicator(
        onRefresh: () async {
          await getTrips();
          await checkApiKey();
        },
        child: _filteredJourneys.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.train, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _journeys.isEmpty
                                ? 'No trips saved yet'
                                : 'No trips match your search',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _journeys.isEmpty
                                ? 'Pull down to refresh or add a new trip'
                                : 'Try a different search term',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  // Pinned trips section
                  if (pinnedJourneys.isNotEmpty) ...[
                    JourneyList(
                      journeys: pinnedJourneys,
                      onJourneyTap: _navigateToTrip,
                      onReverseJourneyTap: _navigateToReverseTrip,
                      onJourneyVisible: TripCacheService.prefetchJourney,
                      onDeleteJourney: deleteTrip,
                      onTogglePin: togglePin,
                      isEditingMode: _isEditingMode,
                      isPinnedSection: true,
                    ),
                    if (unpinnedJourneys.isNotEmpty)
                      const Divider(
                        height: 32,
                        thickness: 2,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                  // Unpinned trips section
                  if (unpinnedJourneys.isNotEmpty)
                    JourneyList(
                      journeys: unpinnedJourneys,
                      onJourneyTap: _navigateToTrip,
                      onReverseJourneyTap: _navigateToReverseTrip,
                      onJourneyVisible: TripCacheService.prefetchJourney,
                      onDeleteJourney: deleteTrip,
                      onTogglePin: togglePin,
                      isEditingMode: _isEditingMode,
                      isPinnedSection: false,
                    ),
                ],
              ),
      ),
    );
  }
}
