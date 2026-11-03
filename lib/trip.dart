import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';
import 'trip_screen/controller.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({
    super.key,
    required this.trip,
    this.skipInitialLoad = false,
    this.initialTrips = const [],
  });
  final Journey trip;
  final bool skipInitialLoad;
  final List<TripJourney> initialTrips;
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with GuardedState<TripScreen> {
  late final TripScreenController _controller;
  final Set<int> _prefetchedVisibleTripIndexes = <int>{};

  bool get _usesTfnswServices {
    if (!RegionFeatureFlags.nsw || widget.trip.isManualMultiLeg) return false;
    for (final id in [widget.trip.originId, widget.trip.destinationId]) {
      final reference = TransitStopRef.tryParse(id);
      if (reference == null && id.contains('|')) return false;
      if (reference != null &&
          (reference.region != TransitRegion.nsw ||
              reference.provider != TransitProviderId.tfnsw)) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = TripScreenController(
      trip: widget.trip,
      initialTrips: widget.initialTrips,
      startAgingTimer: !widget.skipInitialLoad,
      onUsableData: _usesTfnswServices
          ? () => RealtimeService.prefetchAggregates().ignore()
          : null,
    );
    if (!widget.skipInitialLoad) {
      if (_usesTfnswServices) RealtimeService.prefetchAggregates().ignore();
      _controller.load();
    }
  }

  void _pushLegDetail(Leg leg, TripJourney tripJourney) {
    pushPage((context) => TripLegDetailScreen(leg: leg, trip: tripJourney));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prefetchVisibleTrip(TripJourney trip, int index) {
    if (widget.skipInitialLoad ||
        !_usesTfnswServices ||
        !_prefetchedVisibleTripIndexes.add(index)) {
      return;
    }
    RealtimeService.prefetchAggregates().ignore();
    for (final leg in trip.legs.take(2)) {
      if (leg.origin.id.isEmpty || leg.destination.id.isEmpty) continue;
      TripCacheService.getCachedOrFetch(
        originId: leg.origin.id,
        destinationId: leg.destination.id,
      ).ignore();
    }
  }

  Future<void> _refreshTrips() => _controller.load(forceRefresh: true);

  Widget _buildRawTripJsonCard(String rawTripJson) => Padding(
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

  Widget _buildEmptyTripState(BuildContext context, TripScreenState state) {
    final rawTripJson = state.rawTripJson;
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isLoading)
                  const CircularProgressIndicator()
                else
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                if (state.isLoading)
                  Text(loadingTripMessage(widget.trip))
                else if (state.error != null)
                  Column(
                    children: [
                      Text(
                        'Error loading trips:\n${state.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _controller.load,
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
                        onPressed: _controller.load,
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

  Widget _buildTripList(TripScreenState state) => ListView(
    children: [
      for (final (index, tripJourney) in state.trips.indexed)
        TripCard(
          trip: tripJourney,
          onVisible: (trip) => _prefetchVisibleTrip(trip, index),
          onSelectLeg: (leg) => _pushLegDetail(leg, tripJourney),
        ),
    ],
  );

  Widget _buildBody(BuildContext context, TripScreenState state) {
    return Column(
      children: [
        Expanded(
          child: state.trips.isEmpty
              ? _buildEmptyTripState(context, state)
              : _buildTripList(state),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Trip')),
    body: RefreshIndicator(
      onRefresh: _refreshTrips,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _buildBody(context, _controller.state),
      ),
    ),
  );
}
