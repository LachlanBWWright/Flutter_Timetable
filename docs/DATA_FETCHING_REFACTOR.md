# Data fetching with a shared Firebase cache

Status: shared fetching is implemented for NSW and the other existing providers.
See [backend setup and current coverage](../backend/README.md). Without a configured
Firebase URL, or when the shared lookup fails, the app retains its existing direct
provider path. Other-provider static archives use shared Storage downloads.
Prepared static subsets, server-side departure indexes and further caller-specific
query migrations remain planned.

## Intended behaviour

Resolve every transport query in this order: **loaded data → Firebase cache → full new upstream API request**. Return only the records and fields required by the caller at every step.

Loaded data includes in-memory results and suitable data already persisted in the device's Drift database. Firebase provides shared results across devices. A new upstream request runs on the backend, which filters its response before returning it to the device. When the shared backend can resolve a query, the phone receives its compact result. Without shared configuration, for an unsupported source, or after a shared-backend failure, the existing direct provider request remains available.

The hierarchy selects the first sufficiently fresh, complete and compatible result, rather than simply the first result that exists. Retain stale data as a possible fallback while seeking a better result.

## One fetching module for callers

Put the seam at the existing transit repository interfaces in `lib/transit/interfaces/transit_interfaces.dart`. Screens ask for stops, departures, journeys, vehicles, trip updates or alerts. They should not choose between memory, Drift, Firebase and upstream requests.

Keep domain-specific query methods rather than exposing arbitrary URLs or Firestore collections. Examples of the intended interface are:

- `getDepartures(stop, when, limit)`
- `getVehicles(bounds, mode)` or `getJourneyVehicles(tripIdentities)`
- `getTripUpdates(tripIdentities, relevantStops)`
- `getAlerts(stop, routes, when)`
- `searchStops(query, region, limit)`

Use a shared internal resolver for tier selection, freshness, request deduplication and fallback. Domain adapters own canonical keys, coverage checks and response validation. This keeps cache mechanics out of widgets without forcing every transport query into one untyped interface.

Return typed domain records with metadata: source observation time, backend fetch time, freshness expiry, coverage, failed sources and whether the result is stale. Preserve the existing distinction between a valid empty response and an unavailable source. A partial response must identify its missing coverage.

## Resolution rules

1. Canonicalise the request and check in-memory data, then applicable Drift data. A broader loaded snapshot can answer a narrower query only when its coverage and freshness are known. Return a fresh complete result without contacting Firebase.
2. If local data is missing or stale, ask the backend to resolve the query from Firebase. Keep a permissible stale local result available for immediate display while the refresh proceeds.
3. The backend checks for a fresh cached query result. If absent, it checks whether an existing shared source snapshot can answer the query. A missing derived result does not automatically require a new upstream download.
4. Only when the shared data cannot answer the query does the backend request the necessary upstream source or sources. Decode, validate, index and project the response there.
5. Publish a successful shared snapshot and its derived result, then return the compact result. Store it in device memory and, where useful, Drift. A cache-write failure must not discard a successful upstream result.
6. If all refresh paths fail, return the best allowed stale result with its original timestamps and failure metadata. If no usable fallback exists, report unavailable rather than an empty success.

For an offline device, use loaded data only. A Firebase storage outage can be bypassed by the backend to fetch upstream within the request budget; that fallback still returns a compact response. If the backend itself is unreachable or rejects an unsupported source, use the existing direct provider request and its established local fallback. This deliberately preserves operation without Firebase, at the cost of full-feed downloads on that fallback path.

An ordinary pull-to-refresh bypasses the local fresh-result shortcut but still accepts sufficiently current shared data. Any diagnostic operation that explicitly forces upstream work must be separate and rate limited.

## Firebase responsibilities

Use a Firebase-hosted backend entrypoint for query resolution. Devices do not need to orchestrate Firestore reads followed by a second function call. One backend request performs the Firebase-cache lookup and, if necessary, upstream refresh.

Use Firestore for small query results, snapshot manifests and refresh coordination. Keep large source snapshots and prepared static datasets in object storage, with indexed projections suitable for the supported lookups. Do not store a whole regional GTFS feed in one document or read an entire collection to filter it for one stop.

Shared cache writes belong to the backend. Keep provider credentials there. Partition cache namespaces by provider/source and credential scope where upstream access or returned data differs; only equivalent public results may be shared between users.

Do not depend on a backend process's memory surviving between requests. Instance memory can accelerate lookups, but shared snapshots and their manifests remain authoritative.

## Cache identity and coverage

Keys include the schema/projection version, region, provider, source and all parameters that affect the answer. Normalise equivalent requests consistently on device and backend.

- Vehicles: viewport or spatial cells, mode, route filters and requested detail level. Mark incomplete or capped spatial results explicitly.
- Trip updates: provider-qualified trip identity, service date and start time where applicable; relevant stops or leg range.
- Departures: stop identity, requested time window, mode/options and result limit. Larger cached results may satisfy smaller limits only after validating the window and ordering.
- Journeys: origin, destination, departure/arrival semantics, requested time and travel options. Time buckets may locate candidates, but cannot substitute for validating the exact requested journey window.
- Stop search: region/source, normalised query, filters and limit.
- Static data: dataset version, region and requested subset.

Never treat a cache miss as an authoritative empty result. Cache successful empty responses with explicit coverage and a suitable short lifetime. Failures use retry/backoff metadata, not the same representation as empty data.

## What crosses the network

