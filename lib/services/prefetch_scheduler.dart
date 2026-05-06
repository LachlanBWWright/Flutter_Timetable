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
    final backoffUntil = _backoffUntil[job.key];
    if (backoffUntil != null && DateTime.now().isBefore(backoffUntil)) {
      return;
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

    () async {
      try {
        await job.run();
        _backoffUntil.remove(job.key);
      } catch (_) {
        _backoffUntil[job.key] = DateTime.now().add(_baseBackoff);
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
    }();
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
