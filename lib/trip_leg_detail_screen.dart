import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

import 'utils/color_utils.dart';

/// Screen for tracking an individual trip leg with real-time updates
class TripLegDetailScreen extends StatefulWidget {
  final Leg leg;
  final TripJourney? trip;
  final Future<Map<String, dynamic>> Function()? getAllVehiclesAggregated;
  // Allow skipping artificial initial delays in scenarios like widget tests.
  final bool skipInitialLoadDelay;

  const TripLegDetailScreen(
      {super.key,
      required this.leg,
      this.trip,
      this.getAllVehiclesAggregated,
      this.skipInitialLoadDelay = false});

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen> {
  Leg? _updatedLeg;
  bool _isLoading = false;
  String? _error;
  List<VehiclePosition> _vehicles = [];
  Map<String, int> _vehicleBreakdown = {};
  bool _isLoadingVehicles = false;
  bool _filterByLegRoute = false;

  @override
  void initState() {
    super.initState();
    _updatedLeg = widget.leg;
    if (widget.skipInitialLoadDelay) {
      // For tests, skip the simulated 1s delay and avoid scheduling delayed timers.
      _loadVehiclesForLeg();
    } else {
      _refreshLegData();
    }
  }

  String _legDebugString(Leg leg) {
    final buffer = StringBuffer();

    buffer.writeln('Leg summary:');
    buffer.writeln('  distance: ${leg.distance}');
    buffer.writeln('  duration: ${leg.duration}');
    buffer.writeln('  isRealtimeControlled: ${leg.isRealtimeControlled}');
    buffer.writeln(
        '  coords: ${leg.coords?.map((c) => c.join(', ')).toList() ?? 'N/A'}');

    buffer.writeln('\nOrigin:');
    buffer.writeln('  id: ${leg.origin.id}');
    buffer.writeln('  name: ${leg.origin.name}');
    buffer.writeln('  type: ${leg.origin.type}');
    buffer.writeln('  coord: ${leg.origin.coord ?? 'N/A'}');

    buffer.writeln('\nDestination:');
    buffer.writeln('  id: ${leg.destination.id}');
    buffer.writeln('  name: ${leg.destination.name}');
    buffer.writeln('  type: ${leg.destination.type}');
    buffer.writeln('  coord: ${leg.destination.coord ?? 'N/A'}');

    buffer.writeln('\nTransportation:');
    if (leg.transportation != null) {
      buffer.writeln('  id: ${leg.transportation?.id}');
      buffer.writeln('  name: ${leg.transportation?.name}');
      buffer.writeln('  number: ${leg.transportation?.number}');
      buffer.writeln(
          '  product class: ${leg.transportation?.product?.classField}');
    } else {
      buffer.writeln('  N/A');
    }

    buffer.writeln('\nStops (${leg.stopSequence?.length ?? 0}):');
    if (leg.stopSequence != null && leg.stopSequence!.isNotEmpty) {
      for (var i = 0; i < leg.stopSequence!.length; i++) {
        final s = leg.stopSequence![i];
        buffer.writeln('  ${i + 1}. ${s.name} (id: ${s.id})');
      }
    }

    buffer.writeln('\nProperties:');
    buffer.writeln('  differentFares: ${leg.properties?.differentFares}');
    buffer.writeln('  lineType: ${leg.properties?.lineType}');

    // Raw JSON for the leg
    buffer.writeln('\nRaw leg JSON:');
    try {
      final enc = JsonEncoder.withIndent('  ');
      buffer.writeln(enc.convert(leg.toJson()));
    } catch (e) {
      buffer.writeln('  <failed to pretty-print raw JSON for leg: $e>');
    }

    // Raw JSON for origin/destination Stops
    buffer.writeln('\nOrigin raw JSON:');
    try {
      final enc = JsonEncoder.withIndent('  ');
      buffer.writeln(enc.convert(leg.origin?.toJson() ?? {}));
    } catch (e) {
      buffer.writeln('  <failed to pretty-print raw JSON for origin: $e>');
    }

    buffer.writeln('\nDestination raw JSON:');
    try {
      final enc = JsonEncoder.withIndent('  ');
      buffer.writeln(enc.convert(leg.destination?.toJson() ?? {}));
    } catch (e) {
      buffer.writeln('  <failed to pretty-print raw JSON for destination: $e>');
    }

    return buffer.toString();
  }

  String _tripDebugString(TripJourney trip) {
    final buffer = StringBuffer();
    buffer.writeln('Trip summary:');
    buffer.writeln('  isAdditional: ${trip.isAdditional}');
    buffer.writeln('  rating: ${trip.rating}');
    buffer.writeln('  legsCount: ${trip.legs.length}');
    buffer.writeln('\nTrip legs (full details):');
    for (var i = 0; i < trip.legs.length; i++) {
      buffer.writeln('\n--- Leg ${i + 1} ---');
      final leg = trip.legs[i];
      buffer.writeln(_legDebugString(leg));
    }
    buffer.writeln('\nRaw JSON:');
    try {
      final enc = JsonEncoder.withIndent('  ');
      buffer.writeln(enc.convert(trip.toJson()));
    } catch (e) {
      buffer.writeln('  <failed to pretty-print raw JSON: $e>');
    }
    return buffer.toString();
  }

  TransportMode? _getRealtimeModeFromClass(int? transportClass) {
    if (transportClass == null) return null;
    switch (transportClass) {
      case 1: // Train
        return TransportMode.train;
      case 4: // Light Rail
        return TransportMode.lightrail;
      case 5: // Bus
      case 11: // School Bus
        return TransportMode.bus;
      case 9: // Ferry
        return TransportMode.ferry;
      default:
        return null;
    }
  }

  Future<void> _refreshLegData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, just use the original leg data since real-time updates
      // would require additional API endpoints
      if (!widget.skipInitialLoadDelay) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Refresh vehicles when reloading the leg data
      await _loadVehiclesForLeg();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Deduplication is handled in RealtimeService.getAllVehiclePositionsAggregated.

  String _vehicleDisplayId(VehiclePosition v) {
    final desc = v.vehicle;
    if (desc.hasId()) return desc.id;
    if (v.trip.hasTripId()) return 'trip:${v.trip.tripId}';
    if (v.trip.hasRouteId()) return 'route:${v.trip.routeId}';
    return 'unknown';
  }

  String? _legRouteId() => (_updatedLeg ?? widget.leg).transportation?.id;

  List<VehiclePosition> get _displayedVehicles {
    final routeId = _legRouteId();
    if (!_filterByLegRoute || routeId == null || routeId.isEmpty) {
      return _vehicles;
    }
    return _vehicles
        .where((v) => v.trip.hasRouteId() && v.trip.routeId == routeId)
        .toList();
  }

  Future<void> _loadVehiclesForLeg() async {
    setState(() {
      _isLoadingVehicles = true;
    });
    try {
      // Always fetch from all available feeds so the debug card shows
      // the entire current feed state rather than just vehicles for the leg.
      final aggregate = await (widget.getAllVehiclesAggregated?.call() ??
          RealtimeService.getAllVehiclePositionsAggregated());
      final dedupedVehicles =
          (aggregate['vehicles'] as List<VehiclePosition>?) ?? [];
      final breakdown = (aggregate['breakdown'] as Map<String, int>?) ?? {};

      // Sort alphabetically by display id
      dedupedVehicles.sort((a, b) => _vehicleDisplayId(a)
          .toLowerCase()
          .compareTo(_vehicleDisplayId(b).toLowerCase()));

      if (!mounted) return;
      setState(() {
        _vehicles = dedupedVehicles;
        _vehicleBreakdown = breakdown;
        _isLoadingVehicles = false;
      });
    } catch (e) {
      logger.i('Failed to load vehicles for leg: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingVehicles = false;
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
    final String? transportId = transportation?.id;

    final modeColor = transportClass != null
        ? TransportModeUtils.getModeColor(transportClass)
        : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Leg Details'),
        backgroundColor: modeColor,
        foregroundColor: getContrastingForeground(modeColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLegData,
          ),
          if (transportId != null && transportId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                final mode = _getRealtimeModeFromClass(transportClass);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealtimeMapWidget(
                      leg: leg,
                      transportMode: mode,
                      vehicleId: transportId,
                      getAllVehiclesAggregated:
                          RealtimeService.getAllVehiclePositionsAggregated,
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
            const SizedBox(height: 16),

            // Debug/info card showing trip data (including legs and raw json) and detailed leg data
            ValueListenableBuilder<bool>(
              valueListenable: DebugService.showDebugData,
              builder: (context, showDebug, child) {
                if (!showDebug) return const SizedBox.shrink();
                return widget.trip != null
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Trip debug data',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Copy trip debug to clipboard',
                                    onPressed: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      try {
                                        final text =
                                            _tripDebugString(widget.trip!);
                                        await Clipboard.setData(
                                            ClipboardData(text: text));
                                        if (!mounted) return;
                                        messenger.showSnackBar(const SnackBar(
                                            content: Text(
                                                'Copied trip debug data to clipboard')));
                                      } catch (e) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(const SnackBar(
                                            content: Text(
                                                'Failed to copy trip debug data')));
                                      }
                                    },
                                    icon: const Icon(Icons.copy, size: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Full Trip data (includes legs and raw JSON below):',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 320),
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    _tripDebugString(widget.trip!),
                                    style: const TextStyle(
                                        fontFamily: 'monospace', fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: DebugService.showDebugData,
              builder: (context, showDebug, child) {
                if (!showDebug) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Leg debug data',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy debug text to clipboard',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await Clipboard.setData(
                                    ClipboardData(text: _legDebugString(leg)),
                                  );
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Copied leg debug data to clipboard')),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to copy to clipboard')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Leg details (select or copy). Useful for debugging.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _legDebugString(leg),
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            ValueListenableBuilder<bool>(
              valueListenable: DebugService.showDebugData,
              builder: (context, showDebug, child) {
                if (!showDebug) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: title + actions (filter toggle + copy button)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Vehicle debug data',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                if (transportId != null &&
                                    transportId.isNotEmpty)
                                  Row(
                                    children: [
                                      const Text('Filter by route'),
                                      const SizedBox(width: 8),
                                      Switch.adaptive(
                                        value: _filterByLegRoute,
                                        onChanged: (v) {
                                          setState(() {
                                            _filterByLegRoute = v;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                IconButton(
                                  tooltip: 'Copy vehicle debug to clipboard',
                                  onPressed: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    try {
                                      final lines = _displayedVehicles.map((v) {
                                        final id = v.vehicle.hasId()
                                            ? v.vehicle.id
                                            : 'N/A';
                                        final tripId = v.trip.hasTripId()
                                            ? v.trip.tripId
                                            : 'N/A';
                                        final routeId = v.trip.hasRouteId()
                                            ? v.trip.routeId
                                            : 'N/A';
                                        final pos = v.hasPosition() &&
                                                v.position.hasLatitude() &&
                                                v.position.hasLongitude()
                                            ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                                            : 'N/A';
                                        final ts = v.hasTimestamp()
                                            ? DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        v.timestamp.toInt() *
                                                            1000)
                                                .toIso8601String()
                                            : 'N/A';
                                        return 'id=$id trip=$tripId route=$routeId pos=$pos ts=$ts';
                                      }).join('\n');

                                      await Clipboard.setData(
                                          ClipboardData(text: lines));
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Copied vehicle debug data to clipboard')),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Failed to copy vehicle debug data')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Showing ${_displayedVehicles.length} of ${_vehicles.length} realtime vehicles (sorted alphabetically):',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        if (_vehicleBreakdown.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _vehicleBreakdown.entries
                                .map((e) => Chip(
                                      label: Text('${e.key}: ${e.value}'),
                                      backgroundColor: Colors.grey.shade100,
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        if (_isLoadingVehicles)
                          const Center(child: CircularProgressIndicator())
                        else if (_vehicles.isEmpty)
                          const ListTile(
                            leading:
                                Icon(Icons.location_off, color: Colors.grey),
                            title: Text('No vehicles found'),
                          )
                        else if (_displayedVehicles.isEmpty)
                          const ListTile(
                            leading:
                                Icon(Icons.filter_alt_off, color: Colors.grey),
                            title: Text(
                                'No vehicles match the current route filter'),
                          )
                        else
                          SizedBox(
                            height: 320,
                            child: ListView.builder(
                              itemCount: _displayedVehicles.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final v = _displayedVehicles[index];
                                final id =
                                    v.vehicle.hasId() ? v.vehicle.id : 'N/A';
                                final tripId =
                                    v.trip.hasTripId() ? v.trip.tripId : 'N/A';
                                final routeId = v.trip.hasRouteId()
                                    ? v.trip.routeId
                                    : 'N/A';
                                final pos = v.hasPosition() &&
                                        v.position.hasLatitude() &&
                                        v.position.hasLongitude()
                                    ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                                    : 'N/A';
                                final routeMatch = transportId != null &&
                                    v.trip.hasRouteId() &&
                                    v.trip.routeId == transportId;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        routeMatch ? Colors.orange : modeColor,
                                    foregroundColor:
                                        getContrastingForeground(modeColor),
                                    child: Text(id == 'N/A'
                                        ? '?'
                                        : id[0].toUpperCase()),
                                  ),
                                  title: Text(id),
                                  subtitle: Text(
                                      'Trip: $tripId • Route: $routeId • Pos: $pos'),
                                  dense: true,
                                  trailing: routeMatch
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.orange, size: 18)
                                      : null,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
