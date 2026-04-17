import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_shadows.dart';

class PremiumDashboardHeader extends ConsumerWidget {
  final String? firstName;
  final int unreadCount;

  const PremiumDashboardHeader({
    super.key,
    required this.firstName,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasName = firstName != null && firstName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgPageDark : AppColors.bgPage,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      hasName ? firstName!.substring(0, 1).toUpperCase() : 'م',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: AppTextStyles.bodyS.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.premiumTextSub,
                        ),
                      ),
                      Text(
                        hasName ? firstName! : 'المريض',
                        style: AppTextStyles.h2.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildNotificationBadge(context, unreadCount, isDark),
            ],
          ),
          const Gap(24),
          _buildSearchBar(context, isDark),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير 👋';
    if (hour < 17) return 'طاب يومك 👋';
    return 'مساء الخير 👋';
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.premiumCardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: TextField(
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            // Functional search mapping
            context
                .push('/history?search=${Uri.encodeComponent(value.trim())}');
          }
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن التحاليل أو الأدوية...',
          hintStyle: AppTextStyles.bodyM.copyWith(
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[400],
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context, int count, bool isDark) {
    return InkWell(
      onTap: () => context.push('/alerts'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.premiumCardDark : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark ? null : AppShadows.elev1,
        ),
        child: Stack(
          children: [
            const Icon(Icons.notifications_none_outlined, size: 24),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.textCritical,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
