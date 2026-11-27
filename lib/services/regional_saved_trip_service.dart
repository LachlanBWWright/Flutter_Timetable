import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/app_transit_context.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';

typedef RegionalPlanLoader = Future<JourneyPlan> Function(
  JourneyPlanRequest request,
);

/// Plans and adapts a saved regional stop pair to the existing trip UI model.
class RegionalSavedTripService {
  RegionalSavedTripService._();

  static bool hasStructuredStops(Journey trip) =>
      trip.originId.contains('|') || trip.destinationId.contains('|');

  static bool isRegionalTrip(Journey trip) {
    final origin = TransitStopRef.tryParse(trip.originId);
    final destination = TransitStopRef.tryParse(trip.destinationId);
    return origin != null &&
        destination != null &&
        (origin.region != TransitRegion.nsw ||
            destination.region != TransitRegion.nsw);
  }

  static Future<List<api.TripJourney>> planSavedTrip(
    Journey trip, {
    RegionalPlanLoader? planLoader,
    DateTime? when,
    bool arrivalBased = false,
    Duration? walkingLimit,
    TransitAccessibility accessibility = TransitAccessibility.none,
    TransitCancellation? cancellation,
  }) async {
    final origin = TransitStopRef.tryParse(trip.originId);
    final destination = TransitStopRef.tryParse(trip.destinationId);
    if (origin == null || destination == null) {
      throw const UnsupportedCapability(
        message: 'Saved regional stops are missing provider references.',
      );
    }
    if (!RegionFeatureFlags.isEnabled(origin.region) ||
        !RegionFeatureFlags.isEnabled(destination.region)) {
      throw UnsupportedCapability(
        message:
            'Saved journeys for ${origin.region.label} are unavailable in this build.',
      );
    }

    final expectedProvider = _providerForRegion(origin.region);
    if (origin.provider != expectedProvider ||
        destination.provider != _providerForRegion(destination.region)) {
      throw UnsupportedCapability(
        message:
            'Saved stop providers do not match the ${origin.region.label} adapter.',
      );
    }
    final context = AppTransitContext.instance;
    final services = planLoader == null
        ? _servicesFor(context, origin.region)
        : null;
    final planner = services?.journeyPlanner;
    if (planLoader == null && planner == null) {
      throw UnsupportedCapability(
        message: 'Journey planning is unavailable in ${origin.region.label}.',
      );
    }
    if (services != null && services.provider != expectedProvider) {
      throw UnsupportedCapability(
        message: 'The ${origin.region.label} provider is unavailable.',
      );
    }
    final request = JourneyPlanRequest(
      origin: origin,
      destination: destination,
      when: when ?? DateTime.now(),
      arrivalBased: arrivalBased,
      walkingLimit: walkingLimit,
      accessibility: accessibility,
      cancellation: cancellation,
      enabledModes: trip.savedMode == null ? null : [trip.savedMode!],
    );
    final plan = await (planLoader ?? context.planJourney)(request);
    _validatePlan(
      plan,
      region: origin.region,
      provider: expectedProvider,
      sourceId: origin.sourceId,
      destination: destination,
    );
    return plan.journeys
        .map(
          (journey) => _toTripJourney(
            journey,
            timetable: plan.timetable,
            realtimeStatus: plan.rawPayload is Map
                ? (plan.rawPayload as Map)['realtimeStatus'] as String?
                : null,
            region: origin.region,
            provider: expectedProvider,
            sourceId: origin.sourceId,
          ),
        )
        .toList(growable: false);
  }

  static void _validatePlan(
    JourneyPlan plan, {
    required TransitRegion region,
    required TransitProviderId provider,
    required TransitSourceId sourceId,
    required TransitStopRef destination,
  }) {
    bool allowed(TransitRegion r, TransitProviderId p, TransitSourceId s) =>
        (r == region && p == provider && s == sourceId) ||
        (r == destination.region &&
            p == destination.provider &&
            s == destination.sourceId) ||
        (region == TransitRegion.nsw &&
            destination.region == TransitRegion.nsw &&
            provider == TransitProviderId.tfnsw &&
            r == TransitRegion.nsw &&
            p == TransitProviderId.tfnsw &&
            s.value == 'journey-planner');
    for (final journey in plan.journeys) {
      for (final leg in journey.legs) {
        for (final stop in [leg.origin, leg.destination]) {
          final ref = stop.ref;
          if (!allowed(ref.region, ref.provider, ref.sourceId)) {
            throw const InvalidProviderResponse(
              message:
                  'The regional planner returned stops from a different feed.',
            );
          }
        }
        final route = leg.route?.ref;
        if (route != null &&
            !allowed(route.region, route.provider, route.sourceId)) {
          throw const InvalidProviderResponse(
            message:
                'The regional planner returned a route from a different feed.',
          );
        }
      }
    }
  }

  static TransitRegionServices _servicesFor(
    AppTransitContext context,
    TransitRegion region,
  ) {
    try {
      return context.servicesFor(region);
    } on StateError {
      throw UnsupportedCapability(
        message: 'Journey planning is unavailable in ${region.label}.',
      );
    }
  }

  static TransitProviderId _providerForRegion(TransitRegion region) =>
      switch (region) {
        TransitRegion.nsw => TransitProviderId.tfnsw,
        TransitRegion.victoria => TransitProviderId.ptv,
        TransitRegion.queensland => TransitProviderId.translink,
        TransitRegion.southAustralia => TransitProviderId.adelaideMetro,
        TransitRegion.tasmania => TransitProviderId.tasmaniaPublicTransport,
        TransitRegion.northernTerritory => TransitProviderId.ntBus,
        TransitRegion.westernAustralia => TransitProviderId.transperth,
      };

