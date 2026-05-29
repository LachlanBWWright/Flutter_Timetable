import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';

class DebugReferenceTile extends StatelessWidget {
  final DebugEntityRef reference;

  const DebugReferenceTile({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    final subtitle = reference.subtitle;
    final reason = reference.reason;
    final request = reference.request;
    final inheritedLoader = _inheritLoader(context);
    final canOpen =
        reference.canOpen && request != null && inheritedLoader != null;
    final unavailableReason = !canOpen
        ? reason ??
              (request != null && inheritedLoader == null
                  ? 'Debug navigation unavailable in this context'
                  : null)
        : null;
    final subtitleParts = <String>[
      reference.entityId,
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
      if (unavailableReason != null) unavailableReason,
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
        canOpen ? Icons.link : Icons.link_off,
        color: canOpen ? null : Theme.of(context).disabledColor,
      ),
      trailing: canOpen
          ? const Icon(Icons.open_in_new)
          : const Icon(Icons.warning_amber_rounded),
      enabled: canOpen,
      onTap: !canOpen
          ? null
          : () {
              DebugNavigation.pushEntity(
                context,
                request: request,
                loader: inheritedLoader,
              );
            },
    );
  }

  DebugEntityPageLoader? _inheritLoader(BuildContext context) {
    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;
    if (args is DebugNavigationArgs) {
      return args.loader;
    }
    return null;
  }
}
