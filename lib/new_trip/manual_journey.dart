part of '../new_trip.dart';

extension _ManualJourney on _NewTripScreenState {
  Future<void> _saveDirectTrip() async {
    final origin = _originStation;
    final destination = _destinationStation;
    if (origin == null || destination == null) {
      return;
    }
    if (!_validateSavedStopRegions([origin, destination])) return;
    if (_persistedStopId(origin) == _persistedStopId(destination)) {
      showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same stop.'),
        ),
      );
      return;
    }

    final sharedMode = _originMode != null && _originMode == _destinationMode
        ? _originMode
        : null;

    await _persistJourney(
      JourneysCompanion(
        origin: drift.Value(origin.name),
        originId: drift.Value(_persistedStopId(origin)),
        destination: drift.Value(destination.name),
        destinationId: drift.Value(_persistedStopId(destination)),
        tripType: drift.Value(SavedTripType.direct.storageValue),
        mode: sharedMode != null
            ? drift.Value(sharedMode.id)
            : const drift.Value.absent(),
      ),
      successMessage: 'Trip saved.',
    );
  }

  Future<void> _saveManualTrip() => _saveTrip(manual: true);

  Future<void> _saveManualTripDraft() async {
    final draft = _captureDraftLookup();
    final origin = _originStation;
    final destination = _destinationStation;
    final selectedLine = _selectedLine;
    final validationMessage = _manualValidationMessage;
    if (origin == null || destination == null) {
      return;
    }
    if (validationMessage != null) {
      showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
    final orderedStops = _orderedStops;
    if (!_validateSavedStopRegions(orderedStops)) return;

    final builtDefinition = ManualTripDefinition(
      legs: await NewTripService.buildManualTripLegsWithResolvedMetadata(
        origin: origin,
        destination: destination,
        interchanges: _interchanges,
        fallbackMode: _originMode ?? _currentMode,
      ),
    );
    if (!_isCurrentDraftLookup(draft)) return;
    final definition = _withPersistedStopIds(builtDefinition, orderedStops);
    if (!definition.isValid) {
      showSnackBar(
        const SnackBar(content: Text('The saved trip has invalid stops.')),
      );
      return;
    }

    final firstLeg = definition.legs.isNotEmpty ? definition.legs.first : null;
    final firstLegLineId = firstLeg?.lineId;
    final firstLegLineName = firstLeg?.lineName;
    final selectedLineId = selectedLine?.lineId;
    final selectedLineName = selectedLine?.lineName;

    await _persistJourney(
      JourneysCompanion(
        origin: drift.Value(origin.name),
        originId: drift.Value(_persistedStopId(origin)),
        destination: drift.Value(destination.name),
        destinationId: drift.Value(_persistedStopId(destination)),
        tripType: drift.Value(SavedTripType.manualMultiLeg.storageValue),
        mode: drift.Value(
          firstLeg?.mode.id ?? selectedLine?.mode.id ?? _currentMode.id,
        ),
        lineId: firstLegLineId != null
            ? drift.Value(firstLegLineId)
            : selectedLineId != null
            ? drift.Value(selectedLineId)
            : const drift.Value.absent(),
        lineName: firstLegLineName != null
            ? drift.Value(firstLegLineName)
            : selectedLineName != null
            ? drift.Value(selectedLineName)
            : const drift.Value.absent(),
        legsJson: drift.Value(definition.toLegsJson()),
      ),
      successMessage: 'Manual trip saved.',
    );
  }

  ManualTripDefinition _withPersistedStopIds(
    ManualTripDefinition definition,
    List<Station> orderedStops,
  ) {
    if (definition.legs.length != orderedStops.length - 1) {
      return const ManualTripDefinition(legs: []);
    }
    return ManualTripDefinition(
      legs: [
        for (final leg in definition.legs)
          ManualTripLeg(
            index: leg.index,
            originName: leg.originName,
            originId: _persistedStopId(orderedStops[leg.index]),
            destinationName: leg.destinationName,
            destinationId: _persistedStopId(orderedStops[leg.index + 1]),
            mode: leg.mode,
            lineId: leg.lineId,
            lineName: leg.lineName,
            endpointKey: leg.endpointKey,
          ),
      ],
    );
  }

  bool _validateSavedStopRegions(List<Station> stops) {
    if (stops.isEmpty) return false;
    final region = stops.first.transitRef?.region ?? TransitRegion.nsw;
    if (stops.every(
      (stop) => (stop.transitRef?.region ?? TransitRegion.nsw) == region,
    )) {
      return true;
    }
    showSnackBar(
      const SnackBar(
        content: Text('All stops in a trip must be from the same region.'),
      ),
    );
    return false;
  }

  Future<void> _persistJourney(
    JourneysCompanion companion, {
    required String successMessage,
  }) async {
    final draft = _captureDraftLookup();
    final inserted = await JourneyService.insertJourney(_db, companion);
    if (!mounted) return;
    if (inserted) {
      if (!_isCurrentDraftLookup(draft)) {
        showSnackBar(SnackBar(content: Text(successMessage)));
        return;
      }
      _clearAllSelections();
      showSnackBar(SnackBar(content: Text(successMessage)));
      popUntilFirstPage();
      return;
    }
    showSnackBar(const SnackBar(content: Text('Error saving trip')));
  }

  void _clearAllSelections() {
    _invalidateDraftLookups();
    guardedSetState(() {
      _originStation = null;
      _originMode = null;
      _destinationStation = null;
      _destinationMode = null;
      _draftRegion = null;
      _regionalSearchResults = [];
      _sharedLines = [];
      _originLineCandidates = [];
      _sameLineDestinationStations = [];
      _selectedLine = null;
      _manualBuilderEnabled = false;
      _filterDestinationsToSameLine = false;
      _interchanges = [];
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
      _showMapView = false;
    });
    _applySearchFilter();
  }

  Future<void> _startInterchangeSelection(int insertIndex) async {
    final selectedLine = _selectedLine;
    final orderedStops = _orderedStops;
    if (selectedLine == null || orderedStops.length < 2) {
      return;
    }
    if (insertIndex <= 0 || insertIndex >= orderedStops.length) {
      return;
    }

    final previousStop = _itemAtOrNull(orderedStops, insertIndex - 1);
    final nextStop = _itemAtOrNull(orderedStops, insertIndex);
    if (previousStop == null || nextStop == null) {
      return;
    }

    _invalidateDraftLookups();
    guardedSetState(() {
      _pendingInterchangeInsertIndex = insertIndex;
      _isLoadingInterchangeCandidates = true;
      _manualCandidateStations = [];
      _showMapView = false;
    });

    _setTabForMode(selectedLine.mode);

    final draft = _captureDraftLookup();
    final request = ++_interchangeLookupGeneration;
    final rankedStops = await _tripLineService.rankStopsForLine(
      lineId: selectedLine.lineId,
      mode: selectedLine.mode,
      anchorStopIds: [previousStop.id, nextStop.id],
      excludedStopIds: orderedStops.map((stop) => stop.id),
      allowBuild: false,
    );

    if (!_isCurrentDraftLookup(draft) ||
        request != _interchangeLookupGeneration ||
        _selectedLine != selectedLine ||
        _pendingInterchangeInsertIndex != insertIndex) {
      return;
    }
    guardedSetState(() {
      _manualCandidateStations = rankedStops
          .map((lineStop) => lineStop.toStation())
          .toList();
      _isLoadingInterchangeCandidates = false;
    });
  }

  void _insertInterchange(Station station) {
    final selectedLine = _selectedLine;
    final insertIndex = _pendingInterchangeInsertIndex;
    if (selectedLine == null || insertIndex == null) {
      return;
    }
    final orderedStops = _orderedStops;
    if (insertIndex <= 0 || insertIndex >= orderedStops.length) {
      return;
    }

    final interchange = station.copyWith(
      lineId: selectedLine.lineId,
      lineName: selectedLine.lineName,
    );

    _invalidateDraftLookups();
    guardedSetState(() {
      _interchanges.insert(insertIndex - 1, interchange);
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
      keyController.clear();
    });
  }

  void _removeInterchange(int interchangeIndex) {
    _invalidateDraftLookups();
    guardedSetState(() {
      _interchanges.removeAt(interchangeIndex);
      _pendingInterchangeInsertIndex = null;
      _manualCandidateStations = [];
    });
  }

  void _moveInterchange(int interchangeIndex, int delta) {
    final newIndex = interchangeIndex + delta;
    if (newIndex < 0 || newIndex >= _interchanges.length) {
      return;
    }

    _invalidateDraftLookups();
    guardedSetState(() {
      final updated = List<Station>.from(_interchanges);
      final station = updated.removeAt(interchangeIndex);
      updated.insert(newIndex, station);
      _interchanges = updated;
    });
  }

  void _setTabForMode(TransportMode mode) {
    final index = _tabs.indexWhere((tab) => tab.mode == mode);

    if (index != -1 && _tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  List<Station> get _orderedStops {
    final origin = _originStation;
    final destination = _destinationStation;
    if (origin == null || destination == null) {
      return const [];
    }
    return NewTripService.buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: _interchanges,
    );
  }

  bool get _canSaveDirect {
    return !_isSavingTrip &&
        canSaveDirectTrip(
          origin: _originStation,
          destination: _destinationStation,
        );
  }

  String? get _manualValidationMessage {
    return manualTripValidationMessage(
      manualBuilderEnabled: _manualBuilderEnabled || _interchanges.isNotEmpty,
      origin: _originStation,
      destination: _destinationStation,
      interchanges: _interchanges,
      fallbackMode: _originMode ?? _currentMode,
    );
  }

  bool get _canSaveManual =>
      !_isSavingTrip &&
      _interchanges.isNotEmpty &&
      _manualValidationMessage == null;

  Future<void> _saveTrip({bool manual = false}) async {
    if (_isSavingTrip || !mounted) return;
    guardedSetState(() => _isSavingTrip = true);
    try {
      if (manual || _interchanges.isNotEmpty) {
        await _saveManualTripDraft();
      } else {
        await _saveDirectTrip();
      }
    } on Exception {
      if (mounted) {
        showSnackBar(const SnackBar(content: Text('Error saving trip')));
      }
    } finally {
      if (mounted) guardedSetState(() => _isSavingTrip = false);
    }
  }

  String? get _statusMessage {
    return buildNewTripStatusMessage(
      origin: _originStation,
      destination: _destinationStation,
      isResolvingSharedLines: _isResolvingSharedLines,
      manualBuilderEnabled: _manualBuilderEnabled,
      pendingInterchangeInsertIndex: _pendingInterchangeInsertIndex,
      orderedStops: _orderedStops,
      manualValidationMessage: _manualValidationMessage,
      selectedLine: _selectedLine,
      canSaveDirect: _canSaveDirect,
      sharedLines: _sharedLines,
      originMode: _originMode,
      destinationMode: _destinationMode,
    );
  }
}
