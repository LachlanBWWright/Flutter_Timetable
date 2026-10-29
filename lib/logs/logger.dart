import 'package:logger/logger.dart';

/// Global logger instance for the application
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: null,
    errorMethodCount: null,
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
  ),
);

final safeLogger = SafeLogger(logger);

class SafeLogger {
  const SafeLogger(this._logger);

  final Logger _logger;

  void d(Object? message) {
    try {
      _logger.d(message);
    } catch (_) {}
  }

  void i(Object? message) {
    try {
      _logger.i(message);
    } catch (_) {}
  }

  void w(Object? message) {
    try {
      _logger.w(message);
    } catch (_) {}
  }

  void e(Object? message, {Object? error, StackTrace? stackTrace}) {
    try {
      _logger.e(message, error: error, stackTrace: stackTrace);
    } catch (_) {}
  }
}

void safeLogDebug(Object? message) {
  safeLogger.d(message);
}

void safeLogInfo(Object? message) {
  safeLogger.i(message);
}

void safeLogWarning(Object? message) {
  safeLogger.w(message);
}

void safeLogError(Object? message, {Object? error, StackTrace? stackTrace}) {
  safeLogger.e(message, error: error, stackTrace: stackTrace);
}
