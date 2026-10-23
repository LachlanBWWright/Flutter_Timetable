part of '../trip_leg_detail_screen.dart';

/// Composes diagnostic previews and their navigation and copy actions.
extension _DebugCards on _TripLegDetailScreenState {
  Widget _buildDebugCards(Leg leg, String? transportId, Color modeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebug, child) {
        if (!showDebug) return const SizedBox.shrink();
        final trip = widget.trip;
        return Column(
          children: [
            if (transportId != null && transportId.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter vehicle debug data by the active trip or route',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Filter'),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: _filterByLegRoute,
                        onChanged: (value) => guardedSetState(() {
                          _filterByLegRoute = value;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (trip != null) ...[
              _DebugTextCard(
                title: 'Trip debug data',
                description:
                    'Full Trip data (includes legs and raw JSON below):',
                text: _tripDebugPreviewString(trip),
                actions: [
                  IconButton(
                    tooltip: 'Open standalone trip debug page',
                    onPressed: () => _openTripDebugPage(leg),
                    icon: const Icon(Icons.open_in_new, size: 18),
                  ),
                  IconButton(
                    tooltip: 'Open trip debug browser',
                    onPressed: () => _openTripDebugBrowser(leg),
                    icon: const Icon(Icons.manage_search, size: 18),
                  ),
                  IconButton(
                    tooltip: 'Copy trip debug to clipboard',
                    onPressed: () => _copyDebugText(
                      text: _tripDebugString(trip),
                      successMessage: 'Copied trip debug data to clipboard',
                      failureMessage: 'Failed to copy trip debug data',
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _DebugTextCard(
              title: 'Route debug data',
              description: 'Active route/transport details for this leg:',
              text: _routeDebugPreviewString(leg),
              actions: [
                IconButton(
                  tooltip: 'Open standalone route debug page',
                  onPressed: () => _openRouteDebugPage(leg),
                  icon: const Icon(Icons.open_in_new, size: 18),
                ),
                IconButton(
                  tooltip: 'Open route debug browser',
                  onPressed: () => _openRouteDebugBrowser(leg),
                  icon: const Icon(Icons.manage_search, size: 18),
                ),
                IconButton(
                  tooltip: 'Copy route debug to clipboard',
                  onPressed: () => _copyDebugText(
                    text: _routeDebugString(leg),
                    successMessage: 'Copied route debug data to clipboard',
                    failureMessage: 'Failed to copy route debug data',
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DebugTextCard(
              title: 'Leg debug data',
              description:
                  'Leg details (select or copy). Useful for debugging.',
              descriptionSpacing: 6,
              text: _legDebugPreviewString(leg),
              actions: [
                IconButton(
                  tooltip: 'Copy debug text to clipboard',
                  onPressed: () => _copyDebugText(
                    text: _legDebugString(leg),
                    successMessage: 'Copied leg debug data to clipboard',
                    failureMessage: 'Failed to copy to clipboard',
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVehicleDebugCard(leg, transportId, modeColor),
          ],
        );
      },
    );
  }
}

/// Shared presentation for the trip, route, and leg diagnostic previews.
class _DebugTextCard extends StatelessWidget {
  final String title;
  final String description;
  final String text;
  final List<Widget> actions;
  final double descriptionSpacing;

  const _DebugTextCard({
    required this.title,
    required this.description,
    required this.text,
    required this.actions,
    this.descriptionSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
            SizedBox(height: descriptionSpacing),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
