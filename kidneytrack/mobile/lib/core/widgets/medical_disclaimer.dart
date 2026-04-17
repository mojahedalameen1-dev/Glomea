import 'package:flutter/material.dart';

class MedicalDisclaimer extends StatelessWidget {
  final bool compact;
  final Color? color;

  const MedicalDisclaimer({
    super.key,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'هذه المعلومات للتوعية فقط ولا تغني عن استشارة طبيبك المختص',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? Colors.grey[600],
            fontSize: 10,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? Colors.blue).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 22,
            color: color ?? Colors.blue,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه طبي للاسترشاد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'جميع التوصيات والحدود الغذائية في جلوميا هي معلومات استرشادية بناءً على المعايير العامة للكلية ولا تغني عن استشارة طبيبك أو أخصائي التغذية الخاص بك.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
