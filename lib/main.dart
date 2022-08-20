// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/settings.dart';

import 'package:path/path.dart';
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

  Future<void> getTrips() async {
    print('GET Trips function');

    WidgetsFlutterBinding.ensureInitialized();
    final database =
        await openDatabase(join(await getDatabasesPath(), 'trip_database.db'));

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

  @override
  void initState() {
    super.initState();
    getTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewTripScreen()))
                    .then((val) {
                  getTrips(); //TODO: Replace
                });
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
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
                return ListTile(
                  title: Text(_journeys[index]['origin'] +
                      ' - ' +
                      _journeys[index]['destination'].toString()),
                  subtitle: Text('Trip from ' +
                      _journeys[index]['origin'] +
                      ' to ' +
                      _journeys[index]['destination']),
                );
              }),
            ))
          ],
        ),
      ),
    );
  }
}

class Trip extends StatelessWidget {
  Trip(List<Map<String, dynamic>> journeys);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: ((context, index) {
        return const Text('TEST');
      }),
    );
  }
}
