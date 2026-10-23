import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/victoria/services/ptv_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(
      envString: 'PTV_DEV_ID=built-in-id\nPTV_API_KEY=built-in-key',
    );
    await PtvCredentialService.init();
  });

  test(
    'user credentials override and then fall back to built-in values',
    () async {
      expect(loadPtvCredentials().developerId, 'built-in-id');

      await PtvCredentialService.setUserCredentials(
        developerId: ' user-id ',
        apiKey: ' user-key ',
      );
      expect(loadPtvCredentials().developerId, 'user-id');
      expect(loadPtvCredentials().apiKey, 'user-key');

      await PtvCredentialService.clearUserCredentials();
      expect(loadPtvCredentials().developerId, 'built-in-id');
      expect(loadPtvCredentials().apiKey, 'built-in-key');
    },
  );
}
