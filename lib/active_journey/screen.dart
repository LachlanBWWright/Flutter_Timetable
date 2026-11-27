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
    appBar: AppBar(title: const Text('On board')),
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
        final theme = Theme.of(context);
        final destination = selected?.currentDestination;
        final arrival = selected?.stops.lastOrNull?.arrival;
        final isFresh =
            _session.fresh &&
            (selected == null || _session.confirmedMatchIsLive);
        final nextStop = progress.nextStop;
        final destinationSkipped =
            isFresh && selected?.stops.lastOrNull?.skipped == true;
        final primaryLabel = destination != null
            ? progress.arrived
                  ? 'Arrived at'
                  : destinationSkipped
                  ? 'Stop skipped'
                  : 'Get off at'
            : nextStop != null
            ? 'Next reported stop'
            : null;
        final primaryStop = destination ?? nextStop?.name;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (primaryStop != null && primaryLabel != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(primaryLabel, style: theme.textTheme.labelLarge),
                      Text(primaryStop, style: theme.textTheme.headlineSmall),
                      if (!progress.arrived &&
                          !destinationSkipped &&
                          arrival != null)
                        Text(
                          '${isFresh ? 'Arrival' : 'Last available arrival'} ${_time(context, arrival)}',
                        ),
                    ],
                  ),
                ),
              ),
            Text(vehicle.title, style: theme.textTheme.titleMedium),
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
            if (selected == null && service?.matches.isNotEmpty == true) ...[
              const Text('Choose your saved journey'),
              for (final match in service!.matches)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(match.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _session.fresh
                      ? () => _session.confirmJourney(match)
                      : null,
                ),
            ],
            if (progress.stopsRemaining case final remaining?
                when !progress.arrived)
              Text(
                '$remaining known ${remaining == 1 ? 'stop' : 'stops'} remaining',
              ),
            if (selected?.hasOnwardTravel == true)
              Text('After this leg, continue to ${selected!.destination}.'),
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
              for (final (index, stop) in stops.indexed)
                Stack(
                  children: [
                    if (stops.length > 1)
                      PositionedDirectional(
                        start: 10,
                        top: index == 0 ? 24 : 0,
                        bottom: index == stops.length - 1 ? null : 0,
                        height: index == stops.length - 1 && index != 0
                            ? 24
                            : null,
                        width: 2,
                        child: ColoredBox(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 22,
                      leading: Icon(
                        identical(stop, progress.currentStop)
                            ? Icons.radio_button_checked
                            : identical(stop, nextStop)
                            ? Icons.trip_origin
                            : Icons.circle,
                        size: 22,
                        color:
                            identical(stop, progress.currentStop) ||
                                identical(stop, nextStop)
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      title: Text(stop.name),
                      subtitle: stop.skipped
                          ? const Text('Skipped')
                          : identical(stop, progress.currentStop)
                          ? const Text('At this stop')
                          : identical(stop, nextStop)
                          ? const Text('Next reported stop')
                          : null,
                      trailing: stop.arrival == null
                          ? null
                          : Text(_time(context, stop.arrival!)),
                    ),
                  ],
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
