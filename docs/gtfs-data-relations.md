# GTFS Data Relations Documentation

This document describes the relationships between the various GTFS CSV files found in the metro_csv directory and how they work together to provide comprehensive transit data.

## File Overview

The GTFS (General Transit Feed Specification) data consists of 9 interconnected CSV files that form a complete transit dataset:

1. **agency.txt** - Transit agencies
2. **routes.txt** - Transit routes
3. **trips.txt** - Individual trips on routes
4. **stops.txt** - Stop/station locations
5. **stop_times.txt** - Arrival/departure times at stops
6. **shapes.txt** - Geographic path of routes
7. **calendar.txt** - Service schedules
8. **calendar_dates.txt** - Service exceptions
9. **notes.txt** - Additional notes/information

## Data Relationships

### Core Entity Relationships

```
agency.txt (1) ——→ (n) routes.txt
routes.txt (1) ——→ (n) trips.txt
trips.txt (1) ——→ (n) stop_times.txt
stops.txt (1) ——→ (n) stop_times.txt
trips.txt (1) ——→ (1) shapes.txt
trips.txt (n) ——→ (1) calendar.txt
```

### Detailed File Relationships

#### 1. agency.txt
**Purpose**: Defines transit agencies operating the routes
- **Primary Key**: `agency_id`
- **Key Fields**: `agency_name`, `agency_url`, `agency_timezone`
- **Sample**: Sydney Metro (SMNW)

#### 2. routes.txt
**Purpose**: Defines transit routes operated by agencies
- **Primary Key**: `route_id`
- **Foreign Key**: `agency_id` → agency.txt
- **Key Fields**: 
  - `route_short_name` (M1)
  - `route_long_name` (Metro North West & Bankstown Line)
  - `route_type` (401 = Metro)
  - `route_color` (168388 = Teal color)
- **Relationship**: One agency can operate multiple routes

#### 3. trips.txt
**Purpose**: Defines individual journey instances on routes
- **Primary Key**: `trip_id`
- **Foreign Keys**: 
  - `route_id` → routes.txt
  - `service_id` → calendar.txt
  - `shape_id` → shapes.txt
- **Key Fields**:
  - `trip_headsign` (destination display)
  - `direction_id` (0/1 for opposite directions)
  - `block_id` (vehicle assignment)
- **Relationship**: One route can have multiple trips, each trip follows one shape

#### 4. stops.txt
**Purpose**: Defines physical stop/station locations
- **Primary Key**: `stop_id`
- **Key Fields**:
  - `stop_name` (station name)
  - `stop_lat`, `stop_lon` (geographic coordinates)
  - `location_type` (0=platform, 1=station)
  - `parent_station` (links platforms to stations)
  - `platform_code` (platform number)
- **Relationship**: Stations (location_type=1) can have multiple platforms (location_type=0)

#### 5. stop_times.txt
**Purpose**: Defines when trips arrive/depart at specific stops
- **Composite Primary Key**: `trip_id` + `stop_sequence`
- **Foreign Keys**:
  - `trip_id` → trips.txt
  - `stop_id` → stops.txt
- **Key Fields**:
  - `arrival_time`, `departure_time`
  - `stop_sequence` (order of stops in trip)
  - `shape_dist_traveled` (distance along route shape)
- **Relationship**: Links trips to stops with timing information

#### 6. shapes.txt
**Purpose**: Defines the geographic path routes take
- **Composite Primary Key**: `shape_id` + `shape_pt_sequence`
- **Key Fields**:
  - `shape_pt_lat`, `shape_pt_lon` (GPS coordinates)
  - `shape_pt_sequence` (order of points)
  - `shape_dist_traveled` (cumulative distance)
- **Relationship**: One shape can be used by multiple trips

#### 7. calendar.txt
**Purpose**: Defines regular service schedules
- **Primary Key**: `service_id`
- **Key Fields**: Days of week (monday, tuesday, etc.), start_date, end_date
- **Relationship**: One service pattern can apply to multiple trips

#### 8. calendar_dates.txt
**Purpose**: Defines exceptions to regular service (holidays, service changes)
- **Composite Primary Key**: `service_id` + `date`
- **Foreign Key**: `service_id` → calendar.txt
- **Key Fields**: `date`, `exception_type` (1=added, 2=removed)

#### 9. notes.txt
**Purpose**: Contains additional textual information
- **Primary Key**: Varies by implementation
- **Relationship**: Can be referenced from other files via note IDs

## Data Flow Examples

### Example 1: Finding a Trip's Route
1. Start with `trip_id` from trips.txt
2. Get `route_id` from trips.txt
3. Get route details from routes.txt using `route_id`
4. Get agency details from agency.txt using `agency_id`

### Example 2: Building a Trip Itinerary
1. Start with `trip_id`
2. Get all stop_times.txt records for this `trip_id`, ordered by `stop_sequence`
3. For each stop_time, get stop details from stops.txt using `stop_id`
4. Get geographic route path from shapes.txt using `shape_id` from trips.txt

### Example 3: Real-time Integration
1. Use `trip_id` to link GTFS-Realtime feeds to static GTFS data
2. `stop_id` links real-time arrival predictions to static stop information
3. `route_id` can be used to filter real-time feeds by specific routes

## Key Data Patterns

### Hierarchical Stops
- **Station** (location_type=1): "Martin Place Station"
- **Platform** (location_type=0): "Martin Place Station, Platform 3"
- Relationship: Platforms reference their parent station via `parent_station`

### Bidirectional Routes
- **Direction 0**: Typically outbound (e.g., "Sydenham to Tallawong")
- **Direction 1**: Typically inbound (e.g., "Tallawong to Sydenham")
- Same route_id, different direction_id values

### Service Variations
- **Regular Service**: Defined in calendar.txt
- **Exceptions**: Holidays, special events in calendar_dates.txt
- **Multiple Patterns**: Different service_id values for weekday/weekend/holiday patterns

## Usage in Flutter App

This data structure enables:
1. **Route Visualization**: Use shapes.txt coordinates with flutter_map
2. **Trip Planning**: Link stops through stop_times.txt
3. **Real-time Updates**: Match GTFS-RT data using trip_id and stop_id
4. **Service Information**: Display route colors, agency details
5. **Accessibility**: Wheelchair boarding information from stops.txt

## Database Implementation

When storing in Drift/SQLite:
- Create separate tables for each CSV file
- Implement foreign key relationships
- Index frequently queried fields (stop_id, trip_id, route_id)
- Consider denormalized views for performance-critical queries