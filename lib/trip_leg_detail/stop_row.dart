part of '../trip_leg_detail_screen.dart';

class _VehicleStopRow {
  final String label;
  final String? stopId;
  final String? platform;
  final String? wheelchairAccess;
  final String? arrivalTimePlanned;
  final String? arrivalTimeEstimated;
  final String? departureTimePlanned;
  final String? departureTimeEstimated;
  final bool skipped;
  final bool cancelled;

  const _VehicleStopRow({
    required this.label,
    this.stopId,
    this.platform,
    this.wheelchairAccess,
    this.arrivalTimePlanned,
    this.arrivalTimeEstimated,
    this.departureTimePlanned,
    this.departureTimeEstimated,
    this.skipped = false,
    this.cancelled = false,
  });
}
