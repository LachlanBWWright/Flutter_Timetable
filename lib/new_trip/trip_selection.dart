part of '../new_trip.dart';

extension _TripSelection on _NewTripScreenState {
  Future<void> _selectStation(
    Station selectedStation, {
    _StopTarget? target,
    int? index,
  }) async {
    if (_isApplyingStop || _isSavingTrip) return;
    final selectedRegion =
        selectedStation.transitRef?.region ?? TransitRegion.nsw;
    if (_draftRegion != null && selectedRegion != _draftRegion) {
      showSnackBar(
        SnackBar(
          content: Text(
            'This trip is locked to ${_draftRegion!.label}. Clear all selected stops to choose another region.',
          ),
        ),
      );
      return;
    }
    if (target == _StopTarget.addInterchange &&
        (index == null || index < 0 || index > _interchanges.length)) {
      return;
    }
    if (target == _StopTarget.editInterchange &&
        (index == null || index < 0 || index >= _interchanges.length)) {
      return;
    }
    _invalidateDraftLookups();
    final draft = _captureDraftLookup();
    final id = selectedStation.id;
    guardedSetState(() => _isApplyingStop = true);
    TransportMode? mode;
    try {
      mode =
          selectedStation.mode ??
          (widget.skipInitialLoad
              ? _currentMode
              : await StopsService.resolveModeForStopId(
                  id,
                  preferredMode: selectedStation.mode,
                ));
    } finally {
      if (mounted) guardedSetState(() => _isApplyingStop = false);
    }
    if (!_isCurrentDraftLookup(draft) || mode == null) {
      return;
    }

    final station = selectedStation.transitRef != null
        ? selectedStation.copyWith(mode: mode)
        : _resolveStation(id, selectedStation.name, mode);
    if (station == null) {
      return;
    }

    final selectedTarget =
        target ??
        (_originStation == null ? _StopTarget.origin : _StopTarget.destination);
    if ((selectedTarget == _StopTarget.origin &&
            _destinationStation != null &&
            _persistedStopId(station) ==
                _persistedStopId(_destinationStation!)) ||
        (selectedTarget == _StopTarget.destination &&
            _originStation != null &&
            _persistedStopId(station) == _persistedStopId(_originStation!))) {
      showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same stop.'),
        ),
      );
      return;
    }
    guardedSetState(() {
      _draftRegion = selectedRegion;
      switch (selectedTarget) {
        case _StopTarget.origin:
          _originStation = station;
          _originMode = mode;
        case _StopTarget.destination:
          _destinationStation = station;
          _destinationMode = mode;
        case _StopTarget.addInterchange:
          _interchanges.insert(index!, station);
          _manualBuilderEnabled = true;
        case _StopTarget.editInterchange:
          _interchanges[index!] = station;
      }
      if (selectedTarget == _StopTarget.origin ||
          selectedTarget == _StopTarget.destination) {
        _sharedLines = [];
        _originLineCandidates = [];
        _selectedLine = null;
        _sameLineDestinationStations = [];
        _filterDestinationsToSameLine = false;
      }
    });
    _applySearchFilter();
    if (widget.skipInitialLoad) return;
    if (_originStation != null && _destinationStation != null) {
      await _resolveSharedLines();
    } else if (_originStation != null) {
      await _loadOriginLineCandidates();
    }
  }

  Station? _resolveStation(String id, String stationName, TransportMode mode) {
    for (final station in _getStationListForMode(mode)) {
      if (station.id == id) {
        return station.copyWith(mode: mode);
      }
    }

    return Station(name: stationName, id: id, mode: mode);
  }

  void _clearOrigin() => _clearEndpoint(origin: true);

  void _clearDestination() => _clearEndpoint(origin: false);

  void _clearEndpoint({required bool origin}) {
    _invalidateDraftLookups();
    guardedSetState(() {
      if (origin) {
        _originStation = null;
        _originMode = null;
      } else {
        _destinationStation = null;
        _destinationMode = null;
      }
      if (_originStation == null &&
          _destinationStation == null &&
          _interchanges.isEmpty) {
        _draftRegion = null;
      }
      _sharedLines = [];
      _originLineCandidates = [];
      _selectedLine = null;
      _sameLineDestinationStations = [];
      _filterDestinationsToSameLine = false;
    });
    _applySearchFilter();
  }

  Future<void> _loadOriginLineCandidates() async {
    final origin = _originStation;
    final originMode = _originMode;
    if (widget.skipInitialLoad || origin == null || originMode == null) {
      return;
    }
    if (_draftRegion != TransitRegion.nsw) {
      guardedSetState(() {
        _originLineCandidates = [];
        _sameLineDestinationStations = [];
      });
      return;
    }

    guardedSetState(() {
      _isLoadingLineCandidates = true;
      _originLineCandidates = [];
      _sameLineDestinationStations = [];
    });

    final draft = _captureDraftLookup();
    final request = ++_lineLookupGeneration;
    final lines = await _tripLineService.getLinesForStop(
      origin.id,
      mode: originMode,
      allowBuild: true,
    );
    if (!_isCurrentDraftLookup(draft) || request != _lineLookupGeneration) {
      return;
    }
    guardedSetState(() {
      _originLineCandidates = lines;
      _isLoadingLineCandidates = false;
    });
    if (_filterDestinationsToSameLine) {
      await _loadSameLineDestinationStations();
    }
  }

  Future<void> _toggleSameLineDestinationFilter(bool value) async {
    _invalidateDraftLookups();
    guardedSetState(() {
      _filterDestinationsToSameLine = value;
      if (!value) {
        _sameLineDestinationStations = [];
      }
      keyController.clear();
    });

    if (value) {
      if (_originLineCandidates.isEmpty) {
        await _loadOriginLineCandidates();
      } else {
        await _loadSameLineDestinationStations();
      }
    }
  }

  Future<void> _loadSameLineDestinationStations() async {
    final origin = _originStation;
    if (origin == null || _originLineCandidates.isEmpty) {
      guardedSetState(() {
        _sameLineDestinationStations = [];
      });
      return;
    }

    guardedSetState(() {
      _isLoadingLineCandidates = true;
      _sameLineDestinationStations = [];
    });

    final tabEndpointKeys = _currentTab.endpoints
        .map((endpoint) => endpoint.key)
        .toSet();
    final draft = _captureDraftLookup();
    final request = ++_lineLookupGeneration;
    final matchingLines = _originLineCandidates.where((line) {
      return line.mode == _currentMode &&
          tabEndpointKeys.contains(line.endpointKey);
    }).toList();
    final stopsById = <String, Station>{};

    for (final line in matchingLines) {
      final lineStops = await _tripLineService.getStopsForLine(
        line.lineId,
        line.mode,
        allowBuild: true,
      );
      if (!_isCurrentDraftLookup(draft) ||
          request != _lineLookupGeneration ||
          !_filterDestinationsToSameLine) {
        return;
      }
      for (final lineStop in lineStops) {
        if (lineStop.stopId == origin.id) {
          continue;
        }
        stopsById.addAll({lineStop.stopId: lineStop.toStation()});
      }
    }

    if (!_isCurrentDraftLookup(draft) || request != _lineLookupGeneration) {
      return;
    }
    final stations = stopsById.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    guardedSetState(() {
      _sameLineDestinationStations = stations;
      _isLoadingLineCandidates = false;
    });
  }

  Future<void> _resolveSharedLines() async {
    final origin = _originStation;
    final destination = _destinationStation;
    final originMode = _originMode;
    final destinationMode = _destinationMode;

    if (widget.skipInitialLoad || origin == null || destination == null) {
      return;
    }
    if (_draftRegion != TransitRegion.nsw) {
      guardedSetState(() {
        _sharedLines = [];
        _selectedLine = null;
        _isResolvingSharedLines = false;
      });
      return;
    }

    if (origin.id == destination.id) {
      showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same stop.'),
          backgroundColor: Colors.orange,
        ),
      );
      guardedSetState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    if (originMode == null ||
        destinationMode == null ||
        originMode != destinationMode) {
      guardedSetState(() {
        _sharedLines = [];
        _selectedLine = null;
      });
      return;
    }

    guardedSetState(() {
      _isResolvingSharedLines = true;
      _sharedLines = [];
      _selectedLine = null;
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
    });

    final draft = _captureDraftLookup();
    final request = ++_sharedLineLookupGeneration;
    final sharedLines = await _tripLineService.findSharedLines(
      origin.id,
      destination.id,
      mode: originMode,
      allowBuild: true,
    );
    if (!_isCurrentDraftLookup(draft) ||
        request != _sharedLineLookupGeneration) {
      return;
    }

    guardedSetState(() {
      _sharedLines = sharedLines;
      _selectedLine = sharedLines.isEmpty ? null : sharedLines.first;
      _isResolvingSharedLines = false;
    });
  }

  List<StopLineMatch> get _currentTabOriginLineCandidates {
    final tabEndpointKeys = _currentTab.endpoints
        .map((endpoint) => endpoint.key)
        .toSet();
    return _originLineCandidates.where((line) {
      return line.mode == _currentMode &&
          tabEndpointKeys.contains(line.endpointKey);
    }).toList();
  }
}
