import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) => writeResponseData(
    data,
    testOutputFilename: 'performance',
    destinationDirectory: 'build/performance',
  ),
);
