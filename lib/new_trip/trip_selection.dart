part of '../new_trip.dart';

extension _TripSelection on _NewTripScreenState {
  Future<void> _selectStation(Station selectedStation) async {
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
    _invalidateDraftLookups();
    final draft = _captureDraftLookup();
    final id = selectedStation.id;
    final mode =
        selectedStation.mode ??
        await StopsService.resolveModeForStopId(
          id,
          preferredMode: selectedStation.mode,
        );
    if (!_isCurrentDraftLookup(draft) || mode == null) {
      return;
    }

    final station = selectedStation.transitRef != null
        ? selectedStation.copyWith(mode: mode)
        : _resolveStation(id, selectedStation.name, mode);
    if (station == null) {
      return;
    }

    if (_manualBuilderEnabled && _pendingInterchangeInsertIndex != null) {
      _insertInterchange(station);
      return;
    }

    if (_originStation == null) {
      guardedSetState(() {
        _draftRegion = selectedRegion;
        _originStation = station;
        _originMode = mode;
        keyController.clear();
      });
      _resetManualDraft(clearSharedLines: true, keepDestination: false);
      await _loadOriginLineCandidates();
      return;
    }

    if (_destinationStation == null) {
      guardedSetState(() {
        _destinationStation = station;
        _destinationMode = mode;
        keyController.clear();
        _showMapView = false;
      });
      await _resolveSharedLines();
      return;
    }

    if (!mounted) return;
    showSnackBar(
      const SnackBar(
        content: Text('Clear a selected stop before choosing another one.'),
      ),
    );
  }

  Station? _resolveStation(String id, String stationName, TransportMode mode) {
    for (final station in _getStationListForMode(mode)) {
      if (station.id == id) {
        return station;
      }
    }

    return Station(name: stationName, id: id);
  }

  void _clearOrigin() {
    guardedSetState(() {
      _originStation = null;
      _originMode = null;
      if (_destinationStation == null) _draftRegion = null;
    });
    _resetManualDraft(clearSharedLines: true, keepDestination: false);
  }

  void _clearDestination() {
    guardedSetState(() {
      _destinationStation = null;
      _destinationMode = null;
      if (_originStation == null) _draftRegion = null;
    });
    _resetManualDraft(clearSharedLines: true);
  }

  void _resetManualDraft({
    bool clearSharedLines = false,
    bool keepDestination = true,
  }) {
    _invalidateDraftLookups();
    if (!keepDestination) {
      _destinationStation = null;
      _destinationMode = null;
    }

    guardedSetState(() {
      _manualBuilderEnabled = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      _filterDestinationsToSameLine = false;
      _sameLineDestinationStations = [];
      if (clearSharedLines) {
        _sharedLines = [];
        _originLineCandidates = [];
        _selectedLine = null;
      }
    });
    _applySearchFilter();
  }

  Future<void> _loadOriginLineCandidates() async {
    final origin = _originStation;
    final originMode = _originMode;
    if (origin == null || originMode == null) {
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

    if (origin == null || destination == null) {
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
      _manualBuilderEnabled = false;
      _interchanges = [];
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
