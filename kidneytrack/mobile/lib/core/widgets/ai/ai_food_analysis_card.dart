import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kidneytrack_mobile/core/services/ai_food_analysis_service.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';

class AiFoodAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> nutrients;

  const AiFoodAnalysisCard({super.key, required this.nutrients});

  @override
  State<AiFoodAnalysisCard> createState() => _AiFoodAnalysisCardState();
}

class _AiFoodAnalysisCardState extends State<AiFoodAnalysisCard> {
  String? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    // Artificial small delay for smoother transition if local
    final result = await AiFoodAnalysisService.analyzeFood(widget.nutrients);
    if (mounted) {
      setState(() {
        _analysis = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmer();
    }
    
    if (_analysis == null || _analysis!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'رأي المساعد الغذائي',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _analysis!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'هذه إرشادات مساعدة فقط، استشر طبيبك دائمًا',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
