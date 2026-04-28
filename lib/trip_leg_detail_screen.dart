import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

import 'utils/color_utils.dart';

/// Screen for tracking an individual trip leg with real-time updates
class TripLegDetailScreen extends StatefulWidget {
  final Leg leg;
  final TripJourney? trip;
  final Future<VehiclePositionAggregationResult> Function()?
  getAllVehiclesAggregated;
  final Future<TripUpdateAggregationResult> Function()?
  getAllTripUpdatesAggregated;
  // Allow skipping artificial initial delays in scenarios like widget tests.
  final bool skipInitialLoadDelay;

  const TripLegDetailScreen({
    super.key,
    required this.leg,
    this.trip,
    this.getAllVehiclesAggregated,
    this.getAllTripUpdatesAggregated,
    this.skipInitialLoadDelay = false,
  });

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _VehicleStopRow {
  final String label;
  final String? stopId;
  final String? arrivalTimePlanned;
  final String? arrivalTimeEstimated;
  final String? departureTimePlanned;
  final String? departureTimeEstimated;
  final bool skipped;

  const _VehicleStopRow({
    required this.label,
    this.stopId,
    this.arrivalTimePlanned,
    this.arrivalTimeEstimated,
    this.departureTimePlanned,
    this.departureTimeEstimated,
    this.skipped = false,
  });
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen> {
  Leg? _updatedLeg;
  bool _isLoading = false;
  String? _error;
  List<VehiclePosition> _vehicles = [];
  Map<String, int> _vehicleBreakdown = {};
  bool _isLoadingVehicles = false;
  bool _filterByLegRoute = false;
  bool _showAllVehicleStops = false;
  bool _isLoadingVehicleStops = false;
  String? _vehicleStopsError;
  List<_VehicleStopRow> _vehicleStops = [];
  int _currentLegIndex = 0;

  @override
  void initState() {
    super.initState();
    _updatedLeg = widget.leg;
    final legs = widget.trip?.legs;
    if (legs != null) {
      final idx = legs.indexOf(widget.leg);
      _currentLegIndex = idx >= 0 ? idx : 0;
    }
    if (widget.skipInitialLoadDelay) {
      if (_supportsRealtimeForLeg(_updatedLeg ?? widget.leg)) {
        _loadVehiclesForLeg();
      }
    } else {
      _refreshLegData();
    }
  }

  void _goToLeg(int index) {
    final legs = widget.trip?.legs;
    if (legs == null || index < 0 || index >= legs.length) return;
    setState(() {
      _currentLegIndex = index;
      _updatedLeg = legs[index];
      _vehicleStops = [];
      _vehicleStopsError = null;
    });
    _refreshLegData();
  }

  // ... (debug string methods omitted for brevity, keeping existing implementation) ...
  String _legDebugString(Leg leg) {
    final buffer = StringBuffer();

    buffer.writeln('Leg summary:');
    buffer.writeln('  distance: ${leg.distance}');
    buffer.writeln('  duration: ${leg.duration}');
    buffer.writeln('  isRealtimeControlled: ${leg.isRealtimeControlled}');
    buffer.writeln(
      '  coords: ${leg.coords?.map((c) => c.join(', ')).toList() ?? 'N/A'}',
    );

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
        '  product class: ${leg.transportation?.product?.classField}',
      );
    } else {
      buffer.writeln('  N/A');
    }

    buffer.writeln('\nStops (${leg.stopSequence?.length ?? 0}):');
    final stopSequence = leg.stopSequence;
    if (stopSequence != null && stopSequence.isNotEmpty) {
      for (var i = 0; i < stopSequence.length; i++) {
        final s = stopSequence[i];
        buffer.writeln('  ${i + 1}. ${s.name} (id: ${s.id})');
      }
    }

    buffer.writeln('\nProperties:');
    buffer.writeln('  differentFares: ${leg.properties?.differentFares}');
    buffer.writeln('  lineType: ${leg.properties?.lineType}');

    // Raw JSON for the leg
    buffer.writeln('\nRaw leg JSON:');
    try {
      const enc = JsonEncoder.withIndent('  ');
      if (leg.rawJson != null) {
        buffer.writeln(enc.convert(leg.rawJson));
      } else {
        buffer.writeln('  <no raw JSON available for leg>');
      }
    } catch (e) {
      buffer.writeln('  <failed to pretty-print raw JSON for leg>');
    }

    return buffer.toString();
  }

