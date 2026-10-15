part of '../new_trip.dart';

class _DraftLookupSnapshot {
  const _DraftLookupSnapshot(this.generation, this.tab, this.stopIdentities);

  final int generation;
  final _TripCreatorTabKind tab;
  final List<String> stopIdentities;
}

extension _DraftLookups on _NewTripScreenState {
  List<String> get _draftStopIdentities => [
    for (final stop in [_originStation, ..._interchanges, _destinationStation])
      stop == null ? '' : '${_persistedStopId(stop)}:${stop.mode?.id}',
  ];

  _DraftLookupSnapshot _captureDraftLookup() => _DraftLookupSnapshot(
    _draftGeneration,
    _currentTab.kind,
    _draftStopIdentities,
  );

  bool _isCurrentDraftLookup(_DraftLookupSnapshot snapshot) {
    if (!mounted ||
        snapshot.generation != _draftGeneration ||
        snapshot.tab != _currentTab.kind) {
      return false;
    }
    final current = _draftStopIdentities;
    if (current.length != snapshot.stopIdentities.length) return false;
    for (var index = 0; index < current.length; index++) {
      if (current[index] != snapshot.stopIdentities[index]) return false;
    }
    return true;
  }

  void _restartDraftLookups(bool reloadOriginLines, bool reloadSharedLines) {
    if (reloadSharedLines) _resolveSharedLines();
    if (_originStation == null || _destinationStation != null) return;
    if (reloadOriginLines) {
      _loadOriginLineCandidates();
    } else if (_filterDestinationsToSameLine) {
      _loadSameLineDestinationStations();
    }
  }

  void _invalidateDraftLookups() {
    _draftGeneration++;
    _lineLookupGeneration++;
    _sharedLineLookupGeneration++;
    _interchangeLookupGeneration++;
    _isLoadingLineCandidates = false;
    _isResolvingSharedLines = false;
    _isLoadingInterchangeCandidates = false;
    _manualCandidateStations = [];
  }
}
