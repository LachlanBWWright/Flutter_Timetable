import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/saved_trip_render_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/utils/trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';
import 'package:option_result/option_result.dart';

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

  String? _rawTripJson;

  Future<void> getTripData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (widget.trip.isManualMultiLeg) {
      final manualJourney = await SavedTripRenderService.buildManualTripJourney(
        widget.trip,
      );

      if (!context.mounted) return;

      setState(() {
        trips = manualJourney == null ? [] : [manualJourney];
        _rawTripJson = prettyPrintRawJson(manualJourney?.rawJson);
        _error = manualJourney == null
            ? 'Unable to load the saved manual trip.'
            : null;
        _isLoading = false;
      });
      return;
    }

    final result = await TripCacheService.getCachedOrFetch(
      originId: widget.trip.originId,
      destinationId: widget.trip.destinationId,
    );

    if (!context.mounted) return;

    switch (result) {
      case Ok(:final v):
        setState(() {
          trips = sortTripJourneysForDisplay(v.tripJourneys);
          testText = v.toString();
          _rawTripJson = prettyPrintRawJson(v.rawJson);
          _isLoading = false;
        });

        // Preemptively load realtime vehicle positions in the background so
        // the trip leg detail map loads faster when the user taps a leg.
        RealtimeService.getAllVehiclePositionsAggregated().ignore();
      case Err(:final e):
        setState(() {
          _error = e;
          _isLoading = false;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    getTripData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!widget.trip.isManualMultiLeg) {
            TripCacheService.invalidate(
              widget.trip.originId,
              widget.trip.destinationId,
            );
          }
          await getTripData();
        },
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
                            const Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            Text(loadingTripMessage(widget.trip))
                          else if (_error != null)
                            Column(
                              children: [
                                Text(
                                  'Error loading trips:\n$_error',
                                  textAlign: TextAlign.center,
                                ),
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
                                Text(emptyTripMessage(widget.trip)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: getTripData,
                                  child: Text(retryButtonLabel(widget.trip)),
                                ),
                                ValueListenableBuilder<bool>(
                                  valueListenable: DebugService.showDebugData,
                                  builder: (context, showDebug, _) {
                                    if (!showDebug || _rawTripJson == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        width: double.infinity,
                                        constraints: const BoxConstraints(
                                          maxHeight: 240,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            _rawTripJson!,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
