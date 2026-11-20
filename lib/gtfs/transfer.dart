import 'csv_field_reader.dart';

class GtfsTransfer {
  const GtfsTransfer({
    required this.fromStopId,
    required this.toStopId,
    this.type = 0,
    this.minimumSeconds,
    this.fromRouteId,
    this.toRouteId,
    this.fromTripId,
    this.toTripId,
  });
  final String fromStopId, toStopId;
  final int type;
  final int? minimumSeconds;
  final String? fromRouteId, toRouteId, fromTripId, toTripId;
  factory GtfsTransfer.fromCsv(List<String> header, List<String> row) {
    final r = CsvFieldReader(header, row);
    return GtfsTransfer(
      fromStopId: r.fieldOrEmpty('from_stop_id'),
      toStopId: r.fieldOrEmpty('to_stop_id'),
      type: r.intField('transfer_type'),
      minimumSeconds: int.tryParse(r.fieldOrEmpty('min_transfer_time')),
      fromRouteId: r.fieldOrNull('from_route_id'),
      toRouteId: r.fieldOrNull('to_route_id'),
      fromTripId: r.fieldOrNull('from_trip_id'),
      toTripId: r.fieldOrNull('to_trip_id'),
    );
  }
  bool get isQualified =>
      fromRouteId != null ||
      toRouteId != null ||
      fromTripId != null ||
      toTripId != null;
}
