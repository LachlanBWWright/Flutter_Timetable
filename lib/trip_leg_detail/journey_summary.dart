part of '../trip_leg_detail_screen.dart';

/// Builds the leg summary and collects travel warning content.
extension _JourneySummary on _TripLegDetailScreenState {
  Widget _buildInfoCard(
    String originName,
    String destinationName,
    Color modeColor,
    Stop origin,
    Stop destination,
    Leg leg,
  ) {
    final liveOrigin = _liveEndpointRow(leg, arrival: false);
    final liveDestination = _liveEndpointRow(leg, arrival: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From / To with departure / arrival times
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      originName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.departure_board,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _endpointTimeLabel(liveOrigin, arrival: false),
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Icon(Icons.arrow_forward, color: modeColor),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'To',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      destinationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.schedule, color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _endpointTimeLabel(liveDestination, arrival: true),
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          _buildStopListSection(leg, modeColor),
        ],
      ),
    );
  }

  String _endpointTimeLabel(_VehicleStopRow row, {required bool arrival}) {
    if (row.cancelled) return 'Cancelled';
    if (row.skipped) return 'Stop skipped';
    return _formatTimeDifference(
      arrival ? row.arrivalTimePlanned : row.departureTimePlanned,
      arrival ? row.arrivalTimeEstimated : row.departureTimeEstimated,
    );
  }

  List<String> _collectLegNotices(Leg leg) {
    final notices = <String>{};
    for (final info in leg.infos ?? const <Info>[]) {
      final text = trimmedOrNull(info.subtitle) ?? trimmedOrNull(info.content);
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
    if (leg.interchange?.desc case final desc? when desc.trim().isNotEmpty) {
      notices.add(desc.trim());
    }
    return notices.toList(growable: false);
  }

  List<Widget> _buildAlertWarningChildren(Leg leg) {
    final notices = _collectLegNotices(leg);
    final pathSteps = (leg.pathDescriptions ?? const <PathDescription>[])
        .map((step) => step.name?.trim() ?? step.manoeuvre?.trim() ?? '')
        .where((step) => step.isNotEmpty)
        .take(4)
        .toList(growable: false);

    return [
      if (notices.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...notices
            .take(4)
            .map(
              (notice) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $notice', style: const TextStyle(fontSize: 13)),
              ),
            ),
      ],
      if (pathSteps.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text(
          'Walking guidance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        ...pathSteps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $step', style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    ];
  }

  bool _hasAlertWarnings(Leg leg) {
    return _collectLegNotices(leg).isNotEmpty ||
        (leg.pathDescriptions ?? const <PathDescription>[]).any((step) {
          final text = step.name?.trim() ?? step.manoeuvre?.trim() ?? '';
          return text.isNotEmpty;
        });
  }

  /// Formats a single stop time with optional delay indication.
}
