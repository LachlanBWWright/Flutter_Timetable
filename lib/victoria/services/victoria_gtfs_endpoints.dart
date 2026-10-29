/// Official Transport Victoria GTFS Schedule and GTFS-Realtime endpoints.
///
/// Documentation: https://opendata.transport.vic.gov.au/dataset/gtfs-realtime
const victoriaStaticGtfsUrl =
    'https://opendata.transport.vic.gov.au/dataset/'
    '3f4e292e-7f8a-4ffe-831f-1953be0fe448/resource/'
    'fb152201-859f-4882-9206-b768060b50ad/download/gtfs.zip';

class VictoriaRealtimeFeedSet {
  const VictoriaRealtimeFeedSet({
    required this.id,
    required this.label,
    required this.tripUpdatesUrl,
    required this.vehiclePositionsUrl,
    this.alertsUrl,
  });

  final String id;
  final String label;
  final String tripUpdatesUrl;
  final String vehiclePositionsUrl;
  final String? alertsUrl;
}

const _victoriaRealtimeBase =
    'https://api.opendata.transport.vic.gov.au/opendata/'
    'public-transport/gtfs/realtime/v1';

const victoriaRealtimeFeedSets = <VictoriaRealtimeFeedSet>[
  VictoriaRealtimeFeedSet(
    id: 'metro',
    label: 'Metro Train',
    tripUpdatesUrl: '$_victoriaRealtimeBase/metro/trip-updates',
    vehiclePositionsUrl: '$_victoriaRealtimeBase/metro/vehicle-positions/',
    alertsUrl: '$_victoriaRealtimeBase/metro/service-alerts/',
  ),
  VictoriaRealtimeFeedSet(
    id: 'tram',
    label: 'Yarra Trams',
    tripUpdatesUrl: '$_victoriaRealtimeBase/tram/trip-updates/',
    vehiclePositionsUrl: '$_victoriaRealtimeBase/tram/vehicle-positions/',
    alertsUrl: '$_victoriaRealtimeBase/tram/service-alerts/',
  ),
  VictoriaRealtimeFeedSet(
    id: 'bus',
    label: 'Metro and regional bus',
    tripUpdatesUrl: '$_victoriaRealtimeBase/bus/trip-updates/',
    vehiclePositionsUrl: '$_victoriaRealtimeBase/bus/vehicle-positions',
  ),
  VictoriaRealtimeFeedSet(
    id: 'vline',
    label: 'V/Line regional train',
    tripUpdatesUrl: '$_victoriaRealtimeBase/vline/trip-updates',
    vehiclePositionsUrl: '$_victoriaRealtimeBase/vline/vehicle-positions',
  ),
];

VictoriaRealtimeFeedSet? victoriaRealtimeFeedSetById(String id) {
  for (final feed in victoriaRealtimeFeedSets) {
    if (feed.id == id) return feed;
  }
  return null;
}
