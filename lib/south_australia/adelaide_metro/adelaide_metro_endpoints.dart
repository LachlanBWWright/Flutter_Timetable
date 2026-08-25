/// Adelaide Metro public GTFS and GTFS-Realtime endpoints.
///
/// Documentation: https://www.adelaidemetro.com.au/developer-info
const adelaideMetroStaticGtfsUrl =
    'https://gtfs.adelaidemetro.com.au/v1/static/latest/google_transit.zip';

const adelaideMetroRealtimeBase =
    'https://gtfs.adelaidemetro.com.au/v1/realtime';

const adelaideMetroVehiclePositionsUrl =
    '$adelaideMetroRealtimeBase/vehicle_positions';
const adelaideMetroTripUpdatesUrl = '$adelaideMetroRealtimeBase/trip_updates';
const adelaideMetroServiceAlertsUrl =
    '$adelaideMetroRealtimeBase/service_alerts';
