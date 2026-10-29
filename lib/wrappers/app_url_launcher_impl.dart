import 'package:url_launcher/url_launcher.dart';

import '../logs/logger.dart';

class AppUrlLauncher {
  const AppUrlLauncher._();

  static Future<bool> launchExternalUrl(Uri uri, {String? label}) async {
    final description = label ?? uri.toString();
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        safeLogWarning('launchUrl returned false for $description');
      }
      return launched;
    } catch (error, stackTrace) {
      safeLogError(
        'Failed to launch $description',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
