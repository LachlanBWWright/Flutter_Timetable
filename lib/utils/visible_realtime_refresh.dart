import 'dart:async';

import 'package:flutter/widgets.dart';

import '../logs/logger.dart';

/// Runs one refresh at a time while its route and application are visible.
/// Call [updateRoute] from the owner's didChangeDependencies.
class VisibleRealtimeRefresh extends WidgetsBindingObserver {
  VisibleRealtimeRefresh({
    required Future<void> Function() onRefresh,
    this.interval = const Duration(seconds: 30),
    this.enabled = true,
    this.refreshOnStart = true,
  }) : _onRefresh = onRefresh {
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  final Future<void> Function() _onRefresh;
  final Duration interval;
  final bool enabled;
  final bool refreshOnStart;
  bool _routeBound = false;
  Timer? _timer;
  bool _foreground = false;
  bool _routeVisible = false;
  bool _running = false;
  bool _disposed = false;
  bool _refreshPending = false;

  bool get isVisible => !_disposed && _foreground && _routeVisible;

  bool get _active => enabled && isVisible;

  void updateRoute(BuildContext context) {
    final visible = ModalRoute.of(context)?.isCurrent ?? true;
    final firstBinding = !_routeBound;
    _routeBound = true;
    if (_routeVisible == visible) return;
    _routeVisible = visible;
    if (firstBinding && !refreshOnStart && _active) {
      _timer = Timer(interval, _refresh);
      return;
    }
    _visibilityChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (_foreground == foreground) return;
    _foreground = foreground;
    _visibilityChanged();
  }

  void _visibilityChanged() {
    _timer?.cancel();
    _timer = null;
    if (!_active) {
      _refreshPending = false;
      return;
    }
    if (_running) {
      _refreshPending = true;
    } else {
      // Defer until after dependencies/build; refresh may notify listeners.
      _timer = Timer(Duration.zero, _refresh);
    }
  }

  Future<void> _refresh() async {
    _timer = null;
    if (!_active || _running) return;
    _running = true;
    try {
      await _onRefresh();
    } on Exception catch (error, stack) {
      safeLogError(
        'Visible realtime refresh failed',
        error: error,
        stackTrace: stack,
      );
    } finally {
      _running = false;
      if (_active) {
        final delay = _refreshPending ? Duration.zero : interval;
        _refreshPending = false;
        _timer = Timer(delay, _refresh);
      }
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }
}
