import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/app_constants.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/services/app_appearance_service.dart';
import 'package:lbww_flutter/widgets/bootstrap_status_banner.dart';

import 'home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppAppearanceService.themeMode,
      builder: (context, themeMode, child) => MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        themeMode: themeMode,
        onGenerateRoute: DebugNavigation.onGenerateRoute,
        builder: (context, child) => Column(
          children: [
            const BootstrapStatusBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
        home: home ?? const MyHomePage(title: AppConstants.appTitle),
      ),
    );
  }
}
