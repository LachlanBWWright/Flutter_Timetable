# Performance profiling

Run the deterministic work-budget regression with:

```bash
flutter test test/performance
```

This also runs in normal project CI. It exercises production journey cards
with both next-trip subtitles, the real prefetch queue and cache, and checks
bounded visible work, at most two concurrent fetches, and no additional
transport or disk reads on warm rebuilds or periodic refresh. Home uses a lazy
scrollable: offscreen directions are warmed only as they enter its cache area.
Transport and persistence are in-memory fixtures; no API keys are needed.

The suite also checks that 100 simultaneous callers share one request and write,
1,000 warm cache reads add no I/O, loading 100 route pairs retains only the
latest 50 responses in memory, and 100 synchronous invalidations publish one
change notification. Disposed subtitles must stop refreshing even after their
cache is cleared. These assertions fail on excess work or unbounded retention
without depending on machine speed.

## Synthetic ride replay regressions

```bash
flutter test test/vehicle_finder/ride_replay_test.dart
```

These timestamped synthetic trajectories exercise the production controller,
feed polling, location health checks and matcher together over three simulated
minutes. They cover a tunnel GPS gap, a transient feed outage, adjacent moving
services, stationary vehicles, and a 5,000-vehicle feed. They assert confidence
is cleared during interruptions, reacquisition needs fresh motion evidence,
parallel/stationary services remain uncertain, and polling, evaluations,
shortlists and retained histories stay bounded. Stopping must cancel timers
and prevent all later requests. They use fake time, no GPS plugins or API keys,
and no private passenger tracks. They are not field recordings or evidence of
accuracy on a real ride.

## Device profiles

```bash
flutter devices
./scripts/profile.sh linux
# Or use a connected Android/iOS device ID:
./scripts/profile.sh DEVICE_ID
```

The runner uses Flutter's profile mode and integration-test driver. A desktop
run needs a display and the platform's native build dependencies. For a
headless Linux session with Xvfb installed, use:

```bash
xvfb-run -a ./scripts/profile.sh linux
```

The manual **Performance profile** GitHub workflow provides a Linux run and
uploads its report. Hosted runner timings are diagnostic; use the same physical
device for stable comparisons. Debug/widget-test elapsed times are not UI
performance measurements.

Reports are written to `build/performance/performance.json`, with the Flutter
version and Git revision alongside it. Copy the directory before another run
if you want to retain a baseline. The JSON includes these separate scenarios:

| Scenario | Workload |
| --- | --- |
| `app_shell_mount` | Production app shell and seeded Home, with bootstrap and initial database/network loading excluded |
| `subtitle_cold_mount` | First viewport of a lazy production journey list containing 20 trips, 40 directions |
| `subtitle_warm_scroll` | Repeated scrolling after the cache has filled and one warm-up pass |
| `home_search_100` | Four search changes on the real home screen with 100 saved journeys |
| `trip_results_scroll_60` | Scrolling 60 three-leg results on the real trip screen after warm-up |
| `trip_result_expand_collapse` | Ten toggles of a three-leg result |
| `map_mount_pan_2500` | Mount and four pans of the production clustered stops map with 2,500 seeded stops; tiles and GPS disabled |
| `map_navigation_10` | Ten pushes and pops of the same production map route, with a post-pop RSS sample per cycle |

Each scenario contains Flutter's frame build/raster averages, p90/p99 and worst
frame times, missed frame-budget counts, raw frame samples, and GC counts.
It also records before/after process RSS samples. RSS includes the engine and
native allocations; its delta is not a retained-heap or leak measurement.
Metadata records the platform, Dart version, viewport and fixture sizes.
The harness explicitly sets the lifecycle to resumed after mounting so unfocused
desktop test windows exercise foreground subtitle refresh; this is recorded in
the metadata.
`cache_work` records actual request, persistence and peak-concurrency counts.

Only the subtitle scenario enables background journey loading. Home search and
trip results disable startup services and use seeded data to isolate rendering
and interaction cost. The subtitle scenario uses the production JourneyList sliver inside a
CustomScrollView, matching Home’s lazy scrolling structure, without bootstrap,
GPS or feed import.
The cold-mount scenario includes initial UI/cache work, but background fetch
completion is awaited separately before warm scrolling. Map profiles include clustering, viewport updates, Flutter rendering and
route disposal; they exclude tile decoding/network traffic and GPS. These
tests do not measure real network latency, full process startup or GTFS import.
`app_shell_mount` is a shell rendering measurement, not a cold-start result.

Compare frame percentiles and missed-budget fractions (`missed_* / frame_count`)
on the same hardware, display refresh rate, viewport, Flutter version, and power
settings. Run several times to distinguish repeatable changes from noise.
There is deliberately no universal millisecond CI threshold: capture a stable
device baseline first. The integration test fails on empty frame samples,
unexpected duplicate fetches, incomplete cache warming, or a concurrency breach.

This harness uses Flutter's documented
[integration-test performance API](https://docs.flutter.dev/cookbook/testing/integration/profiling)
and `watchPerformance` frame summaries.

## Cold startup and field validation protocol

Full startup passes through dotenv loading, native preference storage, provider
initialization and the installed journey database. The deterministic harness
intentionally does not invoke that bootstrap or read a developer’s API keys.
An additional opt-in native harness invokes the actual `app.main()` and
`AppBootstrapService` against the installed preferences and database:

```bash
mkdir -p build/performance
flutter drive --profile --driver=test_driver/performance_driver.dart \
  --target=integration_test/startup_performance_test.dart \
  --dart-define=RUN_REAL_STARTUP_PROFILE=true \
  --dart-define=ENABLE_NSW=true -d DEVICE_ID
```

It skips unless `RUN_REAL_STARTUP_PROFILE=true` is explicitly supplied.
Run this on a dedicated test installation: it uses real configured providers
and may make normal startup network requests. It does not print credentials
or journey data. It reports `app_main_complete_ms`, `first_home_frame_ms`,
`settled_home_ms`, startup frame metrics and process RSS; pending initial Home
loading or an uncaught error fails the run. Its stopwatch begins just before
the Dart `app.main()` invocation, after the engine and integration runner have
started, so it excludes OS process/engine launch and is not a complete
launch-to-screen benchmark. It is excluded from deterministic CI. The driver
writes the same report path as other profiles, so preserve earlier results.

For full startup, install a profile build on a dedicated physical test device,
record its Flutter/platform version, refresh rate, power mode, enabled regions,
saved-journey count, offline data size and network state. Measure from process
launch to the first useful Home frame using the platform startup trace tools;
force-stop between cold runs, do at least five runs, and keep warm launches
separate. Record empty-install and populated-database cases separately. Do not
combine these numbers with `app_shell_mount`.

For memory investigation, compare `map_navigation_rss_samples_bytes` after
warm-up over repeated runs. Route disappearance asserts the widget was removed;
RSS growth alone cannot establish a leak. Use DevTools allocation/retained-heap
snapshots and inspect retaining paths if growth continues across cycles.

Before treating vehicle inference as reliable, run supervised physical-device
rides with explicit location permission. Include an above-ground ride, tunnel
exit, parallel services, platform waiting, a transfer and a network interruption.
Record expected service, timestamp, GPS accuracy, feed observation age, proposed
candidates/confidence, and recovery time. Check that each interruption removes
confidence and that End trip or leaving finder stops location sampling. Record
battery/thermal behavior across a representative journey. Keep traces local or
anonymize coordinates and identifiers before sharing; never commit keys or raw
personal tracks. Those checks are a field protocol, not tests already completed
by this repository.
