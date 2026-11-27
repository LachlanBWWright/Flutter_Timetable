import 'package:flutter/material.dart';

/// A stop selection surface shared by the trip form and home-stop picker.
class StopAccentCard extends StatelessWidget {
  const StopAccentCard({
    super.key,
    required this.child,
    this.accent,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = this.accent;
    return Card.outlined(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      color: accent == null
          ? colors.surface
          : Color.alphaBlend(
              accent.withValues(alpha: 0.10),
              colors.surfaceContainerLow,
            ),
      child: Stack(
        children: [
          child,
          if (accent != null)
            PositionedDirectional(
              top: 1,
              bottom: 1,
              start: 1,
              width: 4,
              child: IgnorePointer(child: ColoredBox(color: accent)),
            ),
        ],
      ),
    );
  }
}
