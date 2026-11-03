# Multi-region app architecture plan

## Goal

Support NSW, Victoria, and Queensland at the same time without scattering
region-specific checks throughout widgets and services.

The app should expose a provider-neutral transit interface. Region-specific
code should live behind adapters for TfNSW, PTV, and TransLink.

## Core approach

Build a `lib/transit/` layer with shared domain models, capability interfaces,
typed failures, and a service registry.

Screens should ask the current region for capabilities such as stop search,
departures, realtime vehicles, alerts, and journey planning. Screens should not
import provider DTOs or branch directly on provider names.

## Transit domain model

Create provider-neutral types:

- `TransitRegion`
- `TransitProviderId`
- `TransitSourceId`
- `TransitStop`
- `TransitStopRef`
- `TransitRoute`
- `TransitRouteRef`
- `TransitDeparture`
- `TransitVehicle`
- `TransitTripUpdate`
- `TransitAlert`
- `TransitJourney`
- `TransitLeg`
- `TransitServiceDate`
- `TransitAccessibility`

Every provider-owned identifier must include a source namespace. For example:

```dart
class TransitStopRef {
  const TransitStopRef({
    required this.region,
    required this.provider,
    required this.sourceId,
    required this.stopId,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final TransitSourceId sourceId;
  final String stopId;
}
```

## Capability interfaces

Use small interfaces instead of one large provider interface:

```dart
abstract interface class StopRepository {
  Future<List<TransitStop>> searchStops(StopSearchRequest request);
  Future<TransitStop?> getStop(TransitStopRef stop);
}

abstract interface class StaticGtfsRepository {
  Stream<StaticImportProgress> refreshStaticData(StaticImportRequest request);
}

abstract interface class RealtimeRepository {
  Future<RealtimeSnapshot<TransitVehicle>> getVehiclePositions(
    RealtimeRequest request,
  );

  Future<RealtimeSnapshot<TransitTripUpdate>> getTripUpdates(
    RealtimeRequest request,
  );

  Future<RealtimeSnapshot<TransitAlert>> getAlerts(
    RealtimeRequest request,
  );
}

abstract interface class DepartureRepository {
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request);
}

abstract interface class JourneyPlanner {
  Future<JourneyPlan> planJourney(JourneyPlanRequest request);
}

abstract interface class DisruptionRepository {
  Future<List<TransitAlert>> getDisruptions(DisruptionRequest request);
}
```

Regions compose the capabilities they support:

```dart
class TransitRegionServices {
  const TransitRegionServices({
    required this.region,
    required this.stops,
    this.staticGtfs,
    this.realtime,
    this.departures,
    this.journeyPlanner,
    this.disruptions,
  });

  final TransitRegion region;
  final StopRepository stops;
  final StaticGtfsRepository? staticGtfs;
  final RealtimeRepository? realtime;
  final DepartureRepository? departures;
  final JourneyPlanner? journeyPlanner;
  final DisruptionRepository? disruptions;
}
```

## Region registry

Add a registry/facade responsible for returning services for the selected
region:

```dart
abstract interface class TransitRegistry {
  TransitRegionServices servicesFor(TransitRegion region);
}
```

The app should keep selected region as persisted app state. Widgets access the
current region services through a single app-level provider/facade instead of
constructing provider classes directly.

## Provider adapters

### NSW

Wrap the existing implementation first:

- `TfnswStopRepository`
- `TfnswJourneyPlanner`
- `TfnswStaticGtfsRepository`
- `TfnswRealtimeRepository`

This is the compatibility baseline. Existing NSW behavior should remain
unchanged while the UI starts depending on the new interfaces.

### Victoria

Use the generated PTV Timetable API client behind adapters:

- `PtvStopRepository`
- `PtvDepartureRepository`
- `PtvDisruptionRepository`
- `VictoriaStaticGtfsRepository`
- `VictoriaRealtimeRepository`

PTV signing must live in one network boundary, preferably a gateway or a
dedicated signed-client wrapper. It must not be repeated in widgets or endpoint
call sites.

