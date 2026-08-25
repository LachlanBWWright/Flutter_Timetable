/// Golden screenshots for the app's primary pages.
///
/// Generate or refresh the images with:
///
///   flutter test --update-goldens test/screenshots_test.dart
///
/// Compare the current UI with the checked-in images with:
///
///   flutter test test/screenshots_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/previews/page_previews.dart';
import 'package:lbww_flutter/previews/preview_fixtures.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => '/tmp/flutter_timetable_golden',
      );
  // Prevent the trip-detail preview from trying to hydrate optional debug
  // route data from the production database.
  DebugService.showDebugData.value = false;
  ScreenshotDevice.screenshotsFolder = '../screenshots/';

  final pages = <({String name, Widget Function() builder})>[
    (name: '1_home', builder: homePagePreview),
    (name: '2_new_trip', builder: newTripPagePreview),
    (name: '3_settings', builder: settingsPagePreview),
    (name: '4_set_home_stop', builder: setHomeStopPagePreview),
    (name: '5_saved_trip', builder: tripPagePreview),
    (name: '6_trip_legs', builder: tripLegsPagePreview),
    (name: '7_trip_leg_detail', builder: tripLegDetailPagePreview),
    (name: '8_manual_trip_composer', builder: tripComposerPagePreview),
    (name: '9_realtime_map', builder: realtimeMapPagePreview),
    (name: '10_stops_map', builder: stopsMapPagePreview),
    (name: '11_debug_entity', builder: debugEntityScreenPreview),
  ];

  for (final page in pages) {
    _registerScreenshot(page.name, page.builder);
  }

  for (final state in _stateFixtures) {
    for (final mode in TransportMode.values) {
      final stateId = state.label.toLowerCase().replaceAll(' ', '_');
      final modeId = mode.id;
      _registerScreenshot(
        '12_stops_map_${stateId}_$modeId',
        () => _stateStopsMapPreview(state, mode),
      );
      _registerScreenshot(
        '13_realtime_map_${stateId}_$modeId',
        () => _stateRealtimeMapPreview(state, mode),
      );
      _registerScreenshot(
        '14_stop_list_${stateId}_$modeId',
        () => _stateStopListPreview(state, mode),
      );
    }
  }
}

void _registerScreenshot(String name, Widget Function() builder) {
  const device = ScreenshotDevice(
    platform: TargetPlatform.android,
    resolution: Size(430, 850),
    pixelRatio: 1,
    goldenSubFolder: 'phoneScreenshots/',
    frameBuilder: ScreenshotFrame.androidPhone,
  );

  group(name, () {
    testGoldens('for androidPhone430', (tester) async {
      await tester.pumpWidget(
        ScreenshotApp.withConditionalTitlebar(
          device: device,
          title: 'Flutter Timetable',
          home: appPreviewWrapper(builder()),
        ),
      );

      await tester.loadAssets();
      await tester.pumpFrames(
        tester.widget(find.byType(ScreenshotApp)),
        const Duration(seconds: 1),
      );
      await tester.expectScreenshot(device, name);
    });
  });
}

class _StateMapFixture {
  const _StateMapFixture(this.label, this.latitude, this.longitude);

  final String label;
  final double latitude;
  final double longitude;
}

const _stateFixtures = <_StateMapFixture>[
  _StateMapFixture('New South Wales', -33.8831, 151.2065),
  _StateMapFixture('Victoria', -37.8136, 144.9631),
  _StateMapFixture('Queensland', -27.4698, 153.0251),
  _StateMapFixture('South Australia', -34.9285, 138.6007),
  _StateMapFixture('Tasmania', -42.8821, 147.3272),
  _StateMapFixture('Northern Territory', -12.4634, 130.8456),
  _StateMapFixture('Western Australia', -31.9505, 115.8605),
];

Widget _stateStopsMapPreview(_StateMapFixture state, TransportMode mode) {
  return Scaffold(
    appBar: AppBar(title: Text('${state.label} · ${mode.displayName} stops')),
    body: StopsMapWidget(
      embedded: true,
      transportMode: mode,
      modeDisplayName: mode.displayName,
      onStopSelected: previewStopIdNoop,
      showTileLayer: false,
      skipInitialLoad: true,
      initialStops: _stopsForState(state, mode),
    ),
  );
}

Widget _stateRealtimeMapPreview(_StateMapFixture state, TransportMode mode) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${state.label} · ${mode.displayName} realtime'),
    ),
    body: RealtimeMapWidget(
      transportMode: mode,
      showTileLayer: false,
      getPositions: () async => {mode: _feedForState(state, mode)},
    ),
  );
}

Widget _stateStopListPreview(_StateMapFixture state, TransportMode mode) {
  final stations = List<Station>.generate(
    6,
    (index) => Station(
      name: '${state.label} ${mode.displayName} Stop ${index + 1}',
      id: '${state.label.hashCode.abs()}-${mode.id}-$index',
      mode: mode,
      lineId: '${mode.id.toUpperCase()}-${index + 1}',
      lineName: '${mode.displayName} service ${index + 1}',
      platformCode: mode == TransportMode.train
          ? 'Platform ${index + 1}'
          : null,
      latitude: state.latitude + (index * 0.002),
      longitude: state.longitude + (index * 0.002),
      distance: (index + 1) * 0.4,
    ),
  );
  return Scaffold(
    appBar: AppBar(title: Text('${state.label} · ${mode.displayName} stops')),
    body: StationList(listItems: stations, setStation: previewStationNoop),
  );
}

List<gtfs.Stop> _stopsForState(_StateMapFixture state, TransportMode mode) {
  return List<gtfs.Stop>.generate(
    4,
    (index) => gtfs.Stop(
      stopId: '${state.label.hashCode.abs()}-${mode.id}-$index',
      stopName: '${state.label} ${mode.displayName} Stop ${index + 1}',
      stopLat: state.latitude + (index * 0.002),
      stopLon: state.longitude + (index * 0.002),
      locationType: 0,
      wheelchairBoarding: 1,
    ),
  );
}

FeedMessage _feedForState(_StateMapFixture state, TransportMode mode) {
  final feed = FeedMessage();
  for (var index = 0; index < 3; index++) {
    final entity = FeedEntity()..id = '${state.label}-$index';
    final vehicle = VehiclePosition();
    vehicle.vehicle = VehicleDescriptor()..id = '${mode.id}-vehicle-$index';
    vehicle.trip = TripDescriptor()
      ..routeId = '${mode.id.toUpperCase()}-${index + 1}';
    vehicle.position = Position()
      ..latitude = state.latitude + (index * 0.002)
      ..longitude = state.longitude + (index * 0.002);
    entity.vehicle = vehicle;
    feed.entity.add(entity);
  }
  return feed;
}
