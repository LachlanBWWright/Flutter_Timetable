import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/services/location_service.dart';

@immutable
class HomeState {
  HomeState({
    List<db.Journey> journeys = const [],
    this.isLoading = false,
    this.loadFailed = false,
    this.actionError,
  }) : journeys = List.unmodifiable(journeys);

  final List<db.Journey> journeys;
  final bool isLoading;
  final bool loadFailed;
  final String? actionError;

  HomeState copyWith({
    List<db.Journey>? journeys,
    bool? isLoading,
    bool? loadFailed,
    String? actionError,
    bool clearActionError = false,
  }) => HomeState(
    journeys: journeys ?? this.journeys,
    isLoading: isLoading ?? this.isLoading,
    loadFailed: loadFailed ?? this.loadFailed,
    actionError: clearActionError ? null : actionError ?? this.actionError,
  );
}

/// Owns asynchronous journey loading, sorting and saved journey actions.
class HomeController extends ChangeNotifier {
  HomeController({
    db.AppDatabase? database,
    db.AppDatabase Function()? databaseProvider,
    Future<JourneyLoadResult> Function(db.AppDatabase)? loadJourneys,
    Future<List<db.Journey>> Function(List<db.Journey>)? sortJourneys,
    Future<bool> Function(db.AppDatabase, int)? deleteJourney,
    Future<bool> Function(db.AppDatabase, int, bool)? togglePin,
    List<db.Journey> initialJourneys = const [],
  }) : _databaseInstance = database,
       _databaseProvider = databaseProvider ?? db.AppDatabase.new,
       _loadJourneys = loadJourneys ?? JourneyService.loadJourneys,
       _sortJourneys = sortJourneys ?? LocationService.sortJourneys,
       _deleteJourney = deleteJourney ?? JourneyService.deleteJourney,
       _togglePin = togglePin ?? JourneyService.toggleJourneyPin,
       _state = HomeState(journeys: initialJourneys);

  db.AppDatabase? _databaseInstance;
  final db.AppDatabase Function() _databaseProvider;
  final Future<JourneyLoadResult> Function(db.AppDatabase) _loadJourneys;
  final Future<List<db.Journey>> Function(List<db.Journey>) _sortJourneys;
  final Future<bool> Function(db.AppDatabase, int) _deleteJourney;
  final Future<bool> Function(db.AppDatabase, int, bool) _togglePin;
  HomeState _state;
  int _loadToken = 0;
  bool _disposed = false;

  HomeState get state => _state;
  db.AppDatabase get _database => _databaseInstance ??= _databaseProvider();

  void _publish(HomeState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  Future<void> load() async {
    if (_disposed) return;
    final token = ++_loadToken;
    _publish(
      _state.copyWith(
        isLoading: true,
        loadFailed: false,
        clearActionError: true,
      ),
    );
    try {
      final result = await _loadJourneys(_database);
      if (_disposed || token != _loadToken) return;
      if (!result.succeeded) {
        _publish(_state.copyWith(isLoading: false, loadFailed: true));
        return;
      }
      final pinned = result.pinnedJourneys;
      _publish(
        HomeState(
          journeys: [...pinned, ...result.unpinnedJourneys],
          isLoading: true,
        ),
      );
      // LocationService.sortJourneys sorts its argument in place. Database
      // results may be immutable lists, so isolate sorting from that input.
      final sorted = await _sortJourneys(List.of(result.unpinnedJourneys));
      if (_disposed || token != _loadToken) return;
      _publish(HomeState(journeys: [...pinned, ...sorted]));
    } on Exception {
      if (!_disposed && token == _loadToken) {
        _publish(_state.copyWith(isLoading: false, loadFailed: true));
      }
    }
  }

  Future<void> delete(int id) async {
    if (_disposed) return;
    try {
      if (await _deleteJourney(_database, id)) {
        await load();
      } else {
        _publish(_state.copyWith(actionError: 'Could not delete this trip.'));
      }
    } on Exception {
      if (!_disposed) {
        _publish(_state.copyWith(actionError: 'Could not delete this trip.'));
      }
    }
  }

  Future<void> togglePin(int id, bool isPinned) async {
    if (_disposed) return;
    try {
      if (await _togglePin(_database, id, isPinned)) {
        await load();
      } else {
        _publish(_state.copyWith(actionError: 'Could not update this trip.'));
      }
    } on Exception {
      if (!_disposed) {
        _publish(_state.copyWith(actionError: 'Could not update this trip.'));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadToken++;
    super.dispose();
  }
}
