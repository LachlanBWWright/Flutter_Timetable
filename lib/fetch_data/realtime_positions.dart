import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
// logger import removed

Map<String, String> getHeaders() {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchSydneyTrainsPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/sydneytrains');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}
      return null;
    }

    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchSydneyMetroPositions() async {
  try {
    final url =
        Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/metro');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Error fetching Sydney Metro positions: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchBusesPositions() async {
  try {
    final url =
        Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/buses');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchNswTrainsPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/nswtrains');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

// --- Ferries ---
Future<FeedMessage?> fetchFerriesSydneyFerriesPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/sydneyferries');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchFerriesMFFPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/MFF');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

// --- Lightrail ---
Future<FeedMessage?> fetchLightRailCbdAndSoutheastPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/cbdandsoutheast');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchLightRailInnerWestPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/innerwest');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchLightRailNewcastlePositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/newcastle');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchLightRailParramattaPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/parramatta');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

// --- Region Buses ---
Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Positions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana2');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newenglandnorthwest');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesNorthCoastPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Positions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast2');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Positions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast3');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Positions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray2');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Positions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands2');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/sydneysurrounds');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newcastlehunter');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<FeedMessage?> fetchRegionBusesFarWestPositions() async {
  try {
    final url = Uri.parse(
        'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/farwest');
    final response = await http.get(url, headers: getHeaders());
    if (response.statusCode != 200) {
      // Failed to fetch ${url.toString()}: ${response.statusCode}
      return null;
    }
    return FeedMessage.fromBuffer(response.bodyBytes);
  } catch (e) {
    return null;
  }
}

Future<List<FeedMessage?>> getAllFerries() async {
  return await Future.wait([
    fetchFerriesSydneyFerriesPositions(),
    fetchFerriesMFFPositions(),
  ]);
}

Future<List<FeedMessage?>> getAllLightRail() async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastPositions(),
    fetchLightRailInnerWestPositions(),
    fetchLightRailNewcastlePositions(),
    fetchLightRailParramattaPositions(),
  ]);
}

Future<List<FeedMessage?>> getAllRegionBuses() async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaPositions(),
    fetchRegionBusesCentralWestAndOrana2Positions(),
    fetchRegionBusesNewEnglandNorthWestPositions(),
    fetchRegionBusesNorthCoastPositions(),
    fetchRegionBusesNorthCoast2Positions(),
    fetchRegionBusesNorthCoast3Positions(),
    fetchRegionBusesRiverinaMurrayPositions(),
    fetchRegionBusesRiverinaMurray2Positions(),
    fetchRegionBusesSouthEastTablelandsPositions(),
    fetchRegionBusesSouthEastTablelands2Positions(),
    fetchRegionBusesSydneySurroundsPositions(),
    fetchRegionBusesNewcastleHunterPositions(),
    fetchRegionBusesFarWestPositions(),
  ]);
}

Future<List<FeedMessage?>> fetchRegionBusesPositions() async {
  final futures = [
    fetchRegionBusesCentralWestAndOranaPositions(),
    fetchRegionBusesCentralWestAndOrana2Positions(),
    fetchRegionBusesNewEnglandNorthWestPositions(),
    fetchRegionBusesNorthCoastPositions(),
    fetchRegionBusesNorthCoast2Positions(),
    fetchRegionBusesNorthCoast3Positions(),
    fetchRegionBusesRiverinaMurrayPositions(),
    fetchRegionBusesRiverinaMurray2Positions(),
    fetchRegionBusesSouthEastTablelandsPositions(),
    fetchRegionBusesSouthEastTablelands2Positions(),
    fetchRegionBusesSydneySurroundsPositions(),
    fetchRegionBusesNewcastleHunterPositions(),
    fetchRegionBusesFarWestPositions(),
  ];
  final results = await Future.wait(futures);
  return results;
}
