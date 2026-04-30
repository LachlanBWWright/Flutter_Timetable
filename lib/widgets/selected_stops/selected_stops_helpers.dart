import '../../constants/transport_modes.dart';
import '../../services/new_trip_service.dart';
import '../../services/trip_line_service.dart';
import '../station_widgets.dart';

enum SequenceStopKind { origin, interchange, destination }

class SequenceStopDescriptor {
  const SequenceStopDescriptor({
    required this.stop,
    required this.kind,
    required this.insertIndex,
    required this.interchangeIndex,
    required this.canMoveUp,
    required this.canMoveDown,
  });

  final Station stop;
  final SequenceStopKind kind;
  final int insertIndex;
  final int? interchangeIndex;
  final bool canMoveUp;
  final bool canMoveDown;

  String get kindLabel {
    switch (kind) {
      case SequenceStopKind.origin:
        return 'Origin';
      case SequenceStopKind.destination:
        return 'Destination';
      case SequenceStopKind.interchange:
        final index = interchangeIndex;
        final displayIndex = index == null ? 1 : index + 1;
        return 'Interchange $displayIndex';
    }
  }

  bool get isInterchange => kind == SequenceStopKind.interchange;
}

TransportMode resolveAccentMode({
  required TransportMode fallbackMode,
  required StopLineMatch? selectedLine,
}) {
  return selectedLine?.mode ?? fallbackMode;
}

List<Station> buildOrderedStops({
  required Station? origin,
  required Station? destination,
  required List<Station> interchanges,
}) {
  if (origin == null || destination == null) {
    return const [];
  }

  return NewTripService.buildOrderedTripStops(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
  );
}

List<SequenceStopDescriptor> buildSequenceDescriptors({
  required List<Station> orderedStops,
  required int interchangeCount,
}) {
  if (orderedStops.isEmpty) {
    return const [];
  }

  final descriptors = <SequenceStopDescriptor>[];
  for (var index = 0; index < orderedStops.length; index++) {
    final stop = orderedStops[index];
    final isOrigin = index == 0;
    final isDestination = index == orderedStops.length - 1;
    final interchangeIndex = index - 1;
    final kind = isOrigin
        ? SequenceStopKind.origin
        : isDestination
        ? SequenceStopKind.destination
        : SequenceStopKind.interchange;

    descriptors.add(
      SequenceStopDescriptor(
        stop: stop,
        kind: kind,
        insertIndex: index + 1,
        interchangeIndex: kind == SequenceStopKind.interchange
            ? interchangeIndex
            : null,
        canMoveUp: interchangeIndex > 0,
        canMoveDown:
            interchangeIndex >= 0 && interchangeIndex < interchangeCount - 1,
      ),
    );
  }

  return descriptors;
}
