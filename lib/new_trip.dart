import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({Key? key}) : super(key: key);

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  List<Station> _stationList = [];
  String _firstStation = '';
  String _secondStation = '';
  bool _isSearching = false;
  final keyController = TextEditingController();

  void setStation(String station) {
    setState(() {
      if (_firstStation == '') {
        _firstStation = station;
      } else {
        _secondStation = station;
      }
    });
  }

  Future<http.Response> fetchTrips(String stop) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');

    final params = {
      //https://opendata.transport.nsw.gov.au/system/files/resources/Trip%20Planner%20API%20manual-opendataproduction%20v3.2.pdf https://opendata.transport.nsw.gov.au/node/601/exploreapi#!/default/tfnsw_stopfinder_request
      'outputFormat': 'rapidJSON',
      'type_sf': 'stop',
      'name_sf': stop,
      'coordOutputFormat': 'EPSG:4326',
      'TfNSWSF': 'true',
      'version': '10.2.1.42',
    };
    final uri =
        Uri.https('api.transport.nsw.gov.au', '/v1/tp/stop_finder/', params);
    final res =
        await http.get(uri, headers: {'authorization': 'apikey $apiKey'});

    print(jsonDecode(res.body)['locations']);
    for (dynamic location in jsonDecode(res.body)['locations']) {
      print(location);
    }

    return res;
  }

  Future<List<Station>> loadStations() async {
    final dataset =
        await rootBundle.loadString('assets/LocationFacilityData.csv');
    List<dynamic> data = const CsvToListConverter().convert(dataset, eol: "\n");
    data.removeWhere((station) => !station[0].contains("Station"));

    var stations = List<Station>.empty(growable: true);

    for (var element in data) {
      stations.add(Station(element[0], element[6]));
    }

    print(stations[57]);
    return stations;
  }

  @override
  void initState() {
    super.initState();
    loadStations().then((res) {
      setState(() {
        {
          _stationList = res;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                      hintText: "Search for a station",
                      hintStyle: TextStyle(color: Colors.white)),
                  style: const TextStyle(color: Colors.white),
                )
              : const Text('Add New Trip'),
          actions: [
            if (_firstStation == '' || _secondStation == '')
              if (_isSearching)
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
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
                    //TODO: Save the trip to storage
                    fetchTrips(_firstStation);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Saved trip from $_firstStation to $_secondStation."),
                    ));
                    setState(() {
                      _firstStation = '';
                      _secondStation = '';
                    });
                  },
                  icon: const Icon(Icons.arrow_forward))
          ],
        ),
        body: Column(
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
                            });
                          }),
                          child: const Icon(Icons.cancel, size: 20)))
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
                            });
                          }),
                          child: const Icon(Icons.cancel, size: 20)))
                ],
              ),
            Expanded(
              child: StationList(
                listItems: _stationList,
                setStation: setStation,
              ),
            )
          ],
        ));
  }
}

class StationList extends StatelessWidget {
  final List<Station> listItems;
  final Function(String) setStation;

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
  final Function(String) setStation;

  const StationView({Key? key, required this.station, required this.setStation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      child: Card(
          child: InkWell(
              onTap: () {
                setStation(station.name);
              },
              child: Column(
                children: [
                  Text(station.name),
                  Text(station.address),
                ],
              ))),
    );
  }
}

class Station {
  String name;
  String address;
  Station(this.name, this.address);
}
