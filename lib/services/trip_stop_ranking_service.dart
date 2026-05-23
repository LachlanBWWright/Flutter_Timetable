import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

enum StopRankingTier {
  withinBothAnchors,
  withinEitherAnchor,
  sharesLineWithAnchor,
  sharesModeWithAnchor,
  remaining,
}

class StopRankingMetadata {
  const StopRankingMetadata({
    required this.stop,
    required this.tier,
    this.nearestAnchorDistance,
    this.isPreferredNearby = false,
    this.badgeLabel,
  });

  final Station stop;
  final StopRankingTier tier;
  final double? nearestAnchorDistance;
  final bool isPreferredNearby;
  final String? badgeLabel;
}

class TripStopRankingService {
  static const double nearbyDistanceKm = 5.0;

  /// Rank stops for interchange insertion using multi-tier ranking logic.
  ///
  /// Ranking tiers (in priority order):
  /// 1. Within 5 km of both adjacent anchors
  /// 2. Within 5 km of either adjacent anchor
  /// 3. Shares a line with an adjacent anchor
  /// 4. Shares a mode with an adjacent anchor
  /// 5. Remaining stops
  ///
  /// Within each tier, sort by:
  /// 1. Distance to nearest anchor (if coordinates available)
  /// 2. User location distance (if available)
  /// 3. Alphabetical order
  static List<StopRankingMetadata> rankStopsForInterchange({
    required List<Station> candidates,
    Station? previousAnchor,
    Station? nextAnchor,
    TransportMode? selectedMode,
    SortMode sortMode = SortMode.alphabetical,
    String? searchQuery,
  }) {
    final filteredCandidates = _filterCandidates(candidates, searchQuery);
    if (filteredCandidates.isEmpty) {
      return [];
    }

    final List<StopRankingMetadata> metadata = [];
    for (final stop in filteredCandidates) {
      final (tier, distance) = _classifyStop(
        stop,
        previousAnchor,
        nextAnchor,
        selectedMode,
      );

      metadata.add(
        StopRankingMetadata(
          stop: stop,
          tier: tier,
          nearestAnchorDistance: distance,
          isPreferredNearby:
              tier == StopRankingTier.withinBothAnchors ||
              tier == StopRankingTier.withinEitherAnchor,
          badgeLabel: _badgeLabelForTier(tier),
        ),
      );
    }

    metadata.sort((a, b) {
      final tierComparison = a.tier.index.compareTo(b.tier.index);
      if (tierComparison != 0) {
        return tierComparison;
      }

      final aDistance = a.nearestAnchorDistance;
      final bDistance = b.nearestAnchorDistance;
      if (aDistance != null && bDistance != null) {
        final anchorComparison = aDistance.compareTo(bDistance);
        if (anchorComparison != 0) {
          return anchorComparison;
        }
      } else if (aDistance != null) {
        return -1;
      } else if (bDistance != null) {
        return 1;
      }

      if (sortMode == SortMode.distance) {
        final userDistanceComparison = _compareNullableDouble(
          a.stop.distance,
          b.stop.distance,
        );
        if (userDistanceComparison != 0) {
          return userDistanceComparison;
        }
      }

      return a.stop.name.compareTo(b.stop.name);
    });

    return metadata;
  }

  /// Classify a stop into a ranking tier and calculate metadata.
  ///
  /// Returns: (tier, nearestDistance)
  static (StopRankingTier, double?) _classifyStop(
    Station candidate,
    Station? previousAnchor,
    Station? nextAnchor,
    TransportMode? selectedMode,
  ) {
    final previousDistance = previousAnchor != null
        ? _distanceToStop(previousAnchor, candidate)
        : null;
    final nextDistance = nextAnchor != null
        ? _distanceToStop(nextAnchor, candidate)
        : null;

    // Tier 1: Within 5 km of both anchors
    if (previousDistance != null &&
        nextDistance != null &&
        previousDistance <= nearbyDistanceKm &&
        nextDistance <= nearbyDistanceKm) {
      final nearestDistance = previousDistance < nextDistance
          ? previousDistance
          : nextDistance;
      return (StopRankingTier.withinBothAnchors, nearestDistance);
    }

    // Tier 2: Within 5 km of either anchor
    if ((previousDistance != null && previousDistance <= nearbyDistanceKm) ||
        (nextDistance != null && nextDistance <= nearbyDistanceKm)) {
      final nearestDistance = [
        previousDistance,
        nextDistance,
      ].whereType<double>().reduce((a, b) => a < b ? a : b);
      return (StopRankingTier.withinEitherAnchor, nearestDistance);
    }

    final candidateMode = _transportModeForStation(candidate) ?? selectedMode;

    // Tier 3: Check for shared lines
    final sharesLine = _sharesLineWithAnchor(
      candidate,
      previousAnchor,
      nextAnchor,
    );

    if (sharesLine) {
      final nearestDistance = _getNearestDistance(
        previousDistance,
        nextDistance,
      );
      return (StopRankingTier.sharesLineWithAnchor, nearestDistance);
    }

    // Tier 4: Check for shared mode
    final sharesMode = _sharesModeWithAnchor(
      candidate,
      previousAnchor,
      nextAnchor,
      candidateMode,
    );

    if (sharesMode) {
      final nearestDistance = _getNearestDistance(
        previousDistance,
        nextDistance,
      );
      return (StopRankingTier.sharesModeWithAnchor, nearestDistance);
    }

    // Tier 5: Remaining stops
    final nearestDistance = _getNearestDistance(previousDistance, nextDistance);
    return (StopRankingTier.remaining, nearestDistance);
  }

