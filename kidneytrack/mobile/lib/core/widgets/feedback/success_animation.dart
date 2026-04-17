import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimation extends StatelessWidget {
  final VoidCallback onComplete;

  const SuccessAnimation({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/success.json',
        repeat: false,
        onLoaded: (composition) {
          Future.delayed(composition.duration, onComplete);
        },
      ),
    );
  }
}
