import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';

class DebugStatusBanner extends StatelessWidget {
  final DebugStatusBannerData banner;

  const DebugStatusBanner({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (banner.tone) {
      DebugStatusTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.info_outline,
      ),
      DebugStatusTone.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.warning_amber_rounded,
      ),
      DebugStatusTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banner.title != null)
                  Text(
                    banner.title!,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(banner.message, style: TextStyle(color: foreground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
