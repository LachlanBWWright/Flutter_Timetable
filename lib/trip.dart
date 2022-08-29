// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key, required this.trip}) : super(key: key);

  final Map<String, dynamic> trip;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String testText = '';
  List<dynamic> trips = [];

  Future<void> getTripData() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');

    //1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus. (For mode)

    final params = {
      //https://opendata.transport.nsw.gov.au/node/601/exploreapi#!/default/tfnsw_dm_request
      'outputFormat': 'rapidJSON',
      'coordOutputFormat': 'EPSG:4326',
      'depArrMacro':
          'dep', //'dep' or 'arr' - Shows trips that depart or arrive before the time
      //'itdate': '20161001',  If not specified, the current server time is used.
      //'idtime': '1200', // If not specified, the current server time is used.
      'type_origin': 'any',
      'name_origin': widget.trip['originId'],
      'type_destination': 'any',
      'name_destination': widget.trip['destinationId'],
      'calcNumberOfTrips': '20',
      //'wheelchair': 'anything' This will block non-wheelchair accessible results
      'excludedMeans': 'checkbox', //'checkbox
      //'exclMOT_1': 1,
      //'exclMOT_4': 1,
      //'exclMOT_5': 1,
      'exclMOT_7': '1',
      //'exclMOT_9': 1,
      'exclMOT_11': '1',
      'TfNSWTR': 'true', //TODO: change back
      'version': '10.2.1.42',
      'itOptionsActive':
          '0', //1 allows individual transport methods to be taken into account
    };
    final uri = Uri.https('api.transport.nsw.gov.au', '/v1/tp/trip/', params);
    final res =
        await http.get(uri, headers: {'authorization': 'apikey $apiKey'});
    if (res.statusCode != 200) return;

    setState(() {
      testText = jsonDecode(res.body)['journeys'].toString();
    });
    //log(jsonDecode(res.body)['journeys'].length);
    for (dynamic journey in jsonDecode(res.body)['journeys']) {
      //print("TEST");
      trips.add(journey);
      //log(journey.toString());
    }
    print(trips.length);
    //Fields for each journey in 'journeys'
    //rating - Number
    //isAdditional - true/false
    //interchanges - Number
    //legs- Array of 'leg' objects
    //  Duration - Number eg 1020 (Likely seconds)
    //  Distance - Number E.G 1114
    //  Origin -
    //  Destination
    //  TODO: Document
    //fare - Object
    //  tickets - Array
    //daysOfService - {rvb: 30000000027CD9F3000000000000000000000000}}
  }

  @override
  void initState() {
    super.initState();
    getTripData();
  }

  String parseTime(String time) {
    //String is in UTC time, with format 2022-08-28T19:55:54Z
    DateTime dt = DateTime.parse(time).toLocal();
    //24-Hour time to 12-hour
    if (dt.hour == 0) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM (${dt.day}/${dt.month})";
    }
    if (dt.hour == 12) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM (${dt.day}/${dt.month})";
    } else if (dt.hour < 12) {
      return "${dt.hour}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM (${dt.day}/${dt.month})";
    } else {
      return "${dt.hour - 12}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM (${dt.day}/${dt.month})";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: ListView.builder(
          itemBuilder: (((context, index) {
            return Card(
              child: ListTile(
                  title: Text(
                      "${trips[index]['legs'][0]['origin']['disassembledName'].toString()} to ${trips[index]['legs'][trips[index]['legs'].length - 1]['destination']['disassembledName'].toString()}"),
                  subtitle: Column(
                    children: [
                      Text(
                          "${parseTime(trips[index]['legs'][0]['origin']['departureTimePlanned'].toString())} - ${parseTime(trips[index]['legs'][trips[index]['legs'].length - 1]['destination']['arrivalTimePlanned'].toString())} (Scheduled)"),
                      Text(
                          "${parseTime(trips[index]['legs'][0]['origin']['departureTimeEstimated'].toString())} - ${parseTime(trips[index]['legs'][trips[index]['legs'].length - 1]['destination']['arrivalTimeEstimated'].toString())} (Estimated)"),
                      Text("Number of legs: ${trips[index]['legs'].length}"),
                      Text(
                          "Number of interchanges: ${trips[index]['interchanges']}"),
                      //Text("Placeholder Text! ${trips[index].toString()}"),
                    ],
                  )),
            );
          })),
          itemCount: trips.length,
        ));
  }
}

//For each leg of the trip (E.G Station, Bus stop, ETC.)
class TripLegScreen extends StatefulWidget {
  const TripLegScreen({Key? key}) : super(key: key);

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: Column(
          children: [
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
          ],
        ));
  }
}
