import 'dart:async';

import 'package:http/http.dart' as http;

import '../logs/logger.dart';
import '../transit/errors/transit_failure.dart';
import 'app_http_retry_policy.dart';

class AppHttpClient {
  const AppHttpClient._();

  static const Duration _defaultTimeout = Duration(seconds: 20);
  static const int _defaultRetries = 2;
  static Future<http.Response?> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int retries = _defaultRetries,
    http.Client? client,
  }) async {
    final attempts = retries.clamp(0, 4).toInt() + 1;
    final ownsClient = client == null;
    final activeClient = client ?? http.Client();
    Object? lastError;
    StackTrace? lastStackTrace;

    try {
      for (var attempt = 0; attempt < attempts; attempt++) {
        try {
          final response = await _getAttempt(
            activeClient,
            uri,
            headers: headers,
            timeout: timeout,
          );
          if (!AppHttpRetryPolicy.retryableStatusCodes.contains(
                response.statusCode,
              ) ||
              attempt == attempts - 1) {
            return response;
          }
          final delay = AppHttpRetryPolicy.delayFor(attempt, response);
          if (delay == null) return response;
          await Future<void>.delayed(delay);
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          if (attempt == attempts - 1) {
            safeLogError(
              'HTTP GET failed for $uri after $attempts attempt(s)',
              error: error,
              stackTrace: stackTrace,
            );
            return null;
          }
          await Future<void>.delayed(AppHttpRetryPolicy.backoffDelay(attempt));
        }
      }
    } finally {
      if (ownsClient) activeClient.close();
    }

    safeLogError(
      'HTTP GET failed for $uri',
      error: lastError,
      stackTrace: lastStackTrace,
    );
    return null;
  }

  static Future<http.Response> _getAttempt(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
    required Duration timeout,
  }) {
    final abort = Completer<void>();
    final request = http.AbortableRequest(
      'GET',
      uri,
      abortTrigger: abort.future,
    );
    if (headers != null) request.headers.addAll(headers);

    final response = () async {
      final streamedResponse = await client.send(request);
      return http.Response.fromStream(streamedResponse);
    }();

    return response.timeout(
      timeout,
      onTimeout: () {
        _completeAbort(abort);
        throw TimeoutException('HTTP GET exceeded its deadline.', timeout);
      },
    );
  }

  /// Fetches a response while preserving a provider-specific failure reason.
  /// Use this at repository boundaries where an empty response would be
  /// indistinguishable from a valid empty feed.
  static Future<http.Response> getOrThrow(
    Uri uri, {
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int retries = _defaultRetries,
    http.Client? client,
  }) async {
    final response = await get(
      uri,
      headers: headers,
      timeout: timeout,
      retries: retries,
      client: client,
    );
    if (response == null) {
      throw const NetworkUnavailable(message: 'Network request failed.');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const InvalidCredentials(
        message: 'Provider credentials were rejected.',
      );
    }
    if (response.statusCode == 429) {
      throw const RateLimited(message: 'Provider rate limit exceeded.');
    }
    if (response.statusCode >= 500) {
      throw const ProviderUnavailable(
        message: 'Provider is temporarily unavailable.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InvalidProviderResponse(
        message: 'Provider returned HTTP ${response.statusCode}.',
      );
    }
    return response;
  }
}

/// HTTP client used by generated Chopper clients so they inherit the same
/// bounded request lifetime as the application client.
class BoundedHttpClient extends http.BaseClient {
  BoundedHttpClient({
    http.Client? inner,
    this.timeout = const Duration(seconds: 20),
  }) : _inner = inner ?? http.Client();

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final abort = Completer<void>();
    final requestBody = request.finalize();
    final innerRequest = _AbortableRequest(
      request: request,
      body: requestBody,
      abortTrigger: _combinedAbortTrigger(request, abort.future),
    );
    final sendBudget = timeout - stopwatch.elapsed;
    if (sendBudget <= Duration.zero) {
      _completeAbort(abort);
      throw TimeoutException('HTTP request exceeded its deadline.', timeout);
    }

    final response = await _inner
        .send(innerRequest)
        .timeout(
          sendBudget,
          onTimeout: () {
            _completeAbort(abort);
            throw TimeoutException(
              'HTTP request exceeded its deadline.',
              timeout,
            );
          },
        );

    final remaining = timeout - stopwatch.elapsed;
    if (remaining <= Duration.zero) {
      _completeAbort(abort);
      throw TimeoutException('HTTP request exceeded its deadline.', timeout);
    }
    final stream = _deadlineStream(response.stream, remaining, abort);
    return http.StreamedResponse(
      stream,
      response.statusCode,
      contentLength: response.contentLength,
      request: request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}

class _AbortableRequest extends http.BaseRequest with http.Abortable {
  _AbortableRequest({
    required http.BaseRequest request,
    required http.ByteStream body,
    required this.abortTrigger,
  }) : _body = body,
       super(request.method, request.url) {
    headers.addAll(request.headers);
    contentLength = request.contentLength;
    persistentConnection = request.persistentConnection;
    followRedirects = request.followRedirects;
    maxRedirects = request.maxRedirects;
  }

  final http.ByteStream _body;

  @override
  final Future<void>? abortTrigger;

  @override
  http.ByteStream finalize() {
    super.finalize();
    return _body;
  }
}

Future<void> _combinedAbortTrigger(
  http.BaseRequest request,
  Future<void> deadlineAbort,
) {
  final callerAbort = request is http.Abortable ? request.abortTrigger : null;
  if (callerAbort == null) return deadlineAbort;
  return Future.any<void>([callerAbort, deadlineAbort]);
}

Stream<List<int>> _deadlineStream(
  Stream<List<int>> source,
  Duration remaining,
  Completer<void> abort,
) {
  late final StreamController<List<int>> controller;
  StreamSubscription<List<int>>? subscription;
  var finished = false;
  late final Timer timer;

  void finishNormally() {
    if (finished) return;
    finished = true;
    timer.cancel();
    unawaited(controller.close());
  }

  timer = Timer(remaining, () {
    if (finished) return;
    finished = true;
    _completeAbort(abort);
    final activeSubscription = subscription;
    if (activeSubscription != null) unawaited(activeSubscription.cancel());
    controller.addError(
      TimeoutException('HTTP response body exceeded its deadline.'),
    );
    unawaited(controller.close());
  });

  controller = StreamController<List<int>>(
    onListen: () {
      if (finished) return;
      final sourceSubscription = source.listen(
        (chunk) {
          if (!finished) controller.add(chunk);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (finished) return;
          finished = true;
          timer.cancel();
          _completeAbort(abort);
          final activeSubscription = subscription;
          if (activeSubscription != null) {
            unawaited(activeSubscription.cancel());
          }
          controller.addError(error, stackTrace);
          unawaited(controller.close());
        },
        onDone: finishNormally,
      );
      subscription = sourceSubscription;
      // A synchronous source may have errored before listen() returned, when
      // the subscription was not yet available to cancel from onError.
      if (finished) unawaited(sourceSubscription.cancel());
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () async {
      if (!finished) {
        finished = true;
        timer.cancel();
        _completeAbort(abort);
      }
      await subscription?.cancel();
    },
  );
  return controller.stream;
}

void _completeAbort(Completer<void> abort) {
  if (!abort.isCompleted) abort.complete();
}
