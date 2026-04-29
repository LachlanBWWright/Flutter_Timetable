import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/screens/debug_entity_list_screen.dart';
import 'package:lbww_flutter/debug/screens/debug_entity_screen.dart';

class DebugNavigationArgs {
  final DebugEntityRequest request;
  final DebugEntityPageLoader loader;

  const DebugNavigationArgs({required this.request, required this.loader});
}

class DebugBrowserNavigationArgs {
  final DebugEntityType entityType;
  final DebugEntityListPageLoader listLoader;
  final DebugEntityPageLoader pageLoader;

  const DebugBrowserNavigationArgs({
    required this.entityType,
    required this.listLoader,
    required this.pageLoader,
  });
}

class DebugNavigation {
  static const String routeName = '/debug/entity';
  static const String browserRouteName = '/debug/browser';

  static Future<T?> pushEntity<T>(
    BuildContext context, {
    required DebugEntityRequest request,
    required DebugEntityPageLoader loader,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: DebugNavigationArgs(request: request, loader: loader),
    );
  }

  static Future<T?> pushBrowser<T>(
    BuildContext context, {
    required DebugEntityType entityType,
    required DebugEntityListPageLoader listLoader,
    required DebugEntityPageLoader pageLoader,
  }) {
    return Navigator.of(context).pushNamed<T>(
      browserRouteName,
      arguments: DebugBrowserNavigationArgs(
        entityType: entityType,
        listLoader: listLoader,
        pageLoader: pageLoader,
      ),
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeName:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (context) {
            if (args is! DebugNavigationArgs) {
              return const _InvalidDebugRouteScreen(
                title: 'Debug Entity',
                message: 'Missing or invalid debug entity route arguments.',
              );
            }
            return DebugEntityScreen(args: args);
          },
          settings: settings,
        );
      case browserRouteName:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (context) {
            if (args is! DebugBrowserNavigationArgs) {
              return const _InvalidDebugRouteScreen(
                title: 'Debug Browser',
                message: 'Missing or invalid debug browser route arguments.',
              );
            }
            return DebugEntityListScreen(args: args);
          },
          settings: settings,
        );
      default:
        return null;
    }
  }
}

class _InvalidDebugRouteScreen extends StatelessWidget {
  final String title;
  final String message;

  const _InvalidDebugRouteScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(message)),
      ),
    );
  }
}
