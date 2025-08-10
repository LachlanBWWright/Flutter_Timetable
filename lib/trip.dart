import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';

import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/swagger_output/trip_planner.swagger.dart';
import 'package:lbww_flutter/trip_legs_screen.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.trip});

  final Journey trip;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String testText = '';
  List<TripRequestResponseJourney> trips = [];

  Future<void> getTripData() async {
    try {
      final tripData = await TransportApiService.getTrips(
        originId: widget.trip.originId,
        destinationId: widget.trip.destinationId,
      );

      if (!context.mounted) return;

      setState(() {
        trips = tripData;
        testText = tripData.toString();
      });
    } catch (e) {
      print('Error getting trip data: $e');
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
      body: RefreshIndicator(
        onRefresh: getTripData,
        child: trips.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemBuilder: (context, index) {
                  return TripCard(
                    trip: trips[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TripLegScreen(trip: trips[index]),
                        ),
                      );
                    },
                  );
                },
                itemCount: trips.length,
              ),
      ),
    );
  }
}

// TripLegScreen moved to trip_leg_screen.dart
