part of '../new_trip_service_impl.dart';

class _GtfsEndpointFetcher {
  static Future<GtfsData?> fetchGtfsDataForEndpoint(StopsEndpoint endpoint) =>
      endpoint.fetchGtfsData();
}
