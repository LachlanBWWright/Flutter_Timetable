import 'package:flutter/material.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.trip});

  final Map<String, dynamic> trip;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String testText = '';
  List<dynamic> trips = [];

  Future<void> getTripData() async {
    try {
      final tripData = await TransportApiService.getTrips(
        originId: widget.trip['originId'],
        destinationId: widget.trip['destinationId'],
      );

      setState(() {
        trips = tripData;
        testText = tripData.toString();
      });
    } catch (e) {
      print('Error getting trip data: $e');
      setState(() {
        trips = [];
        testText = 'Error loading trip data: $e';
      });
    }
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
  const TripLegScreen({super.key, required this.trip});
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