### Vehicle positions

Source endpoints return vehicles across an operator or region. Return only vehicles matching the selected journey, vehicle ID or map area. Include identifiers, coordinates, heading, observation time and fields actually required by the selected view. Preserve provider and service identity for correct matching.

### Trip updates

Source endpoints return many trips and their stop updates. Return only requested trips and relevant stop ranges, keeping predicted times, stop sequence, cancellation/skipped-stop state and timestamps. A whole leg may be needed for journey progress; a departure row needs much less.

### Alerts and disruptions

Filter by affected entities, active period and language on the backend. Return applicable alert identity, text, validity and status. Preserve enough applicability information for subsequent local filtering. A network-wide alerts view is a separate broad query.

### Static GTFS

Answer stop search, departures and route geometry from server-side indexes rather than downloading the full archive for each purpose. Keep explicit versioned regional downloads for offline planning. Install a new local dataset atomically after validation, retaining the previous usable version on failure.

### NSW Stop Finder and journey planning

Stop search needs bounded identity/name/type results, plus coordinates only where used. Journey lists need summaries; selected journeys need detailed stops, geometry and walking instructions. Replace operational uses of `rawJson` with explicit matching/provenance fields before removing raw payloads. The current app uses raw fields for more than diagnostics.

### PTV endpoints

Stop search needs only bounded stop results. Stop details currently request accessibility and disruptions while mapping name, location and description; remove unused upstream expansions for that caller. Departures are already stop-scoped and bounded: project their required times, platform, route, destination, cancellation and run identity. Filter broad disruptions to the requested context.

## Freshness and consistency

Define policy per data class in the fetching module, not independently in controllers and widgets. Initial realtime windows should be validated against provider update cadence; the current NSW memory cache's 30-second lifetime is a baseline to evaluate, not a universal rule.

Track source observation time separately from backend fetch time. When the source provides no trustworthy timestamp, record that limitation and use fetch time as an explicit proxy. Copying a result from Firebase to Drift or memory must never restart its freshness window. Fetching an unchanged old upstream feed must not make its observations appear new.

Use separate deadlines for fresh reuse, allowable stale display and storage cleanup. Firestore TTL deletion is asynchronous, so application code must check freshness explicitly; TTL is only cleanup. See the [Firebase TTL documentation](https://firebase.google.com/docs/firestore/ttl).

Scheduled timetable data can remain useful offline longer than vehicle positions. Old vehicle positions must not be presented as live. Past departures must not reappear merely because a cached query has not expired. Evaluate service-day and timezone semantics when selecting cached departures.

Publish immutable snapshot generations and switch the active manifest only after a complete validated build. Preserve per-source failure/freshness metadata when aggregating feeds. Reject out-of-order completions so an older refresh cannot overwrite a newer accepted snapshot, locally or on the backend.

## Concurrent requests and refresh ownership

Deduplicate identical device requests in the resolver. On the backend, coordinate refreshes by upstream source rather than only by derived query: two different stops may require the same source feed.

Use a bounded shared refresh lease with an owner and generation token. After acquiring it, recheck the cache; another refresh may already have completed. Only the current owner/generation can publish. Lease expiry allows recovery after crashes. Waiting requests have bounded waits, then use permitted stale data or report temporary unavailability. Apply backoff for failed/rate-limited sources.

After a shared source refresh, derive compact results for waiting queries from that snapshot. Cancel obsolete screen work and guard local writes against disposed consumers, changed query generations and database resets. Stopping one caller must not cancel shared work needed by another.

## Refactor sequence

1. Introduce the typed result metadata, canonical query keys and internal resolver alongside the current repositories. Inject clock, local storage, backend transport and policy for verification.
2. Consolidate existing memory/Drift freshness and in-flight handling into the resolver. Preserve current behaviour before adding Firebase.
3. Add one backend query for NSW journey-specific realtime data. Implement the Firebase shared snapshot lookup, coordinated upstream refresh and compact projection together.
4. Route trip-leg detail and active-journey consumers through that query. Keep a release switch for the pilot, with local stale fallback.
5. Add viewport-filtered vehicle queries, then stop departures backed by static/realtime indexes, then alerts/search/journey projections.
6. Replace broad aggregate prefetch with intent-specific prefetch for visible or likely-next queries. Make full regional dataset downloads an explicit offline feature.
7. Remove duplicate caches and direct upstream calls from migrated production paths. Keep raw-feed inspection separate from ordinary screen fetching.

Relevant existing locations are `lib/nsw/wrappers/realtime_service_impl.dart`, `lib/nsw/wrappers/realtime_service/snapshot_cache.dart`, `lib/wrappers/trip_cache_service/repository.dart`, `lib/transit/gtfs/public_gtfs_departures.dart`, `lib/trip_leg_detail/controller/trip_leg_realtime_controller.dart` and `lib/widgets/realtime_map/vehicle_loading.dart`.

## Verification and rollout

Verify through repository interfaces that a fresh local hit makes no network request; a Firebase hit makes no upstream request; and simultaneous misses for different queries sharing one source produce one coordinated refresh. Cover stale fallback, valid empty results, partial sources, query coverage, cross-provider identities, overnight services, cache-write failures, lease expiry and out-of-order completions.

Measure bytes received per user action, device decoding time, memory, time to useful content, source-data age, tier hit rates, upstream requests per source and backend cost. Compare against the existing path on a lower-end device. Promote each migrated query only after equivalent matching/coverage and lower device work are demonstrated.
