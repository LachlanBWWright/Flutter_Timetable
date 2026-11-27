import 'csv_field_reader.dart';

class GtfsPathway {
  const GtfsPathway({
    required this.id,
    required this.fromStopId,
    required this.toStopId,
    required this.mode,
    required this.bidirectional,
    this.seconds,
    this.length,
    this.estimated = false,
    this.accessibilityKnown = true,
  });
  final String id, fromStopId, toStopId;
  final bool estimated, accessibilityKnown;
  final int mode;
  final bool bidirectional;
  final int? seconds;
  final double? length;
  bool get stepFree =>
      accessibilityKnown && const [1, 3, 5, 6, 7].contains(mode);
  int get traversalSeconds =>
      seconds ?? (length == null ? 60 : (length! / 1.2).ceil());
  factory GtfsPathway.fromCsv(List<String> header, List<String> row) {
    final r = CsvFieldReader(header, row);
    if (!['0', '1'].contains(r.fieldOrEmpty('is_bidirectional'))) {
      throw const FormatException('Invalid pathway direction');
    }
    return GtfsPathway(
      id: r.fieldOrEmpty('pathway_id'),
      fromStopId: r.fieldOrEmpty('from_stop_id'),
      toStopId: r.fieldOrEmpty('to_stop_id'),
      mode: r.intField('pathway_mode', defaultValue: -1),
      bidirectional: r.fieldOrEmpty('is_bidirectional') == '1',
      seconds: int.tryParse(r.fieldOrEmpty('traversal_time')),
      length: double.tryParse(r.fieldOrEmpty('length')),
    );
  }
}
