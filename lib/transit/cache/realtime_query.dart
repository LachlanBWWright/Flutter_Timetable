import 'dart:convert';

/// Candidate filtering only. Service-date and ambiguity matching still runs
/// locally; a route may contain several instances of the same trip.
class RealtimeQuery {
  RealtimeQuery({
    Iterable<String> tripIds = const [],
    this.routeId,
    this.vehicleId,
    this.bounds,
  }) : tripIds = List.unmodifiable(
         tripIds.where((id) => id.isNotEmpty).toSet().toList()..sort(),
       );

  final List<String> tripIds;
  final String? routeId;
  final String? vehicleId;

  /// [south, west, north, east]; west > east crosses the antimeridian.
  final List<double>? bounds;
  bool get isEmpty =>
      tripIds.isEmpty &&
      (routeId == null || routeId!.isEmpty) &&
      (vehicleId == null || vehicleId!.isEmpty) &&
      bounds == null;
  Map<String, Object> toJson() => {
    if (tripIds.isNotEmpty) 'tripIds': tripIds,
    if (vehicleId != null && vehicleId!.isNotEmpty) 'vehicleId': vehicleId!,
    if (bounds != null) 'bounds': bounds!,
    if (routeId != null && routeId!.isNotEmpty) 'routeId': routeId!,
  };
  String get cacheKey => jsonEncode(toJson());
}
