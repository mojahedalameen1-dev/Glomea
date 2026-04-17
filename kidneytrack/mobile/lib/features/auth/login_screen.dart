import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/widgets/layout/glomea_logo.dart';
import 'package:kidneytrack_mobile/features/auth/providers/auth_provider.dart';
import 'package:kidneytrack_mobile/core/theme/app_gradients.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/widgets/inputs/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _onLogin() async {
    final emailValue = _emailController.text.trim();
    final passValue = _passwordController.text.trim();
    
    if (emailValue.isEmpty || passValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء إدخال البيانات المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final error = await ref.read(authNotifierProvider.notifier).login(emailValue, passValue);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        // لا نحتاج للقيام بـ context.go هنا، الراوتر سيتكفل بالأمر تلقائياً
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.textCritical),
        );
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
                  child: Column(
                    children: [
                      // Header with Logo
                      Container(
                        height: screenHeight * 0.32,
                        width: double.infinity,
                        decoration: const BoxDecoration(gradient: AppGradients.headerGradient),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GlomeaLogo(size: 80),
                              const SizedBox(height: 12),
                              Text('جـلـومـيـا', 
                                style: AppTextStyles.h1.copyWith(color: Colors.white, letterSpacing: 2))
                                  .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                            ],
                          ),
                        ),
                      ),
                      
                      // Content Area
                      Transform.translate(
                          offset: const Offset(0, -32),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                            decoration: const BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('مرحباً بك مجدداً', style: AppTextStyles.h1),
                                Text('سجل دخولك لمتابعة صحتك اليوم', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                                
                                const SizedBox(height: 32),
                                
                                AppTextField(
                                  label: 'البريد الإلكتروني',
                                  controller: _emailController,
                                  hint: 'example@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                AppTextField(
                                  label: 'كلمة المرور',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.primary),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {}, // Forgot password
                                    child: Text('نسيت كلمة المرور؟', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary)),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      elevation: 4,
                                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                    ),
                                    child: _isLoading 
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text('تسجيل الدخول', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                Center(
                                  child: TextButton(
                                    onPressed: () => context.go('/register'),
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'ليس لديك حساب؟ ',
                                        style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                                        children: const [
                                          TextSpan(text: 'سجل الآن مجاناً', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
            );
          },
        ),
      ),
    );
  }
}

