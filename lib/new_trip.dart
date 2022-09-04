import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lbww_flutter/schema/journey.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({Key? key}) : super(key: key);

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  List<Station> _trainStationList = [];
  List<Station> _busStationList = [];
  List<Station> _ferryStationList = [];
  List<Station> _lightRailStationList = [];
  String _firstStation = '';
  String _firstStationId = '';
  String _secondStation = '';
  String _secondStationId = '';
  List<Station> _selectedStations = [];
  bool _isSearching = false;
  final keyController = TextEditingController();

  Future<Database> initDb() async {
    //sqfliteFfiInit();
    WidgetsFlutterBinding.ensureInitialized();

    final database =
        await openDatabase(join(await getDatabasesPath(), 'trip_database.db'),
            onCreate: ((Database db, int version) async {
      return await db.execute(
          'CREATE TABLE journeys(id INTEGER PRIMARY KEY AUTOINCREMENT, origin TEXT, originId TEXT, destination TEXT, destinationId TEXT)');
    }), version: 1);
    return database;
  }

  Future<void> insertJourney(Journey journey) async {
    try {
      final db = await initDb();
      await db.insert('journeys', journey.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    // ignore: empty_catches
    catch (e) {}
  }

  void setStation(String station, String id) async {
    setState(() {
      if (_firstStation == '') {
        _firstStation = station;
        _firstStationId = id;
        keyController.text = '';
      } else {
        _secondStation = station;
        _secondStationId = id;
        keyController.text = '';
      }
    });
    loadStations();
  }

  Future<void> loadStations() async {
    final dataset =
        await rootBundle.loadString('assets/LocationFacilityData.csv');
    List<dynamic> data = const CsvToListConverter().convert(dataset, eol: "\n");
    data.removeWhere((station) => !station[9].contains("Train"));
    //[10] - Mode
    var trainStations = List<Station>.empty(growable: true);
    var busStations = List<Station>.empty(growable: true);
    var lightRailStations = List<Station>.empty(growable: true);
    var ferryStations = List<Station>.empty(growable: true);
    for (var station in data) {
      if (station[9].contains("Train")) {
        trainStations.add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains("Bus")) {
        busStations.add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains("Light")) {
        lightRailStations
            .add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains("Ferry")) {
        ferryStations.add(Station(name: station[0], id: station[4].toString()));
      }
    }

    setState(() {
      _trainStationList = trainStations;
      _busStationList = busStations;
      _lightRailStationList = lightRailStations;
      _ferryStationList = ferryStations;
    });
  }

  void loadSearchStations(String search) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');

    final params = {
      //https://opendata.transport.nsw.gov.au/system/files/resources/Trip%20Planner%20API%20manual-opendataproduction%20v3.2.pdf https://opendata.transport.nsw.gov.au/node/601/exploreapi#!/default/tfnsw_stopfinder_request
      'outputFormat': 'rapidJSON',
      'type_sf': 'any',
      'name_sf': search,
      'coordOutputFormat': 'EPSG:4326',
      'TfNSWSF': 'true',
      'version': '10.2.1.42',
    };
    final uri =
        Uri.https('api.transport.nsw.gov.au', '/v1/tp/stop_finder/', params);
    final res =
        await http.get(uri, headers: {'authorization': 'apikey $apiKey'});

    if (res.statusCode == 200) {
      var stations = List<Station>.empty(growable: true);

      for (dynamic location in jsonDecode(res.body)['locations']) {
        stations.add(Station(
            name: '${location['disassembledName']}', id: '${location['id']}'));
      }
      setState(() {
        _trainStationList = stations;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadStations();
    initDb();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      controller: keyController,
                      decoration: const InputDecoration(
                          hintText: "Search for a station",
                          hintStyle: TextStyle(color: Colors.white)),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) {
                        loadSearchStations(value);
                      },
                    )
                  : const Text('Add New Trip'),
              actions: [
                if (_firstStation == '' || _secondStation == '')
                  if (_isSearching)
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (keyController.text == '') {
                              _isSearching = false;
                            } else {
                              keyController.text = '';
                            }
                          });
                        },
                        icon: const Icon(Icons.cancel))
                  else
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        icon: const Icon(Icons.search))
                else
                  IconButton(
                      onPressed: () async {
                        insertJourney(Journey(
                            origin: _firstStation,
                            originId: _firstStationId,
                            destination: _secondStation,
                            destinationId: _secondStationId));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Saved trip from $_firstStation to $_secondStation."),
                        ));
                        setState(() {
                          _firstStation = '';
                          _firstStationId = '';
                          _secondStation = '';
                          _secondStationId = '';
                        });
                      },
                      icon: const Icon(Icons.arrow_forward))
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(
                      icon: Icon(
                    Icons.directions_train,
                    color: Color.fromARGB(255, 255, 97, 35),
                  )),
                  Tab(
                      icon: Icon(
                    Icons.tram,
                    color: Color.fromARGB(255, 255, 82, 82),
                  )),
                  Tab(
                      icon: Icon(Icons.directions_bus,
                          color: Color.fromARGB(255, 82, 186, 255))),
                  Tab(
                      icon: Icon(Icons.directions_ferry,
                          color: Color.fromARGB(255, 68, 240, 91))),
                  Tab(icon: Icon(Icons.map)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    if (_firstStation != '')
                      Stack(
                        children: [
                          Align(
                            child: Text(
                              'First Station Selected: $_firstStation',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                              right: 0,
                              child: InkWell(
                                  onTap: (() {
                                    setState(() {
                                      _firstStation = '';
                                      _firstStationId = '';
                                    });
                                  }),
                                  child: const Icon(Icons.cancel, size: 12)))
                        ],
                      ),
                    if (_secondStation != '')
                      Stack(
                        children: [
                          Align(
                            child: Text(
                              'Second Station Selected: $_secondStation',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                              right: 0,
                              child: InkWell(
                                  onTap: (() {
                                    setState(() {
                                      _secondStation = '';
                                      _secondStationId = '';
                                    });
                                  }),
                                  child: const Icon(Icons.cancel, size: 12)))
                        ],
                      ),
                    Expanded(
                      child: StationList(
                        listItems: _trainStationList,
                        setStation: setStation,
                      ),
                    )
                  ],
                ),
                StationList(
                  listItems: _lightRailStationList,
                  setStation: setStation,
                ),
                StationList(
                  listItems: _busStationList,
                  setStation: setStation,
                ),
                StationList(
                  listItems: _ferryStationList,
                  setStation: setStation,
                ),
                const Text('Placeholder'),
              ],
            )));
  }
}

class StationList extends StatelessWidget {
  final List<Station> listItems;
  final Function(String, String) setStation;

  const StationList(
      {Key? key, required this.listItems, required this.setStation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listItems.length,
        itemBuilder: (context, index) {
          return StationView(station: listItems[index], setStation: setStation);
        });
  }
}

class StationView extends StatelessWidget {
  final Station station;
  final Function(String, String) setStation;

  const StationView({Key? key, required this.station, required this.setStation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      child: Card(
          child: InkWell(
              onTap: () {
                setStation(station.name, station.id);
              },
              child: ListTile(
                title: Text(station.name),
              ))),
    );
  }
}

class StationSelectionColumn extends StatefulWidget {
  @override
  State<StationSelectionColumn> createState() => _StationSelectionColumnState();
}

class _StationSelectionColumnState extends State<StationSelectionColumn> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Station {
  String name;
  String id;
  double? latitude;
  double? longitude;
  Station({
    required this.name,
    required this.id,
    this.latitude,
    this.longitude,
  });
}
