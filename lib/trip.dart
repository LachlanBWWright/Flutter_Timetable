import 'package:flutter/material.dart';
import 'package:lbww_flutter/logs/logger.dart';
// logger removed
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
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
  List<TripJourney> trips = [];
  bool _isLoading = false;
  String? _error;

  Future<void> getTripData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Getting trip data for ${widget.trip.origin} to ${widget.trip.destination}
      logger.i('Calling gettrips');
      final tripData = await TransportApiService.getTrips(
        originId: widget.trip.originId,
        destinationId: widget.trip.destinationId,
      );

      if (!context.mounted) return;

      setState(() {
        // Reorder trips so upcoming trips (departing now or in future) appear
        // first, followed by past trips. This ensures the UI shows both future
        // and past trips (previously only past trips were prominent).
        final now = DateTime.now();

        DateTime? _getDeparture(TripJourney t) {
          if (t.legs.isEmpty) return null;
          final firstLeg = t.legs.first;
          final dep = firstLeg.origin.departureTimeEstimated ??
              firstLeg.origin.departureTimePlanned;
          return dep != null ? DateTimeUtils.parseTimeToDateTime(dep) : null;
        }

        final allTrips = tripData.tripJourneys;
        final upcoming = <TripJourney>[];
        final past = <TripJourney>[];

        for (final t in allTrips) {
          final dt = _getDeparture(t);
          if (dt != null && !dt.isBefore(now)) {
            upcoming.add(t);
          } else {
            past.add(t);
          }
        }

        // Upcoming: earliest-first
        upcoming.sort((a, b) {
          final da = _getDeparture(a)!, db = _getDeparture(b)!;
          return da.compareTo(db);
        });

        // Past: most-recent-first
        past.sort((a, b) {
          final da = _getDeparture(a), db = _getDeparture(b);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });

        trips = [...upcoming, ...past];
        testText = tripData.toString();
        _isLoading = false;
      });
    } catch (e) {
      // Error getting trip data
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
                    onSelectLeg: (leg) {
                      final tripJourney = trips[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TripLegDetailScreen(leg: leg, trip: tripJourney),
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
