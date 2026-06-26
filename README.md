# lbww_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API Code Generation

This project uses `swagger_dart_code_generator` to generate Dart models
and API clients from Swagger/OpenAPI schemas.

The active Swagger codegen target is Victoria/PTV:

- Source URL: `https://timetableapi.ptv.vic.gov.au/swagger/docs/v3`
- Checked-in normalized spec: `lib/victoria/swaggers/ptv_timetable_v3.json`
- Generated client: `lib/victoria/swagger_generated/`

The checked-in PTV spec keeps the upstream API shape but normalizes numeric enum
values to strings and replaces two missing upstream `$ref`s (`V3.Operator` and
`V3.Period`) with generic object arrays so `swagger_dart_code_generator` can
parse it.

NSW/TfNSW generated files remain under `lib/nsw/swagger_generated`, with old
top-level paths kept as compatibility exports. NSW generation is intentionally
not the active `build.yaml` target because that integration has manual fixes.

Queensland/TransLink does not publish a Swagger/OpenAPI contract through the
Queensland open data GTFS page. Static GTFS and GTFS-Realtime feed definitions
live under `lib/queensland/translink/`.

## Multi-region credentials

The multi-region transit layer reads provider credentials and optional feed URLs
from `.env`:

- `API_KEY` for TfNSW
- `PTV_DEV_ID` and `PTV_API_KEY` for PTV signed API access
- `VICTORIA_STATIC_GTFS_URL` for optional Victoria static import
- `VICTORIA_GTFS_RT_VEHICLES_URL`, `VICTORIA_GTFS_RT_TRIP_UPDATES_URL`, and
  `VICTORIA_GTFS_RT_ALERTS_URL` for optional Victoria GTFS-Realtime feeds

To generate code, ensure you have installed dependencies and then run:

```
dart run build_runner build --delete-conflicting-outputs
```

You can also run the helper script:

```
./scripts/generate_api.sh
```

Generated Victoria files will be emitted to `lib/victoria/swagger_generated`
per `build.yaml`.
