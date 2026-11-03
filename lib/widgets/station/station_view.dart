import 'package:flutter/material.dart';

import '../../constants/transport_colors.dart';
import '../../constants/transport_modes.dart';
import '../../services/debug_service.dart';
import '../../transit/transit.dart';
import '../../utils/station_subtitle_utils.dart';
import 'station.dart';

/// Widget for displaying a single station item with optional distance
class StationView extends StatelessWidget {
  final Station station;
  final StationSelectionCallback setStation;
  final SortMode sortMode;
  final TransportMode? mode;

  const StationView({
    super.key,
    required this.station,
    required this.setStation,
    required this.sortMode,
    this.mode,
  });

  void _selectStation() {
    try {
      setStation.call(
        station.mode == null && mode != null
            ? station.copyWith(mode: mode)
            : station,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final transportMode = mode;
    final accentColor = transportMode != null
        ? TransportColors.getColorByTransportMode(transportMode)
        : Colors.grey;
    return Container(
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: InkWell(
        onTap: _selectStation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(title: Text(station.name), subtitle: _buildSubtitle()),
            Container(height: 6, width: double.infinity, color: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebug, _) {
        final items = <Widget>[];

        if (station.transitRef case final ref?) {
          items.add(
            Text(
              '${ref.region.shortLabel} • ${ref.provider.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        if (station.isPreferredNearby) {
          items.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    station.nearbyBadgeLabel ?? 'Best nearby',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          );
        }

        final standardDistanceLine = formatStationDistanceLine(
          station.nearbyAnchorDistance ?? station.distance,
          debugFormat: false,
        );
        if (standardDistanceLine != null && !showDebug) {
          items.add(
            Text(
              standardDistanceLine,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        if (showDebug) {
          items.addAll(
            buildStationDebugLines(station).map(
              (line) => Text(
                line,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          );

          final debugDistanceLine = formatStationDistanceLine(
            station.nearbyAnchorDistance ?? station.distance,
            debugFormat: true,
          );
          if (debugDistanceLine != null) {
            items.add(
              Text(
                debugDistanceLine,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            );
          }
        }

        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        );
      },
    );
  }
}
