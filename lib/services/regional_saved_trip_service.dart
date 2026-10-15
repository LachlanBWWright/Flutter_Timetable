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

typedef RegionalPlanLoader =
    Future<JourneyPlan> Function(JourneyPlanRequest request);

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
        origin.region == destination.region &&
        origin.region != TransitRegion.nsw;
  }

  static Future<List<api.TripJourney>> planSavedTrip(
    Journey trip, {
    RegionalPlanLoader? planLoader,
    DateTime? when,
  }) async {
    final origin = TransitStopRef.tryParse(trip.originId);
    final destination = TransitStopRef.tryParse(trip.destinationId);
    if (origin == null || destination == null) {
      throw const UnsupportedCapability(
        message: 'Saved regional stops are missing provider references.',
      );
    }
    if (origin.region != destination.region) {
      throw const UnsupportedCapability(
        message: 'Cross-region journey planning is not supported.',
      );
    }
    if (origin.region != TransitRegion.nsw &&
        origin.provider != TransitProviderId.ptv &&
        origin.sourceId != destination.sourceId) {
      throw const UnsupportedCapability(
        message:
            'Journey planning between separate regional feed areas is not supported.',
      );
    }
    if (!RegionFeatureFlags.isEnabled(origin.region)) {
      throw UnsupportedCapability(
        message:
            'Saved journeys for ${origin.region.label} are unavailable in this build.',
      );
    }

    final expectedProvider = _providerForRegion(origin.region);
    if (origin.provider != expectedProvider ||
        destination.provider != expectedProvider) {
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
      enabledModes: trip.savedMode == null ? null : [trip.savedMode!],
    );
    final plan = await (planLoader ?? planner!.planJourney)(request);
    _validatePlan(
      plan,
      region: origin.region,
      provider: expectedProvider,
      sourceId: origin.sourceId,
    );
    return plan.journeys
        .map(
          (journey) => _toTripJourney(
            journey,
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
  }) {
    for (final journey in plan.journeys) {
      for (final leg in journey.legs) {
        for (final stop in [leg.origin, leg.destination]) {
          final ref = stop.ref;
          if (ref.region != region ||
              ref.provider != provider ||
              ref.sourceId != sourceId) {
            throw const InvalidProviderResponse(
              message:
                  'The regional planner returned stops from a different feed.',
            );
          }
        }
        final route = leg.route?.ref;
        if (route != null &&
            (route.region != region ||
                route.provider != provider ||
                route.sourceId != sourceId)) {
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
      'transitRegion': region.name,
      'transitProvider': provider.name,
      'transitSourceId': sourceId.value,
    };
    final route = leg.route;
    final mode = leg.mode ?? route?.mode;
    final transportation = route == null && mode == null
        ? null
        : api.Transportation(
            id: route?.ref.storageKey,
            name: route?.name ?? mode?.displayName,
            disassembledName:
                route?.shortName ?? route?.name ?? mode?.displayName,
            number: route?.shortName,
            destination: leg.label == null
                ? null
                : api.TransportationDestination(name: leg.label),
            product: mode == null
                ? null
                : api.Product(
                    classField: _transportClass(mode),
                    name: mode.displayName,
                  ),
            rawJson: {...metadata, 'routeId': route?.ref.routeId},
          );
    final origin = _toApiStop(
      leg.origin,
      metadata,
      departureTime: leg.departureTime,
    );
    final destination = _toApiStop(
      leg.destination,
      metadata,
      arrivalTime: leg.arrivalTime,
    );
    return api.Leg(
      origin: origin,
      destination: destination,
      isRealtimeControlled: false,
      stopSequence: [origin, destination],
      transportation: transportation,
      rawJson: metadata,
    );
  }

  static api.Stop _toApiStop(
    TransitStop stop,
    Map<String, dynamic> metadata, {
    DateTime? departureTime,
    DateTime? arrivalTime,
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
      rawJson: {
        ...metadata,
        'stopId': stop.ref.stopId,
        'stopStorageKey': stop.ref.storageKey,
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
