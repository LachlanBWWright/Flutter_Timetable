import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/constants/app_constants.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

class _MyHomePageState extends State<MyHomePage> {
  List<Journey> _journeys = [];
  List<Journey> _filteredJourneys = [];
  bool _hasApiKey = false;
  bool _isEditingMode = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> getTrips() async {
    try {
      final pinnedJourneys = await AppDatabase().getPinnedJourneys();
      final unpinnedJourneys = await AppDatabase().getUnpinnedJourneys();
      
      // Sort unpinned journeys based on user preference
      final sortedUnpinned = await LocationService.sortJourneys(unpinnedJourneys);
      
      final allJourneys = [...pinnedJourneys, ...sortedUnpinned];
      
      setState(() {
        _journeys = allJourneys;
        _filteredJourneys = allJourneys;
      });
    } catch (e) {
      print('Error loading trips: $e');
    }
  }

  void _filterJourneys(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredJourneys = _journeys;
      } else {
        _filteredJourneys = _journeys.where((journey) {
          return journey.origin.toLowerCase().contains(query.toLowerCase()) ||
                 journey.destination.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> deleteTrip(int tripId) async {
    try {
      await AppDatabase().deleteJourney(tripId);
      getTrips();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Future<void> togglePin(int tripId, bool isPinned) async {
    try {
      await AppDatabase().toggleJourneyPin(tripId, !isPinned);
      getTrips();
    } catch (e) {
      print('Error toggling pin: $e');
    }
  }

  Future<void> checkApiKey() async {
    try {
      final isValid = await TransportApiService.isApiKeyValid();
      setState(() {
        _hasApiKey = isValid;
      });
    } catch (err) {
      setState(() {
        _hasApiKey = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTrips();
    checkApiKey();
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredJourneys = _journeys;
      }
    });
  }

  void _toggleEditingMode() {
    setState(() {
      _isEditingMode = !_isEditingMode;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToNewTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewTripScreen()),
    ).then((val) {
      getTrips();
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((val) {
      checkApiKey();
    });
  }

  void _navigateToTrip(Journey journey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripScreen(
          trip: {
            'id': journey.id,
            'origin': journey.origin,
            'originId': journey.originId,
            'destination': journey.destination,
            'destinationId': journey.destinationId,
          },
        ),
      ),
    );
  }

  void _navigateToReverseTrip(Journey journey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripScreen(
          trip: {
            'id': journey.id,
            'origin': journey.destination,
            'originId': journey.destinationId,
            'destination': journey.origin,
            'destinationId': journey.originId,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedJourneys = _filteredJourneys.where((j) => j.isPinned).toList();
    final unpinnedJourneys = _filteredJourneys.where((j) => !j.isPinned).toList();
    
    return Scaffold(
      appBar: HomeAppBar(
        title: widget.title,
        hasApiKey: _hasApiKey,
        isSearching: _isSearching,
        isEditingMode: _isEditingMode,
        onAddTrip: _navigateToNewTrip,
        onSettings: _navigateToSettings,
        onToggleSearch: _toggleSearchMode,
        onToggleEdit: _toggleEditingMode,
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
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.train,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _journeys.isEmpty ? 'No trips saved yet' : 'No trips match your search',
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
