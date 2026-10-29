import 'package:flutter/material.dart';

import '../active_journey/screen.dart';
import '../active_journey/session.dart';
import '../constants/transport_modes.dart';
import '../schema/database.dart' show Journey;
import '../widgets/realtime_map_widget.dart';
import 'controller.dart';
import 'models.dart';
import 'provider.dart';

class VehicleFinderScreen extends StatefulWidget {
  const VehicleFinderScreen({
    super.key,
    this.controller,
    this.supported = true,
    this.journeys = const [],
    this.session,
  });
  final VehicleFinderController? controller;
  final bool supported;
  final List<Journey> journeys;
  final ActiveJourneySession? session;

  @override
  State<VehicleFinderScreen> createState() => _VehicleFinderScreenState();
}

class _VehicleFinderScreenState extends State<VehicleFinderScreen>
    with WidgetsBindingObserver {
  late final VehicleFinderController _controller;
  ActiveJourneySession get _session =>
      widget.session ?? ActiveJourneySession.instance;
  late final Listenable _changes = Listenable.merge([_controller, _session]);
  TransportMode _mode = TransportMode.train;
  bool _routeWasCurrent = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? VehicleFinderController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (_routeWasCurrent && !current && _controller.running) {
      // Route changes can occur during build. Defer listener notifications.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.stop();
      });
    }
    _routeWasCurrent = current;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.detached) &&
        _controller.running) {
      _controller.stop(
        message:
            'Search paused while the app was away. Start again to continue.',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.stop();
    }
    super.dispose();
  }

  void _showMap(VehicleCandidate candidate) {
    final vehicle = candidate.vehicle;
    _controller.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RealtimeMapPage(
          transportMode: vehicle.mode,
          vehicleId: vehicle.id,
          getAllVehiclesAggregated: () => finderServiceMapVehicles(vehicle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Find my vehicle')),
    body: ListenableBuilder(
      listenable: _changes,
      builder: (context, _) {
        if (!widget.supported) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This experiment currently supports New South Wales. Choose NSW in Settings to try it.',
            ),
          );
        }
        final confirmed = _session.hasSelection ? _controller.confirmed : null;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Experimental · NSW',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Find a likely vehicle by comparing your movement with live positions. Nearby vehicles can look similar, so you choose the match.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Location is used only during this search and kept on your device. Searching stops after three minutes or when you leave this screen.',
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<TransportMode>(
              initialValue: _mode,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Transport type',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final mode in TransportMode.values)
                  DropdownMenuItem(value: mode, child: Text(mode.displayName)),
              ],
              onChanged: _controller.running
                  ? null
                  : (mode) {
                      if (mode != null) setState(() => _mode = mode);
                    },
            ),
            const SizedBox(height: 16),
            if (_controller.running) ...[
              const LinearProgressIndicator(
                semanticsLabel: 'Comparing live vehicle positions',
              ),
              const SizedBox(height: 12),
            ],
            Text(_controller.status),
            if (_controller.location case final location?) ...[
              const SizedBox(height: 8),
              Text('Location accuracy: about ${location.accuracy.round()} m'),
            ],
            if (_controller.error case final error?) ...[
              const SizedBox(height: 12),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (_controller.running)
              OutlinedButton.icon(
                onPressed: () => _controller.stop(),
                icon: const Icon(Icons.stop),
                label: const Text('Stop search'),
              )
            else
              FilledButton.icon(
                onPressed: () => _controller.start(_mode),
                icon: const Icon(Icons.radar),
                label: const Text('Start search'),
              ),
            if (_session.hasSelection)
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ActiveJourneyScreen(
                      journeys: widget.journeys,
                      session: _session,
                    ),
                  ),
                ),
                child: Text(
                  _session.selectedKey != null
                      ? 'View current journey'
                      : _session.service?.matches.isNotEmpty == true
                      ? 'Choose your saved journey'
                      : 'View running service',
                ),
              ),
            if (confirmed != null) ...[
              const SizedBox(height: 20),
              Text(
                'Selected: ${confirmed.vehicle.title}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: () => _showMap(confirmed),
                icon: const Icon(Icons.map_outlined),
                label: const Text('View on map'),
              ),
            ],
            for (final candidate in _controller.candidates)
              _candidateCard(candidate),
          ],
        );
      },
    ),
  );

  Widget _candidateCard(VehicleCandidate candidate) {
    final vehicle = candidate.vehicle;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.likely ? 'Likely your vehicle' : 'Possible vehicle',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(vehicle.title, style: Theme.of(context).textTheme.titleMedium),
            if (vehicle.route?.isNotEmpty == true)
              Text('Route ${vehicle.route}'),
            Text(
              '${candidate.distance.round()} m from your location at its last report',
            ),
            Text(
              '${candidate.observations} distinct live observations compared',
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                _controller.confirm(candidate);
                final selected = _controller.confirmed;
                if (selected != null) {
                  _session.selectVehicle(selected.vehicle, widget.journeys);
                }
              },
              child: const Text('This is my vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
