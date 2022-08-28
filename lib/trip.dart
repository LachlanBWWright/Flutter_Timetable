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
      'calcNumberOfTrips': '6',
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
    log(jsonDecode(res.body)['journeys'].toString());

    //Fields for each journey in 'journeys'
    //rating
    //isAdditional
    //interchanges
    //legs
    //fare
    //daysOfService
  }

  @override
  void initState() {
    super.initState();
    getTripData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: ListView(
          children: [
            Text('TEST! !!${widget.trip.toString()}!'),
            Text('TEST'),
            Text(testText),
          ],
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
