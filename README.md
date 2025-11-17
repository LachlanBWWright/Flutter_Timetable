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
and API clients from Swagger/OpenAPI schemas placed in `lib/swaggers`.

To generate code, ensure you have installed dependencies and then run:

```
dart run build_runner build --delete-conflicting-outputs
```

You can also run the helper script:

```
./scripts/generate_api.sh
```

Generated files will be emitted to `lib/swagger_generated` per `build.yaml`.
