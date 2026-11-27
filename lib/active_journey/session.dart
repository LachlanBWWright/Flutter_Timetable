import 'package:flutter/foundation.dart';

import '../schema/database.dart' show Journey;
import '../vehicle_finder/models.dart';
import '../vehicle_finder/provider.dart';
import 'models.dart';
import 'recovery.dart';
import 'resolver.dart';

typedef ServiceResolver =
    Future<RunningService> Function(
      FinderVehicle vehicle,
      List<Journey> journeys,
      DateTime now,
      RunningService? previous,
    );

/// Shared selection. Recovery is opt-in and never starts GPS or background work.
class ActiveJourneySession extends ChangeNotifier {
  ActiveJourneySession({
    ServiceResolver? resolve,
    Future<List<FinderVehicle>> Function(FinderVehicle)? vehicles,
    DateTime Function()? clock,
    ActiveJourneyRecoveryStore? recoveryStore,
  }) : _resolve = resolve ?? _defaultResolve,
       _vehicles = vehicles ?? ((v) => finderVehicles(v.mode)),
       _clock = clock ?? DateTime.now,
       _store = recoveryStore;
  static final instance = ActiveJourneySession(
    recoveryStore: PreferencesJourneyRecoveryStore(),
  );
  static final _resolver = ActiveServiceResolver();
  static Future<RunningService> _defaultResolve(
    FinderVehicle v,
    List<Journey> j,
    DateTime n,
    RunningService? p,
  ) => _resolver.resolve(v, j, n, previous: p);
  final ActiveJourneyRecoveryStore? _store;
  ActiveJourneyRecovery? recovery;
  bool _recoveryLoaded = false;
  ActiveJourneyMatch? _confirmedMatch;
  bool confirmedMatchIsLive = false;
  ActiveJourneyMatch? get confirmedMatch => _confirmedMatch;
  final ServiceResolver _resolve;
  final Future<List<FinderVehicle>> Function(FinderVehicle) _vehicles;
  final DateTime Function() _clock;
  FinderVehicle? vehicle;
  RunningService? service;
  String? selectedKey;
  DateTime? selectedAt;
  DateTime? confirmedAt;
  String? error;
  bool loading = false;
  int _generation = 0;
  bool _disposed = false;
  Future<void>? _pending;
  int? _pendingGeneration;
  List<Journey> get journeys => List.unmodifiable(_journeys);
  List<Journey> _journeys = [];
  static const lifetime = Duration(hours: 3);

  bool get expired =>
      selectedAt == null ||
      _clock().difference(selectedAt!) >= lifetime ||
      _clock().isBefore(selectedAt!);
  bool get hasSelection => vehicle != null && !expired;
  bool get fresh =>
      hasSelection &&
      error == null &&
      (selectedKey == null || confirmedMatchIsLive) &&
      service != null &&
      !_clock().difference(service!.checkedAt).isNegative &&
      _clock().difference(service!.checkedAt) < const Duration(seconds: 60) &&
      !_clock().difference(vehicle!.observedAt).isNegative &&
      _clock().difference(vehicle!.observedAt) < const Duration(seconds: 90);

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  Future<void> selectVehicle(
    FinderVehicle value,
    List<Journey> journeys,
  ) async {
    if (_disposed) return;
    _generation++;
    recovery = null;
    _confirmedMatch = null;
    confirmedMatchIsLive = false;
    _store?.write(null);
    vehicle = value;
    service = null;
    selectedKey = null;
    confirmedAt = null;
    selectedAt = _clock();
    error = null;
    _journeys = List.of(journeys);
    _publish();
    await refresh(journeys, reloadVehicle: false);
  }

  Future<void> refresh(
    List<Journey> journeys, {
    bool reloadVehicle = true,
  }) async {
    if (_disposed || vehicle == null) return;
    if (expired) {
      end();
      return;
    }
    _journeys = List.of(journeys);
    final generation = _generation;
    final pending = _pending;
    if (pending != null) {
      final sameGeneration = _pendingGeneration == generation;
      await pending;
      if (_disposed ||
          generation != _generation ||
          vehicle == null ||
          sameGeneration) {
        return;
      }
      if (identical(_pending, pending)) _pending = null;
      await refresh(journeys, reloadVehicle: reloadVehicle);
      return;
    }
    if (_disposed || generation != _generation || vehicle == null) return;
    final work = _load(generation, reloadVehicle);
    _pending = work;
    _pendingGeneration = generation;
    await work;
    if (identical(_pending, work)) _pending = null;
  }

  Future<void> _load(int generation, bool reloadVehicle) async {
    loading = true;
    _publish();
    try {
      var current = vehicle!;
      if (reloadVehicle) {
        final observations = await _vehicles(current);
        if (!_current(generation)) return;
        final matches = observations
            .where(
              (v) =>
                  v.key == current.key &&
                  _clock().difference(v.observedAt).inSeconds >= -5 &&
                  _clock().difference(v.observedAt).inSeconds <= 90,
            )
            .toList();
        if (matches.length != 1) {
          throw const VehicleFinderException(
            'The selected service is no longer reporting fresh positions. Find your vehicle again or end this trip.',
          );
        }
        current = matches.single;
      }
      final resolved = await _resolve(
        current,
        List.of(_journeys),
        _clock(),
        service,
      );
      if (!_current(generation)) return;
      vehicle = current;
      final liveMatch = resolved.matches
          .where((m) => m.key == selectedKey)
          .firstOrNull;
      confirmedMatchIsLive = liveMatch != null;
      if (liveMatch != null) _confirmedMatch = liveMatch;
      service = _withConfirmation(resolved);
      error = null;
      reconcile(_journeys, notify: false);
    } catch (failure) {
      if (!_current(generation)) return;
      error = failure is VehicleFinderException
          ? failure.message
          : 'Could not refresh this service. The last selection is retained.';
    } finally {
      if (_current(generation)) {
        loading = false;
        _publish();
      }
    }
  }

