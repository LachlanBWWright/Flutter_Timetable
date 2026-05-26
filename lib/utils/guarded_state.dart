// ignore_for_file: avoid_shadowing_type_parameters, catch_unknown_dynamic_calls

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin GuardedState<T extends StatefulWidget> on State<T> {
  void runGuarded(VoidCallback callback) {
    try {
      callback();
    } catch (_) {}
  }

  Future<T?> runAsyncGuarded<T>(
    Future<T> Function() callback, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      return null;
    }
  }

  Future<T> runAsyncGuardedWithFallback<T>(
    Future<T> Function() callback,
    T fallback, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      return fallback;
    }
  }

  void guardedSetState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    try {
      setState(update);
    } catch (_) {}
  }

  ScaffoldMessengerState? get _messenger => ScaffoldMessenger.maybeOf(context);

  void addListenerSafely(Listenable listenable, VoidCallback listener) {
    try {
      listenable.addListener(listener);
    } catch (_) {}
  }

  void removeListenerSafely(Listenable listenable, VoidCallback listener) {
    try {
      listenable.removeListener(listener);
    } catch (_) {}
  }

  void disposeChangeNotifierSafely(ChangeNotifier notifier) {
    try {
      notifier.dispose();
    } catch (_) {}
  }

  void disposeFocusNodeSafely(FocusNode node) {
    try {
      node.dispose();
    } catch (_) {}
  }

  void addPostFrameCallbackSafely(void Function(Duration) callback) {
    try {
      WidgetsBinding.instance.addPostFrameCallback(callback);
    } catch (_) {}
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
    } catch (_) {
      return Future<R?>.value(null);
    }
  }

  void popPage<R extends Object?>([R? result]) {
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) {
      try {
        navigator?.pop(result);
      } catch (_) {}
    }
  }

  void showSnackBar(SnackBar snackBar) {
    if (!mounted) {
      return;
    }

    _messenger?.showSnackBar(snackBar);
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
    } catch (_) {
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
    } catch (_) {}
  }

  void clearFocus([FocusNode? node]) {
    if (node != null) {
      try {
        node.unfocus();
      } catch (_) {}
      return;
    }
    if (!mounted) {
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (_) {}
      return;
    }
    try {
      FocusScope.of(context).unfocus();
    } catch (_) {}
  }
}
