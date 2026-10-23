part of '../new_trip.dart';

extension _StationTabView on _NewTripScreenState {
  Widget _buildStationTab(_TripCreatorTab tab) {
    final mode = tab.mode;
    if (_showMapView && !_manualBuilderEnabled) {
      final modeDisplayName = NewTripService.getModeDisplayName(mode);
      return StopsMapWidget(
        key: ValueKey('map_${tab.kind}'),
        transportMode: mode,
        modeDisplayName: modeDisplayName,
        endpoints: tab.endpoints,
        embedded: true,
        onStopSelected: (name, id) {
          setStation(Station(name: name, id: id, mode: mode));
        },
        onClose: () {
          guardedSetState(() {
            _showMapView = false;
          });
          _applySearchFilter();
        },
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedLine = _selectedLine;

    if (_isLoadingInterchangeCandidates &&
        _manualBuilderEnabled &&
        _pendingInterchangeInsertIndex != null &&
        selectedLine != null &&
        mode == selectedLine.mode) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSelectingSameLineDestination =
        !_manualBuilderEnabled &&
        _filterDestinationsToSameLine &&
        _originStation != null &&
        _destinationStation == null;
    final useRegionalSearch = _usesRegionalStopSearch;
    final regionalQuery = keyController.text.trim();
    final baseList = keyController.text.trim().isNotEmpty && useRegionalSearch
        ? _regionalSearchResults
              .where((station) => station.mode == null || station.mode == mode)
              .toList()
        : useRegionalSearch
        ? const <Station>[]
        : _manualBuilderEnabled &&
              _pendingInterchangeInsertIndex != null &&
              selectedLine != null &&
              mode == selectedLine.mode
        ? _manualCandidateStations
        : isSelectingSameLineDestination
        ? _sameLineDestinationStations
        : _getStationListForTab(tab);

    final displayList = filterStationsByQuery(baseList, keyController.text);

    if (displayList.isEmpty) {
      if (useRegionalSearch && regionalQuery.isNotEmpty) {
        if (_isRegionalSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_regionalSearchFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Could not search enabled regions. Check your connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _retryRegionalStopSearch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
      }
      final emptyMessage =
          _manualBuilderEnabled &&
              _pendingInterchangeInsertIndex != null &&
              selectedLine != null &&
              mode == selectedLine.mode
          ? buildInterchangeEmptyMessage()
          : isSelectingSameLineDestination
          ? 'No same-line stops found.'
          : 'No stops found.';
      return Center(child: Text(emptyMessage));
    }

    return Column(
      children: [
        Expanded(
          child: EnhancedStationList(
            listItems: displayList,
            setStation: setStation,
            sortMode: _sortMode,
            mode: mode,
          ),
        ),
      ],
    );
  }
}
