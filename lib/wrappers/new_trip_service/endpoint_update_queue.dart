part of '../new_trip_service_impl.dart';

class _EndpointUpdateQueue {
  static Future<void Function()> acquire(StopsEndpoint endpoint) =>
      EndpointStaticUpdateQueue.acquire(endpoint);
}
