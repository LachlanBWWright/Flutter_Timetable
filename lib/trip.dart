import 'package:flutter/material.dart';
import 'package:lbww_flutter/backends/TripPlannerApi.dart';
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
  bool _isLoading = false;
  String? _error;

  Future<void> getTripData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print(
          'Getting trip data for ${widget.trip.origin} to ${widget.trip.destination}');

      final tripData = await TransportApiService.getTrips(
        originId: widget.trip.originId,
        destinationId: widget.trip.destinationId,
      );
      print('Trip data received: $tripData');

      if (!context.mounted) return;

      setState(() {
        trips = tripData;
        testText = tripData.toString();
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting trip data: $e');
      if (!context.mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
      body: RefreshIndicator(
        onRefresh: getTripData,
        child: trips.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading)
                            const CircularProgressIndicator()
                          else
                            const Icon(Icons.info_outline,
                                size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            Text(
                                'Loading trips from ${widget.trip.origin} to ${widget.trip.destination}...')
                          else if (_error != null)
                            Column(
                              children: [
                                Text('Error loading trips:\n$_error',
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: getTripData,
                                  child: const Text('Retry'),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Text(
                                    'No trips found from ${widget.trip.origin} to ${widget.trip.destination}.'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: getTripData,
                                  child: const Text('Search again'),
                                ),
                              ],
                            ),
                        ],
                      ),
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