Victoria should not expose origin-destination journey planning unless a
separate planner backend is added.

### Queensland

Use the TransLink GTFS and GTFS-Realtime feed catalog behind adapters:

- `TranslinkStaticGtfsRepository`
- `TranslinkStopRepository`
- `TranslinkDepartureRepository`
- `TranslinkRealtimeRepository`

Queensland should not expose a `JourneyPlanner` until OpenTripPlanner or an
equivalent routing backend is available.

## UI behavior

Screens should render based on capability availability:

- Stop search requires `StopRepository`.
- Departures require `DepartureRepository`.
- Realtime map requires `RealtimeRepository`.
- Journey planning requires `JourneyPlanner`.
- Disruptions require `DisruptionRepository` or realtime alerts.

If a capability is unavailable, the screen should hide the action or show a
clear unavailable state. It should not show empty results for unsupported
features.

Cross-region journeys should be blocked unless a future inter-region planner
explicitly supports them.

## Persistence and cache changes

Current persistence is NSW-shaped. Update provider-owned data to use
source-qualified identities:

- stops: `source_id + stop_id`
- routes: `source_id + route_id`
- stop-line memberships: `source_id + stop_id + line_id`
- static cache status: `source_id`
- realtime cache: `provider + source_id + feed_kind`
- saved journeys: `region + provider + source-qualified stop and route refs`
- planner cache: `provider + request_fingerprint`

Do not use origin and destination alone as a planner cache key. The fingerprint
must include provider, region, source IDs, stop IDs, departure or arrival time,
enabled modes, accessibility preferences, walking limits, and planner schema
version.

Migration tests should be written before changing the schema.

## Failure model

Use typed failures across all providers:

```dart
sealed class TransitFailure implements Exception {
  const TransitFailure();
}

class UnsupportedCapability extends TransitFailure {}
class InvalidCredentials extends TransitFailure {}
class RateLimited extends TransitFailure {
  const RateLimited({this.retryAfter});
  final Duration? retryAfter;
}
class ProviderUnavailable extends TransitFailure {}
class InvalidProviderResponse extends TransitFailure {}
class NetworkUnavailable extends TransitFailure {}
class StaleDataUnavailable extends TransitFailure {}
```

Screens should map these failures to consistent user-facing states.

## Testing plan

Add tests in this order:

1. NSW adapter parity tests against the current behavior.
2. Registry and capability availability tests.
3. Source-qualified identity and cache-key tests.
4. Versioned migration tests for saved journeys, stops, routes, memberships,
   static cache statuses, and planner cache.
5. Victoria adapter tests using deterministic PTV fixtures.
6. Queensland static GTFS and GTFS-Realtime adapter tests using fixtures.
7. Widget tests for unsupported journey planning in Victoria and Queensland.
8. Import boundary tests or lints that prevent widgets from importing provider
   internals directly.

Live provider tests should be opt-in smoke tests, not normal pull-request CI.

## Suggested implementation order

1. Create `lib/transit/domain`, `lib/transit/interfaces`,
   `lib/transit/errors`, and `lib/transit/registry`.
2. Wrap NSW behind the new interfaces without changing UI behavior.
3. Add selected-region app state and a persisted region selector.
4. Convert stop search, departures, realtime, and trip screens to use
   capabilities from the registry.
5. Add source-qualified persistence and cache migrations.
6. Add Victoria adapters behind the generated PTV client.
7. Add Queensland adapters behind the TransLink feed catalog.
8. Add unavailable-capability UI states for journey planning.
9. Add provider attribution and licensing display.
10. Add gateway or signed-client boundary for PTV credentials.

## Success criteria

- No shared widget imports `lib/nsw`, `lib/victoria`, or `lib/queensland`
  implementation files directly.
- Region-specific code is contained in provider adapters.
- NSW behavior remains unchanged after the abstraction layer is introduced.
- Victoria and Queensland can be enabled independently.
- Unsupported capabilities are explicit and user-friendly.
- Cache and database identifiers cannot collide across providers or regions.
