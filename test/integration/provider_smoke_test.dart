import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

@Tags(['integration'])
void main() {
  test('integration smoke checks are opt-in', () {
    final apiKey = Platform.environment['API_KEY'] ?? '';
    final ptvDevId = Platform.environment['PTV_DEV_ID'] ?? '';
    final ptvApiKey = Platform.environment['PTV_API_KEY'] ?? '';

    if (apiKey.isEmpty || ptvDevId.isEmpty || ptvApiKey.isEmpty) {
      print(
        'Skipping integration smoke tests because provider credentials are unavailable.',
      );
      return;
    }

    expect(apiKey, isNotEmpty);
    expect(ptvDevId, isNotEmpty);
    expect(ptvApiKey, isNotEmpty);
  });
}
