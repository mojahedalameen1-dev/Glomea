import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/medications_provider.dart';
import '../widgets/medication_card.dart';
import '../widgets/today_doses_widget.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  String _selectedFilterKey = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgSurfaceDark : AppColors.bgBase,
      appBar: AppBar(
        title: Text(l10n.myMedications, style: AppTextStyles.h2),
        backgroundColor: isDark ? AppColors.bgSurfaceDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(medicationsProvider.notifier).loadMedications(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => ref.read(medicationsProvider.notifier).loadMedications(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const TodayDosesWidget(),
                   const SizedBox(height: 32),
                   _buildSectionHeader(l10n.allMedications),
                   const SizedBox(height: 16),
                   _buildFilterChips(l10n),
                   const SizedBox(height: 16),
                   _buildMedicationList(state, l10n),
                   const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => context.push('/add-medication'),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h3,
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'key': 'all', 'label': l10n.filterAll},
      {'key': 'pending', 'label': l10n.filterPending},
      {'key': 'taken', 'label': l10n.filterTaken},
      {'key': 'missed', 'label': l10n.filterMissed},
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilterKey == filter['key'];
          return ChoiceChip(
            label: Text(filter['label'] as String),
            selected: isSelected,
            onSelected: (val) {
              if (val) setState(() => _selectedFilterKey = filter['key'] as String);
            },
            selectedColor: AppColors.primary,
            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.bgSurfaceDark 
                : Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderBase.withValues(alpha: 0.2),
              ),
            ),
            elevation: isSelected ? 2 : 0,
            pressElevation: 0,
          );
        },
      ),
    );
  }

  Widget _buildMedicationList(dynamic state, AppLocalizations l10n) {
    if (state.medications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medication_outlined,
        message: l10n.noMedicationsAdded,
        l10n: l10n,
      );
    }

    // Filter logic
    final filteredMeds = state.medications.where((med) {
      if (_selectedFilterKey == 'all') return true;
      
      final logs = state.todayLogs.where((l) => l.medicationId == med.id);
      if (logs.isEmpty) return false;

      if (_selectedFilterKey == 'taken') return logs.any((l) => l.status == 'taken');
      if (_selectedFilterKey == 'missed') return logs.any((l) => l.status == 'missed');
      if (_selectedFilterKey == 'pending') return logs.any((l) => l.status == 'pending');
      
      return true;
    }).toList();

    if (filteredMeds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.filter_list_off_rounded,
        message: l10n.noFilteredMedications,
        isFilterEmpty: true,
        l10n: l10n,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredMeds.length,
      itemBuilder: (context, index) {
        return MedicationCard(medication: filteredMeds[index]);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required AppLocalizations l10n,
    bool isFilterEmpty = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.bgSurfaceDark 
            : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderBase.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isFilterEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() => _selectedFilterKey = 'all'),
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: Text(l10n.resetFilter),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
