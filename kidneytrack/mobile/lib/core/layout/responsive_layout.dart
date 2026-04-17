import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'web_shell.dart';
import '../widgets/layout/bottom_nav_shell.dart';
import 'package:go_router/go_router.dart';

class ResponsiveLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If specifically on Web or if the screen is large enough
        if (kIsWeb || constraints.maxWidth >= 600) {
          return WebShell(navigationShell: navigationShell);
        }

        // Otherwise use the standard Mobile Bottom Navigation
        return BottomNavShell(navigationShell: navigationShell);
      },
    );
  }
}
