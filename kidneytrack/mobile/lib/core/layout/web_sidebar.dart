import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/web/web_nav_item.dart';

class WebSidebar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const WebSidebar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.primary,
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'Glomea',
                  style: AppTextStyles.h1
                      .copyWith(color: Colors.white, letterSpacing: 1.2),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

          const SizedBox(height: 16),

          // Navigation Menu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  WebNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'الرئيسية',
                    isActive: navigationShell.currentIndex == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                  WebNavItem(
                    icon: Icons.history_rounded,
                    label: 'السجل',
                    isActive: navigationShell.currentIndex == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                  WebNavItem(
                    icon: Icons.notifications_active_rounded,
                    label: 'التنبيهات',
                    isActive: navigationShell.currentIndex == 2,
                    onTap: () => _onTap(context, 2),
                  ),
                  WebNavItem(
                    icon: Icons.medical_services_rounded,
                    label: 'الأدوية',
                    isActive: navigationShell.currentIndex == 3,
                    onTap: () => _onTap(context, 3),
                  ),
                  WebNavItem(
                    icon: Icons.person_rounded,
                    label: 'الملف الشخصي',
                    isActive: navigationShell.currentIndex == 4,
                    onTap: () => _onTap(context, 4),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Divider(color: Colors.white24),
                  ),

                  // Additional Quick Actions for Web
                  WebNavItem(
                    icon: Icons.biotech_rounded,
                    label: 'التحاليل',
                    isActive: false,
                    onTap: () => context.push('/lab-entry'),
                  ),
                  WebNavItem(
                    icon: Icons.edit_note_rounded,
                    label: 'السجل اليومي',
                    isActive: false,
                    onTap: () => context.push('/daily_entry'),
                  ),
                ]
                    .animate(interval: 50.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
              ),
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: WebNavItem(
              icon: Icons.logout_rounded,
              label: 'تسجيل الخروج',
              isActive: false,
              onTap: () {
                // Handle logout logic if needed, or navigate to login
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
