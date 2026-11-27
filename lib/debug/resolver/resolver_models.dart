import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

typedef DebugGtfsLoader = Future<GtfsData?> Function(StopsEndpoint endpoint);
typedef DebugVehicleAggregationLoader =
    Future<VehiclePositionAggregationResult?> Function();
typedef DebugTripUpdateAggregationLoader =
    Future<TripUpdateAggregationResult?> Function();
typedef DebugDbStopLoader = Future<List<db.Stop>> Function(String stopId);
typedef DebugEndpointForMode =
    Iterable<StopsEndpoint> Function(TransportMode mode);

class DebugResolvedGtfsRoute {
  final gtfs_route.Route route;
  final gtfs_agency.Agency? agency;
  final GtfsData? data;
  final StopsEndpoint? endpoint;
  final String matchReason;

  const DebugResolvedGtfsRoute({
    required this.route,
    this.agency,
    this.data,
    this.endpoint,
    required this.matchReason,
  });
}

class DebugResolvedGtfsStop {
  final gtfs_stop.Stop stop;
  final GtfsData? data;
  final StopsEndpoint? endpoint;

  const DebugResolvedGtfsStop({required this.stop, this.data, this.endpoint});
}

class DebugDerivedVehicleStops {
  final TripUpdate_StopTimeUpdate? currentStop;
  final TripUpdate_StopTimeUpdate? nextStop;
  final TripUpdate? matchedTripUpdate;
  final List<TripUpdate> candidateTripUpdates;
  final String reason;

  const DebugDerivedVehicleStops({
    this.currentStop,
    this.nextStop,
    this.matchedTripUpdate,
    this.candidateTripUpdates = const <TripUpdate>[],
    this.reason = 'No stop derivation context available.',
  });
}

class DebugSourceResult<T> {
  final T? value;
  final DebugDataSource source;
  final Object? error;
  final StackTrace? stackTrace;

  const DebugSourceResult({
    required this.value,
    required this.source,
    this.error,
    this.stackTrace,
  });

  bool get hasError => error != null;
}
