import 'dart:async';

import 'package:archive/archive.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
// import 'package:lbww_flutter/swagger_generated/realtime_timetables_v1.swagger.dart';

class ProtobufConverter implements chopper.Converter {
  @override
  chopper.Request convertRequest(chopper.Request request) => request;

  @override
  FutureOr<chopper.Response<BodyType>> convertResponse<BodyType, InnerType>(
    chopper.Response response,
  ) {
    if (response.bodyBytes.isNotEmpty) {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      final file = archive.files.first;
      final decompressed = file.content;
      final feedMessage = FeedMessage.fromBuffer(decompressed);
      return response.copyWith(body: feedMessage) as chopper.Response<BodyType>;
    }
    return response as chopper.Response<BodyType>;
  }
}

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('RealtimeTimetablesV1', () {
    test('busesGet returns valid response', () async {
      // Swagger file not yet generated - skipping for now
      // TODO: Generate swagger file for RealtimeTimetablesV1
      // final apiKey = dotenv.env['API_KEY'];
      // final interceptors = <chopper.Interceptor>[];
      // if (apiKey != null && apiKey.isNotEmpty) {
      //   interceptors.add(chopper.HeadersInterceptor({
      //     'Authorization': 'apikey $apiKey',
      //     'accept': 'application/x-google-protobuf'
      //   }));
      // }
      // final service = RealtimeTimetablesV1.create(
      //   interceptors: interceptors,
      //   converter: ProtobufConverter(),
      //   baseUrl: Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/schedule'),
      // );
      // final response = await service.busesGet();
      // expect(response.statusCode, 200);
      // expect(response.body, isNotNull);
      // expect(response.body, isA<FeedMessage>());
    }, skip: true);
  });
}
