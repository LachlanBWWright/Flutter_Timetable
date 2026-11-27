part of '../new_trip.dart';

extension _StationTabView on _NewTripScreenState {
  Widget _buildStationTab(_TripCreatorTab tab) {
    final mode = tab.mode;
    if (_showMapView) {
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
        _pickerTarget == _StopTarget.destination &&
        _filterDestinationsToSameLine &&
        _originStation != null &&
        _destinationStation == null;
    final useRegionalSearch = _usesRegionalStopSearch;
    final baseList =
        _manualBuilderEnabled &&
            _pendingInterchangeInsertIndex != null &&
            selectedLine != null &&
            mode == selectedLine.mode
        ? _manualCandidateStations
        : isSelectingSameLineDestination
        ? _sameLineDestinationStations
        : useRegionalSearch
        ? _regionalSearchResults
        : _getStationListForTab(tab);

    final displayList = filterStationsByQuery(baseList, keyController.text);

    if (displayList.isEmpty) {
      if (useRegionalSearch && _isRegionalSearchLoading) {
        return const Center(child: Text('Loading stops…'));
      }
      if (useRegionalSearch && _regionalSearchFailed) {
        return const Center(
          child: Text('Stops could not be loaded. Retry above.'),
        );
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
            key: PageStorageKey('trip-picker-${tab.kind}'),
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
