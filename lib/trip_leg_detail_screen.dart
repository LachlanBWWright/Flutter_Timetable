import 'package:flutter/material.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

/// Screen for tracking an individual trip leg with real-time updates
class TripLegDetailScreen extends StatefulWidget {
  final Leg leg;

  const TripLegDetailScreen({super.key, required this.leg});

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen> {
  Leg? _updatedLeg;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _updatedLeg = widget.leg;
    _refreshLegData();
  }

  Future<void> _refreshLegData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, just use the original leg data since real-time updates
      // would require additional API endpoints
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    if (estimatedTime == null) {
      return plannedTime != null
          ? DateTimeUtils.parseTimeOnly(plannedTime)
          : 'TBD';
    }

    if (plannedTime == null) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }

    try {
      final planned = DateTimeUtils.parseTimeToDateTime(plannedTime);
      final estimated = DateTimeUtils.parseTimeToDateTime(estimatedTime);

      if (planned == null || estimated == null) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      }

      final difference = estimated.difference(planned).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leg = _updatedLeg ?? widget.leg;
    final transportation = leg.transportation;
    final transportProduct = transportation?.product;
    final transportClass = transportProduct?.classField;

    final origin = leg.origin;
    final destination = leg.destination;
    final originName = origin.disassembledName ?? origin.name;
    final destinationName = destination.disassembledName ?? destination.name;
    final transportName =
        transportation?.name ?? transportation?.disassembledName ?? '';

    final modeColor = transportClass != null
        ? TransportModeUtils.getModeColor(transportClass)
        : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Leg Details'),
        backgroundColor: modeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLegData,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealtimeMapWidget(
                    leg: leg,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLegData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: modeColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            transportClass != null
                                ? TransportModeUtils.getModeName(transportClass)
                                : 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (transportName.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              transportName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: modeColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                originName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: modeColor,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                destinationName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Timing information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timing Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Departure time
                    Row(
                      children: [
                        const Icon(Icons.departure_board, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Departure',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                _formatTimeDifference(
                                  origin.departureTimePlanned,
                                  origin.departureTimeEstimated,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Arrival time
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Arrival',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                _formatTimeDifference(
                                  destination.arrivalTimePlanned,
                                  destination.arrivalTimeEstimated,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        const SizedBox(width: 8),
                        Text(_isLoading ? 'Updating...' : 'On schedule'),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
