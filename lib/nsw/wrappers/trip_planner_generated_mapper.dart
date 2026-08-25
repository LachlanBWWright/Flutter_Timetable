import '../swagger_generated/trip_planner.swagger.dart' as generated;
import 'transport_api_service_impl.dart';

/// Converts generated TfNSW models into the app's existing display models.
///
/// JSON decoding belongs exclusively to the generated client. These functions
/// are deliberately object-to-object adapters so the UI does not need to be
/// rewritten at the same time as the transport client.
GetTripsResponse getTripsResponseFromGenerated(
  generated.TripRequestResponse response, {
  Map<String, dynamic>? rawJson,
}) {
  return GetTripsResponse(
    tripJourneys: (response.journeys ?? const [])
        .map(tripJourneyFromGenerated)
        .toList(growable: false),
    systemMessages: SystemMessages(
      responseMessages: (response.systemMessages ?? const [])
          .map(responseMessageFromGenerated)
          .toList(growable: false),
    ),
    version: response.version ?? '',
    rawJson: rawJson ?? response.toJson(),
  );
}

TripJourney tripJourneyFromGenerated(
  generated.TripRequestResponseJourney value,
) {
  return TripJourney(
    isAdditional: value.isAdditional,
    legs: (value.legs ?? const [])
        .map(legFromGenerated)
        .toList(growable: false),
    rating: value.rating,
    rawJson: value.toJson(),
  );
}

Leg legFromGenerated(generated.TripRequestResponseJourneyLeg value) {
  return Leg(
    coords: value.coords
        ?.map((row) => row.whereType<double>().toList(growable: false))
        .toList(growable: false),
    origin: stopFromGenerated(value.origin) ?? _unknownStopForMapper(),
    destination:
        stopFromGenerated(value.destination) ?? _unknownStopForMapper(),
    distance: value.distance,
    duration: value.duration,
    isRealtimeControlled: value.isRealtimeControlled,
    stopSequence: value.stopSequence
        ?.map(stopFromGenerated)
        .whereType<Stop>()
        .toList(growable: false),
    properties: value.properties == null
        ? null
        : LegProperties(
            differentFares: value.properties!.differentfares,
            planLowFloorVehicle: value.properties!.planLowFloorVehicle,
            planWheelChairAccess: value.properties!.planWheelChairAccess,
            lineType: value.properties!.lineType,
            vehicleAccess: value.properties!.vehicleAccess
                ?.map((item) => item.toString())
                .toList(growable: false),
          ),
    transportation: transportationFromGenerated(value.transportation),
    rawJson: value.toJson(),
  );
}

Stop? stopFromGenerated(generated.TripRequestResponseJourneyLegStop? value) {
  if (value == null) return null;
  return Stop(
    arrivalTimeEstimated: value.arrivalTimeEstimated,
    arrivalTimePlanned: value.arrivalTimePlanned,
    coord: value.coord,
    departureTimeEstimated: value.departureTimeEstimated,
    departureTimePlanned: value.departureTimePlanned,
    disassembledName: value.disassembledName,
    id: value.id ?? '',
    name: value.name ?? '',
    parent: parentFromGenerated(value.parent),
    type: value.type?.value ?? '',
    rawJson: value.toJson(),
  );
}

Parent? parentFromGenerated(generated.ParentLocation? value) {
  if (value == null) return null;
  return Parent(
    disassembledName: value.disassembledName,
    id: value.id ?? '',
    name: value.name ?? '',
    parent: value.parent,
    type: value.type?.value,
  );
}

Transportation? transportationFromGenerated(
  generated.TripTransportation? value,
) {
  if (value == null) return null;
  return Transportation(
    description: value.description,
    destination: value.destination == null
        ? null
        : TransportationDestination(
            id: value.destination!.id,
            name: value.destination!.name,
          ),
    disassembledName: value.disassembledName,
    iconId: value.iconId,
    id: value.id,
    name: value.name,
    number: value.number,
    operator: value.$operator == null
        ? null
        : Operator(id: value.$operator!.id, name: value.$operator!.name),
    product: value.product == null
        ? null
        : Product(
            classField: value.product!.$class,
            iconId: value.product!.iconId,
            name: value.product!.name,
          ),
    properties: value.properties == null
        ? null
        : TransportationProperties(
            isTTB: value.properties!.isTTB,
            tripCode: value.properties!.tripCode,
          ),
    rawJson: value.toJson(),
  );
}

ResponseMessage responseMessageFromGenerated(
  generated.TripRequestResponseMessage value,
) {
  return ResponseMessage(
    code: value.code,
    text: value.error,
    module: value.module,
    type: value.type,
  );
}

Stop _unknownStopForMapper() =>
    Stop(id: '', name: 'Unknown', type: '', rawJson: const <String, dynamic>{});
