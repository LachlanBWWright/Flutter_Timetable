import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';

/// Utility class for transport mode colors and names
class TransportModeUtils {
  /// Get color for transport mode based on ID
  /// 1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus, 100 = walking
  static Color getModeColor(int id) {
    switch (id) {
      case 1:
        return TransportColors.train; // Train
      case 4:
        return TransportColors.lightRail; // Light Rail
      case 5:
      case 11:
        return TransportColors.bus; // Bus/School Bus
      case 7:
        return TransportColors.coach; // Coach
      case 9:
        return TransportColors.ferry; // Ferry
      default:
        return Colors.grey; // Default grey
    }
  }

  /// Get human-readable name for transport mode
  static String getModeName(int id) {
    switch (id) {
      case 1:
        return 'Train';
      case 4:
        return 'Light Rail';
      case 5:
        return 'Bus';
      case 11:
        return 'School Bus';
      case 7:
        return 'Coach';
      case 9:
        return 'Ferry';
      case 99:
      case 100:
        return 'Walk';
      default:
        return 'Mode $id';
    }
  }
}

/// Widget for displaying a single trip card
class TripCard extends StatefulWidget {
  final TripJourney trip;
  final void Function(Leg) onSelectLeg;

  const TripCard({super.key, required this.trip, required this.onSelectLeg});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> with TickerProviderStateMixin {
  bool _expanded = false;

  String _formatTimeDifference(String? planned, String? estimated) {
    if (planned == null || estimated == null) {
      return DateTimeUtils.parseTimeOnly(estimated ?? '');
    }
    try {
      final plannedTime = DateTimeUtils.parseTimeToDateTime(planned);
      final estimatedTime = DateTimeUtils.parseTimeToDateTime(estimated);

      if (plannedTime == null || estimatedTime == null) {
        return DateTimeUtils.parseTimeOnly(estimated);
      }

      final difference = estimatedTime.difference(plannedTime).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimated);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimated)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimated)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final legs = widget.trip.legs;
    if (legs.isEmpty) {
      return const Card(
        child: ListTile(
          title: Text('Unknown trip'),
          subtitle: Text('No legs available'),
        ),
      );
    }

    final firstLeg = legs.first;
    final lastLeg = legs.last;

    // Build sequential segments per-leg, inserting grey waiting segments between legs where applicable
    final segments = <Widget>[];
    for (var i = 0; i < legs.length; i++) {
      final l = legs[i];
      final transportClass = l.transportation?.product?.classField;
      // Convert leg duration (which is seconds in the API) to minutes so the visual
      // proportion between travel time and waiting time makes sense.
      final legDurationSeconds = l.duration ?? 0;
      final legDurationMinutes = legDurationSeconds > 0
          ? (legDurationSeconds / 60).ceil()
          : 1;
      final color = transportClass != null
          ? TransportModeUtils.getModeColor(transportClass)
          : Colors.grey;
      segments.add(
        Expanded(
          flex: legDurationMinutes,
          child: Container(height: 6, color: color),
        ),
      );

      // If there's a next leg, compute waiting time (in minutes) and add a grey segment if > 0
      if (i < legs.length - 1) {
        final curDest = l.destination;
        final nextOrigin = legs[i + 1].origin;
        final curArrival =
            curDest.arrivalTimeEstimated ?? curDest.arrivalTimePlanned;
        final nextDeparture =
            nextOrigin.departureTimeEstimated ??
            nextOrigin.departureTimePlanned;
        final a = curArrival != null
            ? DateTimeUtils.parseTimeToDateTime(curArrival)
            : null;
        final b = nextDeparture != null
            ? DateTimeUtils.parseTimeToDateTime(nextDeparture)
            : null;
        if (a != null && b != null) {
          final diffMinutes = b.difference(a).inMinutes;
          if (diffMinutes > 0) {
            final waitFlex = diffMinutes < 1
                ? 1
                : (diffMinutes > 60 ? 60 : diffMinutes);
            segments.add(
              Expanded(
                flex: waitFlex,
                child: Container(height: 8, color: Colors.grey.shade700),
              ),
            );
          }
        }
      }
    }

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: single-leg trips navigate directly; multi-leg trips expand/collapse
          InkWell(
            onTap: () {
              if (legs.length == 1) {
                widget.onSelectLeg(legs.first);
              } else {
                setState(() => _expanded = !_expanded);
              }
            },
            child: ListTile(
              title: Text(
                '${firstLeg.origin.disassembledName} to ${lastLeg.destination.disassembledName}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatTimeDifference(
                          firstLeg.origin.departureTimePlanned,
                          firstLeg.origin.departureTimeEstimated,
                        ),
                      ),
                      const Text(' - '),
                      Text(
                        _formatTimeDifference(
                          lastLeg.destination.arrivalTimePlanned,
                          lastLeg.destination.arrivalTimeEstimated,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: AnimatedRotation(
                turns: _expanded ? 0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.chevron_right, size: 28),
              ),
            ),
          ),

          // Expanded legs list (multileg trips)
          if (_expanded && legs.length > 1) ...[
            const Divider(height: 1),
            for (final leg in legs)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0.0,
                ),
                title: Text(
                  '${leg.origin.disassembledName} → ${leg.destination.disassembledName}',
                ),
                dense: true,
                trailing: const Padding(
                  padding: EdgeInsets.only(right: 24.0),
                  child: Icon(Icons.chevron_right, size: 20),
                ),
                onTap: () => widget.onSelectLeg(leg),
              ),
            const Divider(height: 1),
          ],
          SizedBox(
            height: 6,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Row(
                children: segments.isNotEmpty
                    ? segments
                    : [Expanded(child: Container(color: Colors.grey))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
