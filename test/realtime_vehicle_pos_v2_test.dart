import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:lbww_flutter/swagger_generated/realtime_vehicle_pos_v2.swagger.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

class ProtobufConverter implements chopper.Converter {
  @override
  chopper.Request convertRequest(chopper.Request request) => request;

  @override
  FutureOr<chopper.Response<BodyType>> convertResponse<BodyType, InnerType>(chopper.Response response) {
    if (response.body is List<int>) {
      final feedMessage = FeedMessage.fromBuffer(response.body);
      return response.copyWith(body: feedMessage) as chopper.Response<BodyType>;
    }
    return response as chopper.Response<BodyType>;
  }
}

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('RealtimeVehiclePosV2', () {
    test('sydneytrainsGet returns valid response', () async {
      final apiKey = dotenv.env['TRANSPORT_API_KEY'] ?? dotenv.env['API_KEY'];
      final interceptors = <chopper.Interceptor>[];
      if (apiKey != null && apiKey.isNotEmpty) {
        interceptors.add(
            chopper.HeadersInterceptor({'Authorization': 'apikey $apiKey'}));
      }
      final client = chopper.ChopperClient(
        baseUrl: Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos'),
        interceptors: interceptors,
        converter: ProtobufConverter(),
      );
      final service = RealtimeVehiclePosV2.create(client: client);
      final response = await service.sydneytrainsGet();
      expect(response.statusCode, 200);
      expect(response.body, isNotNull);
      expect(response.body, isA<FeedMessage>());
    });
  });
}
