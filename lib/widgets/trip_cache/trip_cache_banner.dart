import 'package:flutter/material.dart';

/// Warns when departure times cannot be confirmed.
class TripCacheBanner extends StatelessWidget {
  const TripCacheBanner({
    super.key,
    this.isStale = false,
    this.isExpired = false,
    this.isOffline = false,
    this.isLoading = false,
    this.hasUsableData = true,
    required this.onRetry,
  });

  final bool isStale;
  final bool isExpired;
  final bool isOffline;
  final bool isLoading;
  final bool hasUsableData;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final warning = isStale || isExpired || isOffline;
    if (!warning) return const SizedBox.shrink();
    final message = isExpired
        ? 'Refresh to see current departures.'
        : (isStale || isOffline) && hasUsableData
        ? 'Departure times may be out of date. Refresh to check.'
        : 'Unable to load departures. Please try again.';
    return Semantics(
      liveRegion: warning,
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
