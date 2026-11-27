part of '../trip_leg_detail_screen.dart';

/// Formats route and agency diagnostics for copy and preview actions.
extension _RouteDebugText on _TripLegDetailScreenState {
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
}
