/// The age and availability of the schedule used to produce a result.
class TimetableProvenance {
  const TimetableProvenance({
    required this.fetchedAt,
    required this.isStale,
    this.offlineFallback = false,
  });

  final DateTime fetchedAt;
  final bool isStale;
  final bool offlineFallback;

  Map<String, Object> toJson() => {
    'fetchedAt': fetchedAt.toIso8601String(),
    'isStale': isStale,
    'offlineFallback': offlineFallback,
  };

  static TimetableProvenance? tryParse(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final date = DateTime.tryParse(value['fetchedAt']?.toString() ?? '');
    if (date == null) return null;
    return TimetableProvenance(
      fetchedAt: date,
      isStale: value['isStale'] == true,
      offlineFallback: value['offlineFallback'] == true,
    );
  }

  String get description {
    final date = fetchedAt.toLocal().toString().substring(0, 16);
    final prefix = offlineFallback
        ? 'Offline timetable'
        : isStale
        ? 'Older timetable'
        : 'Scheduled timetable';
    return '$prefix · downloaded $date';
  }
}
