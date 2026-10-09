import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

@Tags(['integration'])
void main() {
  final runNswApiTests = Platform.environment['RUN_NSW_API_TESTS'] == 'true';

  test(
    'TfNSW API key authenticates against Stop Finder',
    () async {
      await dotenv.load();
      expect(dotenv.env['API_KEY'], isNotEmpty);
      expect(await TransportApiService.isApiKeyValid(), isTrue);
    },
    skip: !runNswApiTests,
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
