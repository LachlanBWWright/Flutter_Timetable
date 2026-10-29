import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/debug_page_loader.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' hide logger;
import 'package:lbww_flutter/trip_leg_detail/controller/trip_leg_realtime_controller.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/realtime_leg_match.dart';
import 'package:lbww_flutter/utils/realtime_trip_id_utils.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:lbww_flutter/utils/trip_leg_debug_utils.dart';
import 'package:lbww_flutter/utils/trip_leg_detail_utils.dart';
import 'package:lbww_flutter/utils/visible_realtime_refresh.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/travel_warning_card.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

import 'utils/color_utils.dart';

// These parts share the screen's private state while keeping data loading,
// diagnostics, and presentation grouped by responsibility.
part 'trip_leg_detail/leg_metadata.dart';
part 'trip_leg_detail/journey_debug_text.dart';
part 'trip_leg_detail/route_debug_text.dart';
part 'trip_leg_detail/realtime_loading.dart';
part 'trip_leg_detail/request_lifecycle.dart';
part 'trip_leg_detail/feed_status.dart';
part 'trip_leg_detail/route_lookup.dart';
part 'trip_leg_detail/debug_navigation.dart';
part 'trip_leg_detail/realtime_stops.dart';
part 'trip_leg_detail/map_section.dart';
part 'trip_leg_detail/map_opening.dart';
part 'trip_leg_detail/journey_summary.dart';
part 'trip_leg_detail/stop_list.dart';
part 'trip_leg_detail/stop_row.dart';
part 'trip_leg_detail/vehicle_debug_card.dart';
part 'trip_leg_detail/debug_cards.dart';

/// Screen for tracking an individual trip leg with real-time updates
class TripLegDetailScreen extends StatefulWidget {
  final Leg leg;
  final TripJourney? trip;
  final DebugEntityPageLoader? debugPageLoader;
  final DebugEntityListPageLoader? debugListLoader;
  final Future<VehiclePositionAggregationResult> Function()?
  getAllVehiclesAggregated;
  final Future<TripUpdateAggregationResult> Function()?
  getAllTripUpdatesAggregated;
  final Future<GtfsData?> Function(StopsEndpoint endpoint)?
  getGtfsDataForEndpoint;
  // Allow skipping artificial initial delays in scenarios like widget tests.
  final bool skipInitialLoadDelay;
  final bool skipInitialLoad;

