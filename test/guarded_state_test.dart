import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';

class _GuardedTestWidget extends StatefulWidget {
  const _GuardedTestWidget({required this.onError, super.key});

  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  State<_GuardedTestWidget> createState() => _GuardedTestWidgetState();
}

class _GuardedTestWidgetState extends State<_GuardedTestWidget>
    with GuardedState<_GuardedTestWidget> {
  late final Future<String?> completed = runAsyncGuarded<String?>(
    () async => throw StateError('boom'),
    onError: widget.onError,
  );

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('runAsyncGuarded reports errors and returns null', (
    tester,
  ) async {
    Object? capturedError;
    StackTrace? capturedStackTrace;

    await tester.pumpWidget(
      MaterialApp(
        home: _GuardedTestWidget(
          onError: (error, stackTrace) {
            capturedError = error;
            capturedStackTrace = stackTrace;
          },
        ),
      ),
    );

    final state = tester.state<_GuardedTestWidgetState>(
      find.byType(_GuardedTestWidget),
    );
    final result = await state.completed;

    expect(result, isNull);
    expect(capturedError, isA<StateError>());
    expect(capturedStackTrace, isNotNull);
  });
}
