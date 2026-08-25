import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:lbww_flutter/constants/app_constants.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/screens/debug_entity_screen.dart';
import 'package:lbww_flutter/main.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/previews/preview_fixtures.dart';
import 'package:lbww_flutter/set_home_stop_screen.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/trip.dart';
import 'package:lbww_flutter/trip_composer_screen.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/trip_legs_screen.dart';
import 'package:lbww_flutter/widgets/realtime_map_widget.dart';
import 'package:lbww_flutter/widgets/stops_map_widget.dart';

Future<DebugPageData> previewDebugLoader(DebugEntityRequest request) async =>
    previewDebugPage;

@Preview(
  name: 'Home page',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget homePagePreview() => const MyHomePage(
  title: AppConstants.appTitle,
  skipInitialLoad: true,
  initialJourneys: [previewJourney, previewSecondJourney],
);

@Preview(
  name: 'New trip',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget newTripPagePreview() => const NewTripScreen(
  skipInitialLoad: true,
  initialStations: previewStations,
);

@Preview(
  name: 'Settings',
  group: 'Pages',
  size: Size(430, 900),
  wrapper: appPreviewWrapper,
)
Widget settingsPagePreview() => const SettingsScreen(
  hasUserApiKey: false,
  hasBuiltInApiKey: true,
  stopsManagementWidget: Card(
    child: ListTile(
      leading: Icon(Icons.storage),
      title: Text('12,480 cached stops'),
    ),
  ),
  stopsSearchWidget: Card(
    child: ListTile(
      leading: Icon(Icons.search),
      title: Text('Search provider stops'),
    ),
  ),
  realtimeInfoWidget: Card(
    child: ListTile(
      leading: Icon(Icons.sensors),
      title: Text('Realtime feeds available'),
    ),
  ),
);

@Preview(
  name: 'Set home stop',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget setHomeStopPagePreview() => const SetHomeStopScreen(
  skipInitialLoad: true,
  initialStations: previewStations,
  initialHomeStop: 'Central Station',
);

@Preview(
  name: 'Saved trip',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget tripPagePreview() => TripScreen(
  trip: previewJourney,
  skipInitialLoad: true,
  initialTrips: [previewTripJourney],
);

@Preview(
  name: 'Trip legs',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget tripLegsPagePreview() => TripLegScreen(trip: previewTripJourney);

@Preview(
  name: 'Trip leg detail',
  group: 'Pages',
  size: Size(430, 900),
  wrapper: appPreviewWrapper,
)
Widget tripLegDetailPagePreview() => TripLegDetailScreen(
  leg: previewLeg,
  trip: previewTripJourney,
  debugPageLoader: previewDebugLoader,
  skipInitialLoadDelay: true,
  skipInitialLoad: true,
);

@Preview(
  name: 'Manual trip composer',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget tripComposerPagePreview() => const TripComposerScreen(
  origin: previewCentral,
  destination: previewTownHall,
  currentMode: TransportMode.train,
  originMode: TransportMode.train,
  destinationMode: TransportMode.train,
  selectedLine: null,
  interchanges: [previewMuseum],
  manualValidationMessage: null,
  canSaveManual: true,
  onLoadInterchangeCandidates: previewCandidates,
  onInsertInterchange: previewInsertNoop,
  onRemoveInterchange: previewIndexNoop,
  onMoveInterchange: previewMoveNoop,
  onSaveManual: previewNoop,
);

@Preview(
  name: 'Realtime map',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget realtimeMapPagePreview() => const RealtimeMapPage(
  transportMode: TransportMode.train,
  routeFilter: 'T1',
  showTileLayer: false,
);

@Preview(
  name: 'Stops map',
  group: 'Pages',
  size: Size(430, 850),
  wrapper: appPreviewWrapper,
)
Widget stopsMapPagePreview() => StopsMapWidget(
  transportMode: TransportMode.train,
  modeDisplayName: 'Train',
  onStopSelected: previewStopIdNoop,
  showTileLayer: false,
  skipInitialLoad: true,
  initialStops: previewMapStops,
);

@Preview(
  name: 'Debug entity screen',
  group: 'Pages',
  size: Size(500, 850),
  wrapper: appPreviewWrapper,
)
Widget debugEntityScreenPreview() => const DebugEntityScreen(
  args: DebugNavigationArgs(
    request: DebugEntityRequest(
      entityType: DebugEntityType.stop,
      entityId: '200060',
    ),
    loader: previewDebugLoader,
  ),
);
