import 'package:flutter/material.dart';

import '../schema/database.dart' show Journey;
import '../utils/visible_realtime_refresh.dart';
import '../vehicle_finder/provider.dart';
import '../widgets/realtime_map_widget.dart';
import 'progress.dart';
import 'session.dart';

class ActiveJourneyScreen extends StatefulWidget {
  const ActiveJourneyScreen({super.key, required this.journeys, this.session});
  final List<Journey> journeys;
  final ActiveJourneySession? session;
  @override
  State<ActiveJourneyScreen> createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends State<ActiveJourneyScreen> {
  late final ActiveJourneySession _session =
      widget.session ?? ActiveJourneySession.instance;
  late final VisibleRealtimeRefresh _refresh = VisibleRealtimeRefresh(
    onRefresh: () => _session.refresh(widget.journeys),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh.updateRoute(context);
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  String _time(BuildContext context, DateTime time) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(time.toLocal()),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your running service')),
    body: ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        final vehicle = _session.vehicle;
        if (vehicle == null || !_session.hasSelection) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No active service. Use Find my vehicle to select one.',
            ),
          );
        }
        final service = _session.service;
        final selected = _session.confirmedMatch;
        final progress = JourneyProgress.resolve(
          service,
          selected,
          fresh:
              _session.fresh &&
              (selected == null || _session.confirmedMatchIsLive),
        );
        final stops = selected?.stops ?? service?.stops ?? [];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(vehicle.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Live transport updates keep this service visible. Your location is only used when you start a vehicle search.',
            ),
            const SizedBox(height: 12),
            if (_session.loading)
              const LinearProgressIndicator(
                semanticsLabel: 'Refreshing running service',
              ),
            if (_session.error != null)
              Text(
                _session.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (selected != null) ...[
              Text(
                selected.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _session.labelFor(selected.journey, selected.reverse) ??
                    'Last selection',
              ),
            ] else if (service != null && service.matches.isEmpty)
              const Text(
                'Could not match a saved journey yet. You can still follow this service on the map. A saved connection must identify this exact service to match.',
              )
            else if (service != null) ...[
              const Text(
                'Which saved journey are you taking? A shared service can fit several destinations.',
              ),
              for (final match in service.matches)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(match.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _session.fresh
                      ? () => _session.confirmJourney(match)
                      : null,
                ),
            ],
            if (progress.arrived)
              Text(
                'Arrived at ${selected!.currentDestination}',
                style: Theme.of(context).textTheme.titleMedium,
              )
            else ...[
              if (progress.currentStop != null)
                Text('At ${progress.currentStop!.name}'),
              if (progress.nextStop != null)
                Text('Next reported stop: ${progress.nextStop!.name}'),
              if (progress.stopsRemaining != null)
                Text(
                  '${progress.stopsRemaining} known ${progress.stopsRemaining == 1 ? 'stop' : 'stops'} remaining${selected?.hasOnwardTravel == true ? ' on this leg' : ''}',
                ),
              if (selected?.stops.lastOrNull?.arrival != null)
                Text(
                  '${_session.fresh ? 'Scheduled or reported arrival' : 'Last available arrival'} at ${selected!.currentDestination}: ${_time(context, selected.stops.last.arrival!)}',
                ),
            ],
            if (selected?.hasOnwardTravel == true)
              Text(
                'Continue your journey to ${selected!.destination} after this leg. Only the selected vehicle is being followed.',
              ),
            if (service?.partial == true || (service != null && stops.isEmpty))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Some stops or live updates may be missing. Refresh this service to try again.',
                ),
              ),
            if (stops.any((stop) => !stop.skipped && stop.arrival == null))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Arrival times are unavailable for some stops.'),
              ),
            if (stops.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Known service stops',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final stop in stops)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  selected:
                      identical(stop, progress.nextStop) ||
                      identical(stop, progress.currentStop),
                  title: Text(stop.name),
                  subtitle:
                      !stop.skipped &&
                          !identical(stop, progress.currentStop) &&
                          !identical(stop, progress.nextStop)
                      ? null
                      : Text(
                          stop.skipped
                              ? 'Skipped'
                              : identical(stop, progress.currentStop)
                              ? 'At this stop'
                              : identical(stop, progress.nextStop)
                              ? 'Next reported stop'
                              : '',
                        ),
                  trailing: stop.arrival == null
                      ? null
                      : Text(_time(context, stop.arrival!)),
                ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('View service on map'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RealtimeMapPage(
                    transportMode: vehicle.mode,
                    vehicleId: vehicle.id,
                    tripIds: vehicle.service == null
                        ? null
                        : {vehicle.service!.tripId},
                    filterByLegTrip: vehicle.service?.tripId.isNotEmpty == true,
                    getAllVehiclesAggregated: () =>
                        finderServiceMapVehicles(vehicle),
                  ),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => _session.refresh(widget.journeys),
              child: const Text('Refresh service'),
            ),
            TextButton(onPressed: _session.end, child: const Text('End trip')),
          ],
        );
      },
    ),
  );
}