  static api.TripJourney _toTripJourney(
    TransitJourney journey, {
    TimetableProvenance? timetable,
    String? realtimeStatus,
    required TransitRegion region,
    required TransitProviderId provider,
    required TransitSourceId sourceId,
  }) {
    const provenance = 'regional_journey_planner';
    final convertedLegs = journey.legs
        .map(
          (leg) => _toApiLeg(
            leg,
            region: region,
            provider: provider,
            sourceId: sourceId,
            provenance: provenance,
          ),
        )
        .toList(growable: false);
    return api.TripJourney(
      isAdditional: false,
      legs: convertedLegs,
      rawJson: {
        'provenance': provenance,
        'realtimeStatus': ?realtimeStatus,
        'isApproximate': journey.legs.any((leg) => leg.isApproximate),
        if (timetable != null) 'timetable': timetable.toJson(),
        'transitRegion': region.name,
        'transitProvider': provider.name,
        'transitSourceId': sourceId.value,
        'legs': convertedLegs.map((leg) => leg.rawJson).toList(),
      },
    );
  }

  static api.Leg _toApiLeg(
    TransitLeg leg, {
    required TransitRegion region,
    required TransitProviderId provider,
    required TransitSourceId sourceId,
    required String provenance,
  }) {
    final metadata = <String, dynamic>{
      'provenance': provenance,
      'transitRegion': leg.origin.ref.region.name,
      'transitProvider': leg.origin.ref.provider.name,
      'transitSourceId': leg.origin.ref.sourceId.value,
    };
    final route = leg.route;
    final mode = leg.mode ?? route?.mode;
    final name = leg.isWalking ? 'Walk' : route?.name ?? mode?.displayName;
    final shortName = leg.isWalking ? 'Walk' : route?.shortName ?? name;
    final productClass = leg.isWalking
        ? 100
        : mode == null
        ? null
        : _transportClass(mode);
    final productName = leg.isWalking ? 'Walk' : mode?.displayName;
    final transportation = route == null && mode == null && !leg.isWalking
        ? null
        : api.Transportation(
            id: route?.ref.storageKey,
            name: name,
            disassembledName: shortName,
            number: route?.shortName,
            destination: leg.label == null
                ? null
                : api.TransportationDestination(name: leg.label),
            product: productClass == null
                ? null
                : api.Product(classField: productClass, name: productName),
            rawJson: {
              ...metadata,
              'routeId': route?.ref.routeId,
              'id': route?.ref.storageKey,
              'name': name,
              'disassembledName': shortName,
              'number': route?.shortName,
              if (leg.label != null) 'destination': {'name': leg.label},
              if (productClass != null)
                'product': {'class': productClass, 'name': productName},
            },
          );
    final origin = _toApiStop(
      leg.origin,
      metadata,
      departureTime: leg.plannedDepartureTime ?? leg.departureTime,
      estimatedDepartureTime: leg.isRealtime ? leg.departureTime : null,
    );
    final destination = _toApiStop(
      leg.destination,
      metadata,
      arrivalTime: leg.plannedArrivalTime ?? leg.arrivalTime,
      estimatedArrivalTime: leg.isRealtime ? leg.arrivalTime : null,
    );
    return api.Leg(
      origin: origin,
      destination: destination,
      isRealtimeControlled: leg.isRealtime,
      stopSequence: [origin, destination],
      transportation: transportation,
      duration: leg.departureTime == null || leg.arrivalTime == null
          ? null
          : leg.arrivalTime!.difference(leg.departureTime!).inSeconds,
      rawJson: {
        ...metadata,
        'origin': origin.rawJson,
        'destination': destination.rawJson,
        'stopSequence': [origin.rawJson, destination.rawJson],
        'transportation': transportation?.rawJson,
        'isRealtimeControlled': leg.isRealtime,
        'isApproximate': leg.isApproximate,
        if (leg.departureTime != null && leg.arrivalTime != null)
          'duration': leg.arrivalTime!.difference(leg.departureTime!).inSeconds,
      },
    );
  }

  static api.Stop _toApiStop(
    TransitStop stop,
    Map<String, dynamic> metadata, {
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? estimatedDepartureTime,
    DateTime? estimatedArrivalTime,
  }) {
    final coordinates = stop.latitude != null && stop.longitude != null
        ? [stop.latitude!, stop.longitude!]
        : null;
    return api.Stop(
      id: stop.ref.storageKey,
      name: stop.name,
      disassembledName: stop.name,
      type: 'stop',
      coord: coordinates,
      departureTimePlanned: departureTime?.toIso8601String(),
      arrivalTimePlanned: arrivalTime?.toIso8601String(),
      arrivalTimeEstimated: estimatedArrivalTime?.toIso8601String(),
      departureTimeEstimated: estimatedDepartureTime?.toIso8601String(),
      rawJson: {
        ...metadata,
        'id': stop.ref.storageKey,
        'name': stop.name,
        'disassembledName': stop.name,
        'type': 'stop',
        'coord': coordinates,
        'departureTimePlanned': departureTime?.toIso8601String(),
        'arrivalTimePlanned': arrivalTime?.toIso8601String(),
        'arrivalTimeEstimated': estimatedArrivalTime?.toIso8601String(),
        'departureTimeEstimated': estimatedDepartureTime?.toIso8601String(),
        'stopId': stop.ref.stopId,
        'stopStorageKey': stop.ref.storageKey,
        'transitRegion': stop.ref.region.name,
        'transitProvider': stop.ref.provider.name,
        'transitSourceId': stop.ref.sourceId.value,
      },
    );
  }

  static int _transportClass(TransportMode mode) => switch (mode) {
    TransportMode.train => 1,
    TransportMode.metro => 2,
    TransportMode.lightrail => 4,
    TransportMode.bus => 5,
    TransportMode.ferry => 9,
  };
}
