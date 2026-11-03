import 'package:flutter/material.dart';

import '../services/app_bootstrap_service.dart';

class BootstrapStatusBanner extends StatefulWidget {
  const BootstrapStatusBanner({super.key, this.onRetry});

  final Future<void> Function()? onRetry;

  @override
  State<BootstrapStatusBanner> createState() => _BootstrapStatusBannerState();
}

class _BootstrapStatusBannerState extends State<BootstrapStatusBanner> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await (widget.onRetry ?? AppBootstrapService.retryFailedStages)();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<BootstrapReport>(
    valueListenable: AppBootstrapService.report,
    builder: (context, report, _) {
      if (!report.hasFailures) return const SizedBox.shrink();
      final stages = report.failures.map((failure) => failure.stage).join(', ');
      return Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not load $stages. Some saved settings may be unavailable.',
                  ),
                ),
                TextButton(
                  onPressed: _retrying ? null : _retry,
                  child: Text(_retrying ? 'Retrying…' : 'Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
