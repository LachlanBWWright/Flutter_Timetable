// Official provider URLs mirrored by backend/functions/src/provider-sources.json.
// Keep the catalog contract test passing when changing an endpoint.
const sharedProviderSources = <String, String>{
  'https://gtfsrt.api.translink.com.au/GTFS/SEQ_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/BOW_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/BUN_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/CNS_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/GLT_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/GYM_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/INN_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/KIL_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/MKY_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/MAG_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/MIF_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/MAL_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/MHB_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/NSI_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/RKY_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/TWB_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/TSV_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/WAR_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/GTFS/WHT_GTFS.zip': 'static',
  'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/TripUpdates':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/VehiclePositions':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/Alerts': 'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/BOW/TripUpdates':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/BOW/VehiclePositions':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/BOW/Alerts': 'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/CNS/TripUpdates':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/CNS/VehiclePositions':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/CNS/Alerts': 'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/NSI/TripUpdates':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/NSI/VehiclePositions':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/NSI/Alerts': 'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/MHB/TripUpdates':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/MHB/VehiclePositions':
      'realtime',
  'https://gtfsrt.api.translink.com.au/api/realtime/MHB/Alerts': 'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/metro/trip-updates':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/metro/vehicle-positions/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/metro/service-alerts/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/tram/trip-updates/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/tram/vehicle-positions/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/tram/service-alerts/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/bus/trip-updates/':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/bus/vehicle-positions':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/vline/trip-updates':
      'realtime',
  'https://api.opendata.transport.vic.gov.au/opendata/public-transport/gtfs/realtime/v1/vline/vehicle-positions':
      'realtime',
  'https://opendata.transport.vic.gov.au/dataset/3f4e292e-7f8a-4ffe-831f-1953be0fe448/resource/fb152201-859f-4882-9206-b768060b50ad/download/gtfs.zip':
      'static',
  'https://gtfs.adelaidemetro.com.au/v1/static/latest/google_transit.zip':
      'static',
  'https://gtfs.adelaidemetro.com.au/v1/realtime/vehicle_positions': 'realtime',
  'https://gtfs.adelaidemetro.com.au/v1/realtime/trip_updates': 'realtime',
  'https://gtfs.adelaidemetro.com.au/v1/realtime/service_alerts': 'realtime',
  'https://www.transport.tas.gov.au/__data/assets/file/0011/557615/tas_gtfs.zip':
      'static',
  'https://dli.nt.gov.au/data-feeds/bus-gtfs/google-transit-darwin.zip?v=0.38.2':
      'static',
  'https://dli.nt.gov.au/data-feeds/bus-gtfs/google-transit-alice.zip?v=0.14.0':
      'static',
  'https://www.transperth.wa.gov.au/LinkClick.aspx?link=%2FTimetablePDFs%2FGoogleTransit%2FProduction%2Fgoogle_transit.zip&mid=1470&portalid=0&tabid=267':
      'static',
};
