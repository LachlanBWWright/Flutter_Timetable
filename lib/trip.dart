// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';

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
      'TfNSWTR': 'true',
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
    for (dynamic journey in jsonDecode(res.body)['journeys']) {
      trips.add(journey);
    }
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
    return DateTimeUtils.parseTime(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return TripCard(
            trip: trips[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripLegScreen(trip: trips[index]),
                ),
              );
            },
          );
        },
        itemCount: trips.length,
      ),
    );
  }
}

//For each leg of the trip (E.G Station, Bus stop, ETC.)
class TripLegScreen extends StatefulWidget {
  const TripLegScreen({Key? key, required this.trip}) : super(key: key);
  final dynamic trip;

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return TripLegCard(leg: widget.trip['legs'][index]);
        },
        itemCount: widget.trip['legs'].length,
      ),
    );
  }
}


