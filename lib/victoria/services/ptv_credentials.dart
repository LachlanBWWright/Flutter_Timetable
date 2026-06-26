import 'package:flutter_dotenv/flutter_dotenv.dart';

class PtvCredentials {
  const PtvCredentials({required this.developerId, required this.apiKey});

  final String developerId;
  final String apiKey;

  bool get isConfigured => developerId.isNotEmpty && apiKey.isNotEmpty;
}

PtvCredentials loadPtvCredentials() {
  String read(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  return PtvCredentials(
    developerId: read('PTV_DEV_ID'),
    apiKey: read('PTV_API_KEY'),
  );
}
