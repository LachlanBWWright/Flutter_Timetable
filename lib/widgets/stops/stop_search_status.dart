import 'package:flutter/material.dart';

import '../../transit/transit.dart';
import 'stops_search_repository.dart';

class StopSearchStatus extends StatelessWidget {
  const StopSearchStatus({
    super.key,
    required this.snapshot,
    required this.onCancel,
    required this.onRetry,
  });
  final RegionalStopSearchSnapshot snapshot;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    if (!snapshot.isLoading && snapshot.errors.isEmpty && !snapshot.cancelled) {
      return const SizedBox.shrink();
    }
    final failed = snapshot.errors.keys
        .map((region) => region.shortLabel)
        .join(', ');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (snapshot.isLoading) const LinearProgressIndicator(),
          Semantics(
            liveRegion: true,
            child: Text(
              snapshot.cancelled
                  ? 'Loading stopped. Available stops are kept.'
                  : failed.isNotEmpty
                  ? 'Could not update $failed. ${snapshot.stops.isEmpty ? 'Check your connection and retry.' : 'Available stops are still shown.'}'
                  : snapshot.progress ??
                        (snapshot.isStale
                            ? 'Updating saved stops…'
                            : 'Loading stops…'),
            ),
          ),
          if (snapshot.isLoading)
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel loading'),
            ),
          if (snapshot.errors.isNotEmpty || snapshot.cancelled)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
