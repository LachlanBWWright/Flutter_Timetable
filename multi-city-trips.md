# Multi-region public transport implementation plan

## Objective

Extend Flutter Timetable beyond Transport for NSW while preserving the existing
NSW experience and avoiding provider-specific logic in widgets.

The target rollout is:

1. Extract the existing TfNSW implementation behind stable domain interfaces.
2. Add Melbourne/Victoria timetable and realtime support.
3. Add South East Queensland static and realtime support.
4. Add Queensland journey planning only after a routing backend is available.

This plan is based on the current working tree on
`copilot/move-floating-action-buttons`, where the Drift schema version is `8`.

## Current implementation

The application already has more infrastructure than an initial provider
refactor needs to create:

- Drift tables for journeys, stops, routes, stop-line memberships, static cache
  status, and trip-planner responses.
- Static GTFS parsing and endpoint-specific caching.
- GTFS-Realtime vehicle and trip-update decoding.
- A persisted trip-planner cache with stale-while-revalidate behavior.
- Direct and manual multi-leg saved trips.
- Service entrypoints under `lib/services/` whose implementations live under
  `lib/wrappers/`.
- Unit, widget, parsing, migration, and integration tests.

The primary limitation is not missing layers. It is that identifiers, cache
keys, credentials, endpoints, return models, and transport modes still assume
TfNSW.

The following current structures require provider namespacing:

| Structure | Current identity | Required identity |
|---|---|---|
| Stops | `stopId + endpoint` | `sourceId + stopId` |
| Routes | `endpoint + routeId` | `sourceId + routeId` |
| Stop-line membership | `endpoint + stopId + lineId` | `sourceId + stopId + lineId` |
| Static cache status | `endpoint` | `sourceId` |
| Trip-planner cache | `originId + destinationId` | Provider and complete request fingerprint |
| Saved trip legs | Stop IDs and optional endpoint | Region, provider/source, stop and route references |
| Realtime memory cache | Mode-based string | Provider/source, feed kind, and mode |
| Station memory cache | `TransportMode` | Region/source and mode |

## Scope

### NSW

Preserve existing functionality:

- stop loading and search
- origin-destination journey planning
- static GTFS data
- vehicle positions
- trip updates
- direct and manual multi-leg saved trips

The first delivery phase is complete only when the existing NSW behavior runs
through the new abstractions without a user-visible regression.

### Victoria

The initial Victoria product supports:

- static GTFS import and stop search
- PTV stop, route, departure, and disruption data
- official Victorian GTFS-Realtime feeds
- saved trips where the available data can render them reliably

PTV Timetable API v3 is not equivalent to an origin-destination journey
planner. The Victoria MVP must not promise TfNSW-style itinerary planning
unless a separate routing implementation is selected.

### South East Queensland

The initial Queensland product supports:

- TransLink static GTFS import and local stop search
- vehicle positions
- trip updates
- service alerts
- departures derived from static and realtime data where practical

Origin-destination journey planning is out of scope for the first Queensland
release. It requires a routing backend such as OpenTripPlanner, built from
versioned GTFS and OpenStreetMap inputs. The UI must explicitly hide or explain
unavailable planning capabilities.

## Identity model

Do not use city names as provider identifiers. They are product labels, not
stable data namespaces.

```dart
enum TransitRegion {
  newSouthWales,
  victoria,
  southEastQueensland,
}

enum TransitProvider {
  tfnsw,
  ptv,
  translink,
  openTripPlanner,
}

/// Stable namespace for one imported dataset or realtime feed family.
///
/// Examples:
/// - tfnsw:sydneytrains
/// - tfnsw:buses
/// - ptv:metro-train
/// - translink:seq
extension type const TransitSourceId(String value) {}
```

Every persisted or cached provider-owned identifier must include a
`TransitSourceId`. `TransitRegion` is used for product selection and display.
`TransitProvider` identifies the integration and authentication behavior.
`TransitSourceId` prevents collisions between feeds.

## Architecture

Use small capability-specific interfaces instead of one provider interface
with unsupported methods and nullable results.

```dart
abstract interface class StopRepository {
  Future<List<TransitStop>> searchStops(StopSearchRequest request);
  Future<TransitStop?> getStop(TransitStopRef stop);
}

abstract interface class JourneyPlanner {
  Future<JourneyPlan> planJourney(JourneyPlanRequest request);
}

abstract interface class StaticTransitRepository {
  Stream<StaticImportProgress> refreshStaticData(StaticImportRequest request);
}

abstract interface class DepartureRepository {
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request);
}

abstract interface class RealtimeFeedProvider {
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
```

A region configuration composes the capabilities it supports:

