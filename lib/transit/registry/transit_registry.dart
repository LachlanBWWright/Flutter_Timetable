import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';

class TransitRegionServices {
  const TransitRegionServices({
    required this.region,
    required this.provider,
    required this.stops,
    required this.attribution,
    this.staticGtfs,
    this.realtime,
    this.departures,
    this.journeyPlanner,
    this.disruptions,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final StopRepository stops;
  final TransitProviderAttribution attribution;
  final StaticGtfsRepository? staticGtfs;
  final RealtimeRepository? realtime;
  final DepartureRepository? departures;
  final JourneyPlanner? journeyPlanner;
  final DisruptionRepository? disruptions;

  bool get supportsJourneyPlanning => journeyPlanner != null;
  bool get supportsRealtime => realtime != null;
  bool get supportsStaticImport => staticGtfs != null;
  bool get supportsDepartures => departures != null;
  bool get supportsDisruptions => disruptions != null;
}

abstract interface class TransitRegistry {
  TransitRegionServices servicesFor(TransitRegion region);
}

class InMemoryTransitRegistry implements TransitRegistry {
  InMemoryTransitRegistry(Iterable<TransitRegionServices> regions)
    : _regions = {for (final region in regions) region.region: region};

  final Map<TransitRegion, TransitRegionServices> _regions;

  @override
  TransitRegionServices servicesFor(TransitRegion region) {
    final services = _regions[region];
    if (services == null) {
      throw StateError('No transit services registered for ${region.name}');
    }
    return services;
  }
}
