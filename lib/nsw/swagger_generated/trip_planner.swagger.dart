// compatibility stub for the NSW trip planner client
// The app uses the hand-written transport API wrapper instead of this generated client.

abstract class TripPlanner {
  static TripPlanner create({
    dynamic client,
    dynamic httpClient,
    dynamic authenticator,
    dynamic errorConverter,
    dynamic converter,
    Uri? baseUrl,
    List<dynamic>? interceptors,
  }) {
    return const _TripPlannerStub();
  }
}

class _TripPlannerStub implements TripPlanner {
  const _TripPlannerStub();
}
