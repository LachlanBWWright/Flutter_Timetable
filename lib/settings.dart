import 'package:flutter/material.dart';
import 'widgets/realtime_widgets.dart';
import 'widgets/realtime_map_widget.dart';
import 'widgets/stops_widgets.dart';
import 'services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAlphabeticalSorting = false;

  @override
  void initState() {
    super.initState();
    _loadSortingPreference();
  }

  Future<void> _loadSortingPreference() async {
    final isAlphabetical = await LocationService.isAlphabeticalSorting();
    setState(() {
      _isAlphabeticalSorting = isAlphabetical;
    });
  }

  Future<void> _updateSortingPreference(bool value) async {
    await LocationService.setSortingPreference(value);
    setState(() {
      _isAlphabeticalSorting = value;
    });
  }

  void _navigateToRealtimeMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RealtimeMapWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map access card
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Transport Map',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'View real-time vehicle positions on an interactive map',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRealtimeMap(context),
                        icon: const Icon(Icons.map),
                        label: const Text('Open Realtime Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Trip sorting preference card
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Sorting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how trips are sorted on the main page',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Sort alphabetically'),
                      subtitle: Text(
                        _isAlphabeticalSorting
                            ? 'Trips sorted by origin station name'
                            : 'Trips sorted by closest station to your location',
                      ),
                      value: _isAlphabeticalSorting,
                      onChanged: _updateSortingPreference,
                    ),
                  ],
                ),
              ),
            ),
            const StopsManagementWidget(),
            const StopsSearchWidget(),
            const RealtimeInfoWidget(),
          ],
        ),
      ),
    );
  }
}
