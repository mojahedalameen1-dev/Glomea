import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'web_sidebar.dart';
import '../theme/app_colors.dart';

class WebShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const WebShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 1100;

        return Scaffold(
          backgroundColor: AppColors.bgPage,
          drawer: isLargeScreen
              ? null
              : Drawer(
                  child: WebSidebar(navigationShell: navigationShell),
                ),
          body: Row(
            children: [
              if (isLargeScreen) WebSidebar(navigationShell: navigationShell),
              Expanded(
                child: Column(
                  children: [
                    // Top Bar for Web (Optional but recommended)
                    if (!isLargeScreen)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu_rounded,
                                    color: AppColors.primary),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.favorite_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text('Glomea',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            const Spacer(),
                            const SizedBox(width: 48), // Padding for balance
                          ],
                        ),
                      ),

                    Expanded(
                      child: navigationShell,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
