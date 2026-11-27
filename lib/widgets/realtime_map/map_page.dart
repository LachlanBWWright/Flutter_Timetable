part of '../realtime_map_widget.dart';

/// One coherent view of a leg and the realtime identity used to filter it.
class RealtimeMapLegSnapshot {
  final Leg leg;
  final List<Leg> additionalLegs;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Set<String> tripIds;
  final TripDescriptor? matchedTrip;
  final int refreshGeneration;

  RealtimeMapLegSnapshot({
    required this.leg,
    required List<Leg> additionalLegs,
    required this.transportMode,
    required this.routeFilter,
    required Set<String> tripIds,
    required this.matchedTrip,
    required this.refreshGeneration,
  }) : additionalLegs = List.unmodifiable(additionalLegs),
       tripIds = Set.unmodifiable(tripIds);
}

/// Page wrapper that provides a Scaffold/AppBar for the map when it's
/// shown as a full page. For embedded uses (e.g., inside a Card) use
/// `RealtimeMapWidget` directly so the parent can provide navigation chrome.
class RealtimeMapPage extends StatefulWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Leg? leg;
  final List<Leg>? additionalLegs;
  final String? vehicleId;
  final Future<Map<TransportMode, FeedMessage?>> Function()? getPositions;
  final Future<VehiclePositionAggregationResult> Function()?
  getAllVehiclesAggregated;
  final Future<void> Function()? onRefresh;
  final bool filterByLegTrip;
  final Set<String>? tripIds;
  final TripDescriptor? matchedTrip;
  final bool showTileLayer;
  final Listenable? legListenable;
  final RealtimeMapLegSnapshot Function()? getLegSnapshot;

  const RealtimeMapPage({
    super.key,
    this.mode,
    this.transportMode,
    this.routeFilter,
    this.leg,
    this.additionalLegs,
    this.vehicleId,
    this.getPositions,
    this.getAllVehiclesAggregated,
    this.onRefresh,
    this.filterByLegTrip = false,
    this.tripIds,
    this.matchedTrip,
    this.showTileLayer = true,
    this.legListenable,
    this.getLegSnapshot,
  });

  @override
  State<RealtimeMapPage> createState() => _RealtimeMapPageState();
}

class _RealtimeMapPageState extends State<RealtimeMapPage> {
  final GlobalKey<_RealtimeMapWidgetState> mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final listenable = widget.legListenable;
    return listenable == null
        ? _buildPage(context)
        : ListenableBuilder(
            listenable: listenable,
            builder: (context, _) => _buildPage(context),
          );
  }

  Widget _buildPage(BuildContext context) {
    final snapshot = widget.getLegSnapshot?.call();
    final leg = snapshot?.leg ?? widget.leg;
    return Scaffold(
      appBar: AppBar(
        title: Text(realtimeMapPageTitle(mode: widget.mode, leg: leg)),
        actions: [
          IconButton(
            tooltip: 'Refresh live map',
            icon: const Icon(Icons.refresh),
            onPressed: () => mapKey.currentState?._retryVehiclePositions(),
          ),
        ],
      ),
      body: RealtimeMapWidget(
        key: mapKey,
        mode: widget.mode,
        transportMode: snapshot?.transportMode ?? widget.transportMode,
        routeFilter: snapshot == null
            ? widget.routeFilter
            : snapshot.routeFilter,
        leg: leg,
        additionalLegs: snapshot?.additionalLegs ?? widget.additionalLegs,
        filterByLegTrip: snapshot == null
            ? widget.filterByLegTrip
            : snapshot.routeFilter != null,
        tripIds: snapshot?.tripIds ?? widget.tripIds,
        matchedTrip: snapshot == null
            ? widget.matchedTrip
            : snapshot.matchedTrip,
        refreshGeneration: snapshot?.refreshGeneration ?? 0,
        vehicleId: widget.vehicleId,
        getPositions: widget.getPositions,
        getAllVehiclesAggregated: widget.getAllVehiclesAggregated,
        onRefresh: widget.onRefresh,
        showTileLayer: widget.showTileLayer,
      ),
    );
  }
}
