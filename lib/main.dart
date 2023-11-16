import 'package:flutter/material.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSW Trains Timetable',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NSW Trains Timetable'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _journeys = [];
  bool _hasApiKey = false;

  Future<void> getTrips() async {
    print('GET Trips function');

    WidgetsFlutterBinding.ensureInitialized();
    final database =
        await openDatabase(join(await getDatabasesPath(), 'trip_database.db'),
            onCreate: ((Database db, int version) async {
      return await db.execute(
          'CREATE TABLE journeys(id INTEGER PRIMARY KEY AUTOINCREMENT, origin TEXT, originId TEXT, destination TEXT, destinationId TEXT)');
    }), version: 1);

    try {
      final List<Map<String, dynamic>> journeys =
          await database.query('journeys');
      print(journeys);
      setState(() {
        _journeys = journeys;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTrip(int trip) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database =
        await openDatabase(join(await getDatabasesPath(), 'trip_database.db'));
    try {
      await database.delete('journeys', where: 'id = $trip');
      getTrips();
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('apiKey');

      final params = {
        //https://opendata.transport.nsw.gov.au/system/files/resources/Trip%20Planner%20API%20manual-opendataproduction%20v3.2.pdf https://opendata.transport.nsw.gov.au/node/601/exploreapi#!/default/tfnsw_stopfinder_request
        'outputFormat': 'rapidJSON',
        'type_sf': 'stop',
        'name_sf': '',
        'coordOutputFormat': 'EPSG:4326',
        'TfNSWSF': 'true',
        'version': '10.2.1.42',
      };
      final uri =
          Uri.https('api.transport.nsw.gov.au', '/v1/tp/stop_finder/', params);
      final res =
          await http.get(uri, headers: {'authorization': 'apikey $apiKey'});

      if (res.statusCode == 200) {
        setState(
          () {
            _hasApiKey = true;
          },
        );
      } else {
        setState(() {
          _hasApiKey = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (_hasApiKey)
            IconButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewTripScreen()))
                      .then((val) {
                    getTrips();
                  });
                },
                icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()))
                    .then((val) {
                  checkApiKey();
                });
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemCount: _journeys.length,
              itemBuilder: ((context, index) {
                return Card(
                    child: ListTile(
                  title: Text(_journeys[index]['origin'] +
                      ' - ' +
                      _journeys[index]['destination'].toString()),
                  subtitle: Text(
                      'Trip from ${_journeys[index]['origin']} to ${_journeys[index]['destination']}'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TripScreen(trip: _journeys[index])));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteTrip(_journeys[index]['id']);
                    },
                  ),
                ));
              }),
            ))
          ],
        ),
      ),
    );
  }
}
