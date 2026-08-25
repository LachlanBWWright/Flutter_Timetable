import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/widgets/debug_entity_page.dart';
import 'package:lbww_flutter/debug/widgets/debug_raw_json_card.dart';
import 'package:lbww_flutter/debug/widgets/debug_section_card.dart';
import 'package:lbww_flutter/debug/widgets/debug_status_banner.dart';
import 'package:lbww_flutter/previews/preview_fixtures.dart';
import 'package:lbww_flutter/widgets/interchange_stop_selection_screen.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/widgets/stops_widgets.dart';
import 'package:lbww_flutter/widgets/travel_warning_card.dart';
import 'package:lbww_flutter/widgets/trip_leg_card.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart';

@Preview(
  name: 'Station row — distance',
  group: 'Stations',
  size: Size(430, 110),
  wrapper: appPreviewWrapper,
)
Widget stationRowPreview() => const Scaffold(
  body: StationView(
    station: previewCentral,
    setStation: previewStationNoop,
    sortMode: SortMode.distance,
    mode: TransportMode.train,
  ),
);

@Preview(
  name: 'Station list',
  group: 'Stations',
  size: Size(430, 500),
  wrapper: appPreviewWrapper,
)
Widget stationListPreview() => const Scaffold(
  body: EnhancedStationList(
    listItems: [previewCentral, previewMuseum, previewTownHall],
    setStation: previewStationNoop,
    sortMode: SortMode.alphabetical,
    mode: TransportMode.train,
  ),
);

@Preview(
  name: 'Journey card',
  group: 'Journeys',
  size: Size(430, 190),
  wrapper: appPreviewWrapper,
)
@Preview(
  name: 'Journey card — dark',
  group: 'Journeys',
  size: Size(430, 190),
  brightness: Brightness.dark,
  wrapper: appPreviewWrapper,
)
Widget journeyCardPreview() => const Scaffold(
  body: Padding(
    padding: EdgeInsets.all(12),
    child: JourneyCard(
      journey: previewJourney,
      onTap: previewNoop,
      onReverseTap: previewNoop,
      onDelete: previewNoop,
      onTogglePin: previewNoop,
      isEditingMode: true,
    ),
  ),
);

@Preview(
  name: 'Journey list',
  group: 'Journeys',
  size: Size(430, 600),
  wrapper: appPreviewWrapper,
)
Widget journeyListPreview() => const Scaffold(
  body: JourneyList(
    journeys: [previewJourney],
    onJourneyTap: previewJourneyNoop,
    onReverseJourneyTap: previewJourneyNoop,
    onDeleteJourney: previewJourneyIdNoop,
    onTogglePin: previewJourneyPinNoop,
    isEditingMode: false,
    isPinnedSection: true,
  ),
);

@Preview(
  name: 'Trip result card',
  group: 'Journeys',
  size: Size(430, 520),
  wrapper: appPreviewWrapper,
)
Widget tripCardPreview() => Scaffold(
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: TripCard(trip: previewTripJourney, onSelectLeg: (_) {}),
  ),
);

@Preview(
  name: 'Trip leg card',
  group: 'Journeys',
  size: Size(430, 440),
  wrapper: appPreviewWrapper,
)
Widget tripLegCardPreview() => Scaffold(
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: TripLegCard(leg: previewLeg, trip: previewTripJourney),
  ),
);

@Preview(
  name: 'Selected stops summary',
  group: 'Trip creation',
  size: Size(430, 250),
  wrapper: appPreviewWrapper,
)
Widget selectedStopsSummaryPreview() => const Scaffold(
  body: SelectedStopsSummaryBar(
    origin: previewCentral,
    destination: previewTownHall,
    currentMode: TransportMode.train,
    originMode: TransportMode.train,
    destinationMode: TransportMode.train,
    selectedLine: null,
    isLoadingLineCandidates: false,
    originLineCount: 3,
    statusMessage: 'Ready to save this trip.',
    onClearOrigin: previewNoop,
    onClearDestination: previewNoop,
    onSaveDirect: previewNoop,
    onOpenComposer: previewNoop,
    canSaveDirect: true,
    canComposeManual: true,
  ),
);

