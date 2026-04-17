import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class AuthGatewayScreen extends StatelessWidget {
  const AuthGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/logo_icon.png'),
            opacity: 0.03,
            scale: 0.5,
            alignment: Alignment.center,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo area
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.spa_rounded, size: 60, color: AppColors.primary),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).rotate(begin: -0.2, end: 0),
            
            const SizedBox(height: 40),
            Text(
              'أهلاً بك في جلوميا',
              style: AppTextStyles.h1.copyWith(fontSize: 28),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 12),
            Text(
              'كل ما تحتاجه للعناية بكليتيك في مكان واحد',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
            
            const Spacer(),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => GoRouter.of(context).push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text('إنشاء حساب جديد', style: AppTextStyles.h3.copyWith(color: Colors.white)),
              ),
            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () => GoRouter.of(context).push('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text('تسجيل الدخول', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
              ),
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
