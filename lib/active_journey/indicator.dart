import 'package:flutter/material.dart';

import '../schema/database.dart' show Journey;
import 'screen.dart';
import 'session.dart';

class ActiveJourneyIndicator extends StatelessWidget {
  const ActiveJourneyIndicator({
    super.key,
    required this.journey,
    required this.reverse,
    this.session,
  });
  final Journey journey;
  final bool reverse;
  final ActiveJourneySession? session;
  @override
  Widget build(BuildContext context) {
    final active = session ?? ActiveJourneySession.instance;
    return ListenableBuilder(
      listenable: active,
      builder: (context, _) {
        final label = active.labelFor(journey, reverse);
        if (label == null) return const SizedBox.shrink();
        return TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(48, 48),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ActiveJourneyScreen(
                journeys: active.journeys,
                session: active,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
