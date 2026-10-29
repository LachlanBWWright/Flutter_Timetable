/// Source metadata for Queensland TransLink static GTFS and GTFS-Realtime feeds.
///
/// Data source:
/// https://www.data.qld.gov.au/organization/transport-and-main-roads?q=GTFS
class TranslinkStaticGtfsFeed {
  const TranslinkStaticGtfsFeed({
    required this.id,
    required this.label,
    required this.url,
  });

  final String id;
  final String label;
  final String url;
}

class TranslinkRealtimeFeedSet {
  const TranslinkRealtimeFeedSet({
    required this.id,
    required this.label,
    required this.tripUpdatesUrl,
    required this.vehiclePositionsUrl,
    required this.alertsUrl,
  });

  final String id;
  final String label;
  final String tripUpdatesUrl;
  final String vehiclePositionsUrl;
  final String alertsUrl;
}

const translinkStaticGtfsFeeds = <TranslinkStaticGtfsFeed>[
  TranslinkStaticGtfsFeed(
    id: 'SEQ',
    label: 'South East Queensland',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/SEQ_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'BOW',
    label: 'Bowen',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/BOW_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'BUN',
    label: 'Bundaberg',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/BUN_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'CNS',
    label: 'Cairns',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/CNS_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'GLT',
    label: 'Gladstone',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/GLT_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'GYM',
    label: 'Gympie',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/GYM_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'INN',
    label: 'Innisfail',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/INN_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'KIL',
    label: 'Kilcoy',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/KIL_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'MKY',
    label: 'Mackay',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/MKY_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'MAG',
    label: 'Magnetic Island',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/MAG_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'MIF',
    label: 'Magnetic Island Ferry',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/MIF_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'MAL',
    label: 'Maleny-Landsborough',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/MAL_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'MHB',
    label: 'Maryborough-Hervey Bay',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/MHB_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'NSI',
    label: 'North Stradbroke Island',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/NSI_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'RKY',
    label: 'Rockhampton-Yeppoon',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/RKY_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'TWB',
    label: 'Toowoomba',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/TWB_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'TSV',
    label: 'Townsville',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/TSV_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'WAR',
    label: 'Warwick',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/WAR_GTFS.zip',
  ),
  TranslinkStaticGtfsFeed(
    id: 'WHT',
    label: 'Whitsundays',
    url: 'https://gtfsrt.api.translink.com.au/GTFS/WHT_GTFS.zip',
  ),
];

const translinkRealtimeFeedSets = <TranslinkRealtimeFeedSet>[
  TranslinkRealtimeFeedSet(
    id: 'SEQ',
    label: 'South East Queensland',
    tripUpdatesUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/TripUpdates',
    vehiclePositionsUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/VehiclePositions',
    alertsUrl: 'https://gtfsrt.api.translink.com.au/api/realtime/SEQ/Alerts',
  ),
  TranslinkRealtimeFeedSet(
    id: 'BOW',
    label: 'Bowen',
    tripUpdatesUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/BOW/TripUpdates',
    vehiclePositionsUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/BOW/VehiclePositions',
    alertsUrl: 'https://gtfsrt.api.translink.com.au/api/realtime/BOW/Alerts',
  ),
  TranslinkRealtimeFeedSet(
    id: 'CNS',
    label: 'Cairns',
    tripUpdatesUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/CNS/TripUpdates',
    vehiclePositionsUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/CNS/VehiclePositions',
    alertsUrl: 'https://gtfsrt.api.translink.com.au/api/realtime/CNS/Alerts',
  ),
  TranslinkRealtimeFeedSet(
    id: 'NSI',
    label: 'North Stradbroke Island',
    tripUpdatesUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/NSI/TripUpdates',
    vehiclePositionsUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/NSI/VehiclePositions',
    alertsUrl: 'https://gtfsrt.api.translink.com.au/api/realtime/NSI/Alerts',
  ),
  TranslinkRealtimeFeedSet(
    id: 'MHB',
    label: 'Maryborough Hervey Bay',
    tripUpdatesUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/MHB/TripUpdates',
    vehiclePositionsUrl:
        'https://gtfsrt.api.translink.com.au/api/realtime/MHB/VehiclePositions',
    alertsUrl: 'https://gtfsrt.api.translink.com.au/api/realtime/MHB/Alerts',
  ),
];

TranslinkStaticGtfsFeed? translinkStaticFeedById(String id) {
  for (final feed in translinkStaticGtfsFeeds) {
    if (feed.id == id) {
      return feed;
    }
  }
  return null;
}

TranslinkRealtimeFeedSet? translinkRealtimeFeedSetById(String id) {
  for (final feedSet in translinkRealtimeFeedSets) {
    if (feedSet.id == id) {
      return feedSet;
    }
  }
  return null;
}
