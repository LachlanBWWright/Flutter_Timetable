# lbww_flutter

Multi-region public transport journey planner for NSW, Victoria, and Queensland.

## Toolchain

- Flutter SDK: `3.38.7` (pinned via `.fvmrc`)
- Dart SDK: `>=3.10.7` (managed by the Flutter SDK in this repository)
- Local verification commands:
  - `flutter pub get`
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test --exclude-tags integration`
  - `flutter test --tags integration` (requires provider credentials in `.env`)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Widget previews

Run the Flutter Widget Previewer from the repository root:

```sh
flutter widget-preview start
```

Preview definitions are intentionally kept out of production widget files:

- `lib/previews/page_previews.dart` covers application screens.
- `lib/previews/widget_previews.dart` covers major reusable components and
  important visual states.
- `lib/previews/preview_fixtures.dart` contains deterministic sample data,
  callbacks, and the shared Material app wrapper.

Previews are grouped by Pages, Stations, Journeys, Trip creation, Feedback,
and Debug tools. Fixed phone-sized constraints make page previews predictable;
major cards also include light and dark configurations. Preview fixtures must
remain local and deterministic: do not add live API calls, credentials, native
plugin calls, or `dart:io` dependencies.

## API Code Generation

This project uses `swagger_dart_code_generator` to generate Dart models
and API clients from Swagger/OpenAPI schemas.

The checked-in Swagger codegen targets are Victoria/PTV and NSW/TfNSW:

- Source URL: `https://timetableapi.ptv.vic.gov.au/swagger/docs/v3`
- Checked-in normalized spec: `lib/victoria/swaggers/ptv_timetable_v3.json`
- Generated client: `lib/victoria/swagger_generated/`

The checked-in PTV spec keeps the upstream API shape but normalizes numeric enum
values to strings and replaces two missing upstream `$ref`s (`V3.Operator` and
`V3.Period`) with generic object arrays so `swagger_dart_code_generator` can
parse it.

NSW/TfNSW:

- Verbatim upstream spec: `lib/nsw/swaggers/trip_planner.yaml`
- Generated client: `lib/nsw/swagger_generated/`
- Runtime factory: `createTripPlannerClient` in
  `lib/nsw/swagger_clients/swagger_backend.dart`

The upstream NSW document has three response-schema mismatches observed in live
responses: `systemMessages` is returned as an array, `vehicleAccess` contains
objects, and coordinate `distance` is numeric. These are not applied to the
source document. Run
`dart run tool/normalize_nsw_trip_planner_spec.dart` followed by
`dart run build_runner build -c nsw --delete-conflicting-outputs` creates the
explicit codegen input under `lib/nsw/swaggers/generated/` and regenerates the
client. The normalizer asserts both original shapes before changing them.
The generator currently emits an HTTP default URL, so the runtime factory
always supplies the HTTPS `/v1/tp` base URL explicitly.

Queensland/TransLink does not publish a Swagger/OpenAPI contract through the
Queensland open data GTFS page. Static GTFS and GTFS-Realtime feed definitions
live under `lib/queensland/translink/`.

## Multi-region credentials

The multi-region transit layer reads provider credentials and optional feed URLs
from `.env`:

- `API_KEY` for TfNSW
- `PTV_DEV_ID` and `PTV_API_KEY` for PTV signed API access
- `VICTORIA_OPEN_DATA_API_KEY` for the official Transport Victoria mode-specific
  GTFS-Realtime feeds (sent in the required `KeyID` header)
- `VICTORIA_DATA_PLATFORM_TOKEN` for the optional Transport Victoria portal
  token; the current GTFS-Realtime feeds authenticate with the API key above
  and do not require this token
- `VICTORIA_STATIC_GTFS_URL` to override the official weekly Victoria GTFS
  Schedule download URL
- `VICTORIA_GTFS_RT_VEHICLES_URL`, `VICTORIA_GTFS_RT_TRIP_UPDATES_URL`, and
  `VICTORIA_GTFS_RT_ALERTS_URL` as legacy/custom realtime endpoint overrides

Victoria realtime source IDs are `ptv:metro`, `ptv:tram`, `ptv:bus`, and
`ptv:vline`. Bus and V/Line do not currently publish service-alert feeds, so
alert requests for those sources return an empty snapshot. The official portal
documents per-feed rate limits; callers should cache snapshots and avoid polling
more frequently than the provider refresh rate.

To generate code, ensure you have installed dependencies and then run:

```
dart run build_runner build --delete-conflicting-outputs
```

You can also run the helper script:

```
./scripts/generate_api.sh
```

Generated Victoria files will be emitted to `lib/victoria/swagger_generated`
per `build.yaml`. NSW files can be regenerated by temporarily selecting the
NSW input/output pair in `build.yaml`; the repository's existing Drift
generation warnings currently prevent one combined build from completing.