```dart
class TransitRegionServices {
  const TransitRegionServices({
    required this.region,
    required this.stops,
    required this.staticData,
    this.journeyPlanner,
    this.departures,
    this.realtime,
  });

  final TransitRegion region;
  final StopRepository stops;
  final StaticTransitRepository staticData;
  final JourneyPlanner? journeyPlanner;
  final DepartureRepository? departures;
  final RealtimeFeedProvider? realtime;
}
```

UI code obtains services from a registry/facade. It may inspect capability
availability, but it must not branch on provider names or import provider DTOs.

## Domain model

Provider payloads must be mapped into normalized domain objects before reaching
widgets, saved-trip rendering, or shared caches.

Required domain types:

- `TransitStop` and `TransitStopRef`
- `TransitRoute` and `TransitRouteRef`
- `JourneyPlan`, `TransitJourney`, and `TransitLeg`
- `TransitDeparture`
- `TransitVehicle`
- `TransitTripUpdate`
- `TransitAlert`
- `RealtimeSnapshot<T>`
- `TransitServiceDate`
- `TransitAccessibility`
- `TransitFailure`

All references must carry their source namespace:

```dart
class TransitStopRef {
  const TransitStopRef({
    required this.region,
    required this.provider,
    required this.sourceId,
    required this.stopId,
  });

  final TransitRegion region;
  final TransitProvider provider;
  final TransitSourceId sourceId;
  final String stopId;
}
```

Domain objects may retain a bounded `providerMetadata` map or raw reference for
debugging, but screens must not depend on its shape. Large raw API responses
belong in diagnostic or cache storage rather than every domain object.

Time values must carry enough context to handle service-day boundaries and
daylight-saving changes. Avoid treating provider-local timestamps as UTC
without an explicit conversion.

## Failure model

Empty data is not an error substitute. Shared services must preserve these
states:

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

Realtime and departure results should include:

- retrieval time
- provider/feed timestamp where available
- whether the result came from cache
- whether it is stale
- warnings from partial feed failures

One unavailable feed must not discard successful feeds from the same region.

## Persistence and migration

The migration starts from schema version `8`. It must update all provider-owned
tables, not only stops and journeys.

### Proposed schema changes

#### Stops

- Add `region`, `provider`, and `source_id`.
- Retain provider-native `stop_id`.
- Replace the primary key with `(source_id, stop_id)`.
- Keep `endpoint` temporarily as a deprecated migration alias if needed.
- Add indexes for `(region, stop_name)` and geographic lookup.

#### Routes

- Add `region`, `provider`, and `source_id`.
- Replace the primary key with `(source_id, route_id)`.
- Normalize route mode separately from provider-native route type.

#### Stop-line memberships

- Add `source_id`.
- Replace the primary key with `(source_id, stop_id, line_id)`.
- Add foreign-key relationships where Drift/web compatibility permits.

#### Static cache statuses

- Replace endpoint-only identity with `source_id`.
- Store feed version/ETag/Last-Modified where available.
- Store import schema version, timestamps, row counts, and the latest error.

#### Trip-planner cache

- Add `provider`.
- Replace origin/destination primary key with a `request_fingerprint`.
- Store the normalized request JSON or its relevant fields for diagnostics.
- Store response format/schema version so old provider payloads can be
  invalidated safely.

#### Journeys and manual legs

- Add region/provider fields to journeys.
- Add source-qualified stop and route references to manual leg JSON.
- Version the manual-trip JSON format.
- Continue decoding the existing unversioned format as NSW during migration.

### Migration procedure

Changing composite primary keys requires replacement tables:

1. Create new versioned tables with the target keys and constraints.
2. Copy existing rows while assigning the correct TfNSW region/provider/source.
3. Migrate saved manual-leg JSON to the versioned structure.
4. Convert current trip-planner cache rows to TfNSW request fingerprints.
5. Validate copied row counts and required fields.
6. Drop old tables and rename replacements in one transaction where supported.
7. Recreate indexes.
8. Mark provider caches for rebuild if a row cannot be migrated safely.

Do not silently swallow migration exceptions. A failed migration must be
observable and must not leave a partially upgraded schema.

Migration tests must cover:

- a real version-8 schema upgraded to the target version
- existing NSW stops, routes, memberships, cache statuses, and journeys
- direct and manual multi-leg journeys
- duplicate provider-native IDs across two sources
- malformed legacy manual-leg JSON
- interrupted/failed migration recovery
- native SQLite and the supported web Drift backend

## Cache design

### Journey plans

The request fingerprint must include every input that can change the result:

```text
provider
region
origin source and stop ID
destination source and stop ID
departure or arrival timestamp bucket
depart-after versus arrive-by
enabled modes
accessibility preferences
walking limits and other routing preferences
planner API/schema version
```

The normalized input should be serialized deterministically and hashed.
Origin/destination alone is not a valid cache key.

