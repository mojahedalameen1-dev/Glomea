import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/theme/app_gradients.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/widgets/inputs/app_text_field.dart';
import 'package:kidneytrack_mobile/core/widgets/layout/glomea_logo.dart';
import 'package:kidneytrack_mobile/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;

  double _strength = 0.0;
  String _strengthLabel = '';
  Color _strengthColor = AppColors.textCritical;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _checkStrength(String val) {
    setState(() {
      if (val.isEmpty) {
        _strength = 0;
        _strengthLabel = '';
      } else if (val.length < 8 ||
          !val.contains(RegExp(r'[A-Z]')) ||
          !val.contains(RegExp(r'[0-9]'))) {
        _strength = 0.3;
        _strengthLabel = 'ضعيفة جداً (تحتاج حرف كبير ورقم)';
        _strengthColor = AppColors.textCritical;
      } else if (val.length < 10) {
        _strength = 0.6;
        _strengthLabel = 'جيدة ومقبولة';
        _strengthColor = AppColors.textWarning;
      } else {
        _strength = 1.0;
        _strengthLabel = 'كلمة مرور قوية جداً';
        _strengthColor = AppColors.textSuccess;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('كلمات المرور غير متطابقة'),
            backgroundColor: AppColors.textCritical),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final error = await ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (!mounted) return;

      if (error == null) {
        // Handled by router
      } else if (error == 'CONFIRM_EMAIL') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'تم إنشاء الحساب! يرجى مراجعة بريدك الإلكتروني لتأكيد الحساب قبل تسجيل الدخول.'),
            backgroundColor: AppColors.textSuccess,
            duration: Duration(seconds: 10),
          ),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error), backgroundColor: AppColors.textCritical),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حدث خطأ غير متوقع'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header
                        Container(
                          height: screenHeight * 0.25,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              gradient: AppGradients.headerGradient),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const GlomeaLogo(size: 60),
                                const SizedBox(height: 12),
                                Text(
                                  'جلوميا',
                                  style: AppTextStyles.h1.copyWith(
                                      color: Colors.white, letterSpacing: 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Form Content
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            decoration: const BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('إنشاء حساب جديد',
                                    style: AppTextStyles.h1
                                        .copyWith(fontSize: 26)),
                                const SizedBox(height: 8),
                                Text('ابدأ رحلتك نحو صحة أفضل اليوم',
                                    style: AppTextStyles.bodyM.copyWith(
                                        color: AppColors.textSecondary)),

                                const SizedBox(height: 32),

                                AppTextField(
                                  label: 'البريد الإلكتروني',
                                  hint: 'testuser@example.com',
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocus),
                                  validator: (v) =>
                                      v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                ),

                                const SizedBox(height: 20),
                                AppTextField(
                                  label: 'كلمة المرور',
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  isPassword: true,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_confirmFocus),
                                  onChanged: _checkStrength,
                                  validator: (v) => v!.length < 8
                                      ? 'يجب أن تكون ٨ محارف على الأقل'
                                      : null,
                                ),

                                const SizedBox(height: 12),
                                // Strength Indicator
                                AnimatedOpacity(
                                  duration: 300.ms,
                                  opacity:
                                      _passwordController.text.isEmpty ? 0 : 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('قوة كلمة المرور',
                                              style: AppTextStyles.bodyS),
                                          Text(_strengthLabel,
                                              style: AppTextStyles.bodyS
                                                  .copyWith(
                                                      color: _strengthColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _strength,
                                          backgroundColor: AppColors.borderBase
                                              .withValues(alpha: 0.1),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  _strengthColor),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                AppTextField(
                                  label: 'تأكيد كلمة المرور',
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmFocus,
                                  isPassword: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleRegister(),
                                  validator: (v) =>
                                      v != _passwordController.text
                                          ? 'لا تطابق كلمة المرور'
                                          : null,
                                ),

                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        _isLoading ? null : _handleRegister,
                                    child: AnimatedSwitcher(
                                      duration: 300.ms,
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text('إنشاء الحساب',
                                              style: AppTextStyles.h2.copyWith(
                                                  color: Colors.white)),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .scale(delay: 200.ms, duration: 400.ms),

                                const SizedBox(height: 24),
                                Center(
                                  child: TextButton(
                                    onPressed: () => GoRouter.of(context).pop(),
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'لديك حساب بالفعل؟ ',
                                        style: AppTextStyles.bodyM.copyWith(
                                            color: AppColors.textSecondary),
                                        children: const [
                                          TextSpan(
                                            text: 'سجل دخولك',
                                            style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
