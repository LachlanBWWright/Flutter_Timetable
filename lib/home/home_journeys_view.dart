part of 'home_page.dart';

extension _HomeJourneysView on _MyHomePageState {
  Widget _buildJourneysBody(
    BuildContext context,
    List<db.Journey> pinnedJourneys,
    List<db.Journey> unpinnedJourneys,
  ) {
    return RefreshIndicator(
      key: ValueKey(
        _hasLoadedJourneys ? 'home-journeys-ready' : 'home-journeys-loading',
      ),
      onRefresh: () async {
        await getTrips();
        await _validateApiKey(notifyOnFailure: false);
      },
      child: _filteredJourneys.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                ActiveJourneyRecoveryPrompt(
                  session: ActiveJourneySession.instance,
                  journeys: _journeys,
                ),
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
                        const SizedBox(height: 12),
                        if (_controller.state.loadFailed)
                          TextButton(
                            onPressed: getTrips,
                            child: const Text('Retry'),
                          )
                        else if (_journeys.isEmpty &&
                            AppTransitContext
                                .instance
                                .currentServices
                                .supportsJourneyPlanning)
                          FilledButton.icon(
                            onPressed: _navigateToNewTrip,
                            icon: const Icon(Icons.add),
                            label: const Text('Add trip'),
                          )
                        else if (_journeys.isNotEmpty)
                          const Text('Try a different search term'),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ActiveJourneyRecoveryPrompt(
                    session: ActiveJourneySession.instance,
                    journeys: _journeys,
                  ),
                ),
                if (_controller.state.loadFailed)
                  SliverToBoxAdapter(
                    child: MaterialBanner(
                      content: const Text('Could not load saved trips.'),
                      leading: const Icon(Icons.error_outline),
                      actions: [
                        TextButton(
                          onPressed: getTrips,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                // Pinned trips section
                if (pinnedJourneys.isNotEmpty) ...[
                  JourneyList(
                    asSliver: true,
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
                    const SliverToBoxAdapter(
                      child: Divider(
                        height: 32,
                        thickness: 2,
                        indent: 16,
                        endIndent: 16,
                      ),
                    ),
                ],
                // Unpinned trips section
                if (unpinnedJourneys.isNotEmpty)
                  JourneyList(
                    asSliver: true,
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
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
    );
  }
}
