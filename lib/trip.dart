import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/saved_trip_render_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';
import 'package:option_result/option_result.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.trip});

  final Journey trip;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with GuardedState<TripScreen> {
  String testText = '';
  List<TripJourney> trips = [];
  final Set<int> _prefetchedVisibleTripIndexes = <int>{};
  bool _isLoading = false;
  String? _error;

  String? _rawTripJson;

  void _pushLegDetail(Leg leg, TripJourney tripJourney) {
    pushPage((context) => TripLegDetailScreen(leg: leg, trip: tripJourney));
  }

  void _setTripLoadState({
    required List<TripJourney> loadedTrips,
    String? error,
    String? rawTripJson,
  }) {
    guardedSetState(() {
      trips = loadedTrips;
      _error = error;
      _rawTripJson = rawTripJson;
      _isLoading = false;
    });
  }

  void _setManualTripState(TripJourney? manualJourney) {
    if (manualJourney == null) {
      _setTripLoadState(
        loadedTrips: const <TripJourney>[],
        error: 'Unable to load the saved manual trip.',
      );
      return;
    }

    _setTripLoadState(
      loadedTrips: <TripJourney>[manualJourney],
      rawTripJson: prettyPrintRawJson(manualJourney.rawJson),
    );
  }

  void _setFetchedTripState(GetTripsResponse response) {
    guardedSetState(() {
      trips = sortTripJourneysForDisplay(response.tripJourneys);
      testText = response.toString();
      _rawTripJson = prettyPrintRawJson(response.rawJson);
      _isLoading = false;
    });
  }

  void _setTripLoadError(String error) {
    _setTripLoadState(loadedTrips: const <TripJourney>[], error: error);
  }

  Future<void> getTripData() async {
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    if (widget.trip.isManualMultiLeg) {
      final manualJourney = await SavedTripRenderService.buildManualTripJourney(
        widget.trip,
      );

      if (!context.mounted) return;
      _setManualTripState(manualJourney);
      return;
    }

    final result = await TripCacheService.getCachedOrFetch(
      originId: widget.trip.originId,
      destinationId: widget.trip.destinationId,
    );

    if (!context.mounted) return;

    switch (result) {
      case Ok(:final v):
        _setFetchedTripState(v);

        // Preemptively load realtime vehicle positions in the background so
        // the trip leg detail map loads faster when the user taps a leg.
        RealtimeService.prefetchAggregates().ignore();
      case Err(:final e):
        _setTripLoadError(e);
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

  Future<void> _refreshTrips() async {
    if (!widget.trip.isManualMultiLeg) {
      TripCacheService.invalidate(
        widget.trip.originId,
        widget.trip.destinationId,
      );
    }
    await getTripData();
  }

  Widget _buildRawTripJsonCard(String rawTripJson) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 240),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Text(
            rawTripJson,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTripState(BuildContext context) {
    final rawTripJson = _rawTripJson;
    return ListView(
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
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
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
                          if (!showDebug || rawTripJson == null) {
                            return const SizedBox.shrink();
                          }
                          return _buildRawTripJsonCard(rawTripJson);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripList() {
    final tripCards = <Widget>[];
    var index = 0;
    for (final tripJourney in trips) {
      tripCards.add(
        TripCard(
          trip: tripJourney,
          onVisible: (trip) => _prefetchVisibleTrip(trip, index),
          onSelectLeg: (leg) => _pushLegDetail(leg, tripJourney),
        ),
      );
      index++;
    }

    return ListView(children: tripCards);
  }

  Widget _buildBody(BuildContext context) {
    return trips.isEmpty ? _buildEmptyTripState(context) : _buildTripList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip')),
      body: RefreshIndicator(
        onRefresh: _refreshTrips,
        child: _buildBody(context),
      ),
    );
  }
}

// TripLegScreen moved to trip_leg_screen.dart
