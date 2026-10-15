part of '../realtime_service_impl.dart';

class TripUpdateAggregationResult {
  final List<TripUpdate> tripUpdates;
  final Map<String, int> breakdown;
  final RealtimeSnapshotMetadata metadata;

  const TripUpdateAggregationResult({
    required this.tripUpdates,
    required this.breakdown,
    this.metadata = const RealtimeSnapshotMetadata(),
  });
}

class VehiclePositionAggregationResult {
  final List<VehiclePosition> vehicles;
  final Map<String, int> breakdown;
  final RealtimeSnapshotMetadata metadata;

  const VehiclePositionAggregationResult({
    required this.vehicles,
    required this.breakdown,
    this.metadata = const RealtimeSnapshotMetadata(),
  });
}