@Preview(
  name: 'Selected stops — multi-leg',
  group: 'Trip creation',
  size: Size(500, 650),
  wrapper: appPreviewWrapper,
)
Widget selectedStopsPreview() => const Scaffold(
  body: Align(
    alignment: Alignment.bottomCenter,
    child: SelectedStopsWidget(
      origin: previewCentral,
      destination: previewTownHall,
      currentMode: TransportMode.train,
      originMode: TransportMode.train,
      destinationMode: TransportMode.train,
      isLoadingLineCandidates: false,
      originLineCandidates: [],
      isSameLineFilterEnabled: true,
      onSameLineFilterChanged: previewBoolNoop,
      selectedLine: null,
      interchanges: [previewMuseum],
      isResolvingSharedLines: false,
      isManualBuilderEnabled: true,
      pendingInterchangeInsertIndex: null,
      statusMessage: 'One interchange selected.',
      manualValidationMessage: null,
      onClearOrigin: previewNoop,
      onClearDestination: previewNoop,
      onSaveDirect: previewNoop,
      onSaveManual: previewNoop,
      onAddInterchange: previewIndexNoop,
      onRemoveInterchange: previewIndexNoop,
      onMoveInterchange: previewMoveNoop,
      canSaveDirect: true,
      canSaveManual: true,
    ),
  ),
);

@Preview(
  name: 'Stops management',
  group: 'Data management',
  size: Size(500, 700),
  wrapper: appPreviewWrapper,
)
Widget stopsManagementPreview() => const Scaffold(
  body: SingleChildScrollView(
    child: StopsManagementWidget(
      getTotalStopsCount: previewStopsCount,
      getStopsCountByEndpoint: previewEndpointCounts,
    ),
  ),
);

@Preview(
  name: 'Stops search',
  group: 'Data management',
  size: Size(500, 500),
  wrapper: appPreviewWrapper,
)
Widget stopsSearchPreview() => const Scaffold(body: StopsSearchWidget());

@Preview(
  name: 'Interchange selector',
  group: 'Trip creation',
  size: Size(430, 700),
  wrapper: appPreviewWrapper,
)
Widget interchangeSelectorPreview() => InterchangeStopSelectionScreen(
  insertIndex: 0,
  contextLabel: 'Between Central and Town Hall',
  currentMode: TransportMode.train,
  candidatesFuture: Future.value(const [previewMuseum, previewTownHall]),
);

@Preview(
  name: 'Travel warning',
  group: 'Feedback',
  size: Size(430, 240),
  wrapper: appPreviewWrapper,
)
Widget travelWarningPreview() => const Scaffold(
  body: Padding(
    padding: EdgeInsets.all(12),
    child: TravelWarningCard(
      title: 'Planned trackwork',
      children: [
        SizedBox(height: 8),
        Text('Buses replace trains between Central and Bondi Junction.'),
      ],
    ),
  ),
);

@Preview(
  name: 'Debug entity page',
  group: 'Debug tools',
  size: Size(500, 760),
  wrapper: appPreviewWrapper,
)
Widget debugEntityPagePreview() => Scaffold(
  appBar: AppBar(title: const Text('Stop Debug')),
  body: const DebugEntityPage(pageData: previewDebugPage),
);

@Preview(
  name: 'Debug components',
  group: 'Debug tools',
  size: Size(500, 700),
  wrapper: appPreviewWrapper,
)
Widget debugComponentsPreview() => const Scaffold(
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        DebugStatusBanner(
          banner: DebugStatusBannerData(
            tone: DebugStatusTone.warning,
            title: 'Partial match',
            message: 'Realtime route metadata is not available.',
          ),
        ),
        SizedBox(height: 12),
        DebugSectionCard(
          title: 'Provider identity',
          child: Text('PTV • route 96 • tram'),
        ),
        SizedBox(height: 12),
        DebugRawJsonCard(
          block: DebugJsonBlock(
            title: 'Raw payload',
            data: {'route_id': '96', 'status': 'active'},
          ),
        ),
      ],
    ),
  ),
);
