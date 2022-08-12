import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({Key? key}) : super(key: key);

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  Future<http.Response> fetchTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');

    /* $params = array(
    'outputFormat' => 'rapidJSON',
    'odvSugMacro' => 1
    'name_sf' => $searchQuery,
    'coordOutputFormat' => 'EPSG:4326',
    'TfNSWSF' => 'true'
    ); */

    //https://opendata.transport.nsw.gov.au/system/files/resources/Trip%20Planner%20API%20manual-opendataproduction%20v3.2.pdf
    //https://opendata.transport.nsw.gov.au/node/601/exploreapi#!/default/tfnsw_stopfinder_request

    final params = {
      'outputFormat': 'rapidJSON',
      //'odvSugMacro': '1',
      'type_sf': 'stop',
      'name_sf': 'a',
      'coordOutputFormat': 'EPSG:4326',
      'TfNSWSF': 'true',
      'version': '10.2.1.42',
    };
    final uri =
        Uri.https('api.transport.nsw.gov.au', '/v1/tp/stop_finder/', params);

    final res =
        await http.get(uri, headers: {'authorization': 'apikey $apiKey'});

    print(res.body);

    //print(body.length);

    return http.get(
      Uri.parse(
          'https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete'),
      headers: {'authorization': 'apikey $apiKey'},
    );
  }

  @override
  void initState() {
    super.initState();

    fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add New Trip')),
        body: Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              const Text('MALARKEY'),
              const SizedBox(height: 10),
            ])));
  }
}
