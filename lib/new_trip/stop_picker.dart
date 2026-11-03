part of '../new_trip.dart';

enum _StopTarget { origin, destination, addInterchange, editInterchange }

extension _StopPicker on _NewTripScreenState {
  Future<void> _openStopPicker(_StopTarget target, {int? index}) async {
    if (_pickerOpen || _isApplyingStop || _isSavingTrip) return;
    if (target == _StopTarget.addInterchange &&
        (_originStation == null || _destinationStation == null)) {
      return;
    }
    final title = switch (target) {
      _StopTarget.origin => 'Choose starting stop',
      _StopTarget.destination => 'Choose destination',
      _StopTarget.addInterchange ||
      _StopTarget.editInterchange => 'Choose interchange',
    };
    _pickerTarget = target;
    _pickerOpen = true;
    Station? picked;
    try {
      picked = await Navigator.of(context).push<Station>(
        MaterialPageRoute(
          builder: (context) => AnimatedBuilder(
            animation: _pickerChanges,
            builder: (context, _) {
              _pickerContext = context;
              return PageStorage(
                bucket: _pickerStorage,
                child: Scaffold(
                  appBar: NewTripAppBar(
                    title: title,
                    isSearching: _isSearching,
                    searchController: keyController,
                    searchFocusNode: _searchFocusNode,
                    onSearch: (_) {},
                    onToggleSearch: _toggleSearch,
                    onSaveTrip: null,
                    canSave: false,
                    onOpenMap: _canUseNswStopsMap ? _openMap : null,
                    onToggleSort: _toggleSort,
                    sortMode: _sortMode,
                    showMapView: _showMapView,
                    tabController: _tabController,
                    tabs: _tabs.map((tab) => tab.tab).toList(),
                  ),
                  body: Column(
                    children: [
                      if (_draftRegion case final region?)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Trip region: ${region.label}'),
                        ),
                      if (target == _StopTarget.destination &&
                          _originStation != null &&
                          _destinationStation == null)
                        SameLineFilterToggle(
                          isEnabled: _filterDestinationsToSameLine,
                          isLoading: _isLoadingLineCandidates,
                          lineCount: _currentTabOriginLineCandidates.length,
                          onChanged: _toggleSameLineDestinationFilter,
                          accentColor: Theme.of(context).colorScheme.primary,
                        ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: _tabs.map(_buildStationTab).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } finally {
      _pickerOpen = false;
      _pickerTarget = null;
      _pickerContext = null;
      if (mounted) clearFocus(_searchFocusNode);
    }
    if (!mounted || picked == null) return;
    await _selectStation(picked, target: target, index: index);
  }
}
