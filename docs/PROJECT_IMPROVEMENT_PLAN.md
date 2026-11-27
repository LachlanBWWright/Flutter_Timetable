# Project Improvement Plan

## Purpose

This document turns the July 2026 project review into a practical improvement plan for the Flutter Timetable application. The work is ordered by risk and expected impact, with reliability improvements taking priority over broader refactoring.

## Scope

This plan covers:

- Database reliability and migration safety
- Error handling and observability
- CI/CD quality gates
- Application architecture and maintainability
- Flutter SDK consistency
- Product documentation
- Accessibility and UI regression coverage

The following review recommendations are intentionally excluded:

- Changing how API credentials are bundled or stored. The current provider keys are considered low-sensitivity free API credentials for this project.
- Enabling static analysis for the test directory.

## Phase 1: Database Reliability

### Objective

Ensure database failures are visible and cannot silently appear as successful operations or empty data.

### Work

1. Audit the safe database helpers in `lib/schema/database.dart`, including schema creation, reads, inserts, and transactions.
2. Remove broad exception suppression from schema creation and migration operations.
3. Catch only failures that have a defined recovery path.
4. Log unexpected failures with the operation name, relevant identifiers, error, and stack trace.
5. Return explicit typed results for operations where a recoverable failure is part of normal application behaviour.
6. Ensure the UI distinguishes between an empty result and a failed database read.
7. Add migration tests covering every supported historical schema version through the current version.
8. Add failure-path tests for reads, writes, and transactions.

### Completion criteria

- A failed schema creation or migration stops initialization and produces a useful diagnostic.
- Unexpected read and write failures are not converted into empty collections or `null` without context.
- Migration tests demonstrate that existing user data survives each supported upgrade path.
- Database failures can be presented to the user as recoverable errors where appropriate.

## Phase 2: Error Handling and Observability

### Objective

Replace blanket exception suppression with deliberate recovery and consistent diagnostics.

### Work

1. Inventory the broad `catch (_)` blocks across application source files.
2. Classify each catch as one of:
   - Expected and recoverable
   - Unexpected and reportable
   - Unnecessary
3. Refactor `lib/utils/guarded_state.dart` so that:
   - `onError` callbacks are actually invoked.
   - Errors retain their stack traces.
   - Deterministic framework calls are not wrapped unnecessarily.
   - Fallback values are used only when explicitly chosen by the caller.
4. Define a centralized error-reporting interface with structured context.
5. Use typed failures in service boundaries where the UI needs to choose between retry, fallback, and user-facing error states.
6. Add tests confirming that errors are reported and callbacks run as documented.

### Completion criteria

- No reusable helper silently discards an unexpected exception.
- `runAsyncGuarded` and related APIs behave according to their signatures.
- Important service failures include stack traces and operation context.
- Error, empty, loading, and successful states remain distinguishable.

## Phase 3: Blocking CI/CD Quality Gates

### Objective

Prevent unverified changes from being released or deployed.

### Work

1. Update `.github/workflows/test.yml` to run for `main` and `dev` consistently with the build workflows.
2. Remove job-level `continue-on-error` from the test workflow.
3. Keep formatting, `flutter analyze`, and the normal test suite as blocking checks.
4. Make Android release and web deployment jobs depend on successful quality checks.
5. Separate network-dependent integration tests from the deterministic unit and widget test suite.
6. Run integration tests in a dedicated job with explicit credentials, timeouts, and clear skip behaviour when credentials are unavailable.
7. Add dependency caching where it provides a measurable CI speed improvement.

### Completion criteria

- A formatting, analyzer, unit-test, or widget-test failure blocks merging and release.
- Pushes and pull requests targeting `main` run the quality workflow.
- Releases and deployments cannot proceed after failed quality checks.
- External API instability does not make the deterministic test suite unreliable.

## Phase 4: Architecture and Maintainability

### Objective

Reduce coupling and make major features easier to understand, test, and change.

### Work

1. Split the largest files into feature-focused controllers, services, models, and widgets. Initial candidates include:
   - `lib/trip_leg_detail_screen.dart`
   - `lib/new_trip.dart`
   - Large transport service implementations
   - Large map and stop widgets
2. Keep widget classes focused on presentation and user interaction.
3. Move journey loading, location sorting, API validation, and static-data prefetch orchestration out of the home widget.
4. Introduce explicit dependency injection at application and feature boundaries.
5. Reduce direct access to static service facades and the global database singleton.
6. Define ownership and lifecycle rules for the database, HTTP clients, schedulers, and region-specific services.
7. Preserve the existing transit interfaces and registry as the primary multi-region boundary.
8. Consolidate duplicate GTFS-Realtime generated sources, or document and enforce a single canonical source with compatibility exports.

### Completion criteria

- Major screens can be tested with fake services without changing global state.
- Background work is owned by an application or feature service rather than a widget.
- Resource lifecycles are explicit and testable.
- Large files have clear responsibilities and manageable review scope.
- There is one documented source of truth for generated GTFS-Realtime code.

## Phase 5: Platform, UX, and Documentation

### Objective

Make development reproducible and improve the user-facing quality of the application.

### Work

1. Pin or document a consistent Flutter version for local development and CI that satisfies the Dart SDK constraint.
2. Verify Android, web, and supported desktop builds against that version.
3. Decide whether dark-only mode is a product requirement. If not, add system and user-selectable theme modes.
4. Add accessibility checks for labels, focus order, touch targets, contrast, and text scaling.
5. Add golden or widget coverage for key journey, map, loading, empty, and error states.
6. Replace the starter README content with:
   - Product purpose
   - Supported regions and providers
   - Local setup
   - Environment configuration
   - Architecture overview
   - Code-generation workflow
   - Test commands
   - Supported platforms and known limitations
7. Update project metadata such as the package description and release naming where appropriate.

### Completion criteria

- Local and CI builds use a documented compatible Flutter toolchain.
- Core screens remain usable with large text and assistive technologies.
- Important UI states have regression coverage.
- A new contributor can configure, run, test, and generate code using the README alone.

## Recommended Delivery Order

Work should be delivered in small, independently reviewable changes:

1. Add database failure logging and migration tests.
2. Remove silent database fallbacks.
3. Correct `GuardedState` error callback behaviour.
4. Replace broad catches feature by feature.
5. Fix CI branch filters and make checks blocking.
6. Separate deterministic and network-dependent test suites.
7. Extract home-screen orchestration from the widget layer.
8. Introduce dependency injection at feature boundaries.
9. Decompose the largest screens and services incrementally.
10. Consolidate generated protobuf sources.
11. Pin the Flutter toolchain and verify supported builds.
12. Improve theming, accessibility coverage, UI regression tests, and documentation.

## Implementation Guidelines

- Avoid combining behavioural changes with large mechanical file moves.
- Add characterization tests before refactoring complex existing behaviour.
- Preserve unrelated local changes during each implementation step.
- Prefer typed results at service boundaries over `null` or empty-value error signalling.
- Include a rollback or recovery strategy for every database migration.
- Keep generated files out of manual refactoring unless the generation source or compatibility layout is being changed deliberately.
