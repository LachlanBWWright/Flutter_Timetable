import 'package:flutter/material.dart';
// logger removed
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';

import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

/// Widget for displaying trip leg information

class TripLegCard extends StatelessWidget {
  final Leg leg;
  final TripJourney? trip;

  const TripLegCard({super.key, required this.leg, this.trip});

  bool _isTruthy(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == 'yes' || normalized == 'true' || normalized == '1';
  }

  List<String> _notices() {
    final messages = <String>{};
    for (final info in leg.infos ?? const <Info>[]) {
      final text =
          info.subtitle?.trim().isNotEmpty == true
          ? info.subtitle!.trim()
          : info.content?.trim();
      if (text != null && text.isNotEmpty) {
        messages.add(text);
      }
    }
    for (final hint in leg.hints ?? const <Hint>[]) {
      final text = hint.infoText?.trim();
      if (text != null && text.isNotEmpty) {
        messages.add(text);
      }
    }
    return messages.toList(growable: false);
  }

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    if (estimatedTime == null) {
      return plannedTime != null
          ? DateTimeUtils.parseTimeOnly(plannedTime)
          : 'TBD';
    }

    if (plannedTime == null) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }

    try {
      final planned = DateTimeUtils.parseTimeToDateTime(plannedTime);
      final estimated = DateTimeUtils.parseTimeToDateTime(estimatedTime);

      if (planned == null || estimated == null) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      }

      final difference = estimated.difference(planned).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }
  }

  Widget _buildTimingInfo() {
    final origin = leg.origin;
    final destination = leg.destination;

    // Get first stop timing info
    final originDeparturePlanned = origin.departureTimePlanned;
    final originDepartureEstimated = origin.departureTimeEstimated;

    // Get last stop timing info
    final destinationArrivalPlanned = destination.arrivalTimePlanned;
    final destinationArrivalEstimated = destination.arrivalTimeEstimated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originDeparturePlanned != null || originDepartureEstimated != null)
          Row(
            children: [
              const Icon(Icons.departure_board, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Depart: ${_formatTimeDifference(originDeparturePlanned, originDepartureEstimated)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        if (destinationArrivalPlanned != null ||
            destinationArrivalEstimated != null)
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Arrive: ${_formatTimeDifference(destinationArrivalPlanned, destinationArrivalEstimated)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transportation = leg.transportation;
    final transportProduct = transportation?.product;
    final transportClass = transportProduct?.classField;

    final origin = leg.origin;
    final destination = leg.destination;
    final originName = origin.disassembledName ?? origin.name;
    final destinationName = destination.disassembledName ?? destination.name;
    final transportName =
        transportation?.name ?? transportation?.disassembledName ?? '';
    final routeNumber = transportation?.number;
    final headsign = transportation?.destination?.name;
    final operator = transportation?.operator?.name;
    final notices = _notices();
    final accessibilityNotes = <String>[
      if (_isTruthy(leg.properties?.planWheelChairAccess)) 'Wheelchair access',
      if (_isTruthy(leg.properties?.planLowFloorVehicle)) 'Low-floor vehicle',
      ...?(leg.properties?.vehicleAccess),
    ];

    if (transportClass == null) {
      // Missing transport class
      return const Text('Unknown transport class');
    }

    final modeColor = TransportModeUtils.getModeColor(transportClass);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripLegDetailScreen(leg: leg, trip: trip),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: modeColor, width: 2.0),
          ),
          child: ListTile(
            leading: Container(
              width: 4.0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: modeColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            title: Text(
              '(${TransportModeUtils.getModeName(transportClass)}) $originName to $destinationName',
              style: TextStyle(color: modeColor, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transportName.isNotEmpty)
                  Text(
                    transportName,
                    style: TextStyle(
                      color: modeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (routeNumber != null && routeNumber.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Route $routeNumber',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                if (headsign != null && headsign.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Towards $headsign',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                if (operator != null && operator.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Operator: $operator',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                if (accessibilityNotes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: accessibilityNotes.take(3).map((note) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            note,
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
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
                const SizedBox(height: 4),
                _buildTimingInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
