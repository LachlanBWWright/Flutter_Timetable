import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/transport_modes.dart';
import 'matcher.dart';
import 'models.dart';
import 'provider.dart';

class VehicleFinderController extends ChangeNotifier {
  VehicleFinderController({
    Stream<FinderLocation> Function()? locations,
    Future<List<FinderVehicle>> Function(TransportMode)? vehicles,
    DateTime Function()? clock,
    this.pollInterval = const Duration(seconds: 30),
    this.searchDuration = const Duration(minutes: 3),
  }) : _locations = locations ?? finderLocations,
       _vehicles = vehicles ?? finderVehicles,
       _clock = clock ?? DateTime.now;

  final Stream<FinderLocation> Function() _locations;
  final Future<List<FinderVehicle>> Function(TransportMode) _vehicles;
  final DateTime Function() _clock;
  final Duration pollInterval;
  final Duration searchDuration;
  final matcher = VehicleMatcher();
  StreamSubscription<FinderLocation>? _subscription;
  Timer? _poll;
  Timer? _expiry;
  Timer? _health;
  bool _disposed = false;
  int _generation = 0;
  DateTime? _lastEvaluation;
  int _evaluations = 0;
  @visibleForTesting
  int get evaluations => _evaluations;
  // Keep the slot until a request settles, even after stopping/restarting.
  Future<void>? _inflight;
  List<FinderVehicle> _snapshot = [];
  bool running = false;
  TransportMode mode = TransportMode.train;
  String status = 'Choose your transport type, then start searching.';
  String? error;
  FinderLocation? location;
  List<VehicleCandidate> candidates = [];
  VehicleCandidate? confirmed;

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  void start(TransportMode selectedMode) {
    if (_disposed || running) return;
    stop();
    final generation = _generation;
    mode = selectedMode;
    running = true;
    status = 'Waiting for your location…';
    error = null;
    location = null;
    confirmed = null;
    candidates = [];
    _snapshot = [];
    matcher.clear();
    _publish();
    try {
      _subscription = _locations().listen(
        (sample) {
          if (!_current(generation)) return;
          if (!matcher.addLocation(sample, _clock())) {
            status = 'Waiting for a fresh, more accurate location…';
            candidates = [];
            location = null;
            matcher.clear();
            _lastEvaluation = null;
            _publish();
            return;
          }
          final recovering =
              location == null ||
              _clock().difference(location!.timestamp) >
                  const Duration(seconds: 20);
          location = sample;
          _evaluate(force: recovering);
        },
        onError: (Object failure) {
          if (!_current(generation)) return;
          _fail(
            failure is VehicleFinderException
                ? failure.message
                : 'Could not read your location. Check location access and try again.',
          );
        },
        onDone: () {
          if (_current(generation)) {
            _fail(
              'Location updates stopped. Start another search to try again.',
            );
          }
        },
      );
    } catch (_) {
      _fail('Could not start location updates. Please try again.');
      return;
    }
    _expiry = Timer(searchDuration, () {
      if (!_current(generation)) return;
      stop(message: 'Search finished. Start again if you need more time.');
    });
    _health = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_current(generation)) return;
      if (location == null) {
        status =
            'Waiting for location. Check that precise location is enabled.';
        _publish();
      } else {
        _evaluate();
      }
    });
    unawaited(_refresh(generation));
  }

  bool _current(int generation) =>
      !_disposed && running && generation == _generation;

  Future<void> _refresh(int generation) async {
    final pending = _inflight;
    if (pending != null) await pending;
    if (!_current(generation)) return;
    final request = _load(generation);
    _inflight = request;
    await request;
    if (identical(_inflight, request)) _inflight = null;
    if (_current(generation)) {
      _poll = Timer(pollInterval, () => unawaited(_refresh(generation)));
    }
  }

  Future<void> _load(int generation) async {
    try {
      final snapshot = await _vehicles(mode);
      if (!_current(generation)) return;
      _snapshot = snapshot;
      error = null;
      _evaluate(force: true);
    } catch (failure) {
      if (!_current(generation)) return;
      if (failure is VehicleFinderException && failure.isFatal) {
        _fail(failure.message);
        return;
      }
      _snapshot = [];
      matcher.clear();
      candidates = [];
      error = failure is VehicleFinderException
          ? failure.message
          : 'Could not load live vehicles. Retrying shortly.';
      _publish();
    }
  }

  void _evaluate({bool force = false}) {
    if (!running || _disposed) return;
    final current = location;
    if (current == null) return;
    final now = _clock();
    if (!force &&
        _lastEvaluation != null &&
        now.difference(_lastEvaluation!) < const Duration(seconds: 2)) {
      return;
    }
    _lastEvaluation = now;
    _evaluations++;
    if (_clock().difference(current.timestamp).inSeconds > 20) {
      candidates = [];
      matcher.clear();
      status = 'Location signal lost. Waiting for a fresh location…';
    } else {
      candidates = matcher.match(_snapshot, _clock());
      status = candidates.isEmpty
          ? 'No matching vehicles yet. Keep this screen open while travelling.'
          : candidates.first.likely
          ? 'One vehicle matches your movement. Confirm it below.'
          : 'Nearby vehicles found. Comparing movement over more live updates…';
    }
    _publish();
  }

  void confirm(VehicleCandidate candidate) {
    if (!running) return;
    VehicleCandidate? current;
    for (final match in candidates) {
      if (match.vehicle.key == candidate.vehicle.key) current = match;
    }
    if (current == null) return;
    confirmed = current;
    stop(message: 'Vehicle selected. You can now view it on the map.');
  }

  void _fail(String message) {
    stop(message: 'Search stopped.');
    error = message;
    _publish();
  }

  void stop({
    String message = 'Search paused. Start again when you are ready.',
  }) {
    _generation++;
    running = false;
    _poll?.cancel();
    _expiry?.cancel();
    _health?.cancel();
    _poll = _expiry = _health = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    _snapshot = [];
    candidates = [];
    location = null;
    _lastEvaluation = null;
    matcher.clear();
    status = message;
    _publish();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}
