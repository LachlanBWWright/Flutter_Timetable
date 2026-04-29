import 'package:lbww_flutter/debug/builders/route_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/stop_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/trip_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/vehicle_debug_page_builder.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

class DebugPageLoaderCoordinator {
  final DebugEntityResolver resolver;

  late final TripDebugPageBuilder _tripBuilder = TripDebugPageBuilder(
    resolver: resolver,
  );
  late final StopDebugPageBuilder _stopBuilder = StopDebugPageBuilder(
    resolver: resolver,
  );
  late final RouteDebugPageBuilder _routeBuilder = RouteDebugPageBuilder(
    resolver: resolver,
  );
  late final VehicleDebugPageBuilder _vehicleBuilder = VehicleDebugPageBuilder(
    resolver: resolver,
  );

  DebugPageLoaderCoordinator({required this.resolver});

  Future<DebugPageData> load(DebugEntityRequest request) {
    switch (request.entityType) {
      case DebugEntityType.trip:
        return _tripBuilder.build(request);
      case DebugEntityType.stop:
        return _stopBuilder.build(request);
      case DebugEntityType.route:
        return _routeBuilder.build(request);
      case DebugEntityType.vehicle:
        return _vehicleBuilder.build(request);
    }
  }
}

DebugEntityPageLoader buildDebugEntityPageLoader({
  Future<GtfsData?> Function(StopsEndpoint endpoint)? getGtfsDataForEndpoint,
  Future<VehiclePositionAggregationResult> Function()? getAllVehiclesAggregated,
  Future<TripUpdateAggregationResult> Function()? getAllTripUpdatesAggregated,
  Future<List<db.Stop>> Function(String stopId)? getDbStopsById,
}) {
  final resolver = DebugEntityResolver(
    getGtfsDataForEndpoint: getGtfsDataForEndpoint,
    getAllVehiclesAggregated: getAllVehiclesAggregated,
    getAllTripUpdatesAggregated: getAllTripUpdatesAggregated,
    getDbStopsById: getDbStopsById,
  );
  final coordinator = DebugPageLoaderCoordinator(resolver: resolver);
  return coordinator.load;
}
