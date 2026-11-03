part of '../realtime_map_widget.dart';

extension _RealtimeMapRouteLayers on _RealtimeMapWidgetState {
  // Build polyline(s) for leg stops if provided (in order)
  List<Polyline> _buildRoutePolylines() {
    if (_routePolylines case final cached?) return cached;
    final polylines = <Polyline>[];

    // Draw additional (other) legs first so they appear below the active leg.
    for (final otherLeg in widget.additionalLegs ?? const <Leg>[]) {
      final points = _pointsForLeg(otherLeg);
      if (points.length >= 2) {
        polylines.add(
          Polyline(
            points: points,
            strokeWidth: 2.0,
            color: Colors.grey.withValues(alpha: 0.35),
          ),
        );
      }
    }

    final leg = widget.leg;
    if (leg == null) return _routePolylines = polylines;

    final points = _pointsForLeg(leg);
    if (points.length < 2) return _routePolylines = polylines;

    final mode = widget.transportMode;
    if (mode == null) {
      // Walk or unknown — dashed grey line
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: 3.0,
          color: Colors.grey.shade600,
          pattern: StrokePattern.dashed(segments: const [12, 6]),
        ),
      );
    } else {
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: TransportColors.getColorByTransportMode(mode),
        ),
      );
    }
    return _routePolylines = polylines;
  }
}
