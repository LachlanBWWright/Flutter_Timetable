part of '../new_trip.dart';

enum _TripCreatorTabKind {
  sydneyTrains,
  nswTrainLink,
  lightRail,
  metro,
  bus,
  ferry,
}

class _TripCreatorTab {
  const _TripCreatorTab({
    required this.kind,
    required this.mode,
    required this.tab,
    required this.endpoints,
  });

  final _TripCreatorTabKind kind;
  final TransportMode mode;
  final Tab tab;
  final List<StopsEndpoint> endpoints;
}

const _TripCreatorTab _fallbackTripCreatorTab = _TripCreatorTab(
  kind: _TripCreatorTabKind.sydneyTrains,
  mode: TransportMode.train,
  endpoints: <StopsEndpoint>[StopsEndpoint.sydneytrains],
  tab: Tab(
    icon: AccessibleModeTabIcon(
      label: 'Sydney Trains stops',
      icon: Icons.directions_train,
      color: Color.fromARGB(255, 255, 97, 35),
    ),
  ),
);

List<_TripCreatorTab> _buildTabs() {
  return [
    const _TripCreatorTab(
      kind: _TripCreatorTabKind.sydneyTrains,
      mode: TransportMode.train,
      endpoints: [StopsEndpoint.sydneytrains],
      tab: Tab(
        icon: AccessibleModeTabIcon(
          label: 'Sydney Trains stops',
          icon: Icons.directions_train,
          color: Color.fromARGB(255, 255, 97, 35),
        ),
      ),
    ),
    if (TransportPreferencesService.showNswTrainLink.value)
      const _TripCreatorTab(
        kind: _TripCreatorTabKind.nswTrainLink,
        mode: TransportMode.train,
        endpoints: [StopsEndpoint.nswtrains],
        tab: Tab(
          icon: AccessibleModeTabIcon(
            label: 'NSW TrainLink stops',
            icon: Icons.confirmation_number,
            color: Colors.deepOrange,
          ),
        ),
      ),
    _TripCreatorTab(
      kind: _TripCreatorTabKind.lightRail,
      mode: TransportMode.lightrail,
      endpoints: NewTripService.getEndpointsForMode(TransportMode.lightrail),
      tab: const Tab(
        icon: AccessibleModeTabIcon(
          label:
              'Light rail stops: Inner West, Newcastle, CBD and South East, Parramatta',
          icon: Icons.tram,
          color: Color.fromARGB(255, 255, 82, 82),
        ),
      ),
    ),
    _TripCreatorTab(
      kind: _TripCreatorTabKind.metro,
      mode: TransportMode.metro,
      endpoints: NewTripService.getEndpointsForMode(TransportMode.metro),
      tab: const Tab(
        icon: AccessibleModeTabIcon(
          label: 'Metro stops',
          icon: Icons.subway,
          color: TransportColors.metro,
        ),
      ),
    ),
    _TripCreatorTab(
      kind: _TripCreatorTabKind.bus,
      mode: TransportMode.bus,
      endpoints: NewTripService.getEndpointsForMode(TransportMode.bus),
      tab: const Tab(
        icon: AccessibleModeTabIcon(
          label: 'Bus stops: Sydney and regional bus services',
          icon: Icons.directions_bus,
          color: Color.fromARGB(255, 82, 186, 255),
        ),
      ),
    ),
    _TripCreatorTab(
      kind: _TripCreatorTabKind.ferry,
      mode: TransportMode.ferry,
      endpoints: NewTripService.getEndpointsForMode(TransportMode.ferry),
      tab: const Tab(
        icon: AccessibleModeTabIcon(
          label: 'Ferry stops: Sydney Ferries and MFF',
          icon: Icons.directions_ferry,
          color: Color.fromARGB(255, 68, 240, 91),
        ),
      ),
    ),
  ];
}
