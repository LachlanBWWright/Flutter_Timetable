// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TripLegScreen(trip: trips[index])));
                  },
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
  const TripLegScreen({Key? key, required this.trip}) : super(key: key);
  final dynamic trip;

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  List<Widget> getStops(int index) {
    List<Widget> stops = [];

    try {
      for (dynamic stop in widget.trip['legs'][index]['stopSequence']) {
        stops.add(Text(
            "${stop['disassembledName'] ?? stop['name']} ${stop['departureTimePlanned'] != null ? parseTime(stop['departureTimePlanned']) : "(TBD)"}"));
      }
    } catch (e) {
      stops.add(Text("Walk!"));
    }

    return stops;
  }

  //TODO: Implement!
  Color getModeColor(int id) {
    //1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus. (For mode) 100 - Walking??
    //0xAARRGGBB
    print(id);
    if (id == 1) {
      return Color.fromARGB(255, 255, 97, 35);
    } else if (id == 4) {
      return Color.fromARGB(255, 255, 82, 82);
    } else if (id == 5 || id == 11) {
      return Color.fromARGB(255, 82, 186, 255);
    } else if (id == 7) {
      return Color.fromARGB(255, 161, 84, 47);
    } else if (id == 9) {
      return Color.fromARGB(255, 68, 240, 91);
    }
    return Color(0xFFFFFFFF);
  }

  String getModeName(int id) {
    //1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus. (For mode) 100 - Walking??
    //0xAARRGGBB
    print(id);
    if (id == 1) {
      return "Train";
    } else if (id == 4) {
      return "Light Rail";
    } else if (id == 5) {
      return "Bus";
    } else if (id == 11) {
      return "School Bus";
    } else if (id == 7) {
      return "Coach";
    } else if (id == 9) {
      return "Ferry";
    } else if (id == 100) {
      return "Walk";
    }
    return "(Unknown)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: ListView.builder(
          itemBuilder: (((context, index) {
            return Card(
              color: getModeColor(widget.trip['legs'][index]['transportation']
                  ['product']['class']),
              child: ListTile(
                  title: Text(
                      "(${getModeName(widget.trip['legs'][index]['transportation']['product']['class'])}) ${widget.trip['legs'][index]['origin']['disassembledName'] ?? widget.trip['legs'][index]['origin']['name']} to ${widget.trip['legs'][index]['destination']['disassembledName'] ?? widget.trip['legs'][index]['destination']['name']}"),
                  subtitle: Column(
                    children: <Widget>[
/*                       Text(widget.trip['legs'][index]['transportation']
                          .toString()),
                      Text(""), */ //TODO: Uncomment for more data
                      Text(widget.trip['legs'][index]['transportation']
                              ['name'] ??
                          widget.trip['legs'][index]['transportation']
                              ['disassembledName'] ??
                          ""),
                      Text(""),
                      ...getStops(index)
                    ]
                    //Text("Test ${widget.trip['legs'][index].toString()}"),
                    ,
                  )),
            );
          })),
          itemCount: widget.trip['legs'].length,
        ));
  }
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
