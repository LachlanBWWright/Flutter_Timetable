import 'package:flutter/material.dart';
import 'widgets/realtime_widgets.dart';
import 'widgets/stops_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            StopsManagementWidget(),
            StopsSearchWidget(),
            RealtimeInfoWidget(),
          ],
        ),
      ),
    );
  }
}