Each planner defines:

- fresh TTL
- maximum renderable stale age
- retry/backoff policy
- response schema version
- whether stale data is safe to display

### Static data

Static cache identity is `source_id`. Imports should support atomic replacement
or generation IDs so readers never observe half an imported feed.

Refreshing a source invalidates:

- station memory entries for that source
- route and membership lookup caches
- derived departures for that source
- planner responses when the planner depends on that static dataset

### Realtime data

Realtime cache identity includes provider, source, feed kind, and mode. Cache
entries store provider timestamps and local retrieval timestamps. Rate limits
and refresh intervals are configured per feed instead of globally.

Persisting the last good realtime snapshot is optional per feed. If enabled,
the UI must show its age and stale status.

## Authentication and network boundary

Long-lived transport credentials must not be included in Flutter Web assets.
This is a release prerequisite, not optional hardening.

### Required proxy

Before enabling credential-backed providers on web, implement a small transport
gateway that:

- stores TfNSW and PTV credentials server-side
- signs PTV requests
- allowlists upstream paths and query parameters
- applies per-client and global rate limits
- enforces request timeouts and bounded retries
- caches suitable upstream responses
- emits structured operational metrics without logging secrets
- restricts CORS to deployed application origins
- returns a stable error envelope

Proposed client-facing routes:

```text
GET /v1/tfnsw/stops/search
GET /v1/tfnsw/journeys
GET /v1/tfnsw/realtime/{feed}
GET /v1/ptv/stops/search
GET /v1/ptv/departures
GET /v1/ptv/disruptions
GET /v1/victoria/realtime/{feed}
```

The gateway contract should be documented with OpenAPI. Flutter clients should
depend on that contract rather than recreate PTV signing.

Decide explicitly whether native clients also use the gateway. Using one path
reduces behavioral differences and credential exposure; direct native access
can reduce operating cost but does not make embedded credentials secret.

TransLink feeds that require no credentials may be fetched directly, subject
to provider terms, CORS support, rate limits, and reliability requirements.

### Transitional configuration

`API_KEY` may remain as a deprecated alias for `TFNSW_API_KEY` during the NSW
adapter extraction. Do not add PTV secrets to Flutter `.env` assets.

Runtime configuration should contain public gateway settings and feature flags:

```dotenv
TRANSIT_GATEWAY_BASE_URL=
DEFAULT_REGION=newSouthWales
ENABLE_VICTORIA=false
ENABLE_SOUTH_EAST_QUEENSLAND=false
ENABLE_QUEENSLAND_PLANNER=false
QUEENSLAND_PLANNER_BASE_URL=
```

## Provider implementations

### TfNSW

Move current behavior behind:

- `TfnswStopRepository`
- `TfnswJourneyPlanner`
- `TfnswStaticTransitRepository`
- `TfnswRealtimeProvider`

Initially preserve the current parsing and feed behavior. Normalize results at
the adapter boundary and replace broad exception swallowing with typed
failures. This extraction is the compatibility baseline for later providers.

### PTV and Victorian feeds

Separate timetable and GTFS-Realtime authentication because they have different
request mechanisms.

Implement:

- `PtvStopRepository`
- `PtvDepartureRepository`
- `PtvDisruptionRepository`, or map disruptions through a shared alert service
- `VictoriaStaticTransitRepository`
- `VictoriaRealtimeProvider`

Signing belongs in the gateway. If direct signing remains available for local
development, isolate and test canonical query ordering, encoding, `devid`
placement, and uppercase HMAC output.

### TransLink

Implement:

- `TranslinkStopRepository` backed by imported GTFS
- `TranslinkDepartureRepository` backed by static schedule plus trip updates
- `TranslinkStaticTransitRepository`
- `TranslinkRealtimeProvider`

Do not implement `JourneyPlanner` until a routing backend is deployed. A future
`OtpJourneyPlanner` can be composed into the Queensland region without changing
the TransLink feed adapter.

## UI and product behavior

Add a persisted region selector. Every screen must operate in an explicit
region context; do not infer the region from a stop ID.

Capability-aware behavior:

- Hide or disable journey planning where no planner exists.
- Explain unavailable features in user-facing language.
- Show cached/stale timestamps for degraded realtime data.
- Keep saved journeys associated with their region.
- Prevent cross-region origin/destination combinations unless a future
  inter-region planner explicitly supports them.
- Display provider attribution where required.

Transport mode remains a normalized user-facing category, not a provider or
feed identity. Provider-native route types are mapped at the adapter boundary.

## Delivery phases and acceptance criteria

### Phase 0: security and contracts

Deliver:

- gateway architecture decision
- gateway OpenAPI contract
- identity and normalized domain model
- typed failure model
- persistence migration design

