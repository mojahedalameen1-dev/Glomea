import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/features/potassium_scanner/widgets/scan_method_sheet.dart';

class BottomNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => _openPotassiumScanner(context),
        shape: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
            Text(
              'فحص', 
              style: AppTextStyles.bodyS.copyWith(
                color: Colors.white, 
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        elevation: 0,
        padding: EdgeInsets.zero,
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'الرئيسية',
                index: 0,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
              ),
              _NavBarItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'السجل',
                index: 1,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
              ),
              const SizedBox(width: 64), // Optimized space for FAB
              _NavBarItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'تنبيهات',
                index: 2,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'الملف',
                index: 4,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPotassiumScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ScanMethodSheet(),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = index == currentIndex;
    
    final activeColor = isDark ? AppColors.textInfoDark : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 26,
          ),
          const Gap(4),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
