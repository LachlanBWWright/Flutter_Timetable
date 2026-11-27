part of '../trip_leg_detail_screen.dart';

/// Formats journey and leg snapshots without changing their source data.
extension _JourneyDebugText on _TripLegDetailScreenState {
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
}
