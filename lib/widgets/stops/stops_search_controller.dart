import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../transit/transit.dart';

typedef StopsSearchRepository =
    Future<List<TransitStop>> Function(String query);

/// Immutable view of the latest stop search.
@immutable
class StopsSearchState {
  StopsSearchState({
    Iterable<TransitStop> results = const [],
    this.isSearching = false,
    this.hasFailed = false,
  }) : results = List.unmodifiable(results);

  final List<TransitStop> results;
  final bool isSearching;
  final bool hasFailed;
}

/// Debounces searches and rejects completions from superseded requests.
class StopsSearchController extends ChangeNotifier {
  StopsSearchController({
    required StopsSearchRepository repository,
    this.debounceDuration = const Duration(milliseconds: 300),
  }) : _repository = repository;

  StopsSearchRepository _repository;
  final Duration debounceDuration;
  StopsSearchState _state = StopsSearchState();
  StopsSearchState get state => _state;

  Timer? _debounce;
  int _generation = 0;
  bool _disposed = false;

  void updateRepository(StopsSearchRepository repository, String query) {
    if (_disposed) return;
    _repository = repository;
    search(query);
  }

  void search(String rawQuery) {
    if (_disposed) return;
    _debounce?.cancel();
    final generation = ++_generation;
    final query = rawQuery.trim();
    _setState(StopsSearchState(isSearching: query.isNotEmpty));
    if (query.isEmpty) return;
    _debounce = Timer(
      debounceDuration,
      () => unawaited(_run(query, generation)),
    );
  }

  void retry(String query) => search(query);

  void _setState(StopsSearchState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> _run(String query, int generation) async {
    if (_disposed || generation != _generation) return;
    try {
      final results = await _repository(query);
      if (_disposed || generation != _generation) return;
      _setState(StopsSearchState(results: results));
    } on Exception {
      if (_disposed || generation != _generation) return;
      _setState(StopsSearchState(hasFailed: true));
    }
  }

  /// Invalidates queued and in-flight work, including when the owner is removed.
  void invalidate() {
    _debounce?.cancel();
    _debounce = null;
    _generation++;
  }

  @override
  void dispose() {
    invalidate();
    _disposed = true;
    super.dispose();
  }
}
