import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/transit/cache/shared_transit_cache.dart';
import 'package:lbww_flutter/transit/transit.dart';

class _StreamingClient extends http.BaseClient {
  final started = Completer<void>();
  final bodyCancelled = Completer<void>();
  final aborted = Completer<void>();
  late final body = StreamController<List<int>>(
    onCancel: () {
      if (!bodyCancelled.isCompleted) bodyCancelled.complete();
    },
  );
  int requests = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    if (request is http.Abortable) {
      unawaited(
        request.abortTrigger!.then((_) {
          if (!aborted.isCompleted) aborted.complete();
        }),
      );
    }
    body.add([1, 2, 3]);
    started.complete();
    return http.StreamedResponse(body.stream, 200);
  }
}

void main() {
  test(
    'already-cancelled waiters still observe late transport failures',
    () async {
      final cancellation = TransitCancellation()..cancel();
      final work = Completer<void>();
      final result = expectLater(
        cancellation.wait(work.future),
        throwsA(isA<TransitOperationCancelled>()),
      );
      await result;
      work.completeError(const NetworkUnavailable(message: 'Late failure'));
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'shared-cache downloads abort only when the last subscriber cancels',
    () async {
      final client = _StreamingClient();
      final cache = SharedTransitCache(
        endpoint: Uri.parse('https://cache.example/lookup'),
        hosts: {'provider.example'},
      );
      final uri = Uri.parse('https://provider.example/feed');
      final one = TransitCancellation();
      final two = TransitCancellation();
      final first = cache.lookup(uri, client: client, cancellation: one);
      final firstCancelled = expectLater(
        first,
        throwsA(isA<TransitOperationCancelled>()),
      );
      await client.started.future;
      final second = cache.lookup(uri, client: client, cancellation: two);
      final secondCancelled = expectLater(
        second,
        throwsA(isA<TransitOperationCancelled>()),
      );
      one.cancel();
      await firstCancelled;
      expect(client.aborted.isCompleted, isFalse);
      two.cancel();
      await secondCancelled;
      await client.aborted.future.timeout(const Duration(seconds: 1));
      await client.bodyCancelled.future.timeout(const Duration(seconds: 1));
      expect(client.requests, 1);
      await client.body.close();
      final retry = _StreamingClient();
      final token = TransitCancellation();
      final next = cache.lookup(uri, client: retry, cancellation: token);
      final nextCancelled = expectLater(
        next,
        throwsA(isA<TransitOperationCancelled>()),
      );
      await retry.started.future.timeout(const Duration(seconds: 1));
      token.cancel();
      await nextCancelled;
      await retry.bodyCancelled.future.timeout(const Duration(seconds: 1));
      await retry.body.close();
    },
  );

  test('cancelling an active body aborts HTTP and cancels the subscription without retrying', () async {
    final client = _StreamingClient();
    final cancellation = TransitCancellation();
    final response = AppHttpClient.getOrThrow(
      Uri.parse('https://example.com/feed'),
      client: client,
      retries: 3,
      cancellation: cancellation,
    );
    final cancelled = expectLater(
      response,
      throwsA(isA<TransitOperationCancelled>()),
    );
    await client.started.future;
    await Future<void>.delayed(Duration.zero);
    cancellation.cancel();
    await cancelled;
    await client.aborted.future.timeout(const Duration(seconds: 1));
    await client.bodyCancelled.future.timeout(const Duration(seconds: 1));
    expect(client.requests, 1);
    await client.body.close();
  });
}
