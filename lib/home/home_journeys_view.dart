part of 'home_page.dart';

extension _HomeJourneysView on _MyHomePageState {
  Widget _buildJourneysBody(
    BuildContext context,
    List<db.Journey> pinnedJourneys,
    List<db.Journey> unpinnedJourneys,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await getTrips();
        await _validateApiKey(notifyOnFailure: false);
      },
      child: _filteredJourneys.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _controller.state.loadFailed
                              ? Icons.error_outline
                              : Icons.train,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _controller.state.loadFailed
                              ? 'Could not load saved trips'
                              : _journeys.isEmpty
                              ? 'No trips saved yet'
                              : 'No trips match your search',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controller.state.loadFailed
                              ? 'Pull down to retry'
                              : _journeys.isEmpty
                              ? 'Pull down to refresh or add a new trip'
                              : 'Try a different search term',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              children: [
                if (_controller.state.loadFailed)
                  MaterialBanner(
                    content: const Text(
                      'Could not load saved trips. Pull down to retry.',
                    ),
                    leading: const Icon(Icons.error_outline),
                    actions: [
                      TextButton(
                        onPressed: getTrips,
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                // Pinned trips section
                if (pinnedJourneys.isNotEmpty) ...[
                  JourneyList(
                    journeys: pinnedJourneys,
                    onJourneyTap: _navigateToTrip,
                    onReverseJourneyTap: _navigateToReverseTrip,
                    onJourneyVisible: widget.skipInitialLoad
                        ? null
                        : TripCacheService.prefetchJourney,
                    onDeleteJourney: deleteTrip,
                    onTogglePin: togglePin,
                    isEditingMode: _isEditingMode,
                    showNextTripTimes: !widget.skipInitialLoad,
                    isPinnedSection: true,
                  ),
                  if (unpinnedJourneys.isNotEmpty)
                    const Divider(
                      height: 32,
                      thickness: 2,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
                // Unpinned trips section
                if (unpinnedJourneys.isNotEmpty)
                  JourneyList(
                    journeys: unpinnedJourneys,
                    onJourneyTap: _navigateToTrip,
                    onReverseJourneyTap: _navigateToReverseTrip,
                    onJourneyVisible: widget.skipInitialLoad
                        ? null
                        : TripCacheService.prefetchJourney,
                    onDeleteJourney: deleteTrip,
                    onTogglePin: togglePin,
                    isEditingMode: _isEditingMode,
                    showNextTripTimes: !widget.skipInitialLoad,
                    isPinnedSection: false,
                  ),
              ],
            ),
    );
  }
}