  bool _current(int generation) =>
      !_disposed && generation == _generation && vehicle != null;

  void confirmJourney(ActiveJourneyMatch match) {
    if (!hasSelection ||
        !fresh ||
        service?.matches.any((m) => m.key == match.key) != true) {
      return;
    }
    selectedKey = match.key;
    _confirmedMatch = match;
    confirmedMatchIsLive = true;
    confirmedAt = _clock();
    _persist();
    _publish();
  }

  void reconcile(List<Journey> journeys, {bool notify = true}) {
    _journeys = List.of(journeys);
    final previous = service;
    if (previous == null) return;
    final remaining = previous.matches
        .map((match) => reconcileMatch(match, journeys))
        .whereType<ActiveJourneyMatch>()
        .toList();
    if (_confirmedMatch != null) {
      _confirmedMatch = reconcileMatch(_confirmedMatch!, journeys);
      if (_confirmedMatch == null) {
        selectedKey = null;
        confirmedAt = null;
        confirmedMatchIsLive = false;
        _store?.write(null);
      }
    }
    service = RunningService(
      vehicle: previous.vehicle,
      stops: previous.stops,
      matches: remaining,
      checkedAt: previous.checkedAt,
      cacheCheckedAt: previous.cacheCheckedAt,
      checkedDirections: previous.checkedDirections,
      retainedTrips: previous.retainedTrips,
      partial: previous.partial,
    );
    if (notify) _publish();
  }

  RunningService _withConfirmation(RunningService resolved) {
    final retained = _confirmedMatch;
    if (retained == null ||
        resolved.matches.any((m) => m.key == retained.key)) {
      return resolved;
    }
    return RunningService(
      vehicle: resolved.vehicle,
      stops: resolved.stops,
      matches: [...resolved.matches, retained],
      checkedAt: resolved.checkedAt,
      cacheCheckedAt: resolved.cacheCheckedAt,
      checkedDirections: resolved.checkedDirections,
      retainedTrips: resolved.retainedTrips,
      partial: true,
    );
  }

  void _persist() {
    final match = _confirmedMatch;
    if (match == null || vehicle == null || confirmedAt == null) return;
    _store?.write(
      ActiveJourneyRecovery(
        vehicle: vehicle!,
        match: match,
        selectedAt: selectedAt!,
        confirmedAt: confirmedAt!,
      ),
    );
  }

  Future<void> loadRecovery(List<Journey> journeys) async {
    if (_recoveryLoaded || _disposed) return;
    _recoveryLoaded = true;
    final generation = _generation;
    ActiveJourneyRecovery? saved;
    try {
      saved = await _store?.read();
    } catch (_) {
      return;
    }
    if (_disposed || generation != _generation || hasSelection) return;
    if (saved == null) return;
    final match = reconcileMatch(saved.match, journeys);
    if (!saved.validAt(_clock(), lifetime) || match == null) {
      await _store?.write(null);
      return;
    }
    recovery = ActiveJourneyRecovery(
      vehicle: saved.vehicle,
      match: match,
      selectedAt: saved.selectedAt,
      confirmedAt: saved.confirmedAt,
    );
    _publish();
  }

  Future<void> resumeRecovery(List<Journey> journeys) async {
    final saved = recovery;
    if (_disposed || saved == null) return;
    final match = reconcileMatch(saved.match, journeys);
    if (!saved.validAt(_clock(), lifetime) || match == null) {
      dismissRecovery();
      return;
    }
    _generation++;
    recovery = null;
    vehicle = saved.vehicle;
    selectedAt = saved.selectedAt;
    confirmedAt = saved.confirmedAt;
    selectedKey = match.key;
    _confirmedMatch = match;
    confirmedMatchIsLive = false;
    service = RunningService(
      vehicle: saved.vehicle,
      stops: match.stops,
      matches: [match],
      checkedAt: saved.vehicle.observedAt,
      partial: true,
    );
    error = null;
    _journeys = List.of(journeys);
    _publish();
    await refresh(journeys);
  }

  void dismissRecovery() {
    recovery = null;
    _store?.write(null);
    _publish();
  }

  String? labelFor(Journey journey, bool reverse) {
    if (!hasSelection) return null;
    final key = '${journey.id}:$reverse';
    if (selectedKey != null && selectedKey != key) return null;
    if (service?.matches.any(
          (m) =>
              m.key == key &&
              m.journey.originId == journey.originId &&
              m.journey.destinationId == journey.destinationId,
        ) !=
        true) {
      return null;
    }
    if (!fresh) {
      return selectedKey == key ? 'Last confirmed' : 'Last possible match';
    }
    if (selectedKey != key) {
      return _clock().difference(selectedAt!) < const Duration(minutes: 2)
          ? 'Possible current trip'
          : 'Possible journey';
    }
    return confirmedAt != null &&
            _clock().difference(confirmedAt!) < const Duration(minutes: 2)
        ? 'Current trip'
        : 'Following this service';
  }

  void end() {
    _generation++;
    recovery = null;
    _confirmedMatch = null;
    confirmedMatchIsLive = false;
    _store?.write(null);
    vehicle = null;
    service = null;
    selectedKey = null;
    selectedAt = confirmedAt = null;
    error = null;
    loading = false;
    _journeys = [];
    _publish();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
