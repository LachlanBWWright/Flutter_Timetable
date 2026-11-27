import 'package:flutter/material.dart';

import '../schema/database.dart' show Journey;
import 'recovery.dart';
import 'session.dart';

class ActiveJourneyRecoveryPrompt extends StatelessWidget {
  const ActiveJourneyRecoveryPrompt({
    super.key,
    required this.session,
    required this.journeys,
  });
  final ActiveJourneySession session;
  final List<Journey> journeys;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final recovery = session.recovery;
      if (recovery == null ||
          reconcileMatch(recovery.match, journeys) == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resume following ${recovery.title}?'),
                const Text(
                  'Checks live service updates without using location.',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => session.resumeRecovery(journeys),
                      child: const Text('Resume'),
                    ),
                    TextButton(
                      onPressed: session.dismissRecovery,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
