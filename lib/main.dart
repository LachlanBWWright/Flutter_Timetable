import 'package:flutter/material.dart';

import 'home/app.dart';
import 'services/app_bootstrap_service.dart';

export 'home/app.dart';
export 'home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrapService.initialize();
  runApp(const MyApp());
}
