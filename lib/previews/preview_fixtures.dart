import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

Widget appPreviewWrapper(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
  darkTheme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
    useMaterial3: true,
  ),
  home: child,
);

void previewNoop() {}
void previewStationNoop(Station station) {}
void previewJourneyNoop(Journey journey) {}
void previewJourneyIdNoop(int id) {}
void previewJourneyPinNoop(int id, bool pinned) {}
void previewIndexNoop(int index) {}
void previewMoveNoop(int index, int delta) {}
void previewInsertNoop(int index, Station station) {}
void previewStopIdNoop(String name, String id) {}
void previewBoolNoop(bool value) {}
Future<int> previewStopsCount() async => 12480;
Future<Map<TransportMode?, Map<String, int>>> previewEndpointCounts() async =>
    const {
      TransportMode.train: {'sydneytrains': 178},
      TransportMode.metro: {'metro': 46},
      TransportMode.bus: {'buses': 12140},
      TransportMode.ferry: {'ferries': 56},
      TransportMode.lightrail: {'lightrail': 60},
    };
Future<List<Station>> previewCandidates(int index) async => const [
  previewMuseum,
  previewTownHall,
];

const previewCentral = Station(
  name: 'Central Station',
  id: '200060',
  mode: TransportMode.train,
  platformCode: 'Platform 1',
  latitude: -33.8831,
  longitude: 151.2065,
  distance: 420,
);

const previewTownHall = Station(
  name: 'Town Hall Station',
  id: '200070',
  mode: TransportMode.train,
  platformCode: 'Platform 4',
  latitude: -33.8732,
  longitude: 151.2069,
  distance: 1150,
);

const previewMuseum = Station(
  name: 'Museum Station',
  id: '200050',
  mode: TransportMode.train,
  latitude: -33.8759,
  longitude: 151.2093,
  distance: 830,
);

const previewWynyard = Station(
  name: 'Wynyard Station',
  id: '200ಣಿ',
  mode: TransportMode.train,
  platformCode: 'Platform 2',
  latitude: -33.8658,
  longitude: 151.2053,
  distance: 1700,
);

const previewMartinPlace = Station(
  name: 'Martin Place Station',
  id: '200011',
  mode: TransportMode.train,
  platformCode: 'Platform 1',
  latitude: -33.8675,
  longitude: 151.2088,
  distance: 2100,
);

const previewStations = [
  previewCentral,
  previewMuseum,
  previewTownHall,
  previewWynyard,
  previewMartinPlace,
];

gtfs.Stop previewStop(String id, String name, double lat, double lon) =>
    gtfs.Stop(
      stopId: id,
      stopName: name,
      stopLat: lat,
      stopLon: lon,
      locationType: 0,
      wheelchairBoarding: 1,
    );

final previewMapStops = [
  previewStop('200060', 'Central Station', -33.8831, 151.2065),
  previewStop('200050', 'Museum Station', -33.8759, 151.2093),
  previewStop('200070', 'Town Hall Station', -33.8732, 151.2069),
];

const previewJourney = Journey(
  id: 1,
  origin: 'Central Station',
  originId: '200060',
  destination: 'Town Hall Station',
  destinationId: '200070',
  tripType: 'direct',
  mode: 'train',
  lineId: 'T1',
  lineName: 'T1 North Shore & Western Line',
  isPinned: true,
);

const previewSecondJourney = Journey(
  id: 2,
  origin: 'Wynyard Station',
  originId: '200080',
  destination: 'Martin Place Station',
  destinationId: '200011',
  tripType: 'direct',
  mode: 'train',
  lineId: 'T4',
  lineName: 'Eastern Suburbs & Illawarra Line',
  isPinned: false,
);

final previewTripJourney = TripJourney.fromJson({
  'isAdditional': false,
  'rating': 1,
  'legs': [
    {
      'origin': {
        'id': '200060',
        'name': 'Central Station',
        'coord': [-33.8831, 151.2065],
        'departureTimePlanned': '2026-08-13T10:00:00+10:00',
        'departureTimeEstimated': '2026-08-13T10:02:00+10:00',
      },
      'destination': {
        'id': '200070',
        'name': 'Town Hall Station',
        'coord': [-33.8732, 151.2069],
        'arrivalTimePlanned': '2026-08-13T10:06:00+10:00',
        'arrivalTimeEstimated': '2026-08-13T10:08:00+10:00',
      },
      'duration': 480,
      'distance': 1900,
      'transportation': {
        'id': 'T1',
        'name': 'T1 North Shore & Western Line',
        'number': 'T1',
        'product': {'name': 'Train'},
        'destination': {'name': 'Hornsby'},
      },
    },
  ],
});

Leg get previewLeg => previewTripJourney.legs.first;

const previewDebugPage = DebugPageData(
  title: 'Central Station',
  entityType: DebugEntityType.stop,
  canonicalId: '200060',
  aliases: ['Central', 'Sydney Terminal'],
  sourceBadges: [DebugDataSource.api, DebugDataSource.gtfs],
  banners: [
    DebugStatusBannerData(
      message: 'Realtime and GTFS records matched successfully.',
      tone: DebugStatusTone.info,
    ),
  ],
  sections: [
    DebugSectionData(
      title: 'Identity',
      fields: [
        DebugFieldRow(label: 'Stop ID', value: '200060'),
        DebugFieldRow(label: 'Mode', value: 'Train'),
        DebugFieldRow(label: 'Endpoint', value: 'sydneytrains'),
      ],
    ),
  ],
);
