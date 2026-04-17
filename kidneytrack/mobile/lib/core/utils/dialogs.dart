import 'package:flutter/material.dart';

Future<bool> showExitConfirmDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('الخروج بدون حفظ؟'),
          content: const Text('البيانات التي أدخلتها لن تُحفظ.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('البقاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('الخروج'),
            ),
          ],
        ),
      ) ??
      false;
}
