import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gap/gap.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScanMethodSheet extends StatelessWidget {
  const ScanMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FocusScope(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'طريقة الفحص',
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: isDark ? const Border(top: BorderSide(color: AppColors.borderBaseDark)) : null,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Bar with Drag handle and Close button
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.close, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق',
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Text(
                'كيف تريد الفحص؟',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const Gap(8),
              Text(
                'اختر الطريقة المناسبة لنوع المنتج',
                style: AppTextStyles.bodyM.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const Gap(24),

              // بطاقة 1 — باركود
              _ScanMethodCard(
                lottieAsset: 'assets/animations/barcode_scan.json',
                title: 'مسح الباركود',
                description: 'صوّر الباركود الموجود على العبوة للحصول على نتيجة فورية',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () => _handleBarcodeScan(context),
              ),
              const Gap(16),

              // بطاقة 2 — بحث
              _ScanMethodCard(
                lottieAsset: 'assets/animations/search_food.json',
                title: 'بحث بالاسم',
                description: 'ابحث عن "تمر" أو "لحم" لمعرفة محتواها الغذائي',
                color: isDark ? AppColors.textSuccessDark : AppColors.textSuccess,
                isDark: isDark,
                onTap: () => _handleFoodSearch(context),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBarcodeScan(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!context.mounted) return;
      Navigator.pop(context);
      context.push(AppRouter.barcodeScanner);
    } else {
      if (!context.mounted) return;
      _showPermissionDenied(context);
    }
  }

  Future<void> _handleFoodSearch(BuildContext context) async {
    Navigator.pop(context);
    context.push(AppRouter.foodSearch);
  }

  void _showPermissionDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ نحتاج صلاحية الكاميرا لمسح الباركود')),
    );
  }
}

class _ScanMethodCard extends StatelessWidget {
  final String lottieAsset, title, description;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ScanMethodCard({
    required this.lottieAsset,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Lottie.asset(
                  lottieAsset,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.qr_code_scanner, color: color, size: 40),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      description,
                      style: AppTextStyles.bodyS.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
