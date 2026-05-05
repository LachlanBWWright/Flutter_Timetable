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

class _TripCardState extends State<TripCard> with TickerProviderStateMixin {
  bool _expanded = false;
  bool _didNotifyVisible = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onVisible?.call(widget.trip);
    });
  }

  bool _isTruthy(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == 'yes' || normalized == 'true' || normalized == '1';
  }

  String _displayStopName(Stop stop) {
    return stop.disassembledName ?? stop.name;
  }

  String _formatDurationMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return rem == 0 ? '${hours}h' : '${hours}h ${rem}m';
  }

  int _journeyDurationMinutes(List<Leg> legs) {
    final first = legs.first;
    final last = legs.last;
    final departure =
        first.origin.departureTimeEstimated ?? first.origin.departureTimePlanned;
    final arrival =
        last.destination.arrivalTimeEstimated ?? last.destination.arrivalTimePlanned;
    final start = departure != null
        ? DateTimeUtils.parseTimeToDateTime(departure)
        : null;
    final end = arrival != null ? DateTimeUtils.parseTimeToDateTime(arrival) : null;
    if (start != null && end != null) {
      final diff = end.difference(start).inMinutes;
      if (diff > 0) return diff;
    }

    final summedSeconds = legs.fold<int>(
      0,
      (sum, leg) => sum + (leg.duration ?? 0),
    );
    return summedSeconds > 0 ? (summedSeconds / 60).ceil() : 0;
  }

  List<String> _journeyNotices(List<Leg> legs) {
    final notices = <String>{};
    for (final leg in legs) {
      for (final info in leg.infos ?? const <Info>[]) {
        final text =
            info.subtitle?.trim().isNotEmpty == true
            ? info.subtitle!.trim()
            : info.content?.trim();
        if (text != null && text.isNotEmpty) {
          notices.add(text);
        }
      }
      for (final hint in leg.hints ?? const <Hint>[]) {
        final text = hint.infoText?.trim();
        if (text != null && text.isNotEmpty) {
          notices.add(text);
        }
      }
    }
    return notices.toList(growable: false);
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
    try {
      final plannedTime = DateTimeUtils.parseTimeToDateTime(planned);
      final estimatedTime = DateTimeUtils.parseTimeToDateTime(estimated);

      if (plannedTime == null || estimatedTime == null) {
        return DateTimeUtils.parseTimeOnly(fallbackTime);
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
      return DateTimeUtils.parseTimeOnly(fallbackTime);
    }
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
    final firstTransport = firstLeg.transportation;
    final firstRouteNumber = firstTransport?.number;
    final firstHeadsign = firstTransport?.destination?.name;
    final firstOperator = firstTransport?.operator?.name;
    final journeyMinutes = _journeyDurationMinutes(legs);
    final notices = _journeyNotices(legs);
    final lowFloor = legs.any(
      (leg) => _isTruthy(leg.properties?.planLowFloorVehicle),
    );
    final wheelchair = legs.any(
      (leg) =>
          _isTruthy(leg.properties?.planWheelChairAccess) ||
          _isTruthy(leg.origin.properties?.wheelchairAccess) ||
          _isTruthy(leg.destination.properties?.wheelchairAccess),
    );

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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (journeyMinutes > 0)
                        _summaryChip(_formatDurationMinutes(journeyMinutes)),
                      if (legs.length > 1)
                        _summaryChip('${legs.length - 1} transfer${legs.length == 2 ? '' : 's'}'),
                      if (firstRouteNumber != null && firstRouteNumber.isNotEmpty)
                        _summaryChip('Route $firstRouteNumber'),
                      if (wheelchair) _summaryChip('Wheelchair friendly'),
                      if (lowFloor) _summaryChip('Low-floor vehicles'),
                      if (widget.trip.isAdditional == true)
                        _summaryChip('Extra service'),
                      if (widget.trip.rating != null)
                        _summaryChip('Rating ${widget.trip.rating}'),
                    ],
                  ),
                  if (firstHeadsign != null && firstHeadsign.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Destination sign: $firstHeadsign',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (firstOperator != null && firstOperator.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Operator: $firstOperator',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (notices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Alert: ${notices.first}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                onTap: () => widget.onSelectLeg(leg),
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

  Widget _summaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget? _buildLegSubtitle(Leg leg) {
    final details = <String>[];
    final routeNumber = leg.transportation?.number;
    final headsign = leg.transportation?.destination?.name;
    final operator = leg.transportation?.operator?.name;

    if (routeNumber != null && routeNumber.isNotEmpty) {
      details.add('Route $routeNumber');
    }
    if (headsign != null && headsign.isNotEmpty) {
      details.add('towards $headsign');
    }
    if (operator != null && operator.isNotEmpty) {
      details.add(operator);
    }
    if (_isTruthy(leg.properties?.planWheelChairAccess)) {
      details.add('wheelchair access');
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
