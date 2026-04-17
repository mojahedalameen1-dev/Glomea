import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/constants/health_constants.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_types.dart';
import 'package:kidneytrack_mobile/core/providers/localization_provider.dart';
import 'package:kidneytrack_mobile/core/widgets/indicators/status_badge.dart';
import 'package:kidneytrack_mobile/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(authNotifierProvider).valueOrNull;
    final birth = patient?.birthDate;
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(patient),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    title: l10n.healthInfo,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          l10n.birthDateAge,
                          birth != null
                              ? '${birth.year}/${birth.month}/${birth.day} (${_calculateAge(birth)} ${l10n.years})'
                              : l10n.tapToSelect,
                          onTap: () => _updateBirthDate(context, ref, patient),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.targetBp,
                          '${patient?.targetSystolic ?? HealthConstants.profileScreenDefaultSystolic} / ${patient?.targetDiastolic ?? HealthConstants.profileScreenDefaultDiastolic}',
                          onTap: () =>
                              _showBpTargetSheet(context, ref, patient),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.height,
                          '${patient?.heightCm?.toInt() ?? "-"} ${l10n.unitCm}',
                          onTap: () => _updateField(context, ref, 'heightCm',
                              l10n.height, patient?.heightCm ?? 170.0),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.weight,
                          '${patient?.weightKg ?? "-"} ${l10n.unitKg}',
                          onTap: () => _updateField(context, ref, 'weightKg',
                              l10n.weight, patient?.weightKg ?? 70.0),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.fluidLimit,
                          '${patient?.fluidLimitMl ?? HealthConstants.defaultFluidLimitMl} ${l10n.unitMl}',
                          onTap: () => _updateField(
                              context,
                              ref,
                              'fluidLimitMl',
                              l10n.fluidLimit,
                              (patient?.fluidLimitMl ??
                                      HealthConstants.defaultFluidLimitMl)
                                  .toDouble()),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.potassiumLimit,
                          '${patient?.potassiumLimitMg ?? HealthConstants.defaultPotassiumLimitMg} ${l10n.unitMg}',
                          onTap: () => _updateField(
                              context,
                              ref,
                              'potassiumLimitMg',
                              l10n.potassiumLimit,
                              (patient?.potassiumLimitMg ??
                                      HealthConstants.defaultPotassiumLimitMg)
                                  .toDouble()),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.phosphorusLimit,
                          '${patient?.phosphorusLimitMg ?? HealthConstants.defaultPhosphorusLimitMg} ${l10n.unitMg}',
                          onTap: () => _updateField(
                              context,
                              ref,
                              'phosphorusLimitMg',
                              l10n.phosphorusLimit,
                              (patient?.phosphorusLimitMg ??
                                      HealthConstants.defaultPhosphorusLimitMg)
                                  .toDouble()),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.sodiumLimit,
                          '${patient?.sodiumLimitMg ?? HealthConstants.defaultSodiumLimitMg} ${l10n.unitMg}',
                          onTap: () => _updateField(
                              context,
                              ref,
                              'sodiumLimitMg',
                              l10n.sodiumLimit,
                              (patient?.sodiumLimitMg ??
                                      HealthConstants.defaultSodiumLimitMg)
                                  .toDouble()),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          l10n.proteinLimit,
                          '${patient?.proteinLimitG ?? HealthConstants.defaultProteinLimitG} ${l10n.unitG}',
                          onTap: () => _updateField(
                              context,
                              ref,
                              'proteinLimitG',
                              l10n.proteinLimit,
                              (patient?.proteinLimitG ??
                                      HealthConstants.defaultProteinLimitG)
                                  .toDouble()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.settings,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          Icons.notifications_outlined,
                          l10n.notifications,
                          subtitle: l10n.notificationsComingSoon,
                          trailing: Switch(
                            value: patient?.notificationsEnabled ?? false,
                            onChanged: null,
                          ),
                        ),
                        _buildDivider(),
                        _buildLanguageSetting(context, ref, activeLocale, l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.security,
                    child: _buildSettingTile(
                        Icons.lock_outline, l10n.changePassword,
                        onTap: () {}),
                  ),
                  const SizedBox(height: 40),
                  TextButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon:
                        const Icon(Icons.logout, color: AppColors.textCritical),
                    label: Text(l10n.logout,
                        style: const TextStyle(
                            color: AppColors.textCritical,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon:
                        const Icon(Icons.logout, color: AppColors.textCritical),
                    label: const Text('تسجيل الخروج',
                        style: TextStyle(
                            color: AppColors.textCritical,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic patient) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: patient?.avatarUrl != null
                ? NetworkImage(patient!.avatarUrl!)
                : null,
            child: patient?.avatarUrl == null
                ? Text(
                    patient?.fullName?.substring(0, 1).toUpperCase() ?? 'K',
                    style: AppTextStyles.h1
                        .copyWith(color: AppColors.primary, fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(patient?.fullName ?? l10n.patient,
              style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const StatusBadge(status: IndicatorStatus.safe),
              const SizedBox(width: 8),
              Text(
                '${_getStageDisplay(l10n, patient?.kidneyStage)} • ${_getDialysisDisplay(l10n, patient?.dialysisStatus)}',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStageDisplay(AppLocalizations l10n, String? stage) {
    switch (stage) {
      case 'STAGE_1':
        return l10n.stage1;
      case 'STAGE_2':
        return l10n.stage2;
      case 'STAGE_3':
        return l10n.stage3;
      case 'STAGE_4':
        return l10n.stage4;
      case 'STAGE_5':
        return l10n.stage5;
      case 'POST_TRANSPLANT':
        return l10n.kidneyTransplant;
      default:
        return l10n.notSpecified;
    }
  }

  String _getDialysisDisplay(AppLocalizations l10n, String? status) {
    switch (status) {
      case 'NON_DIALYSIS':
        return l10n.noDialysis;
      case 'HEMODIALYSIS':
        return l10n.hemodialysis;
      case 'PERITONEAL':
        return l10n.peritonealDialysis;
      default:
        return '-';
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: Text(title,
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.borderBase.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        color: AppColors.borderBase.withValues(alpha: 0.05),
        indent: 16,
        endIndent: 16);
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyM),
            Row(
              children: [
                Text(value,
                    style: AppTextStyles.h3
                        .copyWith(fontSize: 14, color: AppColors.primary)),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_left,
                      size: 16, color: AppColors.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context, WidgetRef ref,
      Locale activeLocale, AppLocalizations l10n) {
    final isAr = activeLocale.languageCode == 'ar';
    return _buildSettingTile(
      Icons.language,
      l10n.language,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isAr ? 'العربية' : 'English',
              style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_left,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
      onTap: () {
        ref
            .read(localizationProvider.notifier)
            .setLocale(isAr ? const Locale('en') : const Locale('ar'));
      },
    );
  }

  Widget _buildSettingTile(IconData icon, String label,
      {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyM),
      subtitle: subtitle != null
          ? Text(subtitle,
              style:
                  AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary))
          : null,
      trailing: trailing ??
          Icon(isRtl ? Icons.chevron_left : Icons.chevron_right,
              size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: Text(l10n.logout,
                style: const TextStyle(color: AppColors.textCritical)),
          ),
        ],
      ),
    );
  }

  void _updateField(BuildContext context, WidgetRef ref, String field,
      String label, double initialValue) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.edit} $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null) {
                final data = {
                  field: field == 'fluidLimitMl' ? value.toInt() : value
                };
                final error = await ref
                    .read(authNotifierProvider.notifier)
                    .updatePatient(data);
                if (error == null && context.mounted) {
                  Navigator.pop(context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error!)));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBpTargetSheet(
      BuildContext context, WidgetRef ref, dynamic patient) {
    final l10n = AppLocalizations.of(context)!;
    int systolic =
        patient?.targetSystolic ?? HealthConstants.profileScreenDefaultSystolic;
    int diastolic = patient?.targetDiastolic ??
        HealthConstants.profileScreenDefaultDiastolic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.editTargetBp, style: AppTextStyles.h2),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.systolic, style: AppTextStyles.bodyM),
                  Text('$systolic',
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.primary)),
                ],
              ),
              Slider(
                value: systolic.toDouble(),
                min: 90,
                max: 180,
                activeColor: AppColors.primary,
                onChanged: (v) => setSheetState(() => systolic = v.toInt()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.diastolic, style: AppTextStyles.bodyM),
                  Text('$diastolic',
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.primary)),
                ],
              ),
              Slider(
                value: diastolic.toDouble(),
                min: 60,
                max: 110,
                activeColor: AppColors.primary,
                onChanged: (v) => setSheetState(() => diastolic = v.toInt()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'targetSystolic': systolic,
                      'targetDiastolic': diastolic
                    };
                    final error = await ref
                        .read(authNotifierProvider.notifier)
                        .updatePatient(data);
                    if (error == null && context.mounted) {
                      Navigator.pop(context);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error!)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.saveChanges,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateBirthDate(
      BuildContext context, WidgetRef ref, dynamic patient) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: patient?.birthDate ?? DateTime(1980),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != patient?.birthDate) {
      final error = await ref
          .read(authNotifierProvider.notifier)
          .updatePatient({'birthDate': picked.toIso8601String()});
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}
