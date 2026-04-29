import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';

class DebugReferenceTile extends StatelessWidget {
  final DebugEntityRef reference;

  const DebugReferenceTile({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      reference.entityId,
      if (reference.subtitle != null && reference.subtitle!.isNotEmpty)
        reference.subtitle!,
      if (!reference.canOpen && reference.reason != null) reference.reason!,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(child: Text(reference.title)),
          const SizedBox(width: 12),
          Chip(
            label: Text(reference.entityType.label),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      subtitle: Text(subtitleParts.join(' • ')),
      leading: Icon(
        reference.canOpen ? Icons.link : Icons.link_off,
        color: reference.canOpen ? null : Theme.of(context).disabledColor,
      ),
      trailing: reference.canOpen
          ? const Icon(Icons.open_in_new)
          : const Icon(Icons.warning_amber_rounded),
      enabled: reference.canOpen,
      onTap: !reference.canOpen || reference.request == null
          ? null
          : () {
              DebugNavigation.pushEntity(
                context,
                request: reference.request!,
                loader: _inheritLoader(context),
              );
            },
    );
  }

  DebugEntityPageLoader _inheritLoader(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;
    if (args is! DebugNavigationArgs) {
      throw StateError(
        'Debug reference navigation requires DebugNavigationArgs',
      );
    }
    return args.loader;
  }
}
