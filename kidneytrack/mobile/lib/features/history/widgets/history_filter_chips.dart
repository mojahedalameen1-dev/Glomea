import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

enum HistoryCategory { all, labs, vitals, food, medications }

extension HistoryCategoryX on HistoryCategory {
  String get label {
    return switch (this) {
      HistoryCategory.all => 'الكل',
      HistoryCategory.labs => 'التحاليل',
      HistoryCategory.vitals => 'المؤشرات حيوية',
      HistoryCategory.food => 'الغذاء',
      HistoryCategory.medications => 'الأدوية',
    };
  }

  IconData get icon {
    return switch (this) {
      HistoryCategory.all => Icons.dashboard_outlined,
      HistoryCategory.labs => Icons.science_outlined,
      HistoryCategory.vitals => Icons.favorite_outline,
      HistoryCategory.food => Icons.restaurant_outlined,
      HistoryCategory.medications => Icons.medication_outlined,
    };
  }
}

class HistoryFilterChips extends StatelessWidget {
  final HistoryCategory selected;
  final Function(HistoryCategory) onSelected;

  const HistoryFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padStatic20),
        scrollDirection: Axis.horizontal,
        itemCount: HistoryCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = HistoryCategory.values[index];
          final isSelected = selected == category;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterChip(
              avatar: Icon(
                category.icon,
                size: 18,
                color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              label: Text(category.label),
              selected: isSelected,
              onSelected: (_) => onSelected(category),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              labelStyle: AppTextStyles.label.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
              backgroundColor: isDark ? AppColors.bgSurfaceDark : Colors.white,
              side: BorderSide(
                color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? AppColors.borderBaseDark : AppColors.borderBase).withValues(alpha: 0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          );
        },
      ),
    );
  }
}
