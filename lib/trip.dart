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
import 'package:lbww_flutter/widgets/travel_warning_card.dart';
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
  List<ResponseMessage> _systemMessages = const [];
  final Set<int> _prefetchedVisibleTripIndexes = <int>{};
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
        _systemMessages = const [];
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
          _systemMessages =
              v.systemMessages.responseMessages
                  ?.where((m) => (m.error ?? m.text)?.trim().isNotEmpty == true)
                  .toList() ??
              const [];
          testText = v.toString();
          _rawTripJson = prettyPrintRawJson(v.rawJson);
          _isLoading = false;
        });

        // Preemptively load realtime vehicle positions in the background so
        // the trip leg detail map loads faster when the user taps a leg.
        RealtimeService.prefetchAggregates().ignore();
      case Err(:final e):
        setState(() {
          _error = e;
          _systemMessages = const [];
          _isLoading = false;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    RealtimeService.prefetchAggregates().ignore();
    getTripData();
  }

  void _prefetchVisibleTrip(TripJourney trip, int index) {
    if (_prefetchedVisibleTripIndexes.contains(index)) {
      return;
    }

    _prefetchedVisibleTripIndexes.add(index);

    // Warm detail screens for the most likely taps first.
    RealtimeService.prefetchAggregates().ignore();

    final legs = trip.legs;
    for (final leg in legs.take(2)) {
      final origin = leg.origin;
      final destination = leg.destination;
      final hasOrigin = origin.id.isNotEmpty;
      final hasDestination = destination.id.isNotEmpty;
      if (!hasOrigin || !hasDestination) {
        continue;
      }
      TripCacheService.getCachedOrFetch(
        originId: origin.id,
        destinationId: destination.id,
      ).ignore();
    }
  }

  List<Widget> _buildSystemMessageWarningChildren() {
    return [
      const SizedBox(height: 8),
      ..._systemMessages.take(4).map((message) {
        final text = (message.error ?? message.text ?? '').trim();
        if (text.isEmpty) {
          return const SizedBox.shrink();
        }
        final prefix = [
          if ((message.type ?? '').isNotEmpty) message.type,
          if ((message.module ?? '').isNotEmpty) message.module,
        ].join(' • ');
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            prefix.isEmpty ? text : '$prefix: $text',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip'),
        actions: [
          if (_systemMessages.isNotEmpty)
            TravelWarningAction(
              title: 'Travel Alerts',
              tooltip: 'Show travel alerts',
              children: _buildSystemMessageWarningChildren(),
            ),
        ],
      ),
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
                                            _rawTripJson ?? '',
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
            : ListView(
                children: [
                  ...List.generate(trips.length, (index) {
                    return TripCard(
                      trip: trips[index],
                      onVisible: (trip) => _prefetchVisibleTrip(trip, index),
                      onSelectLeg: (leg) {
                        final tripJourney = trips[index];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripLegDetailScreen(
                              leg: leg,
                              trip: tripJourney,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

// TripLegScreen moved to trip_leg_screen.dart
