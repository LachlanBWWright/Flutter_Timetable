# Australian public transport integration research

Research checked on 24 August 2026. The assessment focuses on data that can
support this application's provider capabilities: static GTFS, stop search,
departures, journey planning, GTFS-Realtime, disruptions, authentication, and
redistribution terms.

## Existing providers

NSW, Queensland, and Victoria are already registered in the application.
NSW has generated TfNSW API clients and server-side journey planning. QLD and
Victoria use static GTFS with local GTFS journey planning and GTFS-Realtime.

## Remaining jurisdictions

### South Australia — highest priority

Adelaide Metro publishes an official static GTFS feed and documented
GTFS-Realtime feeds for vehicle positions, trip updates, and service alerts.
The developer page describes the feeds as free to use under Creative Commons.
The realtime portal also publishes a Swagger/OpenAPI description, making this a
good candidate for generated HTTP code where useful.

- Static feed: `https://gtfs.adelaidemetro.com.au/v1/static/latest/google_transit.zip`
- Realtime base: `https://gtfs.adelaidemetro.com.au/v1/realtime`
- Realtime resources: `vehicle_positions`, `trip_updates`, `service_alerts`
- Scope: Adelaide Metro bus, train, tram, and ferry data, with regional
  operators represented in the static feed
- Authentication: no credentials were indicated in the public developer
  documentation
- Licensing: Creative Commons attribution requested as “Adelaide Metro –
  Department for Infrastructure and Transport, South Australia”
- Source: [Adelaide Metro developer information](https://www.adelaidemetro.com.au/developer-info)
- Realtime API: [Adelaide Metro GTFS-R portal](https://gtfs.adelaidemetro.com.au/)

Expected implementation: static stop search, departures, local journey
planning, vehicle positions, trip updates, and service alerts.

### Tasmania — second priority

The Tasmanian Government publishes a statewide GTFS ZIP under Creative Commons
Attribution 4.0. Public realtime tracking covers regular public buses across
the state and Hobart's River Derwent ferries, but the public page presents this
through an interactive map rather than a clearly documented feed URL.

- Static feed: linked from the official GTFS page
- Realtime: buses and Hobart ferries, endpoint discovery still required
- Authentication: not indicated for the static feed; realtime access needs
  verification
- Licensing: Creative Commons Attribution 4.0
- Sources: [Tasmanian GTFS data](https://www.transport.tas.gov.au/public_transport/gtfs-data),
  [Tasmanian realtime tracking](https://www.transport.tas.gov.au/public_transport/real-time-bus-and-ferry-tracking)

Expected implementation: full static integration first, followed by realtime
once the underlying feed is identified.

### Northern Territory — low-risk static provider

The NT Department of Logistics and Infrastructure publishes separate GTFS ZIPs
for Darwin and Alice Springs under Creative Commons Attribution 4.0. No public
GTFS-Realtime feed was identified in the official material.

- Static feeds: Darwin and Alice Springs
- Realtime: not identified
- Authentication: none indicated
- Licensing: Creative Commons Attribution 4.0
- Source: [NT bus timetable data](https://dli.nt.gov.au/data/bus-timetable-data-and-geographic-information)

Expected implementation: static stops, departures, and local journey planning.

### Australian Capital Territory — good coverage, credentials required

Transport Canberra publishes static GTFS and is transitioning from SIRI to
GTFS-Realtime for MyWay+. The production realtime API requires basic
authentication and access keys requested through the Transport Canberra
developer portal, which requires a MuleSoft Anypoint Platform account.

- Static: bus and light rail GTFS
- Realtime: MyWay+ GTFS-Realtime API, with trip updates, vehicle positions, and
  alerts planned by the new interface
- Authentication: developer portal access key and basic authentication
- Licensing: Creative Commons BY
- Sources: [Transport Canberra developer information](https://www.transport.act.gov.au/contact-us/information-for-developers),
  [MyWay+ access guide](https://www.transport.act.gov.au/__data/assets/pdf_file/0005/2865398/MyWayPlus-GTFS-developer-access-guide-v1.2.pdf)

Expected implementation: static integration can begin immediately; realtime
should wait for production credentials and confirmation of the current API
contract.

### Western Australia — static data with custom terms

Transperth provides official GTFS spatial data for Perth bus, train, and ferry
services. Its custom licence permits redistribution subject to attribution and
other restrictions, and can be revoked. No equivalent public Transperth
GTFS-Realtime feed was identified in the official sources reviewed.

- Static: Transperth bus, train, and ferry GTFS
- Realtime: no public GTFS-Realtime endpoint identified
- Authentication: download is available through the website
- Licensing: custom, limited and revocable licence; attribution is required
- Source: [Transperth spatial data access](https://www.transperth.wa.gov.au/About/Spatial-Data-Access)

Expected implementation: static-only provider unless a realtime feed and
redistribution permission can be confirmed.

## Recommended order

1. South Australia — strongest combination of open static and realtime feeds.
2. Tasmania — statewide static data and likely realtime, pending endpoint
   discovery.
3. Northern Territory — small, straightforward static-only integration.
4. ACT — technically strong, but realtime requires user/developer access.
5. Western Australia — useful static coverage, but weaker realtime access and
   more restrictive data terms.

## Application fit

South Australia can reuse the existing QLD/Victoria architecture:

1. download and parse the official static GTFS ZIP;
2. persist stops under an SA-specific source ID;
3. use the shared GTFS departure and journey-planning implementations; and
4. decode the three standard GTFS-Realtime protobuf feeds with generated
   Adelaide-specific protobuf models, because Adelaide's `VehicleDescriptor`
   extension is not compatible with the existing TfNSW model.

The first implementation should validate the live Adelaide feeds before adding
any custom SIRI support. SIRI remains a possible fallback for richer stop
monitoring, but it is not necessary for the core application capabilities.

## South Australia implementation result

Adelaide Metro is now registered as a first-class provider. The app imports
static stops, searches them, calculates departures, plans local GTFS journeys,
saves journeys, and consumes vehicle positions, trip updates, and service
alerts. The realtime client requests `application/x-google-protobuf`; the
endpoint returns base64 JSON for the more generic `application/x-protobuf`
header. Live coverage is exercised by the gated Adelaide Metro integration
tests in `test/south_australia/`.

Tasmania, the Northern Territory, and Western Australia are also now
registered as credential-free static providers. Their live tests cover GTFS
download, stop search, departures, journey planning, and saved journeys. The
NT provider exposes separate Darwin and Alice Springs feeds. These providers
currently do not claim realtime support because no stable public no-key
GTFS-Realtime endpoint was established during this work. Transperth's data is
available under its own limited and revocable licence, so redistribution and
product use should remain subject to that agreement.
