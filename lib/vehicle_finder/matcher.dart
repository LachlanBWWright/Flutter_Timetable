import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../constants/transport_modes.dart';
import 'models.dart';

/// Conservative experimental matcher. Histories never leave this session.
class VehicleMatcher {
  final _locations = <FinderLocation>[];
  final _tracks = <String, _Track>{};
  static const maxLocations = 90;
  static const maxTracks = 100;
  int get locationCount => _locations.length;
  int get trackCount => _tracks.length;

  static bool validCoordinate(double latitude, double longitude) =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180;

  bool addLocation(FinderLocation location, DateTime now) {
    if (!validCoordinate(location.latitude, location.longitude) ||
        !location.accuracy.isFinite ||
        location.accuracy < 0 ||
        location.accuracy > 100 ||
        now.difference(location.timestamp).inSeconds > 20 ||
        location.timestamp.difference(now).inSeconds > 5 ||
        (_locations.isNotEmpty &&
            !location.timestamp.isAfter(_locations.last.timestamp))) {
      return false;
    }
    // At most one stored fix per two seconds: fast GPS streams must not
    // evict the history needed to align delayed vehicle reports.
    if (_locations.isNotEmpty &&
        location.timestamp.difference(_locations.last.timestamp) <
            const Duration(seconds: 2)) {
      return true;
    }
    _locations.add(location);
    _locations.removeWhere((p) => now.difference(p.timestamp).inSeconds > 180);
    if (_locations.length > maxLocations) _locations.removeAt(0);
    return true;
  }

