import 'package:lbww_flutter/debug/builders/route_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/stop_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/trip_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/vehicle_debug_page_builder.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';

DebugEntityPageLoader buildDebugEntityPageLoader({
  DebugGtfsLoader? getGtfsDataForEndpoint,
  DebugVehicleAggregationLoader? getAllVehiclesAggregated,
  DebugTripUpdateAggregationLoader? getAllTripUpdatesAggregated,
  DebugDbStopLoader? getDbStopsById,
}) {
  final resolver = DebugEntityResolver(
    getGtfsDataForEndpoint: getGtfsDataForEndpoint,
    getAllVehiclesAggregated: getAllVehiclesAggregated,
    getAllTripUpdatesAggregated: getAllTripUpdatesAggregated,
    getDbStopsById: getDbStopsById,
  );
  final tripBuilder = TripDebugPageBuilder(resolver: resolver);
  final stopBuilder = StopDebugPageBuilder(resolver: resolver);
  final routeBuilder = RouteDebugPageBuilder(resolver: resolver);
  final vehicleBuilder = VehicleDebugPageBuilder(resolver: resolver);

  return (request) {
    switch (request.entityType) {
      case DebugEntityType.trip:
        return tripBuilder.build(request);
      case DebugEntityType.stop:
        return stopBuilder.build(request);
      case DebugEntityType.route:
        return routeBuilder.build(request);
      case DebugEntityType.vehicle:
        return vehicleBuilder.build(request);
    }
  };
}
