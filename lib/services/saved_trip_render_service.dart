import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

class SavedTripRenderService {
  SavedTripRenderService._();

  static Future<api.TripJourney?> buildManualTripJourney(
    Journey journey,
  ) async {
    final definition = journey.manualTripDefinition;
    if (definition == null) {
      return null;
    }

    final legs = <api.Leg>[];
    for (final leg in definition.legs) {
      legs.add(await _buildManualLeg(leg, definition.mode));
    }

    return api.TripJourney(
      isAdditional: false,
      legs: legs,
      rawJson: {
        'manual': true,
        'lineId': definition.lineId,
        'lineName': definition.lineName,
        'legs': definition.legs.map((leg) => leg.toJson()).toList(),
      },
    );
  }

  static Future<api.Leg> _buildManualLeg(
    ManualTripLeg leg,
    TransportMode mode,
  ) async {
    final origin = await _buildStop(leg.originId, leg.originName);
    final destination = await _buildStop(
      leg.destinationId,
      leg.destinationName,
    );

    return api.Leg(
      origin: origin,
      destination: destination,
      isRealtimeControlled: false,
      stopSequence: [origin, destination],
      transportation: api.Transportation(
        name: leg.lineName,
        disassembledName: leg.lineName,
        number: leg.lineName,
        product: api.Product(
          classField: _transportClassForMode(mode),
          name: mode.displayName,
        ),
        rawJson: {
          'manual': true,
          'lineId': leg.lineId,
          'lineName': leg.lineName,
        },
      ),
      rawJson: {
        'manual': true,
        'lineId': leg.lineId,
        'lineName': leg.lineName,
        'originId': leg.originId,
        'destinationId': leg.destinationId,
      },
    );
  }

  static Future<api.Stop> _buildStop(String stopId, String fallbackName) async {
    final rows = await StopsService.database.getStopsById(stopId);
    final row = rows.isNotEmpty ? rows.first : null;
    final lat = row?.stopLat;
    final lon = row?.stopLon;
    final hasCoordinates =
        lat != null && lon != null && lat != 0.0 && lon != 0.0;

    return api.Stop(
      id: stopId,
      name: row?.stopName ?? fallbackName,
      disassembledName: row?.stopName ?? fallbackName,
      type: 'stop',
      coord: hasCoordinates ? [lat, lon] : null,
      rawJson: {'manual': true, 'id': stopId},
    );
  }

  static int _transportClassForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.train:
        return 1;
      case TransportMode.metro:
        return 2;
      case TransportMode.lightrail:
        return 4;
      case TransportMode.bus:
        return 5;
      case TransportMode.ferry:
        return 9;
    }
  }
}
