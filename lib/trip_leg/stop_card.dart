part of '../trip_leg_screen.dart';

class _TripLegStopCard extends StatelessWidget {
  const _TripLegStopCard({
    required this.stop,
    required this.index,
    required this.currentVehicle,
  });

  final Map<String, dynamic> stop;
  final int index;
  final VehiclePosition? currentVehicle;

  @override
  Widget build(BuildContext context) {
    final stopName =
        tryReadStringValue(stop, 'disassembledName') ??
        tryReadStringValue(stop, 'name') ??
        'Unknown Stop';
    final departureTimePlanned = tryReadStringValue(
      stop,
      'departureTimePlanned',
    );
    final departureTimeEstimated = tryReadStringValue(
      stop,
      'departureTimeEstimated',
    );
    final arrivalTimePlanned = tryReadStringValue(stop, 'arrivalTimePlanned');
    final arrivalTimeEstimated = tryReadStringValue(
      stop,
      'arrivalTimeEstimated',
    );

    // Check if this stop is where the vehicle currently is
    bool isCurrentStop = false;
    final currentVehicle = this.currentVehicle;
    if (currentVehicle != null) {
      final currentStopSequence = currentVehicle.currentStopSequence;
      if (currentStopSequence > 0 && currentStopSequence == index + 1) {
        isCurrentStop = true;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isCurrentStop ? Colors.orange.withValues(alpha: .1) : null,
        border: isCurrentStop
            ? Border.all(color: Colors.orange, width: 2)
            : Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentStop ? Colors.orange : Colors.grey,
          foregroundColor: getContrastingForeground(
            isCurrentStop ? Colors.orange : Colors.grey,
          ),
          child: Text('${index + 1}'),
        ),
        title: Text(
          stopName,
          style: TextStyle(
            fontWeight: isCurrentStop ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (departureTimePlanned != null || departureTimeEstimated != null)
              Row(
                children: [
                  const Icon(
                    Icons.departure_board,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Depart: ${formatTimeDifference(departureTimePlanned, departureTimeEstimated)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            if (arrivalTimePlanned != null || arrivalTimeEstimated != null)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Arrive: ${formatTimeDifference(arrivalTimePlanned, arrivalTimeEstimated)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        trailing: isCurrentStop
            ? const Icon(Icons.directions_bus, color: Colors.orange)
            : null,
      ),
    );
  }
}
