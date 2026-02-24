# Matching Strategy: Vehicle IDs

## Findings

After analyzing the Trip Planner API, GTFS Realtime Updates, and Vehicle Positions API, the following strategy has been identified to match vehicle IDs.

### 1. Data Sources

*   **Trip Planner API**: Provides trip journeys, legs, and transportation details.
*   **GTFS Realtime Updates**: Provides trip updates (delays, stop times) and links to vehicles.
*   **GTFS Vehicle Positions**: Provides the current location of vehicles.

### 2. Matching Logic

The primary key for matching vehicles is the `tripId`.

1.  **Trip Planner -> Realtime Updates**:
    *   Trip Planner provides a `tripId` (often embedded in `transportation.properties.tripCode` or inferred from `transportation.id` and time).
    *   Realtime Updates (`FeedEntity`) contain `tripUpdate.trip.tripId`.
    *   **Note**: Direct matching from Trip Planner to Realtime Updates can be complex due to ID format differences. However, once a Realtime Update is found, it links to a vehicle.

2.  **Realtime Updates -> Vehicle Positions**:
    *   Realtime Updates contain `tripUpdate.trip.tripId`.
    *   Vehicle Positions contain `vehicle.trip.tripId`.
    *   **Strategy**: Match `FeedEntity.tripUpdate.trip.tripId` == `FeedEntity.vehicle.trip.tripId`.
    *   **Verification**: A test suite `test/match_vehicle_ids_test.dart` confirmed that ~36% of active trips in the Realtime Updates feed have a corresponding Vehicle Position record with a matching `tripId`.

### 3. Implementation in `TripLegDetailScreen`

To visualize the correct vehicle for a trip leg:

1.  **Identify Route**: Use `leg.transportation.id` (Route ID, e.g., "T1") to filter relevant vehicles.
2.  **Identify Trip**: If `tripId` is available from the Trip Planner leg (e.g., in `properties` or `rawJson`), filter vehicles by `vehicle.trip.tripId`.
3.  **Fallback**: If `tripId` is not available or doesn't match, show all vehicles on the matching Route (`vehicle.trip.routeId`). This provides context even if the exact vehicle cannot be pinpointed.
4.  **Vehicle ID**: If `leg.transportation` contains a specific vehicle ID (rare in static data), use `vehicle.vehicle.id`.

### 4. Code Example

```dart
// Filter vehicles by Route ID
final routeId = leg.transportation?.id;
final matchingVehicles = vehicles.where((v) =>
  v.trip.hasRouteId() && v.trip.routeId == routeId
).toList();

// Refine by Trip ID if available
if (knownTripId != null) {
  final exactVehicle = matchingVehicles.firstWhere(
    (v) => v.trip.tripId == knownTripId,
    orElse: () => null
  );
}
```

## Verification Results

A comprehensive verification test (`test/match_vehicle_ids_test.dart`) was run against live API data.

*   **Date**: 2026-01-04
*   **Scenario**: Trip search between Redfern Station and Central Station.
*   **Total Trips Checked (Realtime Updates)**: 300
*   **Matches Found (Vehicle Positions)**: 108 (36.0% match rate)

**Deep Analysis of Mismatches**:
Further investigation into unmatched trips attempted fuzzy matching on:
*   Route ID
*   Start Time
*   Start Date
*   Vehicle Label / License Plate

**Result**: No additional matches were found using fuzzy logic on these fields for the unmatched trips. This indicates that the unmatched trips in the Realtime Updates feed likely do not have a corresponding active record in the Vehicle Positions feed at that moment (e.g. latency, vehicle not yet active, or phantom updates), confirming that **exact `tripId` matching** is the most reliable and correct strategy.

## Setup Instructions

To run the verification tests:

1.  Install Flutter on Linux (see standard instructions or use the provided setup commands).
2.  Ensure `API_KEY` environment variable is set.
3.  Run `flutter test test/match_vehicle_ids_test.dart`.
