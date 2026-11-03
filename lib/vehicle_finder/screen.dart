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
  bool _routeWasCurrent = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? VehicleFinderController(searchDuration: null);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current != _routeWasCurrent) _scheduleSearchSync();
    _routeWasCurrent = current;
  }

  void _scheduleSearchSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final visible =
          _foreground &&
          (ModalRoute.of(context)?.isCurrent ?? true) &&
          widget.supported;
      if (!visible) {
        if (_controller.running) _controller.stop();
      } else if (!_controller.running && _controller.confirmed == null) {
        _controller.start();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _scheduleSearchSync();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _foreground = false;
      if (_controller.running) _controller.stop();
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
    appBar: AppBar(
      title: const Text('Find my vehicle'),
      actions: [
        if (widget.supported)
          IconButton(
            tooltip: 'Refresh nearby vehicles',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.stop();
              _controller.start();
            },
          ),
      ],
    ),
    body: ListenableBuilder(
      listenable: _changes,
      builder: (context, _) {
        if (!widget.supported) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Find my vehicle currently supports New South Wales. Choose NSW in Settings to use it.',
            ),
          );
        }
        final confirmed = _session.hasSelection ? _controller.confirmed : null;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Nearby vehicles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Trains, light rail, metro, buses and ferries'),
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
            if (!_controller.running && _controller.error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _controller.start(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
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
            if (_controller.candidates.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Nearby matches',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final candidate in _controller.candidates)
                _candidateRow(candidate),
            ],
          ],
        );
      },
    ),
  );

  IconData _modeIcon(TransportMode mode) => switch (mode) {
    TransportMode.train => Icons.train,
    TransportMode.lightrail => Icons.tram,
    TransportMode.metro => Icons.subway,
    TransportMode.bus => Icons.directions_bus,
    TransportMode.ferry => Icons.directions_boat,
  };

  Widget _candidateRow(VehicleCandidate candidate) {
    final vehicle = candidate.vehicle;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Icon(_modeIcon(vehicle.mode)),
          title: Text(
            vehicle.label?.isNotEmpty == true
                ? '${vehicle.mode.displayName} · ${vehicle.title}'
                : vehicle.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vehicle.route?.isNotEmpty == true)
                Text('Route ${vehicle.route}'),
              Text(
                candidate.likely ? 'Likely your vehicle' : 'Possible vehicle',
              ),
              Text('${candidate.distance.round()} m away at its last report'),
              Text(
                '${candidate.observations} distinct live observations compared',
              ),
              const SizedBox(height: 8),
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
        const Divider(height: 1),
      ],
    );
  }
}
