part of '../trip_leg_detail_screen.dart';

/// Builds the leg summary and collects travel warning content.
extension _JourneySummary on _TripLegDetailScreenState {
  Widget _buildInfoCard(
    String originName,
    String destinationName,
    Color modeColor,
    Leg leg,
  ) {
    final origin = _endpoint(
      label: 'From',
      name: originName,
      row: _liveEndpointRow(leg, arrival: false),
      arrival: false,
    );
    final destination = _endpoint(
      label: 'To',
      name: destinationName,
      row: _liveEndpointRow(leg, arrival: true),
      arrival: true,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
            if (constraints.maxWidth < 480 * textScale) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [origin, const SizedBox(height: 12), destination],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: origin),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Icon(Icons.arrow_forward, color: modeColor),
                ),
                Expanded(child: destination),
              ],
            );
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _endpoint({
    required String label,
    required String name,
    required _VehicleStopRow row,
    required bool arrival,
  }) {
    final theme = Theme.of(context);
    final platform = trimmedOrNull(row.platform);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(_endpointTimeLabel(row, arrival: arrival)),
            if (platform != null &&
                !name.toLowerCase().contains(
                  'platform ${platform.toLowerCase()}',
                ))
              Text('Platform $platform'),
          ],
        ),
      ],
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
