import 'package:flutter/material.dart';

import '../services/realtime_service.dart';

/// Shows loading, missing vehicles, or information that may be out of date.
class RealtimeStatusBanner extends StatelessWidget {
  const RealtimeStatusBanner({
    super.key,
    required this.metadata,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyMessage = 'No live vehicles available.',
    this.onRetry,
  });

  final RealtimeSnapshotMetadata metadata;
  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final updatedAt = metadata.fetchedAt;
    final String message;
    if (isLoading) {
      message = updatedAt == null
          ? 'Loading live data…'
          : 'Refreshing live data…';
    } else if (metadata.isUnavailable) {
      message = 'Live data is unavailable right now.';
    } else if (metadata.isStale) {
      message = 'Live information may be out of date. Please retry.';
    } else if (metadata.isPartial) {
      message = 'Some live updates are unavailable.';
    } else if (isEmpty) {
      message = emptyMessage;
    } else {
      return const SizedBox.shrink();
    }

    final hasProblem =
        metadata.isUnavailable || metadata.isStale || metadata.isPartial;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(hasProblem ? Icons.info_outline : Icons.schedule, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(message, style: theme.textTheme.bodySmall),
              ),
            ),
            if (hasProblem && onRetry != null)
              TextButton(
                onPressed: isLoading ? null : onRetry,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