Acceptance:

- no PTV secret is required by Flutter Web
- cache key and source identity rules are documented and testable
- every proposed provider capability maps to a small interface

### Phase 1: NSW extraction

Deliver:

- TfNSW adapters
- region/service registry
- schema migration from version 8
- namespaced caches
- existing screens wired through normalized domain services

Acceptance:

- current NSW unit and widget tests pass
- direct and manual saved trips survive migration
- duplicate IDs in different fixture sources do not collide
- no shared widget imports TfNSW DTOs
- planner and realtime failures remain distinguishable

### Phase 2: web gateway

Deliver:

- deployed gateway
- server-side TfNSW/PTV credentials
- request allowlisting, rate limits, metrics, and stable error responses
- Flutter gateway client

Acceptance:

- built web assets contain no transport API secret
- unsupported upstream paths cannot be proxied
- provider timeouts and rate limits map to typed client failures

### Phase 3: Victoria MVP

Deliver:

- Victorian static GTFS source definitions
- PTV stops, departures, and disruptions
- Victorian realtime feeds
- region selection and Victoria-specific attribution

Acceptance:

- stop search, departures, disruptions, and supported realtime views work from
  deterministic fixtures and a controlled smoke test
- the UI does not advertise origin-destination planning without a planner
- rate limiting and partial feed failures degrade by feed

### Phase 4: South East Queensland MVP

Deliver:

- TransLink GTFS import
- local stop search and departures
- vehicle, trip-update, and alert feeds
- planner-unavailable UI state

Acceptance:

- static and realtime fixtures pass end-to-end adapter tests
- unavailable journey planning is clear and does not appear as an empty result
- train, bus, ferry, and light-rail feed mappings are tested

### Phase 5: optional Queensland planner

Deliver:

- versioned GTFS/OSM build pipeline
- hosted OpenTripPlanner or selected alternative
- health checks and data-version reporting
- `OtpJourneyPlanner` adapter

Acceptance:

- routing dataset age is visible operationally
- planner requests use the same normalized journey model
- planner failure does not remove static or realtime Queensland functionality

## Testing

Use deterministic fixtures as the default:

```text
test/fixtures/tfnsw/
test/fixtures/ptv/
test/fixtures/victoria_gtfs_rt/
test/fixtures/translink/
test/fixtures/otp/
```

Required coverage:

- provider DTO-to-domain mapping
- PTV signing/gateway request canonicalization
- source-qualified identity and cache fingerprints
- service dates, timezones, and daylight-saving transitions
- unsupported capabilities
- unauthorized, rate-limited, timeout, malformed, and partial responses
- stale cache display behavior
- static import atomicity and invalidation
- version-8 migration
- region-aware saved trips and manual-leg compatibility
- capability-aware widget behavior

Credential-backed live tests should be opt-in or scheduled smoke tests. They
must not be required for normal pull-request CI.

## CI and delivery

The existing test workflow targets `master` and `dev`, while build workflows
target `main` and `dev`. Align all workflows with the actual protected
branches.

Required changes:

- remove `continue-on-error: true`
- make formatting, analysis, unit tests, and migration tests blocking
- verify generated Drift/OpenAPI output is committed and current
- separate deterministic tests from credential-backed smoke tests
- scan web artifacts for forbidden secret values
- prevent deployment when gateway configuration or migrations are incompatible

## Operations and compliance

Before enabling a provider:

- confirm feed/API licensing and attribution requirements
- document permitted caching and retention
- configure provider-specific quotas and refresh intervals
- record source data age and import success metrics
- add gateway and planner health checks
- redact credentials, precise user locations, and journey queries from logs
- define cache clearing and source rebuild procedures

Operational fallback is per source and capability. A TfNSW planner outage must
not disable saved manual journeys; one Victorian realtime feed must not blank
other modes; an OTP outage must not disable Queensland stops and departures.

## Initial implementation file map

```text
lib/transit/
  domain/
  errors/
  interfaces/
  registry/
  providers/
    tfnsw/
    ptv/
    victoria/
    translink/
    otp/

lib/schema/
  database.dart
  tables/

test/fixtures/
  tfnsw/
  ptv/
  victoria_gtfs_rt/
  translink/
  otp/
```

Existing service exports can remain as compatibility facades during Phase 1.
Provider implementations belong under `lib/transit/providers/`, not in widgets
or mode switch statements.

## Immediate next steps

1. Add identity, domain, failure, and capability interfaces without changing UI
   behavior.
2. Write version-8 migration tests before changing the schema.
3. Extract TfNSW adapters and qualify all cache keys.
4. Specify and deploy the credential gateway.
5. Add Victoria only after the NSW compatibility baseline and gateway pass.
6. Add South East Queensland feeds independently of any planner decision.
