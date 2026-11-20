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

  Future<void> _planningOptions() async {
    var when = _controller.planningTime ?? DateTime.now();
    var arrive = _controller.arrivalBased;
    var access = _controller.accessibility;
    var walk = _controller.walkingLimit?.inMinutes;
    final qualified =
        TransitStopRef.tryParse(widget.trip.originId) != null &&
        TransitStopRef.tryParse(widget.trip.destinationId) != null;
    final applied = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Journey options'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Arrive by'),
                  value: arrive,
                  onChanged: (v) => setLocal(() => arrive = v),
                ),
                ListTile(
                  title: Text(
                    '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')} ${TimeOfDay.fromDateTime(when).format(context)}',
                  ),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: when,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(when),
                    );
                    if (time != null && context.mounted) {
                      setLocal(
                        () => when = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        ),
                      );
                    }
                  },
                ),
                DropdownButtonFormField<TransitAccessibility>(
                  initialValue: access,
                  decoration: const InputDecoration(labelText: 'Accessibility'),
                  items: const [
                    DropdownMenuItem(
                      value: TransitAccessibility.none,
                      child: Text('Any service'),
                    ),
                    DropdownMenuItem(
                      value: TransitAccessibility.wheelchairPreferred,
                      child: Text('Wheelchair preferred'),
                    ),
                    DropdownMenuItem(
                      value: TransitAccessibility.stepFreeOnly,
                      child: Text('Confirmed step-free only'),
                    ),
                  ],
                  onChanged: (v) => setLocal(() => access = v!),
                ),
                if (qualified)
                  DropdownButtonFormField<int>(
                    initialValue: walk ?? -1,
                    decoration: const InputDecoration(
                      labelText: 'Total walking time',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: -1,
                        child: Text('No limit'),
                      ),
                      for (final m in [0, 5, 10, 20, 30, 60])
                        DropdownMenuItem(value: m, child: Text('$m minutes')),
                    ],
                    onChanged: (v) => setLocal(() => walk = v == -1 ? null : v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.planningTime = null;
                _controller.arrivalBased = false;
                _controller.accessibility = TransitAccessibility.none;
                _controller.walkingLimit = null;
                Navigator.pop(dialogContext, false);
                _controller.load();
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (applied == true && mounted) {
      _controller.planningTime = when;
      _controller.arrivalBased = arrive;
      _controller.accessibility = access;
      _controller.walkingLimit = walk == null ? null : Duration(minutes: walk!);
      await _controller.load();
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(loadingTripMessage(widget.trip)),
                      TextButton(
                        onPressed: _controller.cancelPlanning,
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
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
    appBar: AppBar(
      title: const Text('Trip'),
      actions: [
        if (!widget.trip.isManualMultiLeg)
          IconButton(
            tooltip: 'Journey options',
            onPressed: _planningOptions,
            icon: const Icon(Icons.tune),
          ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _refreshTrips,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _buildBody(context, _controller.state),
      ),
    ),
  );
}
