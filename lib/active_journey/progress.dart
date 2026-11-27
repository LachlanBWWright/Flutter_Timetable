import 'models.dart';

/// Progress uses absolute live sequences only, never cached-plan numbering.
class JourneyProgress {
  const JourneyProgress({
    this.nextStop,
    this.currentStop,
    this.stopsRemaining,
    this.arrived = false,
  });

  /// The next stop in the available pattern; feeds may omit other calls.
  final RunningStop? nextStop;
  final RunningStop? currentStop;

  /// Count of known non-skipped stops, not proof of a complete stop pattern.
  final int? stopsRemaining;
  final bool arrived;

  static JourneyProgress resolve(
    RunningService? service,
    ActiveJourneyMatch? selected, {
    required bool fresh,
  }) {
    if (!fresh || service == null) return const JourneyProgress();
    final vehicle = service.vehicle;
    final live = service.stops;
    final positions = live.where((stop) {
      final sequence = vehicle.currentStopSequence;
      if (sequence != null && stop.sequence != sequence) return false;
      final id = vehicle.currentStopId;
      if (id?.isNotEmpty == true && !stop.matches(id!)) return false;
      return sequence != null || id?.isNotEmpty == true;
    }).toList();
    if (positions.length != 1 || positions.single.skipped) {
      return const JourneyProgress();
    }
    final position = positions.single;
    // A cached leg can use local sequence numbers. A repeated station in the
    // live pattern cannot safely be mapped to that leg by station ID alone.
    if (selected != null &&
        live
                .where((s) => s.matches(position.id) || position.matches(s.id))
                .length !=
            1) {
      return const JourneyProgress();
    }
    final stops = selected?.stops ?? live;
    final indices = stops.indexed.where((entry) {
      final stop = entry.$2;
      return stop.matches(position.id) || position.matches(stop.id);
    }).toList();
    if (indices.length != 1) return const JourneyProgress();
    final index = indices.single.$1;
    final arrived =
        selected != null &&
        index == stops.length - 1 &&
        vehicle.atStop &&
        !stops.last.skipped;
    final nextIndex = vehicle.atStop ? index + 1 : index;
    final remaining = stops.skip(nextIndex).where((s) => !s.skipped).toList();
    return JourneyProgress(
      currentStop: vehicle.atStop ? stops[index] : null,
      nextStop: remaining.firstOrNull,
      stopsRemaining: selected == null ? null : remaining.length,
      arrived: arrived,
    );
  }
}
