part of '../new_trip_service_impl.dart';

class _GtfsEndpointFetcher {
  static Future<GtfsData?> fetchGtfsDataForEndpoint(
    StopsEndpoint endpoint, {
    bool force = false,
    TransitCancellation? cancellation,
  }) =>
      fetchStaticGtfsSource(endpoint, force: force, cancellation: cancellation);
}