  const TripLegDetailScreen({
    super.key,
    required this.leg,
    this.trip,
    this.debugPageLoader,
    this.debugListLoader,
    this.getAllVehiclesAggregated,
    this.getAllTripUpdatesAggregated,
    this.getGtfsDataForEndpoint,
    this.skipInitialLoadDelay = false,
    this.skipInitialLoad = false,
  });

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen>
    with GuardedState<TripLegDetailScreen> {
  int _requestGeneration = 0;
  int _stopRequestGeneration = 0;
  int _debugRequestGeneration = 0;
  Leg? _updatedLeg;
  late final DebugEntityPageLoader _debugPageLoader;
  late final DebugEntityListPageLoader _debugListLoader;
  String? _error;
  List<VehiclePosition> _vehicles = [];
  Map<String, int> _vehicleBreakdown = {};
  bool _isLoadingVehicles = false;
  bool _filterByLegRoute = false;
  bool _showAllVehicleStops = false;
  bool _isLoadingVehicleStops = false;
  String? _vehicleStopsError;
  List<_VehicleStopRow> _vehicleStops = [];
  bool _isLoadingRouteDebug = false;
  bool _showEmbeddedMap = false;
  String? _routeDebugError;
  gtfs_route.Route? _gtfsRoute;
  gtfs_agency.Agency? _gtfsAgency;
  String? _gtfsRouteEndpointKey;
  String? _gtfsRouteMatchReason;
  int _currentLegIndex = 0;
  late final TripLegRealtimeController _realtimeController;
  late final VisibleRealtimeRefresh _visibleRefresh;

  @override
  void initState() {
    super.initState();
    if (!widget.skipInitialLoad && !widget.skipInitialLoadDelay) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Let the route's entrance animation finish before building FlutterMap
        // and its stop/route layers, which can otherwise compete with it.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        guardedSetState(() {
          _showEmbeddedMap = true;
        });
      });
    } else {
      _showEmbeddedMap = true;
    }
    _debugPageLoader =
        widget.debugPageLoader ??
        buildDebugEntityPageLoader(
          getGtfsDataForEndpoint: widget.getGtfsDataForEndpoint,
          getAllVehiclesAggregated: widget.getAllVehiclesAggregated,
          getAllTripUpdatesAggregated: widget.getAllTripUpdatesAggregated,
        );
    _debugListLoader =
        widget.debugListLoader ??
        buildDebugEntityListLoader(
          getGtfsDataForEndpoint: widget.getGtfsDataForEndpoint,
          getAllVehiclesAggregated: widget.getAllVehiclesAggregated,
          getAllTripUpdatesAggregated: widget.getAllTripUpdatesAggregated,
        );
    _realtimeController = TripLegRealtimeController(
      loadVehicles: _loadVehicleAggregate,
      loadTripUpdates: _loadTripUpdateAggregate,
    )..addListener(_syncRealtimeState);
    _updatedLeg = widget.leg;
    _visibleRefresh = VisibleRealtimeRefresh(
      onRefresh: () async {
        if (_supportsRealtimeForLeg(_activeLeg)) {
          await _refreshLegData(forceRefresh: true);
        }
      },
      enabled: !widget.skipInitialLoad,
      refreshOnStart: false,
    );
    final idx = _tripLegs.indexOf(widget.leg);
    _currentLegIndex = idx >= 0 ? idx : 0;
    if (widget.skipInitialLoad) {
      // Static previews intentionally avoid realtime, database, and network
      // lookups; the supplied leg remains available for rendering.
    } else if (widget.skipInitialLoadDelay) {
      if (_supportsRealtimeForLeg(_activeLeg)) {
        _loadVehiclesForLeg();
        _loadRealtimeTripStatusForLeg();
      }
      if (DebugService.showDebugData.value) {
        _ensureRouteDebugLoaded();
      }
    } else {
      _refreshLegData();
    }
    addListenerSafely(
      DebugService.showDebugData,
      _handleDebugVisibilityChanged,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visibleRefresh.updateRoute(context);
  }

  void _goToLeg(int index) {
    final legs = _tripLegs;
    if (index < 0 || index >= legs.length) return;
    final selectedLeg = _itemAt(legs, index);
    if (selectedLeg == null) {
      return;
    }
    _invalidateLegRequests();
    guardedSetState(() {
      _currentLegIndex = index;
      _updatedLeg = selectedLeg;
      _vehicleStops = [];
      _vehicleStopsError = null;
      _resetRouteDebugState();
    });
    _refreshLegData();
  }

  @override
  void didUpdateWidget(covariant TripLegDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.leg, widget.leg) ||
        !identical(oldWidget.trip, widget.trip)) {
      _updatedLeg = widget.leg;
      final index = _tripLegs.indexOf(widget.leg);
      _currentLegIndex = index < 0 ? 0 : index;
      _invalidateLegRequests();
      if (!widget.skipInitialLoad) _refreshLegData();
    }
  }

  @override
  void dispose() {
    _visibleRefresh.dispose();
    _realtimeController.removeListener(_syncRealtimeState);
    _realtimeController.dispose();
    removeListenerSafely(
      DebugService.showDebugData,
      _handleDebugVisibilityChanged,
    );
    super.dispose();
  }

  void _handleDebugVisibilityChanged() {
    if (DebugService.showDebugData.value) {
      _ensureRouteDebugLoaded();
    }
  }

  void _resetRouteDebugState() {
    _isLoadingRouteDebug = false;
    _routeDebugError = null;
    _gtfsRoute = null;
    _gtfsAgency = null;
    _gtfsRouteEndpointKey = null;
    _gtfsRouteMatchReason = null;
  }

  /// Get the color of the adjacent leg for navigation button colors.
  Color _getAdjacentLegColor(int index) {
    final legs = _tripLegs;
    if (index < 0 || index >= legs.length) return Colors.grey;
    final adjLeg = _itemAt(legs, index);
    if (adjLeg == null) {
      return Colors.grey;
    }
    final adjClass = _transportClass(adjLeg.transportation);
    return adjClass != null
        ? TransportModeUtils.getModeColor(adjClass)
        : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final leg = _activeLeg;
    final transportation = leg.transportation;
    final transportProduct = transportation?.product;
    final transportClass = transportProduct?.classField;

    final origin = leg.origin;
    final destination = leg.destination;
    final originName = origin.disassembledName ?? origin.name;
    final destinationName = destination.disassembledName ?? destination.name;
    final String? transportId = _legRouteIdFor(leg);

    final modeColor = transportClass != null
        ? TransportModeUtils.getModeColor(transportClass)
        : Colors.blue;

    final mode = _getRealtimeModeFromClass(transportClass);

    final tripLegs = _tripLegs;
    final otherLegs = tripLegs.where((l) => l != leg).toList();
    final legCount = tripLegs.length;
    final hasPrev = legCount > 1 && _currentLegIndex > 0;
    final hasNext = legCount > 1 && _currentLegIndex < legCount - 1;

    final prevColor = hasPrev
        ? _getAdjacentLegColor(_currentLegIndex - 1)
        : Colors.grey;
    final nextColor = hasNext
        ? _getAdjacentLegColor(_currentLegIndex + 1)
        : Colors.grey;
    final hasAlertWarnings = _hasAlertWarnings(leg);

    final debugOnlyBody = ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebugData, _) {
        if (!(widget.skipInitialLoadDelay && showDebugData)) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          child: _buildDebugCards(leg, transportId, modeColor),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Leg Details'),
        backgroundColor: modeColor,
        foregroundColor: getContrastingForeground(modeColor),
        actions: [
          if (hasAlertWarnings)
            TravelWarningAction(
              title: 'Travel Notes',
              tooltip: 'Show travel notes',
              children: _buildAlertWarningChildren(leg),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryRealtimeFeeds,
          ),
          if (transportId != null && transportId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Open trip map',
              onPressed: _openFullscreenMap,
            ),
        ],
      ),
      // FABs for navigating between legs
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: legCount > 1
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'prev_leg',
                    onPressed: hasPrev
                        ? () => _goToLeg(_currentLegIndex - 1)
                        : null,
                    backgroundColor: hasPrev ? prevColor : Colors.grey,
                    foregroundColor: hasPrev
                        ? getContrastingForeground(prevColor)
                        : Colors.white,
                    child: const Icon(Icons.arrow_back),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'next_leg',
                    onPressed: hasNext
                        ? () => _goToLeg(_currentLegIndex + 1)
                        : null,
                    backgroundColor: hasNext ? nextColor : Colors.grey,
                    foregroundColor: hasNext
                        ? getContrastingForeground(nextColor)
                        : Colors.white,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            )
          : null,
      body: ValueListenableBuilder<bool>(
        valueListenable: DebugService.showDebugData,
        builder: (context, showDebugData, _) {
          if (widget.skipInitialLoadDelay && showDebugData) {
            return debugOnlyBody;
          }

          return RefreshIndicator(
            onRefresh: _retryRealtimeFeeds,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              child: Column(
                children: [
                  _buildMapCard(transportId, mode, leg, modeColor, otherLegs),
                  _buildInfoCard(
                    originName,
                    destinationName,
                    modeColor,
                    origin,
                    destination,
                    leg,
                  ),
                  const SizedBox(height: 8),
                  _buildDebugCards(leg, transportId, modeColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
