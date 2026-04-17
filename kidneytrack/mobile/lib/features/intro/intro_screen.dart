import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_gradients.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroStep> _steps = [
    IntroStep(
      title: 'مرحباً بك في جلوميا',
      description: 'رفيقك الذكي للعناية بصحة كليتيك بأمان ودقة.',
      icon: Icons.favorite_rounded,
      color: AppColors.primary,
    ),
    IntroStep(
      title: 'تتبع مؤشراتي',
      description:
          'سجل فحوصاتك المخبرية وراقب تغيرات البوتاسيوم والكرياتينين بلحظة.',
      icon: Icons.analytics_rounded,
      color: AppColors.accent,
    ),
    IntroStep(
      title: 'تنبيهات ذكية',
      description:
          'احصل على تنبيهات فورية ونصائح طبية مبنية على نتائج فحوصاتك.',
      icon: Icons.notifications_active_rounded,
      color: AppColors.textWarning,
    ),
  ];

  void _onNext() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      GoRouter.of(context).go('/auth-gateway');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: 100,
                        color: step.color,
                      ),
                    )
                        .animate(key: ValueKey('icon_$index'))
                        .scale(duration: 600.ms, curve: Curves.easeOutBack)
                        .shimmer(delay: 800.ms, duration: 1500.ms),
                    const SizedBox(height: 60),
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1
                          .copyWith(color: AppColors.textPrimary),
                    )
                        .animate(key: ValueKey('title_$index'))
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 20),
                    Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    )
                        .animate(key: ValueKey('desc_$index'))
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              );
            },
          ),

          // Navigation Bottom Bar
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.borderBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next/Start Button
                GestureDetector(
                  onTap: _onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _steps.length - 1
                              ? 'ابدأ الآن'
                              : 'التالي',
                          style: AppTextStyles.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white),
                      ],
                    ),
                  )
                      .animate(
                          target: _currentPage == _steps.length - 1 ? 1 : 0)
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 400.ms)
                      .then()
                      .shake(hz: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
