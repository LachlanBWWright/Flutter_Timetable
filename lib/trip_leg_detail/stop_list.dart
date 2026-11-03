part of '../trip_leg_detail_screen.dart';

/// Builds scheduled and realtime stop rows, metadata, and arrival times.
extension _StopList on _TripLegDetailScreenState {
  /// Builds a section listing every stop in the leg's stop sequence with
  /// its planned/estimated departure and arrival times.
  Widget _buildStopListSection(Leg leg, Color modeColor) {
    final tripStops = leg.stopSequence;
    if (tripStops == null || tripStops.isEmpty) return const SizedBox.shrink();

    final supportsRealtime = _supportsRealtimeForLeg(leg);
    final tripRows = _liveTripStopRows(leg);
    final useVehicleStops = _showAllVehicleStops && _vehicleStops.isNotEmpty;
    final rows = useVehicleStops ? _vehicleStops : _scheduledStopRows(tripRows);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    useVehicleStops
                        ? 'All stops (${rows.length})'
                        : 'Trip stops (${rows.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (_isLoadingVehicleStops)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (supportsRealtime)
                  TextButton.icon(
                    onPressed: () async {
                      if (_showAllVehicleStops) {
                        guardedSetState(() {
                          _showAllVehicleStops = false;
                        });
                        return;
                      }

                      guardedSetState(() {
                        _showAllVehicleStops = true;
                      });
                      await _loadVehicleStopsForLeg();
                    },
                    icon: Icon(
                      _showAllVehicleStops
                          ? Icons.view_list_outlined
                          : Icons.directions_bus,
                    ),
                    label: Text(
                      _showAllVehicleStops
                          ? 'Show trip stops'
                          : 'Show all stops',
                    ),
                  ),
              ],
            ),
          ),
          if (_vehicleStopsError != null && _showAllVehicleStops) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _vehicleStopsError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const Divider(height: 1),
          ...rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final stop = entry.value;
            final isFirst = idx == 0;
            final isLast = idx == rows.length - 1;

            final depPlanned = stop.departureTimePlanned;
            final depEstimated = stop.departureTimeEstimated;
            final arrPlanned = stop.arrivalTimePlanned;
            final arrEstimated = stop.arrivalTimeEstimated;
            final mainTimePlanned = depPlanned ?? arrPlanned;
            final mainTimeEstimated = depEstimated ?? arrEstimated;

            return Container(
              decoration: (isFirst || isLast)
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: modeColor, width: 4),
                      ),
                    )
                  : null,
              child: ListTile(
                dense: true,
                leading: SizedBox(
                  width: 28,
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: (isFirst || isLast)
                            ? modeColor
                            : modeColor.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  stop.label,
                  style: TextStyle(
                    fontWeight: (isFirst || isLast)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                subtitle: stop.cancelled || stop.skipped
                    ? Text(
                        stop.cancelled ? 'Cancelled' : 'Skipped',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      )
                    : _buildStopMetaSubtitle(stop),
                trailing: mainTimePlanned != null
                    ? _buildStopTimeWidget(
                        mainTimePlanned,
                        mainTimeEstimated,
                        isArrival: depPlanned == null && arrPlanned != null,
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_VehicleStopRow> _buildTripStopRows(List<Stop> stops) {
    final rows = <_VehicleStopRow>[];
    for (final stop in stops) {
      rows.add(
        _VehicleStopRow(
          label: stop.disassembledName ?? stop.name,
          stopId: stop.id,
          platform: _extractPlatformLabel(stop),
          wheelchairAccess: stop.properties?.wheelchairAccess,
          arrivalTimePlanned: stop.arrivalTimePlanned,
          arrivalTimeEstimated: stop.arrivalTimeEstimated,
          departureTimePlanned: stop.departureTimePlanned,
          departureTimeEstimated: stop.departureTimeEstimated,
        ),
      );
    }
    return rows;
  }

  List<_VehicleStopRow> _scheduledStopRows(List<_VehicleStopRow> rows) {
    return rows.where(_hasStopTime).toList(growable: false);
  }

  bool _hasStopTime(_VehicleStopRow row) {
    return row.arrivalTimePlanned != null ||
        row.arrivalTimeEstimated != null ||
        row.departureTimePlanned != null ||
        row.departureTimeEstimated != null;
  }

  Widget? _buildStopMetaSubtitle(_VehicleStopRow stop) {
    final children = <Widget>[];
    final platform = trimmedOrNull(stop.platform);
    if (platform != null) {
      children.add(
        Text('Platform $platform', style: const TextStyle(fontSize: 12)),
      );
    }
    if (_isWheelchairAccessible(stop.wheelchairAccess)) {
      if (children.isNotEmpty) {
        children.add(const Text(' • ', style: TextStyle(fontSize: 12)));
      }
      children.add(
        const Icon(
          Icons.accessible_forward,
          size: 15,
          semanticLabel: 'Wheelchair accessible',
        ),
      );
    }
    if (children.isEmpty) return null;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  bool _isWheelchairAccessible(String? value) {
    final normalized = trimmedOrNull(value)?.toLowerCase();
    return normalized == 'true' || normalized == 'yes' || normalized == '1';
  }

  String? _extractPlatformLabel(Stop stop) {
    final raw = stop.rawJson;
    final candidates = [
      tryReadMapValue(raw, 'platform'),
      tryReadMapValue(raw, 'platformCode'),
      tryReadMapValue(raw, 'platformName'),
      tryReadMapValue(tryReadJsonMap(raw, 'properties'), 'platform'),
      tryReadMapValue(tryReadJsonMap(raw, 'properties'), 'platformCode'),
    ];
    for (final candidate in candidates) {
      final text = candidate?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  Widget _buildStopTimeWidget(
    String planned,
    String? estimated, {
    bool isArrival = false,
  }) {
    final plannedFormatted = _formatTimeOrEmpty(planned);
    String? delayText;
    Color timeColor = Colors.grey.shade700;

    if (estimated != null && estimated != planned) {
      final plannedDt = DateTimeUtils.parseTimeToDateTime(planned);
      final estimatedDt = DateTimeUtils.parseTimeToDateTime(estimated);
      if (plannedDt != null && estimatedDt != null) {
        final diff = estimatedDt.difference(plannedDt).inMinutes;
        if (diff > 0) {
          delayText = '+${diff}m';
          timeColor = Colors.red;
        } else if (diff < 0) {
          delayText = '${diff}m';
          timeColor = Colors.orange;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          plannedFormatted,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: delayText != null ? Colors.grey : timeColor,
            decoration: delayText != null
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        if (delayText != null)
          Text(
            delayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
      ],
    );
  }

  String _formatTimeOrEmpty(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    return DateTimeUtils.parseTimeOnly(timeStr);
  }
}
