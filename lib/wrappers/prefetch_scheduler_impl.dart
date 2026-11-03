import 'dart:async';
import 'dart:collection';

enum PrefetchQueueKind { staticData, tripPlanner }

class PrefetchScheduler {
  PrefetchScheduler._();

  static final PrefetchScheduler instance = PrefetchScheduler._();

  final Queue<_PrefetchJob> _staticQueue = Queue<_PrefetchJob>();
  final Queue<_PrefetchJob> _tripPlannerQueue = Queue<_PrefetchJob>();
  final Set<String> _queuedOrInflightKeys = <String>{};
  final Map<String, DateTime> _backoffUntil = <String, DateTime>{};
  int _activeStaticJobs = 0;
  int _activeTripPlannerJobs = 0;

  static const int _maxStaticJobs = 1;
  static const int _maxTripPlannerJobs = 2;
  static const Duration _baseBackoff = Duration(minutes: 2);
  static const int _maxBackoffEntries = 500;
  static const int _maxQueuedJobsPerKind = 200;

  void _pruneBackoff(DateTime now) {
    _backoffUntil.removeWhere((_, until) => !now.isBefore(until));
  }

  void _setBackoffUntil(String key, DateTime value) {
    final now = DateTime.now();
    _pruneBackoff(now);
    if (!_backoffUntil.containsKey(key) &&
        _backoffUntil.length >= _maxBackoffEntries) {
      String? earliestKey;
      DateTime? earliestValue;
      for (final entry in _backoffUntil.entries) {
        if (earliestValue == null || entry.value.isBefore(earliestValue)) {
          earliestKey = entry.key;
          earliestValue = entry.value;
        }
      }
      if (earliestKey != null) _backoffUntil.remove(earliestKey);
    }
    _backoffUntil[key] = value;
  }

  Future<void> _runJob(_PrefetchJob job) async {
    try {
      await job.run();
      _backoffUntil.remove(job.key);
    } catch (_) {
      _setBackoffUntil(job.key, DateTime.now().add(_baseBackoff));
    } finally {
      _queuedOrInflightKeys.remove(job.key);
      switch (job.kind) {
        case PrefetchQueueKind.staticData:
          _activeStaticJobs -= 1;
          break;
        case PrefetchQueueKind.tripPlanner:
          _activeTripPlannerJobs -= 1;
          break;
      }
      _pump();
    }
  }

  void enqueueStatic({
    required String key,
    required Future<void> Function() job,
    int priority = 100,
  }) {
    _enqueue(
      _staticQueue,
      _PrefetchJob(
        kind: PrefetchQueueKind.staticData,
        key: 'static:$key',
        priority: priority,
        run: job,
      ),
    );
  }

  void enqueueTripPlanner({
    required String key,
    required Future<void> Function() job,
    int priority = 100,
  }) {
    _enqueue(
      _tripPlannerQueue,
      _PrefetchJob(
        kind: PrefetchQueueKind.tripPlanner,
        key: 'trip:$key',
        priority: priority,
        run: job,
      ),
    );
  }

  void _enqueue(Queue<_PrefetchJob> queue, _PrefetchJob job) {
    if (_queuedOrInflightKeys.contains(job.key)) {
      return;
    }
    final now = DateTime.now();
    _pruneBackoff(now);
    final backoffUntil = _backoffUntil[job.key];
    if (backoffUntil != null && DateTime.now().isBefore(backoffUntil)) {
      return;
    }

    if (queue.length >= _maxQueuedJobsPerKind) {
      final lowestPriority = queue.last;
      if (job.priority >= lowestPriority.priority) return;
      queue.removeLast();
      _queuedOrInflightKeys.remove(lowestPriority.key);
    }
    _queuedOrInflightKeys.add(job.key);
    queue.add(job);
    _sortQueue(queue);
    scheduleMicrotask(_pump);
  }

  void _pump() {
    while (_activeStaticJobs < _maxStaticJobs && _staticQueue.isNotEmpty) {
      _start(_staticQueue.removeFirst());
    }
    while (_activeTripPlannerJobs < _maxTripPlannerJobs &&
        _tripPlannerQueue.isNotEmpty) {
      _start(_tripPlannerQueue.removeFirst());
    }
  }

  void _start(_PrefetchJob job) {
    switch (job.kind) {
      case PrefetchQueueKind.staticData:
        _activeStaticJobs += 1;
        break;
      case PrefetchQueueKind.tripPlanner:
        _activeTripPlannerJobs += 1;
        break;
    }

    unawaited(_runJob(job));
  }

  void _sortQueue(Queue<_PrefetchJob> queue) {
    final sorted = queue.toList()
      ..sort((left, right) => left.priority.compareTo(right.priority));
    queue
      ..clear()
      ..addAll(sorted);
  }
}

class _PrefetchJob {
  const _PrefetchJob({
    required this.kind,
    required this.key,
    required this.priority,
    required this.run,
  });

  final PrefetchQueueKind kind;
  final String key;
  final int priority;
  final Future<void> Function() run;
}
