import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/constants/app_constants.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
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
  bool _hasApiKey = false;

  Future<void> getTrips() async {
    try {
      final journeys = await AppDatabase().getAllJourneys();
      setState(() {
        _journeys = journeys;
      });
    } catch (e) {
      print('Error loading trips: $e');
    }
  }

  Future<void> deleteTrip(int tripId) async {
    try {
      await AppDatabase().deleteJourney(tripId);
      getTrips();
    } catch (e) {
      print('Error deleting trip: $e');
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
    return Scaffold(
      appBar: HomeAppBar(
        title: widget.title,
        hasApiKey: _hasApiKey,
        onAddTrip: _navigateToNewTrip,
        onSettings: _navigateToSettings,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            JourneyList(
              journeys: _journeys,
              onJourneyTap: _navigateToTrip,
              onReverseJourneyTap: _navigateToReverseTrip,
              onDeleteJourney: deleteTrip,
            ),
          ],
        ),
      ),
    );
  }
}
