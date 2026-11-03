import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

import 'entity_data_source.dart';
import 'resolver_models.dart';

class DebugEndpointResolver {
  final DebugEntityDataSource _dataSource;
  final DebugEndpointForMode _endpointsForMode;

  DebugEndpointResolver({
    required DebugEntityDataSource dataSource,
    required DebugEndpointForMode endpointsForMode,
  }) : _dataSource = dataSource,
       _endpointsForMode = endpointsForMode;

  StopsEndpoint? endpointForKey(String? endpointKey) {
    if (endpointKey == null) {
      return null;
    }
    return StopsEndpoint.values.firstWhereOrNull(
      (endpoint) => endpoint.key == endpointKey,
    );
  }

  Future<List<StopsEndpoint>> candidateRouteEndpoints({
    api.Leg? leg,
    api.TripJourney? trip,
    TransportMode? modeHint,
    StopsEndpoint? explicitEndpoint,
  }) async {
    final ordered = <StopsEndpoint>{};
    if (explicitEndpoint != null) {
      ordered.add(explicitEndpoint);
    }

    final stopIds = <String>{};
    if (leg != null) {
      stopIds
        ..add(leg.origin.id)
        ..add(leg.destination.id)
        ..addAll(
          (leg.stopSequence ?? const <api.Stop>[]).map((stop) => stop.id),
        );
    }
    if (trip != null && leg == null) {
      stopIds.addAll(
        DebugExtractors.collectStopsForTrip(trip).map((stop) => stop.id),
      );
    }

    for (final stopId in stopIds.where((id) => id.isNotEmpty)) {
      final rows = await _dataSource.lookupDbStops(stopId);
      for (final row in rows) {
        final endpoint = endpointForKey(row.endpoint);
        if (endpoint != null) {
          ordered.add(endpoint);
        }
      }
    }

    if (modeHint != null) {
      try {
        ordered.addAll(_endpointsForMode.call(modeHint));
      } catch (_) {}
    }
    return ordered.toList(growable: false);
  }
}
