// ignore_for_file: catch_unknown_dynamic_calls

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/trip_leg_detail_utils.dart';

/// Utility class for transport mode colors and names
class TransportModeUtils {
  /// Get color for transport mode based on ID
  /// 1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus, 100 = walking
  static Color getModeColor(int id) {
    switch (id) {
      case 1:
        return TransportColors.train; // Train
      case 2:
        return TransportColors.metro; // Metro
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
      case 2:
        return 'Metro';
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
  final void Function(TripJourney)? onVisible;

  const TripCard({
    super.key,
    required this.trip,
    required this.onSelectLeg,
    this.onVisible,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard>
    with TickerProviderStateMixin, GuardedState<TripCard> {
  bool _expanded = false;
  bool _didNotifyVisible = false;

  void _notifyVisible() {
    final onVisible = widget.onVisible;
    if (onVisible == null) {
      return;
    }
    runGuarded(() => onVisible(widget.trip));
  }

  void _selectLeg(Leg leg) {
    final onSelectLeg = widget.onSelectLeg;
    runGuarded(() => onSelectLeg(leg));
  }

  @override
  void didUpdateWidget(covariant TripCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.trip, widget.trip)) {
      _didNotifyVisible = false;
    }
  }

  void _notifyVisibleOnce() {
    if (_didNotifyVisible) return;
    _didNotifyVisible = true;
    addPostFrameCallbackSafely((_) {
      if (!mounted) return;
      _notifyVisible();
    });
  }

  String _displayStopName(Stop stop) {
    return stop.disassembledName ?? stop.name;
  }

  String _formatTimeDifference(String? planned, String? estimated) {
    final hasPlanned = planned != null && planned.isNotEmpty;
    final hasEstimated = estimated != null && estimated.isNotEmpty;
    final fallbackTime = estimated ?? planned;
    if (!hasPlanned && !hasEstimated) {
      return 'TBD';
    }
    if (fallbackTime == null) {
      return 'TBD';
    }
    if (!hasEstimated) {
      return DateTimeUtils.parseTimeOnly(fallbackTime);
    }
    if (!hasPlanned) {
      return DateTimeUtils.parseTimeOnly(fallbackTime);
    }
    return formatTimeDifference(planned, estimated);
  }

  String _formatTimeRange(Leg leg) {
    final departure = _formatTimeDifference(
      leg.origin.departureTimePlanned,
      leg.origin.departureTimeEstimated,
    );
    final arrival = _formatTimeDifference(
      leg.destination.arrivalTimePlanned,
      leg.destination.arrivalTimeEstimated,
    );
    return '$departure - $arrival';
  }

  @override
  Widget build(BuildContext context) {
    _notifyVisibleOnce();

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
    for (final (index, l) in legs.indexed) {
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
      final nextLeg = legs.skip(index + 1).firstOrNull;
      if (nextLeg != null) {
        final curDest = l.destination;
        final nextOrigin = nextLeg.origin;
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
                _selectLeg(legs.first);
              } else {
                guardedSetState(() => _expanded = !_expanded);
              }
            },
            child: ListTile(
              title: Text(
                '${_displayStopName(firstLeg.origin)} to ${_displayStopName(lastLeg.destination)}',
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
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TransportModeUtils.getModeColor(
                      leg.transportation?.product?.classField ?? -1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Row(
                  children: [
                    // Timestamp left of the leg description
                    Text(
                      _formatTimeRange(leg),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_displayStopName(leg.origin)} → ${_displayStopName(leg.destination)}',
                      ),
                    ),
                  ],
                ),
                subtitle: _buildLegSubtitle(leg),
                dense: true,
                trailing: const Padding(
                  padding: EdgeInsets.only(right: 24.0),
                  child: Icon(Icons.chevron_right, size: 20),
                ),
                onTap: () => _selectLeg(leg),
              ),
            const Divider(height: 1),
          ],
          if (!_expanded)
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

  Widget? _buildLegSubtitle(Leg leg) {
    final details = <String>[];
    final routeNumber = leg.transportation?.number;

    if (routeNumber != null && routeNumber.isNotEmpty) {
      details.add('Route $routeNumber');
    }

    if (details.isEmpty) return null;
    return Text(
      details.join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12),
    );
  }
}