  /// Calculate distance between two stops in km.
  /// Returns null if either stop lacks coordinates.
  static double? _distanceToStop(Station from, Station to) {
    final fromLatitude = from.latitude;
    final fromLongitude = from.longitude;
    final toLatitude = to.latitude;
    final toLongitude = to.longitude;
    if (fromLatitude == null ||
        fromLongitude == null ||
        toLatitude == null ||
        toLongitude == null) {
      return null;
    }

    return LocationService.calculateDistance(
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    );
  }

  /// Find the nearest of two distances, or return the only available one.
  static double? _getNearestDistance(double? d1, double? d2) {
    if (d1 == null && d2 == null) return null;
    if (d1 == null) return d2;
    if (d2 == null) return d1;
    return d1 < d2 ? d1 : d2;
  }

  /// Check if candidate shares a line with either anchor.
  static bool _sharesLineWithAnchor(
    Station candidate,
    Station? previousAnchor,
    Station? nextAnchor,
  ) {
    if (candidate.lineId == null) return false;

    if (previousAnchor != null && previousAnchor.lineId == candidate.lineId) {
      return true;
    }

    if (nextAnchor != null && nextAnchor.lineId == candidate.lineId) {
      return true;
    }

    return false;
  }

  /// Check if candidate shares a mode with an anchor or selected mode.
  static bool _sharesModeWithAnchor(
    Station candidate,
    Station? previousAnchor,
    Station? nextAnchor,
    TransportMode? candidateMode,
  ) {
    if (candidateMode == null) {
      return false;
    }

    final previousMode = _transportModeForStation(previousAnchor);
    if (previousMode != null && previousMode == candidateMode) {
      return true;
    }

    final nextMode = _transportModeForStation(nextAnchor);
    if (nextMode != null && nextMode == candidateMode) {
      return true;
    }

    return false;
  }

  static TransportMode? _transportModeForStation(Station? station) {
    if (station == null) {
      return null;
    }

    final stationMode = station.mode;
    if (stationMode != null) {
      return stationMode;
    }

    final lineId = station.lineId;
    if (lineId != null) {
      final endpointKey = lineId.split('|').first;
      final resolvedMode = StopsService.modeForEndpointKey(endpointKey);
      if (resolvedMode != null) {
        return resolvedMode;
      }
    }

    return null;
  }

  static String? _badgeLabelForTier(StopRankingTier tier) {
    switch (tier) {
      case StopRankingTier.withinBothAnchors:
        return 'Near both legs';
      case StopRankingTier.withinEitherAnchor:
        return 'Near adjacent leg';
      case StopRankingTier.sharesLineWithAnchor:
        return 'Shared line';
      case StopRankingTier.sharesModeWithAnchor:
        return 'Shared mode';
      case StopRankingTier.remaining:
        return null;
    }
  }

  static List<Station> _filterCandidates(
    List<Station> candidates,
    String? searchQuery,
  ) {
    final normalizedQuery = searchQuery?.trim().toLowerCase() ?? '';
    if (normalizedQuery.isEmpty) {
      return candidates;
    }

    return candidates.where((stop) {
      final nameMatch = stop.name.toLowerCase().contains(normalizedQuery);
      final lineMatch =
          stop.lineName?.toLowerCase().contains(normalizedQuery) ?? false;
      return nameMatch || lineMatch;
    }).toList();
  }

  static int _compareNullableDouble(double? a, double? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.compareTo(b);
  }
}
