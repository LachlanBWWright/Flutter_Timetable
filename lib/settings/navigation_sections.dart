part of '../settings.dart';

extension _SettingsNavigationSections on _SettingsScreenState {
  Widget _buildMapSection() => ListTile(
    leading: const Icon(Icons.map_outlined),
    title: const Text('Live map'),
    trailing: const Icon(Icons.chevron_right),
    onTap: _navigateToRealtimeMap,
  );

  Widget _buildHomeStopSection() => ListTile(
    leading: const Icon(Icons.home_outlined),
    title: const Text('Home stop'),
    trailing: const Icon(Icons.chevron_right),
    onTap: _navigateToSetHomeStop,
  );

  Widget _buildTransportOptionsSection() {
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transport Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('NSW TrainLink'),
              subtitle: const Text(
                'Show booked regional and interstate train services in the trip creator.',
              ),
              value: TransportPreferencesService.showNswTrainLink.value,
              onChanged: _isSavingPreference ? null : _toggleNswTrainLink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperOptionsSection() {
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developer Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Toggle visibility of debug information throughout the app',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: DebugService.showDebugData,
              builder: (context, showDebug, child) {
                return SwitchListTile(
                  title: const Text('Show debug data'),
                  value: showDebug,
                  onChanged: _isSavingPreference ? null : _toggleDebugData,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Standalone Debug Pages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openDebugBrowser(DebugEntityType.stop),
                  icon: const Icon(Icons.place),
                  label: const Text('Browse stop debug pages'),
                  style: ButtonStyles.elevated(Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _openDebugBrowser(DebugEntityType.route),
                  icon: const Icon(Icons.alt_route),
                  label: const Text('Browse route debug pages'),
                  style: ButtonStyles.elevated(Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _openDebugBrowser(DebugEntityType.trip),
                  icon: const Icon(Icons.route),
                  label: const Text('Browse trip debug pages'),
                  style: ButtonStyles.elevated(Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _openDebugBrowser(DebugEntityType.vehicle),
                  icon: const Icon(Icons.directions_bus),
                  label: const Text('Browse vehicle debug pages'),
                  style: ButtonStyles.elevated(Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
