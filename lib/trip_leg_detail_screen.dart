// ignore_for_file: catch_unknown_dynamic_calls

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
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/realtime_trip_id_utils.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:lbww_flutter/utils/trip_leg_debug_utils.dart';
import 'package:lbww_flutter/utils/trip_leg_detail_utils.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/travel_warning_card.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

import 'utils/color_utils.dart';

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
  });

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _VehicleStopRow {
  final String label;
  final String? stopId;
  final String? platform;
  final String? wheelchairAccess;
  final String? arrivalTimePlanned;
  final String? arrivalTimeEstimated;
  final String? departureTimePlanned;
  final String? departureTimeEstimated;
  final bool skipped;

  const _VehicleStopRow({
    required this.label,
    this.stopId,
    this.platform,
    this.wheelchairAccess,
    this.arrivalTimePlanned,
    this.arrivalTimeEstimated,
    this.departureTimePlanned,
    this.departureTimeEstimated,
    this.skipped = false,
  });
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen>
    with GuardedState<TripLegDetailScreen> {
  Leg? _updatedLeg;
  late final DebugEntityPageLoader _debugPageLoader;
  late final DebugEntityListPageLoader _debugListLoader;
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
  bool _isLoadingRouteDebug = false;
  String? _routeDebugError;
  gtfs_route.Route? _gtfsRoute;
  gtfs_agency.Agency? _gtfsAgency;
  String? _gtfsRouteEndpointKey;
  String? _gtfsRouteMatchReason;
  int _currentLegIndex = 0;
  Future<VehiclePositionAggregationResult>? _vehicleAggregateFuture;
  Future<TripUpdateAggregationResult>? _tripUpdateAggregateFuture;

  T? _itemAt<T>(List<T> items, int index) {
    if (index < 0) {
      return null;
    }
    var currentIndex = 0;
    for (final item in items) {
      if (currentIndex == index) {
        return item;
      }
      currentIndex++;
    }
    return null;
  }

  StopsEndpoint? _endpointForKey(String key) {
    for (final endpoint in StopsEndpoint.values) {
      if (endpoint.key == key) {
        return endpoint;
      }
    }
    return null;
  }

  Leg get _activeLeg => _updatedLeg ?? widget.leg;
  List<Leg> get _tripLegs => widget.trip?.legs ?? const <Leg>[];

  String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _firstNonBlank(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = _trimmedOrNull(value);
      if (trimmed != null) {
        return trimmed;
      }
    }
    return null;
  }

  String _displayOrNa(String? value) => value ?? 'N/A';

  String _displayValueOrNa(Object? value) => value?.toString() ?? 'N/A';

  String? _legRouteIdFor(Leg leg) => _trimmedOrNull(leg.transportation?.id);

  List<Stop> _legStops(Leg leg) => leg.stopSequence ?? const <Stop>[];

  String? _transportDisassembledName(Transportation? transportation) {
    return _trimmedOrNull(transportation?.disassembledName);
  }

  String? _transportOperatorId(Transportation? transportation) {
    return _trimmedOrNull(transportation?.operator?.id);
  }

  String? _transportLabel(Transportation? transportation) {
    return _firstNonBlank([
      transportation?.name,
      transportation?.disassembledName,
      transportation?.id,
    ]);
  }

  String _legTransportLabel(Leg leg) {
    return _displayOrNa(_transportLabel(leg.transportation));
  }

  String? _transportNumber(Transportation? transportation) {
    return _trimmedOrNull(transportation?.number);
  }

  String? _transportDescription(Transportation? transportation) {
    return _trimmedOrNull(transportation?.description);
  }

  String? _transportDestinationId(Transportation? transportation) {
    return _trimmedOrNull(transportation?.destination?.id);
  }

  String? _transportDestinationName(Transportation? transportation) {
    return _firstNonBlank([transportation?.destination?.name]);
  }

  String? _transportOperatorName(Transportation? transportation) {
    return _firstNonBlank([transportation?.operator?.name]);
  }

  String? _transportProductName(Transportation? transportation) {
    return _firstNonBlank([transportation?.product?.name]);
  }

  int? _transportClass(Transportation? transportation) {
    return transportation?.product?.classField;
  }

  Map<String, dynamic>? _transportRawJson(Transportation? transportation) {
    if (transportation == null || transportation.rawJson.isEmpty) {
      return null;
    }
    return transportation.rawJson;
  }

  @override
  void initState() {
    super.initState();
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
    _updatedLeg = widget.leg;
    final idx = _tripLegs.indexOf(widget.leg);
    _currentLegIndex = idx >= 0 ? idx : 0;
    if (widget.skipInitialLoadDelay) {
      if (_supportsRealtimeForLeg(_activeLeg)) {
        _loadVehiclesForLeg();
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

  void _goToLeg(int index) {
    final legs = _tripLegs;
    if (index < 0 || index >= legs.length) return;
    final selectedLeg = _itemAt(legs, index);
    if (selectedLeg == null) {
      return;
    }
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
  void dispose() {
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
    final transport = leg.transportation;
    if (transport != null) {
      buffer.writeln('  id: ${_displayOrNa(_legRouteIdFor(leg))}');
      buffer.writeln('  name: ${_displayOrNa(_transportLabel(transport))}');
      buffer.writeln('  number: ${_displayOrNa(_transportNumber(transport))}');
      buffer.writeln(
        '  product class: ${_displayValueOrNa(_transportClass(transport))}',
      );
    } else {
      buffer.writeln('  N/A');
    }

    final stopSequence = _legStops(leg);
    buffer.writeln('\nStops (${stopSequence.length}):');
    if (stopSequence.isNotEmpty) {
      var stopNumber = 1;
      for (final stop in stopSequence) {
        buffer.writeln('  $stopNumber. ${stop.name} (id: ${stop.id})');
        stopNumber++;
      }
    }

    buffer.writeln('\nProperties:');
    buffer.writeln('  differentFares: ${leg.properties?.differentFares}');
    buffer.writeln('  lineType: ${leg.properties?.lineType}');

    _appendLegRelationshipSnapshot(buffer, leg);

    // Raw JSON for the leg
    buffer.writeln('\nRaw leg JSON:');
    final prettyLegJson = prettyPrintJsonOrNull(leg.rawJson);
    buffer.writeln(
      prettyLegJson ?? '  <failed to pretty-print raw JSON for leg>',
    );

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
    var legNumber = 1;
    for (final tripLeg in trip.legs) {
      buffer.writeln('\n--- Leg $legNumber ---');
      buffer.writeln(_legDebugString(tripLeg));
      legNumber++;
    }
    buffer.writeln('\nFull trip raw JSON:');
    buffer.writeln(const JsonEncoder.withIndent('  ').convert(trip.rawJson));
    return buffer.toString();
  }

  Set<String> _collectDebugTripIds(TripJourney trip) {
    final tripIds = <String>{};
    tripIds.addAll(collectTripIdsFromRawJson(trip.rawJson));

    final legsJson = tryReadListValue(trip.rawJson, 'legs');
    if (legsJson != null) {
      for (final legJson in legsJson.whereType<Map<String, dynamic>>()) {
        tripIds.addAll(collectTripIdsFromRawJson(legJson));
      }
    }

    return tripIds;
  }

  Set<String> _collectDebugRouteIds(TripJourney trip) {
    final routeIds = <String>{};

    for (final leg in trip.legs) {
      final routeId = _legRouteIdFor(leg);
      if (routeId != null && routeId.isNotEmpty) {
        routeIds.add(routeId);
      }

      final transport = tryReadJsonMap(leg.rawJson, 'transportation');
      final rawTransportId = tryReadMapValue(transport, 'id');
      if (rawTransportId != null) {
        final rawRouteId = rawTransportId.toString();
        if (rawRouteId.isNotEmpty) {
          routeIds.add(rawRouteId);
        }
      }
    }

    final legsJson = tryReadListValue(trip.rawJson, 'legs');
    if (legsJson != null) {
      for (final legJson in legsJson.whereType<Map<String, dynamic>>()) {
        final transport = tryReadJsonMap(legJson, 'transportation');
        final rawTransportId = tryReadMapValue(transport, 'id');
        if (rawTransportId != null) {
          final rawRouteId = rawTransportId.toString();
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
    var legNumber = 1;
    for (final tripLeg in trip.legs) {
      buffer.writeln('\n--- Leg $legNumber ---');
      buffer.writeln('  from: ${tripLeg.origin.name} (${tripLeg.origin.id})');
      buffer.writeln(
        '  to: ${tripLeg.destination.name} (${tripLeg.destination.id})',
      );
      buffer.writeln('  transport: ${_legTransportLabel(tripLeg)}');
      legNumber++;
    }
    appendScalarPreviewFields(
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
    buffer.writeln('  transport: ${_legTransportLabel(leg)}');
    buffer.writeln('  stops: ${leg.stopSequence?.length ?? 0}');
    _appendLegRelationshipSnapshot(buffer, leg);
    appendScalarPreviewFields(buffer, leg.rawJson, title: 'Leg raw fields');
    return buffer.toString();
  }

  void _appendLegRelationshipSnapshot(StringBuffer buffer, Leg leg) {
    final tripIds = _collectTripIdsForActiveLeg().toList(growable: false)
      ..sort();
    final stopIds = <String>{
      leg.origin.id,
      leg.destination.id,
      ..._legStops(leg).map((stop) => stop.id),
    }.where((id) => id.isNotEmpty).toList(growable: false)..sort();
    final vehicleIds =
        _displayedVehicles.map(vehicleDisplayId).toSet().toList(growable: false)
          ..sort();

    buffer.writeln('\nRelationship snapshot:');
    buffer.writeln('  routeId: ${_displayOrNa(_legRouteIdFor(leg))}');
    buffer.writeln(
      '  tripIds: ${tripIds.isEmpty ? 'N/A' : tripIds.join(', ')}',
    );
    buffer.writeln(
      '  stopIds: ${stopIds.isEmpty ? 'N/A' : stopIds.join(', ')}',
    );
    buffer.writeln(
      '  displayedVehicleIds: ${vehicleIds.isEmpty ? 'N/A' : vehicleIds.join(', ')}',
    );
    buffer.writeln('  gtfsEndpoint: ${_displayOrNa(_gtfsRouteEndpointKey)}');
    buffer.writeln('  gtfsRouteId: ${_displayOrNa(_gtfsRoute?.routeId)}');
    buffer.writeln('  gtfsAgency: ${_displayOrNa(_gtfsAgency?.agencyName)}');
  }

  String _routeDebugString(Leg leg) {
    final buffer = StringBuffer();
    final transport = leg.transportation;
    final rawTransport = tryReadMapValue(leg.rawJson, 'transportation');

    buffer.writeln('Route summary:');
    buffer.writeln('  id: ${_displayOrNa(_legRouteIdFor(leg))}');
    buffer.writeln('  name: ${_displayOrNa(_transportLabel(transport))}');
    buffer.writeln(
      '  disassembledName: ${_displayOrNa(_transportDisassembledName(transport))}',
    );
    buffer.writeln(
      '  description: ${_displayOrNa(_transportDescription(transport))}',
    );
    buffer.writeln('  number: ${_displayOrNa(_transportNumber(transport))}');
    buffer.writeln(
      '  operator.id: ${_displayOrNa(_transportOperatorId(transport))}',
    );
    buffer.writeln(
      '  operator.name: ${_displayOrNa(_transportOperatorName(transport))}',
    );
    buffer.writeln(
      '  destination.id: ${_displayOrNa(_transportDestinationId(transport))}',
    );
    buffer.writeln(
      '  destination.name: ${_displayOrNa(_transportDestinationName(transport))}',
    );
    buffer.writeln(
      '  product.name: ${_displayOrNa(_transportProductName(transport))}',
    );
    buffer.writeln(
      '  product.class: ${_displayValueOrNa(_transportClass(transport))}',
    );
    buffer.writeln(
      '  product.iconId: ${_displayValueOrNa(transport?.product?.iconId)}',
    );
    buffer.writeln('  iconId: ${_displayValueOrNa(transport?.iconId)}');
    buffer.writeln();

    buffer.writeln('Route properties:');
    final properties = transport?.properties;
    if (properties != null) {
      buffer.writeln('  isTTB: ${properties.isTTB}');
      buffer.writeln('  tripCode: ${properties.tripCode}');
    } else {
      buffer.writeln('  N/A');
    }

    _appendGtfsRouteDebugFields(buffer);

    buffer.writeln('\nTransportation raw JSON:');
    final transportRawJson = _transportRawJson(transport);
    final prettyRouteJson = prettyPrintJsonOrNull(
      transportRawJson ?? rawTransport,
    );
    if (prettyRouteJson != null) {
      buffer.writeln(prettyRouteJson);
    } else if (transportRawJson == null && rawTransport == null) {
      buffer.writeln('  <no raw JSON available for route>');
    } else {
      buffer.writeln('  <failed to pretty-print raw JSON for route>');
    }

    return buffer.toString();
  }

  String _routeDebugPreviewString(Leg leg) {
    final buffer = StringBuffer();
    final transport = leg.transportation;
    final rawTransport = tryReadMapValue(leg.rawJson, 'transportation');

    buffer.writeln('Route summary:');
    buffer.writeln('  id: ${_displayOrNa(_legRouteIdFor(leg))}');
    buffer.writeln('  name: ${_displayOrNa(_transportLabel(transport))}');
    buffer.writeln(
      '  disassembledName: ${_displayOrNa(_transportDisassembledName(transport))}',
    );
    buffer.writeln(
      '  description: ${_displayOrNa(_transportDescription(transport))}',
    );
    buffer.writeln('  number: ${_displayOrNa(_transportNumber(transport))}');
    buffer.writeln(
      '  operator.id: ${_displayOrNa(_transportOperatorId(transport))}',
    );
    buffer.writeln(
      '  operator.name: ${_displayOrNa(_transportOperatorName(transport))}',
    );
    buffer.writeln(
      '  destination.id: ${_displayOrNa(_transportDestinationId(transport))}',
    );
    buffer.writeln(
      '  destination.name: ${_displayOrNa(_transportDestinationName(transport))}',
    );
    buffer.writeln(
      '  product.name: ${_displayOrNa(_transportProductName(transport))}',
    );
    buffer.writeln(
      '  product class: ${_displayValueOrNa(_transportClass(transport))}',
    );
    buffer.writeln(
      '  product.iconId: ${_displayValueOrNa(transport?.product?.iconId)}',
    );
    buffer.writeln('  iconId: ${_displayValueOrNa(transport?.iconId)}');

    _appendGtfsRouteDebugFields(buffer);

    if (rawTransport is Map<String, dynamic>) {
      appendScalarPreviewFields(
        buffer,
        rawTransport,
        title: 'Transportation raw fields',
      );
    }

    return buffer.toString();
  }

  void _appendGtfsRouteDebugFields(StringBuffer buffer) {
    buffer.writeln();
    buffer.writeln('GTFS route lookup:');
    if (_isLoadingRouteDebug) {
      buffer.writeln('  status: loading');
      return;
    }
    if (_routeDebugError != null) {
      buffer.writeln('  status: error');
      buffer.writeln('  message: $_routeDebugError');
      return;
    }
    if (_gtfsRoute == null) {
      buffer.writeln('  status: not loaded');
      return;
    }

    final route = _gtfsRoute;
    if (route == null) {
      buffer.writeln('  status: not loaded');
      return;
    }
    final agency = _gtfsAgency;
    buffer.writeln('  status: loaded');
    buffer.writeln('  endpoint: ${_gtfsRouteEndpointKey ?? 'N/A'}');
    buffer.writeln('  match_reason: ${_gtfsRouteMatchReason ?? 'N/A'}');
    buffer.writeln('  route_id: ${route.routeId}');
    buffer.writeln('  route_short_name: ${route.routeShortName}');
    buffer.writeln('  route_long_name: ${route.routeLongName}');
    buffer.writeln('  route_desc: ${route.routeDesc ?? 'N/A'}');
    buffer.writeln('  route_type: ${route.routeType}');
    buffer.writeln('  route_url: ${route.routeUrl ?? 'N/A'}');
    buffer.writeln('  route_color: ${route.routeColor ?? 'N/A'}');
    buffer.writeln('  route_text_color: ${route.routeTextColor ?? 'N/A'}');
    buffer.writeln('  route_sort_order: ${route.routeSortOrder ?? 'N/A'}');
    buffer.writeln('  continuous_pickup: ${route.continuousPickup ?? 'N/A'}');
    buffer.writeln(
      '  continuous_drop_off: ${route.continuousDropOff ?? 'N/A'}',
    );
    buffer.writeln('  network_id: ${route.networkId ?? 'N/A'}');
    buffer.writeln('  agency_id: ${route.agencyId ?? 'N/A'}');
    if (agency != null) {
      buffer.writeln('  agency_name: ${agency.agencyName}');
      buffer.writeln('  agency_url: ${agency.agencyUrl}');
      buffer.writeln('  agency_timezone: ${agency.agencyTimezone}');
      buffer.writeln('  agency_lang: ${agency.agencyLang ?? 'N/A'}');
      buffer.writeln('  agency_phone: ${agency.agencyPhone ?? 'N/A'}');
      buffer.writeln('  agency_fare_url: ${agency.agencyFareUrl ?? 'N/A'}');
      buffer.writeln('  agency_email: ${agency.agencyEmail ?? 'N/A'}');
    }
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
    if (tryReadMapValue(rawJson, 'manual') == true) {
      return true;
    }

    final transportRawJson = _transportRawJson(leg.transportation);
    return tryReadMapValue(transportRawJson, 'manual') == true;
  }

  bool _supportsRealtimeForLeg(Leg leg) {
    final transportId = _legRouteIdFor(leg);
    return !_isManualLeg(leg) && transportId != null && transportId.isNotEmpty;
  }

  Future<void> _refreshLegData() async {
    _vehicleAggregateFuture = null;
    _tripUpdateAggregateFuture = null;
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    await runAsyncGuarded(
      () async {
        if (!mounted) return;
        guardedSetState(() {
          _isLoading = false;
        });
        final activeLeg = _activeLeg;
        if (_supportsRealtimeForLeg(activeLeg)) {
          await Future.wait([
            _loadVehiclesForLeg(),
            _loadRealtimeTripStatusForLeg(),
          ]);
          if (_showAllVehicleStops) {
            await _loadVehicleStopsForLeg();
          }
          if (DebugService.showDebugData.value) {
            _ensureRouteDebugLoaded();
          }
        } else if (mounted) {
          guardedSetState(() {
            _vehicles = [];
            _vehicleBreakdown = {};
            _vehicleStops = [];
            _vehicleStopsError = null;
            _isLoadingVehicles = false;
            _isLoadingVehicleStops = false;
            _resetRouteDebugState();
          });
        }
      },
      onError: (error, _) {
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  Future<VehiclePositionAggregationResult> _getVehicleAggregate() {
    final existing = _vehicleAggregateFuture;
    if (existing != null) {
      return existing;
    }

    late final Future<VehiclePositionAggregationResult> future;
    Future<VehiclePositionAggregationResult> loadAggregate() async {
      final getAllVehiclesAggregated = widget.getAllVehiclesAggregated;
      if (getAllVehiclesAggregated != null) {
        return runAsyncGuardedWithFallback(
          () => getAllVehiclesAggregated(),
          const VehiclePositionAggregationResult(
            vehicles: <VehiclePosition>[],
            breakdown: <String, int>{},
          ),
          onError: (_, _) {
            if (identical(_vehicleAggregateFuture, future)) {
              _vehicleAggregateFuture = null;
            }
          },
        );
      }
      return RealtimeService.getAllVehiclePositionsAggregatedSafe();
    }

    future = loadAggregate();
    _vehicleAggregateFuture = future;
    return future;
  }

  Future<TripUpdateAggregationResult> _getTripUpdateAggregate() {
    final existing = _tripUpdateAggregateFuture;
    if (existing != null) {
      return existing;
    }

    late final Future<TripUpdateAggregationResult> future;
    Future<TripUpdateAggregationResult> loadAggregate() async {
      final getAllTripUpdatesAggregated = widget.getAllTripUpdatesAggregated;
      if (getAllTripUpdatesAggregated != null) {
        return runAsyncGuardedWithFallback(
          () => getAllTripUpdatesAggregated(),
          const TripUpdateAggregationResult(
            tripUpdates: <TripUpdate>[],
            breakdown: <String, int>{},
          ),
          onError: (_, _) {
            if (identical(_tripUpdateAggregateFuture, future)) {
              _tripUpdateAggregateFuture = null;
            }
          },
        );
      }
      return RealtimeService.getAllTripUpdatesAggregatedSafe();
    }

    future = loadAggregate();
    _tripUpdateAggregateFuture = future;
    return future;
  }

  Future<void> _ensureRouteDebugLoaded() async {
    final leg = _activeLeg;
    final transportId = _legRouteIdFor(leg);
    final mode = _getRealtimeModeFromClass(_transportClass(leg.transportation));
    if (transportId == null || transportId.isEmpty) {
      guardedSetState(() {
        _routeDebugError = 'No route id available for this leg';
      });
      return;
    }
    if (_isLoadingRouteDebug || _gtfsRoute?.routeId == transportId) {
      return;
    }

    guardedSetState(() {
      _isLoadingRouteDebug = true;
      _routeDebugError = null;
      _gtfsRoute = null;
      _gtfsAgency = null;
      _gtfsRouteEndpointKey = null;
      _gtfsRouteMatchReason = null;
    });

    await runAsyncGuarded(
      () async {
        final endpoints = await _candidateRouteEndpoints(leg, mode);
        if (endpoints.isEmpty) {
          guardedSetState(() {
            _isLoadingRouteDebug = false;
            _routeDebugError =
                'No GTFS endpoint mapping found for this leg. Load stops data first or provide a transport mode.';
          });
          return;
        }

        final injectedGtfsLoader = widget.getGtfsDataForEndpoint;
        if (injectedGtfsLoader != null) {
          for (final endpoint in endpoints) {
            final data = await injectedGtfsLoader(endpoint);
            if (data == null) {
              continue;
            }
            final match = _matchGtfsRoute(leg, data.routes);
            final route = match?.$1;
            if (route == null) {
              continue;
            }
            final agency = _matchAgencyForRoute(route, data.agencies);
            if (!mounted) return;
            guardedSetState(() {
              _gtfsRoute = route;
              _gtfsAgency = agency;
              _gtfsRouteEndpointKey = endpoint.key;
              _gtfsRouteMatchReason = match?.$2;
              _isLoadingRouteDebug = false;
              _routeDebugError = null;
            });
            return;
          }
        } else {
          for (final endpoint in endpoints) {
            final routes = await _loadPersistedRoutesForEndpoint(endpoint);
            if (routes.isEmpty) {
              continue;
            }
            final match = _matchGtfsRoute(leg, routes);
            final route = match?.$1;
            if (route == null) {
              continue;
            }
            if (!mounted) return;
            guardedSetState(() {
              _gtfsRoute = route;
              _gtfsAgency = null;
              _gtfsRouteEndpointKey = endpoint.key;
              _gtfsRouteMatchReason = '${match?.$2} (cached routes table)';
              _isLoadingRouteDebug = false;
              _routeDebugError = null;
            });
            return;
          }
        }

        guardedSetState(() {
          _isLoadingRouteDebug = false;
          _routeDebugError =
              'No GTFS route match found for route id $transportId';
        });
      },
      onError: (error, _) {
        safeLogInfo('Failed to load GTFS route debug data: $error');
        guardedSetState(() {
          _isLoadingRouteDebug = false;
          _routeDebugError = error.toString();
        });
      },
    );
  }

  Future<List<gtfs_route.Route>> _loadPersistedRoutesForEndpoint(
    StopsEndpoint endpoint,
  ) async {
    final rows = await StopsService.database.getRoutesForEndpoint(endpoint.key);
    return rows.map(_dbRouteToGtfsRoute).toList(growable: false);
  }

  gtfs_route.Route _dbRouteToGtfsRoute(db.Route route) {
    return gtfs_route.Route(
      routeId: route.routeId,
      routeShortName: route.routeShortName ?? '',
      routeLongName: route.routeLongName ?? '',
      routeDesc: route.routeDesc,
      routeType: route.routeType ?? '',
      routeColor: route.routeColor,
      routeTextColor: route.routeTextColor,
      routeSortOrder: route.routeSortOrder,
    );
  }

  Future<List<StopsEndpoint>> _candidateRouteEndpoints(
    Leg leg,
    TransportMode? mode,
  ) async {
    if (mode != null) {
      return NewTripService.getEndpointsForMode(mode);
    }

    final orderedKeys = <String>[];

    final stopIds = <String>{
      leg.origin.id,
      leg.destination.id,
      ...?leg.stopSequence?.map((stop) => stop.id),
    }.where((id) => id.isNotEmpty);

    for (final stopId in stopIds) {
      final rows = await runAsyncGuardedWithFallback(
        () => StopsService.database.getStopsById(stopId),
        const <db.Stop>[],
        onError: (error, _) {
          safeLogInfo(
            'Failed to resolve stop endpoint for route debug: $error',
          );
        },
      );
      for (final row in rows) {
        if (!orderedKeys.contains(row.endpoint)) {
          orderedKeys.add(row.endpoint);
        }
      }
    }

    return orderedKeys.map(_endpointForKey).whereType<StopsEndpoint>().toList();
  }

  (gtfs_route.Route, String)? _matchGtfsRoute(
    Leg leg,
    List<gtfs_route.Route> routes,
  ) {
    final transport = leg.transportation;
    final transportId = _legRouteIdFor(leg);
    final transportNumber = _transportNumber(transport);
    final trimmedTransportName = _trimmedOrNull(transport?.name);
    final trimmedDisassembledName = _transportDisassembledName(transport);
    final transportNames = <String>{
      if (trimmedTransportName != null && trimmedTransportName.isNotEmpty)
        trimmedTransportName,
      if (trimmedDisassembledName != null && trimmedDisassembledName.isNotEmpty)
        trimmedDisassembledName,
    };

    for (final route in routes) {
      if (transportId != null &&
          transportId.isNotEmpty &&
          route.routeId == transportId) {
        return (route, 'route_id == transportation.id');
      }
    }

    if (transportNumber != null && transportNumber.isNotEmpty) {
      for (final route in routes) {
        if (route.routeShortName == transportNumber) {
          return (route, 'route_short_name == transportation.number');
        }
      }
    }

    for (final name in transportNames) {
      for (final route in routes) {
        if (route.routeShortName == name) {
          return (route, 'route_short_name == transportation.name');
        }
        if (route.routeLongName == name) {
          return (route, 'route_long_name == transportation.name');
        }
      }
    }

    return null;
  }

  gtfs_agency.Agency? _matchAgencyForRoute(
    gtfs_route.Route route,
    List<gtfs_agency.Agency> agencies,
  ) {
    if (agencies.isEmpty) {
      return null;
    }
    final agencyId = route.agencyId;
    if (agencyId != null && agencyId.isNotEmpty) {
      for (final agency in agencies) {
        if (agency.agencyId == agencyId) {
          return agency;
        }
      }
    }
    return agencies.length == 1 ? agencies.first : null;
  }

  StopsEndpoint? _currentGtfsEndpoint() {
    return currentGtfsEndpointFromKey(_gtfsRouteEndpointKey);
  }

  DebugEntityContext _debugContextForLeg(Leg leg, {VehiclePosition? vehicle}) {
    return DebugEntityContext(
      tripJourney: widget.trip,
      leg: leg,
      transportation: leg.transportation,
      vehiclePosition: vehicle,
      gtfsRoute: _gtfsRoute,
      gtfsAgency: _gtfsAgency,
      gtfsEndpoint: _currentGtfsEndpoint(),
      gtfsMatchReason: _gtfsRouteMatchReason,
    );
  }

  Future<void> _openTripDebugPage(Leg leg) async {
    final trip = widget.trip;
    if (trip == null) {
      return;
    }
    final tripIds = _collectDebugTripIds(trip);
    final tripId = tripIds.isNotEmpty ? tripIds.first : 'trip';
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.trip,
        entityId: tripId,
        context: _debugContextForLeg(leg),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openRouteDebugPage(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    if (routeId == null || routeId.isEmpty) {
      return;
    }
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.route,
        entityId: routeId,
        context: _debugContextForLeg(leg),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openVehicleDebugPage(Leg leg, VehiclePosition vehicle) async {
    final vehicleId = vehicleDisplayId(vehicle);
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.vehicle,
        entityId: vehicleId,
        context: _debugContextForLeg(leg, vehicle: vehicle),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openDebugBrowser(
    DebugEntityType entityType, {
    String? initialSearchQuery,
    Map<String, String> initialFilters = const {},
  }) async {
    await DebugNavigation.pushBrowser(
      context,
      entityType: entityType,
      listLoader: _debugListLoader,
      pageLoader: _debugPageLoader,
      initialSearchQuery: initialSearchQuery,
      initialFilters: initialFilters,
    );
  }

  Future<void> _openTripDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    final tripId = firstSortedValue(_collectTripIdsForActiveLeg());
    await _openDebugBrowser(
      DebugEntityType.trip,
      initialSearchQuery: tripId,
      initialFilters: {
        if (routeId != null && routeId.isNotEmpty) 'route': routeId,
      },
    );
  }

  Future<void> _openRouteDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    await _openDebugBrowser(
      DebugEntityType.route,
      initialSearchQuery: routeId != null && routeId.isNotEmpty
          ? routeId
          : null,
    );
  }

  Future<void> _openVehicleDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    final tripId = firstSortedValue(_collectTripIdsForActiveLeg());
    await _openDebugBrowser(
      DebugEntityType.vehicle,
      initialFilters: {
        if (routeId != null && routeId.isNotEmpty) 'route': routeId,
        if (tripId != null) 'trip': tripId,
      },
    );
  }

  String? _legRouteId() => _legRouteIdFor(_activeLeg);

  Set<String> _collectTripIdsForActiveLeg() {
    return collectTripIdsForVehicleFiltering(
      tripRawJson: widget.trip?.rawJson,
      legRawJson: _activeLeg.rawJson,
    );
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

    final tripIds = collectTripIdsForVehicleFiltering(
      tripRawJson: widget.trip?.rawJson,
      legRawJson: _activeLeg.rawJson,
    );

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
    guardedSetState(() {
      _isLoadingVehicles = true;
    });
    final aggregate = await _getVehicleAggregate();
    final dedupedVehicles = aggregate.vehicles.toList();
    final breakdown = aggregate.breakdown;

    dedupedVehicles.sort(
      (a, b) => vehicleDisplayId(
        a,
      ).toLowerCase().compareTo(vehicleDisplayId(b).toLowerCase()),
    );

    guardedSetState(() {
      _vehicles = dedupedVehicles;
      _vehicleBreakdown = breakdown;
      _isLoadingVehicles = false;
    });
  }

  Future<void> _loadRealtimeTripStatusForLeg() async {
    final aggregate = await _getTripUpdateAggregate();
    _matchTripUpdateForLeg(aggregate.tripUpdates);
  }

  TripUpdate? _matchTripUpdateForLeg(List<TripUpdate> tripUpdates) {
    final tripIds = _collectTripIdsForActiveLeg();
    if (tripIds.isNotEmpty) {
      for (final update in tripUpdates) {
        if (update.trip.hasTripId() && tripIds.contains(update.trip.tripId)) {
          return update;
        }
      }
    }

    final routeId = _legRouteId();
    if (routeId != null && routeId.isNotEmpty) {
      for (final update in tripUpdates) {
        if (update.trip.hasRouteId() && update.trip.routeId == routeId) {
          return update;
        }
      }
    }
    return null;
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
    final legStops = _legStops(_activeLeg);
    final rows = _buildTripStopRows(legStops);
    final usedUpdateIndexes = <int>{};

    _VehicleStopRow overlayRealtimeStop(
      _VehicleStopRow row,
      TripUpdate_StopTimeUpdate stopUpdate,
    ) {
      final arrival = stopUpdate.hasArrival() ? stopUpdate.arrival : null;
      final departure = stopUpdate.hasDeparture() ? stopUpdate.departure : null;

      return _VehicleStopRow(
        label: row.label,
        stopId: row.stopId,
        platform: row.platform,
        wheelchairAccess: row.wheelchairAccess,
        arrivalTimePlanned: arrival != null
            ? _plannedFromEvent(arrival)
            : row.arrivalTimePlanned,
        arrivalTimeEstimated: arrival != null
            ? _isoFromUnixSeconds(arrival.time.toInt())
            : row.arrivalTimeEstimated,
        departureTimePlanned: departure != null
            ? _plannedFromEvent(departure)
            : row.departureTimePlanned,
        departureTimeEstimated: departure != null
            ? _isoFromUnixSeconds(departure.time.toInt())
            : row.departureTimeEstimated,
        skipped:
            stopUpdate.scheduleRelationship ==
            TripUpdate_StopTimeUpdate_ScheduleRelationship.SKIPPED,
      );
    }

    int? matchUpdateIndexForRow(_VehicleStopRow row, int rowIndex) {
      if (stopUpdates.isEmpty) return null;

      final rowStopId = row.stopId;
      if (rowStopId != null && rowStopId.isNotEmpty) {
        var updateIndex = 0;
        for (final update in stopUpdates) {
          if (usedUpdateIndexes.contains(updateIndex)) {
            updateIndex++;
            continue;
          }
          if (update.hasStopId() && update.stopId == rowStopId) {
            return updateIndex;
          }
          updateIndex++;
        }
      }

      final targetSequence = rowIndex + 1;
      var updateIndex = 0;
      for (final update in stopUpdates) {
        if (usedUpdateIndexes.contains(updateIndex)) {
          updateIndex++;
          continue;
        }
        if (update.hasStopSequence() && update.stopSequence == targetSequence) {
          return updateIndex;
        }
        updateIndex++;
      }

      return null;
    }

    final overlaidRows = <_VehicleStopRow>[];
    var rowIndex = 0;
    for (final row in rows) {
      final matchIndex = matchUpdateIndexForRow(row, rowIndex);
      if (matchIndex == null) continue;
      usedUpdateIndexes.add(matchIndex);
      final matchedUpdate = _itemAt(stopUpdates, matchIndex);
      overlaidRows.add(
        matchedUpdate == null ? row : overlayRealtimeStop(row, matchedUpdate),
      );
      rowIndex++;
    }
    if (overlaidRows.isNotEmpty) {
      rows
        ..clear()
        ..addAll(overlaidRows);
    }

    var updateNumber = 0;
    for (final stopUpdate in stopUpdates) {
      if (usedUpdateIndexes.contains(updateNumber)) {
        updateNumber++;
        continue;
      }
      final stopId = stopUpdate.hasStopId() ? stopUpdate.stopId : null;
      final seq = stopUpdate.hasStopSequence()
          ? stopUpdate.stopSequence
          : rows.length + 1;
      final arrival = stopUpdate.hasArrival() ? stopUpdate.arrival : null;
      final departure = stopUpdate.hasDeparture() ? stopUpdate.departure : null;

      rows.add(
        _VehicleStopRow(
          label: stopId != null && stopId.isNotEmpty
              ? stopId
              : 'Stop ${seq > 0 ? seq : updateNumber + 1}',
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
      updateNumber++;
    }

    return rows;
  }

  Future<void> _loadVehicleStopsForLeg() async {
    guardedSetState(() {
      _isLoadingVehicleStops = true;
      _vehicleStopsError = null;
      _vehicleStops = [];
    });

    await runAsyncGuarded(
      () async {
        final aggregate = await _getTripUpdateAggregate();
        final tripUpdates = aggregate.tripUpdates;
        final tripIds = _collectTripIdsForActiveLeg();
        final routeId = _legRouteId();
        final match = _matchTripUpdateForLeg(tripUpdates);
        if (match == null) {
          guardedSetState(() {
            _vehicleStopsError = _buildRealtimeTripUpdateUnavailableMessage(
              tripIds: tripIds,
              routeId: routeId,
              breakdown: aggregate.breakdown,
            );
            _isLoadingVehicleStops = false;
          });
          return;
        }

        final rows = await _buildVehicleStopsFromTripUpdate(match);

        guardedSetState(() {
          _vehicleStops = rows;
          _isLoadingVehicleStops = false;
        });
      },
      onError: (error, _) {
        safeLogInfo('Failed to load vehicle stops for leg: $error');
        guardedSetState(() {
          _vehicleStopsError = error.toString();
          _isLoadingVehicleStops = false;
        });
      },
    );
  }

  Future<void> _copyDebugText({
    required String text,
    required String successMessage,
    required String failureMessage,
  }) async {
    final copied = await setClipboardTextSafely(text);
    if (copied) {
      showSnackBar(SnackBar(content: Text(successMessage)));
      return;
    }
    showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    return formatTimeDifference(plannedTime, estimatedTime);
  }

  String _buildRealtimeTripUpdateUnavailableMessage({
    required Set<String> tripIds,
    required String? routeId,
    required Map<String, int> breakdown,
  }) {
    final details = <String>[
      if (tripIds.isNotEmpty) 'tripIds=${tripIds.join(', ')}',
      if (routeId != null && routeId.isNotEmpty) 'routeId=$routeId',
      if (breakdown.isNotEmpty) 'feeds=${breakdown.keys.join(', ')}',
    ];
    if (details.isEmpty) {
      return 'No realtime match found for this leg.';
    }
    return 'No realtime match found for this leg (${details.join(' • ')}).';
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
          ? _getVehicleAggregate
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
                    pushPage(
                      (context) => RealtimeMapPage(
                        leg: leg,
                        additionalLegs: additionalLegs,
                        transportMode: mode,
                        routeFilter: hasTransport ? transportId : null,
                        filterByLegTrip: hasTransport,
                        tripIds: hasTransport ? _collectLegTripIds() : null,
                        getAllVehiclesAggregated: hasTransport
                            ? _getVehicleAggregate
                            : () async =>
                                  const VehiclePositionAggregationResult(
                                    vehicles: <VehiclePosition>[],
                                    breakdown: <String, int>{},
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
    Leg leg,
  ) {
    final routeNumber = _transportNumber(leg.transportation);
    final headsign = _transportDestinationName(leg.transportation);
    final operator = _transportOperatorName(leg.transportation);

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
            if (routeNumber != null && routeNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Route $routeNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (headsign != null && headsign.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Towards $headsign',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            if (operator != null && operator.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Operated by $operator',
                  style: const TextStyle(fontSize: 13),
                ),
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
                          ? 'All stops (${rows.length})'
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
                          guardedSetState(() {
                            _showAllVehicleStops = false;
                          });
                          return;
                        }

                        guardedSetState(() {
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
                            ? 'Show scheduled stops'
                            : 'Show all stops',
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
                      : _buildStopMetaSubtitle(stop),
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
    final rows = <_VehicleStopRow>[];
    for (final stop in stops) {
      rows.add(
        _VehicleStopRow(
          label: stop.disassembledName ?? stop.name,
          stopId: stop.id,
          platform: _extractPlatformLabel(stop),
          wheelchairAccess: stop.properties?.wheelchairAccess,
          arrivalTimePlanned: stop.arrivalTimePlanned,
          arrivalTimeEstimated: stop.arrivalTimeEstimated,
          departureTimePlanned: stop.departureTimePlanned,
          departureTimeEstimated: stop.departureTimeEstimated,
        ),
      );
    }
    return rows;
  }

  Widget? _buildStopMetaSubtitle(_VehicleStopRow stop) {
    final metadata = <String>[];
    final platform = trimmedOrNull(stop.platform);
    if (platform != null) {
      metadata.add('Platform $platform');
    }
    final wheelchairAccess = trimmedOrNull(stop.wheelchairAccess);
    if (wheelchairAccess != null) {
      metadata.add('Wheelchair: $wheelchairAccess');
    }
    if (metadata.isEmpty) return null;
    return Text(
      metadata.join(' • '),
      style: const TextStyle(fontSize: 12),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String? _extractPlatformLabel(Stop stop) {
    final raw = stop.rawJson;
    final candidates = [
      tryReadMapValue(raw, 'platform'),
      tryReadMapValue(raw, 'platformCode'),
      tryReadMapValue(raw, 'platformName'),
      tryReadMapValue(tryReadJsonMap(raw, 'properties'), 'platform'),
      tryReadMapValue(tryReadJsonMap(raw, 'properties'), 'platformCode'),
    ];
    for (final candidate in candidates) {
      final text = candidate?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  List<String> _collectLegNotices(Leg leg) {
    final notices = <String>{};
    for (final info in leg.infos ?? const <Info>[]) {
      final text = trimmedOrNull(info.subtitle) ?? trimmedOrNull(info.content);
      if (text != null && text.isNotEmpty) {
        notices.add(text);
      }
    }
    for (final hint in leg.hints ?? const <Hint>[]) {
      final text = hint.infoText?.trim();
      if (text != null && text.isNotEmpty) {
        notices.add(text);
      }
    }
    if (leg.interchange?.desc case final desc? when desc.trim().isNotEmpty) {
      notices.add(desc.trim());
    }
    return notices.toList(growable: false);
  }

  List<Widget> _buildAlertWarningChildren(Leg leg) {
    final notices = _collectLegNotices(leg);
    final pathSteps = (leg.pathDescriptions ?? const <PathDescription>[])
        .map((step) => step.name?.trim() ?? step.manoeuvre?.trim() ?? '')
        .where((step) => step.isNotEmpty)
        .take(4)
        .toList(growable: false);

    return [
      if (notices.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...notices
            .take(4)
            .map(
              (notice) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $notice', style: const TextStyle(fontSize: 13)),
              ),
            ),
      ],
      if (pathSteps.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text(
          'Walking guidance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        ...pathSteps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $step', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    ];
  }

  bool _hasAlertWarnings(Leg leg) {
    return _collectLegNotices(leg).isNotEmpty ||
        (leg.pathDescriptions ?? const <PathDescription>[]).any((step) {
          final text = step.name?.trim() ?? step.manoeuvre?.trim() ?? '';
          return text.isNotEmpty;
        });
  }

  /// Formats a single stop time with optional delay indication.
  Widget _buildStopTimeWidget(
    String planned,
    String? estimated, {
    bool isArrival = false,
  }) {
    final plannedFormatted = _formatTimeOrEmpty(planned);
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

  String _formatTimeOrEmpty(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    return DateTimeUtils.parseTimeOnly(timeStr);
  }

  Widget _buildDebugCards(Leg leg, String? transportId, Color modeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebug, child) {
        if (!showDebug) return const SizedBox.shrink();
        final trip = widget.trip;
        final tripDebugPreviewText = trip == null
            ? null
            : _tripDebugPreviewString(trip);
        final routeDebugPreviewText = _routeDebugPreviewString(leg);
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
                          guardedSetState(() {
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
            if (trip != null && tripDebugPreviewText != null) ...[
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Open standalone trip debug page',
                                onPressed: () => _openTripDebugPage(leg),
                                icon: const Icon(Icons.open_in_new, size: 18),
                              ),
                              IconButton(
                                tooltip: 'Open trip debug browser',
                                onPressed: () => _openTripDebugBrowser(leg),
                                icon: const Icon(Icons.manage_search, size: 18),
                              ),
                              IconButton(
                                tooltip: 'Copy trip debug to clipboard',
                                onPressed: () async {
                                  await _copyDebugText(
                                    text: _tripDebugString(trip),
                                    successMessage:
                                        'Copied trip debug data to clipboard',
                                    failureMessage:
                                        'Failed to copy trip debug data',
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                              ),
                            ],
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
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              tripDebugPreviewText,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
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
                            'Route debug data',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Open standalone route debug page',
                              onPressed: () => _openRouteDebugPage(leg),
                              icon: const Icon(Icons.open_in_new, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Open route debug browser',
                              onPressed: () => _openRouteDebugBrowser(leg),
                              icon: const Icon(Icons.manage_search, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Copy route debug to clipboard',
                              onPressed: () async {
                                await _copyDebugText(
                                  text: _routeDebugString(leg),
                                  successMessage:
                                      'Copied route debug data to clipboard',
                                  failureMessage:
                                      'Failed to copy route debug data',
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Active route/transport details for this leg:',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            routeDebugPreviewText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
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
                            'Leg debug data',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy debug text to clipboard',
                          onPressed: () async {
                            await _copyDebugText(
                              text: _legDebugString(leg),
                              successMessage:
                                  'Copied leg debug data to clipboard',
                              failureMessage: 'Failed to copy to clipboard',
                            );
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
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            legDebugPreviewText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Open vehicle debug browser',
                              onPressed: () => _openVehicleDebugBrowser(leg),
                              icon: const Icon(Icons.manage_search, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Copy vehicle debug to clipboard',
                              onPressed: () async {
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

                                await _copyDebugText(
                                  text: lines,
                                  successMessage:
                                      'Copied vehicle debug data to clipboard',
                                  failureMessage:
                                      'Failed to copy vehicle debug data',
                                );
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
                            final v = _itemAt(_displayedVehicles, index);
                            if (v == null) {
                              return const SizedBox.shrink();
                            }
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
                                  id == 'N/A'
                                      ? '?'
                                      : id.substring(0, 1).toUpperCase(),
                                ),
                              ),
                              title: Text(id),
                              subtitle: Text(
                                'Trip: $tripId • Route: $routeId • Pos: $pos',
                              ),
                              dense: true,
                              onTap: () => _openVehicleDebugPage(leg, v),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (routeMatch)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new, size: 18),
                                ],
                              ),
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
    final transportName = _transportLabel(transportation) ?? '';
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
            onPressed: _refreshLegData,
          ),
          if (transportId != null && transportId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                pushPage(
                  (context) => RealtimeMapPage(
                    leg: leg,
                    additionalLegs: otherLegs,
                    transportMode: mode,
                    routeFilter: transportId,
                    filterByLegTrip: true,
                    tripIds: _collectLegTripIds(),
                    getAllVehiclesAggregated: _getVehicleAggregate,
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
                    leg,
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