  String _tripDebugString(TripJourney trip) {
    final buffer = StringBuffer();
    final tripIds = _collectDebugTripIds(trip);
    final routeIds = _collectDebugRouteIds(trip);

    buffer.writeln(
      'Trip IDs: ${tripIds.isNotEmpty ? tripIds.join(', ') : 'N/A'}',
    );
    buffer.writeln(
      'Route IDs: ${routeIds.isNotEmpty ? routeIds.join(', ') : 'N/A'}',
    );
    buffer.writeln();

    buffer.writeln('Trip summary:');
    buffer.writeln('  isAdditional: ${trip.isAdditional}');
    buffer.writeln('  rating: ${trip.rating}');
    buffer.writeln('  legsCount: ${trip.legs.length}');
    buffer.writeln('\nTrip legs (full details):');
    for (var i = 0; i < trip.legs.length; i++) {
      buffer.writeln('\n--- Leg ${i + 1} ---');
      buffer.writeln(_legDebugString(trip.legs[i]));
    }
    if (trip.rawJson != null) {
      buffer.writeln('\nFull trip raw JSON:');
      buffer.writeln(const JsonEncoder.withIndent('  ').convert(trip.rawJson));
    }
    return buffer.toString();
  }

  Set<String> _collectDebugTripIds(TripJourney trip) {
    final tripIds = <String>{};
    _collectTripIdsFromRawJson(trip.rawJson, tripIds);

    final legsJson = trip.rawJson?['legs'];
    if (legsJson is List) {
      for (final legJson in legsJson.whereType<Map<String, dynamic>>()) {
        _collectTripIdsFromRawJson(legJson, tripIds);
      }
    }

    return tripIds;
  }

  Set<String> _collectDebugRouteIds(TripJourney trip) {
    final routeIds = <String>{};

    for (final leg in trip.legs) {
      final routeId = leg.transportation?.id;
      if (routeId != null && routeId.isNotEmpty) {
        routeIds.add(routeId);
      }

      final transport = leg.rawJson?['transportation'];
      if (transport is Map && transport['id'] != null) {
        final rawRouteId = transport['id'].toString();
        if (rawRouteId.isNotEmpty) {
          routeIds.add(rawRouteId);
        }
      }
    }

    final legsJson = trip.rawJson?['legs'];
    if (legsJson is List) {
      for (final legJson in legsJson.whereType<Map<String, dynamic>>()) {
        final transport = legJson['transportation'];
        if (transport is Map && transport['id'] != null) {
          final rawRouteId = transport['id'].toString();
          if (rawRouteId.isNotEmpty) {
            routeIds.add(rawRouteId);
          }
        }
      }
    }

    return routeIds;
  }

  String _tripDebugPreviewString(TripJourney trip) {
    final buffer = StringBuffer();
    final tripIds = _collectDebugTripIds(trip);
    final routeIds = _collectDebugRouteIds(trip);

    buffer.writeln(
      'Trip IDs: ${tripIds.isNotEmpty ? tripIds.join(', ') : 'N/A'}',
    );
    buffer.writeln(
      'Route IDs: ${routeIds.isNotEmpty ? routeIds.join(', ') : 'N/A'}',
    );
    buffer.writeln();

    buffer.writeln('Trip summary:');
    buffer.writeln('  isAdditional: ${trip.isAdditional}');
    buffer.writeln('  rating: ${trip.rating}');
    buffer.writeln('  legsCount: ${trip.legs.length}');
    buffer.writeln('\nTrip legs (preview):');
    for (var i = 0; i < trip.legs.length; i++) {
      final leg = trip.legs[i];
      buffer.writeln('\n--- Leg ${i + 1} ---');
      buffer.writeln('  from: ${leg.origin.name} (${leg.origin.id})');
      buffer.writeln('  to: ${leg.destination.name} (${leg.destination.id})');
      buffer.writeln(
        '  transport: ${leg.transportation?.name ?? leg.transportation?.id ?? 'N/A'}',
      );
    }
    _appendScalarPreviewFields(
      buffer,
      trip.rawJson,
      title: 'Top-level raw fields',
    );
    return buffer.toString();
  }

