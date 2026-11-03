import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lbww_flutter/logs/logger.dart';

mixin GuardedState<T extends StatefulWidget> on State<T> {
  void _reportError(
    String operation,
    Object error,
    StackTrace stackTrace, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (onError != null) {
      onError(error, stackTrace);
    } else {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'GuardedState',
          context: ErrorDescription(operation),
        ),
      );
    }
    safeLogError(
      'Unexpected guarded-state error during $operation',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void runGuarded(
    VoidCallback callback, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      callback();
    } catch (error, stackTrace) {
      _reportError('runGuarded', error, stackTrace, onError: onError);
    }
  }

  Future<R?> runAsyncGuarded<R>(
    Future<R> Function() callback, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      _reportError('runAsyncGuarded', error, stackTrace, onError: onError);
      return null;
    }
  }

  Future<R> runAsyncGuardedWithFallback<R>(
    Future<R> Function() callback,
    R fallback, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      _reportError(
        'runAsyncGuardedWithFallback',
        error,
        stackTrace,
        onError: onError,
      );
      return fallback;
    }
  }

  void guardedSetState(
    VoidCallback update, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (!mounted) {
      return;
    }
    try {
      setState(update);
    } catch (error, stackTrace) {
      _reportError('guardedSetState', error, stackTrace, onError: onError);
    }
  }

  ScaffoldMessengerState? get _messenger => ScaffoldMessenger.maybeOf(context);

  void addListenerSafely(Listenable listenable, VoidCallback listener) {
    try {
      listenable.addListener(listener);
    } catch (error, stackTrace) {
      _reportError('addListenerSafely', error, stackTrace);
    }
  }

  void removeListenerSafely(Listenable listenable, VoidCallback listener) {
    try {
      listenable.removeListener(listener);
    } catch (error, stackTrace) {
      _reportError('removeListenerSafely', error, stackTrace);
    }
  }

  void disposeChangeNotifierSafely(ChangeNotifier notifier) {
    try {
      notifier.dispose();
    } catch (error, stackTrace) {
      _reportError('disposeChangeNotifierSafely', error, stackTrace);
    }
  }

  void disposeFocusNodeSafely(FocusNode node) {
    try {
      node.dispose();
    } catch (error, stackTrace) {
      _reportError('disposeFocusNodeSafely', error, stackTrace);
    }
  }

  void addPostFrameCallbackSafely(void Function(Duration) callback) {
    try {
      WidgetsBinding.instance.addPostFrameCallback(callback);
    } catch (error, stackTrace) {
      _reportError('addPostFrameCallbackSafely', error, stackTrace);
    }
  }

  Future<R?> pushPage<R>(WidgetBuilder builder) {
    if (!mounted) {
      return Future<R?>.value(null);
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      return Future<R?>.value(null);
    }
    try {
      return navigator.push<R>(MaterialPageRoute(builder: builder));
    } catch (error, stackTrace) {
      _reportError('pushPage', error, stackTrace);
      return Future<R?>.value(null);
    }
  }

  void popPage<R extends Object?>([R? result]) {
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) {
      try {
        navigator?.pop(result);
      } catch (error, stackTrace) {
        _reportError('popPage', error, stackTrace);
      }
    }
  }

  void showSnackBar(SnackBar snackBar) {
    if (!mounted) {
      return;
    }
    try {
      _messenger?.showSnackBar(snackBar);
    } catch (error, stackTrace) {
      _reportError('showSnackBar', error, stackTrace);
    }
  }

  void popUntilFirstPage() {
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      return;
    }
    try {
      navigator.popUntil((route) => route.isFirst);
    } catch (error, stackTrace) {
      _reportError('popUntilFirstPage', error, stackTrace);
    }
  }

  void showSnackBarMessage(
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  Future<bool> setClipboardTextSafely(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (error, stackTrace) {
      _reportError('setClipboardTextSafely', error, stackTrace);
      return false;
    }
  }

  void hideCurrentSnackBar() {
    _messenger?.hideCurrentSnackBar();
  }

  void requestFocus(FocusNode node) {
    if (!mounted || !node.canRequestFocus) {
      return;
    }
    try {
      FocusScope.of(context).requestFocus(node);
    } catch (error, stackTrace) {
      _reportError('requestFocus', error, stackTrace);
    }
  }

  void clearFocus([FocusNode? node]) {
    if (node != null) {
      try {
        node.unfocus();
      } catch (error, stackTrace) {
        _reportError('clearFocus', error, stackTrace);
      }
      return;
    }
    if (!mounted) {
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (error, stackTrace) {
        _reportError('clearFocus', error, stackTrace);
      }
      return;
    }
    try {
      FocusScope.of(context).unfocus();
    } catch (error, stackTrace) {
      _reportError('clearFocus', error, stackTrace);
    }
  }
}