  List<VehicleCandidate> match(List<FinderVehicle> vehicles, DateTime now) {
    if (_locations.isEmpty ||
        now.difference(_locations.last.timestamp).inSeconds > 20) {
      _tracks.clear();
      return [];
    }
    final nearby =
        <
          ({
            FinderVehicle vehicle,
            FinderLocation phone,
            double distance,
            double radius,
          })
        >[];
    final alignedPhones = <int, FinderLocation>{};
    for (final vehicle in vehicles) {
      if (vehicle.id.isEmpty ||
          !validCoordinate(vehicle.latitude, vehicle.longitude) ||
          now.difference(vehicle.observedAt).inSeconds > 90 ||
          vehicle.observedAt.difference(now).inSeconds > 5) {
        continue;
      }
      // Compare with the phone where it was when the vehicle was measured.
      final phone = alignedPhones.putIfAbsent(
        vehicle.observedAt.millisecondsSinceEpoch,
        () => _locations.reduce(
          (a, b) =>
              a.timestamp.difference(vehicle.observedAt).abs() <=
                  b.timestamp.difference(vehicle.observedAt).abs()
              ? a
              : b,
        ),
      );
      final offset =
          phone.timestamp.difference(vehicle.observedAt).abs().inMilliseconds /
          1000;
      if (offset > 15) continue;
      final distance = Geolocator.distanceBetween(
        phone.latitude,
        phone.longitude,
        vehicle.latitude,
        vehicle.longitude,
      );
      final lengthAllowance = switch (vehicle.mode) {
        TransportMode.train || TransportMode.metro => 200.0,
        TransportMode.ferry => 100.0,
        _ => 40.0,
      };
      final speed = _validSpeed(phone.speed) ?? 0;
      final radius = math.min(
        500.0,
        lengthAllowance + phone.accuracy + offset * math.min(speed, 35),
      );
      if (distance <= radius) {
        nearby.add((
          vehicle: vehicle,
          phone: phone,
          distance: distance,
          radius: radius,
        ));
      }
    }
    nearby.sort((a, b) => a.distance.compareTo(b.distance));
    final candidates = <VehicleCandidate>[];
    final seen = <String>{};
    for (final item in nearby.take(maxTracks)) {
      final vehicle = item.vehicle;
      if (!seen.add(vehicle.key)) continue;
      final phone = item.phone;
      final track = _tracks.putIfAbsent(vehicle.key, _Track.new);
      if (track.points.isNotEmpty &&
          vehicle.observedAt.isBefore(track.points.last.time)) {
        continue;
      }
      // Repeated cached messages and out-of-order reports are not new evidence.
      if (track.points.isEmpty ||
          vehicle.observedAt.isAfter(track.points.last.time)) {
        final userSpeed = _validSpeed(phone.speed);
        final vehicleSpeed = _validSpeed(vehicle.speed);
        var compatible = true;
        if (userSpeed != null &&
            vehicleSpeed != null &&
            (userSpeed - vehicleSpeed).abs() > math.max(5, userSpeed * 0.5)) {
          compatible = false;
        }
        if ((userSpeed ?? 0) > 2 &&
            _validHeading(phone.heading) &&
            _validHeading(vehicle.heading)) {
          final delta = (phone.heading! - vehicle.heading!).abs() % 360;
          if (math.min(delta, 360 - delta) > 45) compatible = false;
        }
        final score = compatible
            ? 1 - (item.distance / item.radius) * 0.6
            : 0.0;
        track.points.add(_Evidence(vehicle.observedAt, phone, vehicle, score));
        track.points.removeWhere((p) => now.difference(p.time).inSeconds > 120);
        if (track.points.length > 6) track.points.removeAt(0);
      }
      final points = track.points;
      if (points.isEmpty) continue;
      final moved = Geolocator.distanceBetween(
        points.first.phone.latitude,
        points.first.phone.longitude,
        points.last.phone.latitude,
        points.last.phone.longitude,
      );
      final score =
          points.map((p) => p.score).reduce((a, b) => a + b) / points.length;
      final vehicleMoved = Geolocator.distanceBetween(
        points.first.vehicle.latitude,
        points.first.vehicle.longitude,
        points.last.vehicle.latitude,
        points.last.vehicle.longitude,
      );
      final span =
          points.last.time.difference(points.first.time).inMilliseconds / 1000;
      var sameDirection = false;
      if (moved >= 60 && vehicleMoved >= 60) {
        final phoneBearing = Geolocator.bearingBetween(
          points.first.phone.latitude,
          points.first.phone.longitude,
          points.last.phone.latitude,
          points.last.phone.longitude,
        );
        final vehicleBearing = Geolocator.bearingBetween(
          points.first.vehicle.latitude,
          points.first.vehicle.longitude,
          points.last.vehicle.latitude,
          points.last.vehicle.longitude,
        );
        final delta = (phoneBearing - vehicleBearing).abs() % 360;
        sameDirection = math.min(delta, 360 - delta) <= 45;
      }
      final stable =
          points.length >= 3 &&
          points.last.time.difference(points.first.time).inSeconds >= 20 &&
          moved >= 60 &&
          vehicleMoved >= 60 &&
          span > 0 &&
          moved / span >= 2 &&
          sameDirection &&
          moved / vehicleMoved >= 0.5 &&
          moved / vehicleMoved <= 2 &&
          points.every((p) => p.score >= 0.55);
      candidates.add(
        VehicleCandidate(
          vehicle: vehicle,
          distance: item.distance,
          observations: points.length,
          score: score,
          likely: stable,
        ),
      );
    }
    _tracks.removeWhere((key, _) => !seen.contains(key));
    candidates.sort((a, b) => b.score.compareTo(a.score));
    final ambiguous =
        candidates.length > 1 &&
        candidates.first.score - candidates[1].score < 0.15;
    return candidates
        .take(3)
        .map(
          (candidate) => VehicleCandidate(
            vehicle: candidate.vehicle,
            distance: candidate.distance,
            observations: candidate.observations,
            score: candidate.score,
            likely:
                identical(candidate, candidates.first) &&
                candidate.likely &&
                !ambiguous,
          ),
        )
        .toList(growable: false);
  }

  static double? _validSpeed(double? value) =>
      value != null && value.isFinite && value >= 0 ? value : null;
  static bool _validHeading(double? value) =>
      value != null && value.isFinite && value >= 0 && value <= 360;
  void clear() {
    _locations.clear();
    _tracks.clear();
  }
}

class _Track {
  final points = <_Evidence>[];
}

class _Evidence {
  _Evidence(this.time, this.phone, this.vehicle, this.score);
  final DateTime time;
  final FinderLocation phone;
  final FinderVehicle vehicle;
  final double score;
}