  String _legDebugPreviewString(Leg leg) {
    final buffer = StringBuffer();
    buffer.writeln('Leg summary:');
    buffer.writeln('  distance: ${leg.distance}');
    buffer.writeln('  duration: ${leg.duration}');
    buffer.writeln('  isRealtimeControlled: ${leg.isRealtimeControlled}');
    buffer.writeln('  from: ${leg.origin.name} (${leg.origin.id})');
    buffer.writeln('  to: ${leg.destination.name} (${leg.destination.id})');
    buffer.writeln(
      '  transport: ${leg.transportation?.name ?? leg.transportation?.id ?? 'N/A'}',
    );
    buffer.writeln('  stops: ${leg.stopSequence?.length ?? 0}');
    _appendScalarPreviewFields(buffer, leg.rawJson, title: 'Leg raw fields');
    return buffer.toString();
  }

  TransportMode? _getRealtimeModeFromClass(int? transportClass) {
    if (transportClass == null) return null;
    switch (transportClass) {
      case 1: // Train
        return TransportMode.train;
      case 2: // Metro
        return TransportMode.metro;
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

  bool _isManualLeg(Leg leg) {
    final rawJson = leg.rawJson;
    if (rawJson != null && rawJson['manual'] == true) {
      return true;
    }

    final transportRawJson = leg.transportation?.rawJson;
    return transportRawJson != null && transportRawJson['manual'] == true;
  }

  bool _supportsRealtimeForLeg(Leg leg) {
    final transportId = leg.transportation?.id;
    return !_isManualLeg(leg) && transportId != null && transportId.isNotEmpty;
  }

  Future<void> _refreshLegData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (!widget.skipInitialLoadDelay) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final activeLeg = _updatedLeg ?? widget.leg;
      if (_supportsRealtimeForLeg(activeLeg)) {
        await _loadVehiclesForLeg();
        if (_showAllVehicleStops) {
          await _loadVehicleStopsForLeg();
        }
      } else if (mounted) {
        setState(() {
          _vehicles = [];
          _vehicleBreakdown = {};
          _vehicleStops = [];
          _vehicleStopsError = null;
          _isLoadingVehicles = false;
          _isLoadingVehicleStops = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _vehicleDisplayId(VehiclePosition v) {
    final desc = v.vehicle;
    if (desc.hasId()) return desc.id;
    if (v.trip.hasTripId()) return 'trip:${v.trip.tripId}';
    if (v.trip.hasRouteId()) return 'route:${v.trip.routeId}';
    return 'unknown';
  }

  String? _legRouteId() => (_updatedLeg ?? widget.leg).transportation?.id;

  void _collectTripIdsFromRawJson(
    Map<String, dynamic>? rawJson,
    Set<String> ids,
  ) {
    if (rawJson == null) return;
    if (rawJson['tripId'] != null && rawJson['tripId'].toString().isNotEmpty) {
      ids.add(rawJson['tripId'].toString());
    }
    if (rawJson['id'] != null && rawJson['id'].toString().isNotEmpty) {
      ids.add(rawJson['id'].toString());
    }
    if (rawJson['trip_id'] != null &&
        rawJson['trip_id'].toString().isNotEmpty) {
      ids.add(rawJson['trip_id'].toString());
    }

    final t = rawJson['transportation'];
    if (t is Map && t['properties'] is Map) {
      final p = t['properties'] as Map<dynamic, dynamic>;
      if (p['RealtimeTripId'] != null &&
          p['RealtimeTripId'].toString().isNotEmpty) {
        ids.add(p['RealtimeTripId'].toString());
      }
      if (p['AVMSTripID'] != null && p['AVMSTripID'].toString().isNotEmpty) {
        ids.add(p['AVMSTripID'].toString());
      }
      if (p['realtimeTripId'] != null &&
          p['realtimeTripId'].toString().isNotEmpty) {
        ids.add(p['realtimeTripId'].toString());
      }
    }
  }

  Set<String> _collectTripIdsForActiveLeg() {
    final ids = <String>{};
    _collectTripIdsFromRawJson(widget.trip?.rawJson, ids);
    _collectTripIdsFromRawJson((_updatedLeg ?? widget.leg).rawJson, ids);
    return ids;
  }

  /// Collect only the trip IDs that belong to the active leg (not the whole trip)
  Set<String> _collectLegTripIds() {
    return _collectTripIdsForActiveLeg();
  }

  List<VehiclePosition> get _displayedVehicles {
    final routeId = _legRouteId();
    if (!_filterByLegRoute) {
      return _vehicles;
    }

    // If the trip/leg contains any explicit trip IDs (e.g., RealtimeTripId),
    // prefer filtering vehicles by trip id rather than by route id.
    final tripIds = <String>{};

    // Collect trip IDs from provided TripJourney raw JSON
    if (widget.trip?.rawJson case final r?) {
      if (r['tripId'] != null && r['tripId'].toString().isNotEmpty) {
        tripIds.add(r['tripId'].toString());
      }
      if (r['id'] != null && r['id'].toString().isNotEmpty) {
        tripIds.add(r['id'].toString());
      }
      if (r['trip_id'] != null && r['trip_id'].toString().isNotEmpty) {
        tripIds.add(r['trip_id'].toString());
      }

      if (r['transportation'] is Map) {
        final tp = r['transportation'] as Map<dynamic, dynamic>;
        if (tp['properties'] is Map) {
          final p = tp['properties'] as Map<dynamic, dynamic>;
          if (p['RealtimeTripId'] != null &&
              p['RealtimeTripId'].toString().isNotEmpty) {
            tripIds.add(p['RealtimeTripId'].toString());
          }
          if (p['AVMSTripID'] != null &&
              p['AVMSTripID'].toString().isNotEmpty) {
            tripIds.add(p['AVMSTripID'].toString());
          }
          if (p['realtimeTripId'] != null &&
              p['realtimeTripId'].toString().isNotEmpty) {
            tripIds.add(p['realtimeTripId'].toString());
          }
        }
      }

      final legsJson = r['legs'];
      if (legsJson is List) {
        for (var l in legsJson) {
          if (l is Map<String, dynamic>) {
            if (l['tripId'] != null && l['tripId'].toString().isNotEmpty) {
              tripIds.add(l['tripId'].toString());
            }
            if (l['trip_id'] != null && l['trip_id'].toString().isNotEmpty) {
              tripIds.add(l['trip_id'].toString());
            }

            final ttp = l['transportation'];
            if (ttp is Map && ttp['properties'] is Map) {
              final p = ttp['properties'] as Map<dynamic, dynamic>;
              if (p['RealtimeTripId'] != null &&
                  p['RealtimeTripId'].toString().isNotEmpty) {
                tripIds.add(p['RealtimeTripId'].toString());
              }
              if (p['AVMSTripID'] != null &&
                  p['AVMSTripID'].toString().isNotEmpty) {
                tripIds.add(p['AVMSTripID'].toString());
              }
              if (p['realtimeTripId'] != null &&
                  p['realtimeTripId'].toString().isNotEmpty) {
                tripIds.add(p['realtimeTripId'].toString());
              }
            }
          }
        }
      }
    }

    // Also collect trip IDs from the active leg's raw JSON or transportation raw JSON
    final legObj = _updatedLeg ?? widget.leg;
    final lr = legObj.rawJson;
    if (lr != null) {
      if (lr['tripId'] != null && lr['tripId'].toString().isNotEmpty) {
        tripIds.add(lr['tripId'].toString());
      }
      if (lr['trip_id'] != null && lr['trip_id'].toString().isNotEmpty) {
        tripIds.add(lr['trip_id'].toString());
      }

      final t = lr['transportation'];
      if (t is Map && t['properties'] is Map) {
        final p = t['properties'] as Map<dynamic, dynamic>;
        if (p['RealtimeTripId'] != null &&
            p['RealtimeTripId'].toString().isNotEmpty) {
          tripIds.add(p['RealtimeTripId'].toString());
        }
        if (p['AVMSTripID'] != null && p['AVMSTripID'].toString().isNotEmpty) {
          tripIds.add(p['AVMSTripID'].toString());
        }
        if (p['realtimeTripId'] != null &&
            p['realtimeTripId'].toString().isNotEmpty) {
          tripIds.add(p['realtimeTripId'].toString());
        }
      }
    }

    // If we found any trip IDs, filter vehicles by trip id; otherwise fallback to route id filter
    if (tripIds.isNotEmpty) {
      return _vehicles
          .where((v) => v.trip.hasTripId() && tripIds.contains(v.trip.tripId))
          .toList();
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
      final aggregate =
          await (widget.getAllVehiclesAggregated?.call() ??
              RealtimeService.getAllVehiclePositionsAggregated());
      final dedupedVehicles = aggregate.vehicles.toList();
      final breakdown = aggregate.breakdown;

      dedupedVehicles.sort(
        (a, b) => _vehicleDisplayId(
          a,
        ).toLowerCase().compareTo(_vehicleDisplayId(b).toLowerCase()),
      );

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

  String? _isoFromUnixSeconds(int? unixSeconds) {
    if (unixSeconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    ).toIso8601String();
  }

  String? _plannedFromEvent(TripUpdate_StopTimeEvent event) {
    if (!event.hasTime()) return null;
    final eventTime = event.time.toInt();
    final time = _isoFromUnixSeconds(eventTime);
    if (time == null || !event.hasDelay()) return time;
    return DateTime.fromMillisecondsSinceEpoch(
      eventTime * 1000,
      isUtc: true,
    ).subtract(Duration(seconds: event.delay)).toIso8601String();
  }

  Future<List<_VehicleStopRow>> _buildVehicleStopsFromTripUpdate(
    TripUpdate update,
  ) async {
    final stopUpdates = update.stopTimeUpdate;
    if (stopUpdates.isEmpty) return <_VehicleStopRow>[];

    final rows = <_VehicleStopRow>[];

    for (var i = 0; i < stopUpdates.length; i++) {
      final stopUpdate = stopUpdates[i];
      final stopId = stopUpdate.hasStopId() ? stopUpdate.stopId : null;
      final seq = stopUpdate.hasStopSequence()
          ? stopUpdate.stopSequence
          : i + 1;

      final label = stopId != null && stopId.isNotEmpty
          ? stopId
          : 'Stop ${seq > 0 ? seq : i + 1}';

      final arrival = stopUpdate.hasArrival() ? stopUpdate.arrival : null;
      final departure = stopUpdate.hasDeparture() ? stopUpdate.departure : null;

      rows.add(
        _VehicleStopRow(
          label: label,
          stopId: stopId,
          arrivalTimePlanned: arrival != null
              ? _plannedFromEvent(arrival)
              : null,
          arrivalTimeEstimated: arrival != null
              ? _isoFromUnixSeconds(arrival.time.toInt())
              : null,
          departureTimePlanned: departure != null
              ? _plannedFromEvent(departure)
              : null,
          departureTimeEstimated: departure != null
              ? _isoFromUnixSeconds(departure.time.toInt())
              : null,
          skipped:
              stopUpdate.scheduleRelationship ==
              TripUpdate_StopTimeUpdate_ScheduleRelationship.SKIPPED,
        ),
      );
    }

    return rows;
  }

  Future<void> _loadVehicleStopsForLeg() async {
    setState(() {
      _isLoadingVehicleStops = true;
      _vehicleStopsError = null;
      _vehicleStops = [];
    });

    try {
      final aggregate =
          await (widget.getAllTripUpdatesAggregated?.call() ??
              RealtimeService.getAllTripUpdatesAggregated());
      final tripUpdates = aggregate.tripUpdates;
      final tripIds = _collectTripIdsForActiveLeg();
      final routeId = _legRouteId();

      TripUpdate? match;
      if (tripIds.isNotEmpty) {
        for (final update in tripUpdates) {
          if (update.trip.hasTripId() && tripIds.contains(update.trip.tripId)) {
            match = update;
            break;
          }
        }
      }

      if (match == null && routeId != null && routeId.isNotEmpty) {
        for (final update in tripUpdates) {
          if (update.trip.hasRouteId() && update.trip.routeId == routeId) {
            match = update;
            break;
          }
        }
      }

      if (match == null) {
        throw StateError('No realtime trip update found for this leg');
      }

      final rows = await _buildVehicleStopsFromTripUpdate(match);

      if (!mounted) return;
      setState(() {
        _vehicleStops = rows;
        _isLoadingVehicleStops = false;
      });
    } catch (e) {
      logger.i('Failed to load vehicle stops for leg: $e');
      if (!mounted) return;
      setState(() {
        _vehicleStopsError = e.toString();
        _isLoadingVehicleStops = false;
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

  /// Returns true when the leg has enough coordinate data to render a map.
  bool _legHasCoords(Leg leg) {
    final coords = leg.coords;
    if (coords != null && coords.length >= 2) return true;
    final stops = leg.stopSequence;
    if (stops != null && stops.length >= 2) return true;
    // At minimum, origin + destination coords are enough to draw a line.
    return (leg.origin.coord?.length ?? 0) >= 2 &&
        (leg.destination.coord?.length ?? 0) >= 2;
  }

  /// Builds the core [RealtimeMapWidget] for a leg, used in both the card
  /// (scrollable debug layout) and the full-height (non-scrollable) layout.
  RealtimeMapWidget _buildRealtimeMapWidget(
    String? transportId,
    TransportMode? mode,
    Leg leg,
    List<Leg> additionalLegs,
  ) {
    final hasTransport = transportId != null && transportId.isNotEmpty;
    return RealtimeMapWidget(
      // No ValueKey: didUpdateWidget in RealtimeMapWidget handles camera
      // updates when the leg prop changes, avoiding a full teardown/rebuild.
      leg: leg,
      additionalLegs: additionalLegs,
      transportMode: mode,
      routeFilter: hasTransport ? transportId : null,
      filterByLegTrip: hasTransport,
      tripIds: hasTransport ? _collectLegTripIds() : null,
      showVehicleCount: false,
      getAllVehiclesAggregated: hasTransport
          ? (widget.getAllVehiclesAggregated ??
                RealtimeService.getAllVehiclePositionsAggregated)
          : () async => const VehiclePositionAggregationResult(
              vehicles: <VehiclePosition>[],
              breakdown: <String, int>{},
            ),
    );
  }

  /// Returns the map widget filling all available space (used in the
  Widget _buildMapCard(
    String? transportId,
    TransportMode? mode,
    Leg leg,
    Color modeColor,
    List<Leg> additionalLegs,
  ) {
    if (widget.skipInitialLoadDelay) {
      return const SizedBox.shrink();
    }

    final hasTransport = transportId != null && transportId.isNotEmpty;
    if (!hasTransport && !_legHasCoords(leg)) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            _buildRealtimeMapWidget(transportId, mode, leg, additionalLegs),
            Positioned(
              bottom: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen),
                  color: modeColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeMapPage(
                          leg: leg,
                          transportMode: mode,
                          routeFilter: hasTransport ? transportId : null,
                          filterByLegTrip: hasTransport,
                          tripIds: hasTransport ? _collectLegTripIds() : null,
                          getAllVehiclesAggregated: hasTransport
                              ? RealtimeService.getAllVehiclePositionsAggregated
                              : () async =>
                                    const VehiclePositionAggregationResult(
                                      vehicles: <VehiclePosition>[],
                                      breakdown: <String, int>{},
                                    ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String? transportName,
    int? transportClass,
    String originName,
    String destinationName,
    Color modeColor,
    Stop origin,
    Stop destination,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode badge + service name
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
                if (transportName != null && transportName.isNotEmpty) ...[
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
                // Status indicator
                const SizedBox(width: 8),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // From / To with departure / arrival times
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        originName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.departure_board,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeDifference(
                              origin.departureTimePlanned,
                              origin.departureTimeEstimated,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Icon(Icons.arrow_forward, color: modeColor),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'To',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        destinationName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeDifference(
                              destination.arrivalTimePlanned,
                              destination.arrivalTimeEstimated,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a card listing every stop in the leg's stop sequence with
  /// its planned/estimated departure and arrival times.
  Widget _buildStopList(Leg leg, Color modeColor) {
    final tripStops = leg.stopSequence;
    if (tripStops == null || tripStops.isEmpty) return const SizedBox.shrink();

    final supportsRealtime = _supportsRealtimeForLeg(leg);
    final tripRows = _buildTripStopRows(tripStops);
    final useVehicleStops = _showAllVehicleStops && _vehicleStops.isNotEmpty;
    final rows = useVehicleStops ? _vehicleStops : tripRows;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      useVehicleStops
                          ? 'Vehicle stops (${rows.length})'
                          : 'Trip stops (${rows.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (_isLoadingVehicleStops)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (supportsRealtime)
                    TextButton.icon(
                      onPressed: () async {
                        if (_showAllVehicleStops) {
                          setState(() {
                            _showAllVehicleStops = false;
                          });
                          return;
                        }

                        setState(() {
                          _showAllVehicleStops = true;
                        });
                        await _loadVehicleStopsForLeg();
                      },
                      icon: Icon(
                        _showAllVehicleStops
                            ? Icons.view_list_outlined
                            : Icons.directions_bus,
                      ),
                      label: Text(
                        _showAllVehicleStops
                            ? 'Show trip stops'
                            : 'Show vehicle stops',
                      ),
                    ),
                ],
              ),
            ),
            if (_vehicleStopsError != null && _showAllVehicleStops) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Vehicle stop view unavailable: $_vehicleStopsError',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
            const Divider(height: 1),
            ...rows.asMap().entries.map((entry) {
              final idx = entry.key;
              final stop = entry.value;
              final isFirst = idx == 0;
              final isLast = idx == rows.length - 1;

              final depPlanned = stop.departureTimePlanned;
              final depEstimated = stop.departureTimeEstimated;
              final arrPlanned = stop.arrivalTimePlanned;
              final arrEstimated = stop.arrivalTimeEstimated;
              final mainTimePlanned = depPlanned ?? arrPlanned;
              final mainTimeEstimated = depEstimated ?? arrEstimated;

              return Container(
                decoration: (isFirst || isLast)
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(color: modeColor, width: 4),
                        ),
                      )
                    : null,
                child: ListTile(
                  dense: true,
                  leading: SizedBox(
                    width: 28,
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: (isFirst || isLast)
                              ? modeColor
                              : modeColor.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    stop.label,
                    style: TextStyle(
                      fontWeight: (isFirst || isLast)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: stop.skipped
                      ? const Text(
                          'Skipped',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        )
                      : null,
                  trailing: mainTimePlanned != null
                      ? _buildStopTimeWidget(
                          mainTimePlanned,
                          mainTimeEstimated,
                          isArrival: depPlanned == null && arrPlanned != null,
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_VehicleStopRow> _buildTripStopRows(List<Stop> stops) {
    return stops.asMap().entries.map((entry) {
      final stop = entry.value;
      return _VehicleStopRow(
        label: stop.disassembledName ?? stop.name,
        stopId: stop.id,
        arrivalTimePlanned: stop.arrivalTimePlanned,
        arrivalTimeEstimated: stop.arrivalTimeEstimated,
        departureTimePlanned: stop.departureTimePlanned,
        departureTimeEstimated: stop.departureTimeEstimated,
      );
    }).toList();
  }

  /// Formats a single stop time with optional delay indication.
  Widget _buildStopTimeWidget(
    String planned,
    String? estimated, {
    bool isArrival = false,
  }) {
    final plannedFormatted = _safeFormatTime(planned);
    String? delayText;
    Color timeColor = Colors.grey.shade700;

    if (estimated != null && estimated != planned) {
      final plannedDt = DateTimeUtils.parseTimeToDateTime(planned);
      final estimatedDt = DateTimeUtils.parseTimeToDateTime(estimated);
      if (plannedDt != null && estimatedDt != null) {
        final diff = estimatedDt.difference(plannedDt).inMinutes;
        if (diff > 0) {
          delayText = '+${diff}m';
          timeColor = Colors.red;
        } else if (diff < 0) {
          delayText = '${diff}m';
          timeColor = Colors.orange;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          plannedFormatted,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: delayText != null ? Colors.grey : timeColor,
            decoration: delayText != null
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        if (delayText != null)
          Text(
            delayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
      ],
    );
  }

  String _safeFormatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      return DateTimeUtils.parseTimeOnly(timeStr);
    } catch (_) {
      return timeStr;
    }
  }

  void _appendScalarPreviewFields(
    StringBuffer buffer,
    Map<String, dynamic>? json, {
    required String title,
    int maxEntries = 8,
  }) {
    if (json == null) {
      return;
    }

    final entries = json.entries
        .where((entry) {
          final value = entry.value;
          return value == null ||
              value is String ||
              value is num ||
              value is bool;
        })
        .take(maxEntries)
        .toList();

    if (entries.isEmpty) {
      return;
    }

    buffer.writeln('\n$title:');
    for (final entry in entries) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }
  }

  Widget _buildDebugCards(Leg leg, String? transportId, Color modeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebug, child) {
        if (!showDebug) return const SizedBox.shrink();
        final tripDebugPreviewText = widget.trip != null
            ? _tripDebugPreviewString(widget.trip!)
            : null;
        final legDebugPreviewText = _legDebugPreviewString(leg);
        return Column(
          children: [
            if (transportId != null && transportId.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter vehicle debug data by the active trip or route',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Filter'),
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
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.trip != null && tripDebugPreviewText != null) ...[
              Card(
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
                              'Trip debug data',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy trip debug to clipboard',
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: _tripDebugString(widget.trip!),
                                  ),
                                );
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Copied trip debug data to clipboard',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to copy trip debug data',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Full Trip data (includes legs and raw JSON below):',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: SingleChildScrollView(
                          child: Text(
                            tripDebugPreviewText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
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
                            style: Theme.of(context).textTheme.titleMedium
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
                                    'Copied leg debug data to clipboard',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to copy to clipboard'),
                                ),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: SingleChildScrollView(
                        child: Text(
                          legDebugPreviewText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
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
                            'Vehicle debug data',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy vehicle debug to clipboard',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final lines = _displayedVehicles
                                  .map((v) {
                                    final id = v.vehicle.hasId()
                                        ? v.vehicle.id
                                        : 'N/A';
                                    final tripId = v.trip.hasTripId()
                                        ? v.trip.tripId
                                        : 'N/A';
                                    final routeId = v.trip.hasRouteId()
                                        ? v.trip.routeId
                                        : 'N/A';
                                    final pos =
                                        v.hasPosition() &&
                                            v.position.hasLatitude() &&
                                            v.position.hasLongitude()
                                        ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                                        : 'N/A';
                                    final ts = v.hasTimestamp()
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                            v.timestamp.toInt() * 1000,
                                          ).toIso8601String()
                                        : 'N/A';
                                    return 'id=$id trip=$tripId route=$routeId pos=$pos ts=$ts';
                                  })
                                  .join('\n');

                              await Clipboard.setData(
                                ClipboardData(text: lines),
                              );
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Copied vehicle debug data to clipboard',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to copy vehicle debug data',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Showing ${_displayedVehicles.length} of ${_vehicles.length} realtime vehicles (sorted alphabetically):',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    if (_vehicleBreakdown.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _vehicleBreakdown.entries
                            .map(
                              (e) => Chip(
                                label: Text('${e.key}: ${e.value}'),
                                backgroundColor: Colors.grey.shade100,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    if (transportId == null || transportId.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.route, color: Colors.grey),
                        title: Text(
                          'Realtime tracking unavailable for this leg',
                        ),
                      )
                    else if (_isLoadingVehicles)
                      const Center(child: CircularProgressIndicator())
                    else if (_vehicles.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.location_off, color: Colors.grey),
                        title: Text('No vehicles found'),
                      )
                    else if (_displayedVehicles.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.filter_alt_off, color: Colors.grey),
                        title: Text(
                          'No vehicles match the current trip/route filter',
                        ),
                      )
                    else
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          itemCount: _displayedVehicles.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final v = _displayedVehicles[index];
                            final id = v.vehicle.hasId() ? v.vehicle.id : 'N/A';
                            final tripId = v.trip.hasTripId()
                                ? v.trip.tripId
                                : 'N/A';
                            final routeId = v.trip.hasRouteId()
                                ? v.trip.routeId
                                : 'N/A';
                            final pos =
                                v.hasPosition() &&
                                    v.position.hasLatitude() &&
                                    v.position.hasLongitude()
                                ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                                : 'N/A';
                            final routeMatch =
                                v.trip.hasRouteId() &&
                                v.trip.routeId == transportId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: routeMatch
                                    ? Colors.orange
                                    : modeColor,
                                foregroundColor: getContrastingForeground(
                                  modeColor,
                                ),
                                child: Text(
                                  id == 'N/A' ? '?' : id[0].toUpperCase(),
                                ),
                              ),
                              title: Text(id),
                              subtitle: Text(
                                'Trip: $tripId • Route: $routeId • Pos: $pos',
                              ),
                              dense: true,
                              trailing: routeMatch
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                      size: 18,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get the color of the adjacent leg (for navigation button colors).
  Color _getAdjacentLegColor(int index) {
    final legs = widget.trip?.legs;
    if (legs == null || index < 0 || index >= legs.length) return Colors.grey;
    final adjLeg = legs[index];
    final adjClass = adjLeg.transportation?.product?.classField;
    return adjClass != null
        ? TransportModeUtils.getModeColor(adjClass)
        : Colors.grey;
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

    final mode = _getRealtimeModeFromClass(transportClass);

    final tripLegs = widget.trip?.legs ?? [];
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLegData,
          ),
          if (transportId != null && transportId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealtimeMapPage(
                      leg: leg,
                      transportMode: mode,
                      routeFilter: transportId,
                      filterByLegTrip: true,
                      tripIds: _collectLegTripIds(),
                      getAllVehiclesAggregated:
                          RealtimeService.getAllVehiclePositionsAggregated,
                    ),
                  ),
                );
              },
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
            onRefresh: _refreshLegData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              child: Column(
                children: [
                  _buildMapCard(transportId, mode, leg, modeColor, otherLegs),
                  _buildInfoCard(
                    transportName,
                    transportClass,
                    originName,
                    destinationName,
                    modeColor,
                    origin,
                    destination,
                  ),
                  const SizedBox(height: 8),
                  _buildStopList(leg, modeColor),
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
