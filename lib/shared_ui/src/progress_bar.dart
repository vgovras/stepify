import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Animated gradient progress bar.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.progress});

  /// Value between 0.0 and 1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.br,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ac),
        ),
      ),
    );
  }
}
