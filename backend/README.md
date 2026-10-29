# Optional shared transit cache

The Flutter app works without Firebase. Leave `FIREBASE_CACHE_URL` empty to keep
its existing memory/Drift caches and direct provider requests. A configured but
unavailable backend also falls back to those provider requests.

## Current coverage

NSW uses the realtime sources in `functions/src/sources.json`, Stop Finder and
journey planning. The other regions use the exact URLs in
`functions/src/provider-sources.json`, mirrored by the Flutter catalog and checked
by a contract test:

- Victoria: Transport Victoria realtime feeds, the official static GTFS archive,
  and legacy PTV stop search/details, departures and disruptions.
- Queensland: all configured TransLink realtime feed sets and static archives.
- South Australia: Adelaide Metro vehicles, trip updates, alerts and static GTFS.
- Tasmania, Northern Territory and Western Australia: their current public static
  GTFS archives, including Darwin and Alice Springs and the Transperth download.

The shared backend caches full source snapshots across users. Realtime trip,
route, vehicle and viewport filters reduce the response before transmission.
Regional repositories accept these hints through `RealtimeRequest.query`; final
identity/ambiguity matching stays with the caller, including on direct fallback.
Provider protobuf extensions survive filtering. Original fetch timestamps survive
mapping into regional domain snapshots. NSW trip-leg detail, active journeys and
selected-service maps send scoped queries; ordinary NSW maps send visible bounds.

Static archives use immutable Storage objects and token-based download URLs, so
the function response contains only a small pointer. The app then downloads the
ZIP from Storage without sending provider credentials. These public-dataset
URLs grant read access to that generation; they do not grant write access or
expose provider keys. Loaded regional datasets still avoid all remote requests.
Static feeds are cached for six hours. Preparing smaller regional datasets and
server-side departure indexes remains separate work; this change preserves the
existing GTFS parsers and offline journey planning.

PTV signatures and developer IDs are removed from the shared lookup. The backend
signs public PTV queries with its own credentials and filters unused JSON fields,
while retaining referenced routes/runs/directions and cancellation information.
Backend credentials also allow legacy PTV departures, stop details and disruptions
without device-side credentials. If legacy access is unavailable, disruptions
retain their existing Open Data alert fallback. Direct requests retain their
original device signatures. Stop search prefers
loaded static data when device PTV credentials are absent; an empty local search
can use the configured backend. Modern Victoria realtime can be enabled by the
Firebase URL without a device-side Open Data key.

The backend rejects unknown URLs and credential-bearing queries. Custom feed URL
overrides not listed in the catalog retain their normal direct provider path.
NSW static GTFS archives and splitting NSW journey summaries from details remain
separate migrations. Journey payloads retain operational raw fields for matching.

## Set up Firebase

Use a dedicated Firebase project with Firestore, Cloud Storage and Functions
billing enabled. No Firebase project has been selected or deployed by this change.

1. In `backend/functions`, run `npm ci` and `npm test` with Node 22.
2. Install/sign in to the Firebase CLI and select your project explicitly with
   `--project YOUR_PROJECT_ID` on each command below.
3. From `backend`, run
   `firebase functions:secrets:set TRANSIT_PROVIDER_CREDENTIALS --project YOUR_PROJECT_ID`.
   Enter a JSON object in the CLI's private prompt, using the field names
   `tfnswApiKey`, `victoriaOpenDataApiKey`, `ptvDeveloperId` and `ptvApiKey` for the
   providers you use. Omit unused fields; `{}` supports public providers without
   any provider credentials. This replaces the earlier standalone `TFNSW_API_KEY`
   binding: move an existing NSW key into the JSON object's `tfnswApiKey` field.
   Keep this JSON in Secret Manager, rather than source control or the app.
   See [Firebase secret configuration](https://firebase.google.com/docs/functions/config-env).
4. Deploy with
   `firebase deploy --only functions:transit-cache,firestore:rules,storage --project YOUR_PROJECT_ID`.
   The supplied rules deny client access to cache data. If reusing an existing
   project, merge these rules into its existing rules before deploying them.
5. Set `FIREBASE_CACHE_URL` in the app's `.env` to the returned `transitCache`
   HTTPS URL, or pass `--dart-define=FIREBASE_CACHE_URL=https://...` at build time.
   A nonempty Dart define takes precedence. No app-side Firebase SDK setup is
   necessary. Keep existing app provider credentials for direct fallback.

The function runs in `australia-southeast1`, with a maximum of five instances.
Its HTTPS query endpoint serves public transport data; provider credentials are
backend-only, client cache writes are denied, upstream URLs are allowlisted and
realtime redirects are rejected. Static downloads may follow up to three
same-origin redirects; provider credentials are never forwarded on redirects. Requests contain query identifiers and journey parameters,
so treat the deployed backend as a trusted data recipient. Configure deployment
access controls, quotas and monitoring appropriate to the intended audience.

## Cache storage and freshness

Firestore's `transitSourceCache` collection holds manifests and refresh leases.
Cloud Storage holds immutable source generations under `transit-cache/`.
An owner token and expiry prevent an old refresh from publishing over a newer
owner. Concurrent queries for different trips reuse one source download.
Set a bucket lifecycle rule to delete `transit-cache/` objects older than one day;
superseded generations are not deleted synchronously. Do not apply this lifecycle
rule to unrelated application objects. Expired Firestore manifests are overwritten
on subsequent source refreshes. A Firestore TTL policy is not required.

Realtime and journey source results are fresh for 30 seconds; Stop Finder results
and PTV stop/search results for one hour; static archives for six hours.
Original backend fetch times survive client transport, realtime
snapshots and persisted journey caches. GTFS feed and entity observation timestamps
remain unchanged. Device/domain freshness policies still apply independently.

Provider-key validation explicitly bypasses Firebase so cached results cannot
validate an incorrect device credential.

The app bounds the shared lookup to four seconds and a subsequent Storage archive
download to twenty seconds, aborts timed-out HTTP requests and
briefly backs off after transport failures. It then uses its ordinary provider
request. Shared response validation rejects malformed, incompatible and expired
data. A valid empty feed/search remains a successful response. Resetting realtime
caches clears shared transport memory and prevents pending requests from
reinstalling invalidated data. Ordinary refresh may reuse a fresh server snapshot.

If Firebase storage cannot be read, the backend can still fetch upstream. A cache
write failure still allows an inline response for payloads up to 28 MiB; larger
archives fall back to the existing provider download. Source downloads are bounded
to 128 MiB for static archives and 32 MiB for other responses. If the backend
cannot complete, the device retains its established provider/fallback behaviour.
The app does not send its Authorization header to the shared backend.

## Local verification

Run `npm test` and `npm run check` in `backend/functions`. Tests use injected stores
and provider loaders; they require no Firebase account or provider credentials.
For emulator checks, configure local Firebase emulators and put the secret in the
ignored `functions/.secret.local` as a `TRANSIT_PROVIDER_CREDENTIALS` JSON value. Run `firebase emulators:start` from `backend`
with an explicit project ID. Point the app at
`http://127.0.0.1:5001/PROJECT/australia-southeast1/transitCache` (Android emulator:
`10.0.2.2`). Only loopback/emulator HTTP URLs are accepted; production requires HTTPS.

Flutter verification:

```sh
flutter test test/transit/cache test/realtime_snapshot_cache_test.dart test/app_http_client_test.dart
flutter analyze
```

Live provider performance, Firebase emulator behaviour and deployed IAM/bucket
configuration must be verified in the target project before enabling the URL in
release builds.
