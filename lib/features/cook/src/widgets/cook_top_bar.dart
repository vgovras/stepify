import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';

/// Top bar with exit button, progress bar, and step counter.
class CookTopBar extends StatelessWidget {
  const CookTopBar({
    super.key,
    required this.completedCount,
    required this.totalSteps,
    required this.onExit,
  });

  final int completedCount;
  final int totalSteps;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? completedCount / totalSteps : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onExit,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                '✕',
                style: TextStyle(fontSize: 19, color: AppColors.t2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppProgressBar(progress: progress),
                const SizedBox(height: 5),
                Text(
                  '${completedCount + 1} / $totalSteps',
                  style: const TextStyle(
                    fontSize: AppSizes.fontLabel,
                    color: AppColors.t3,
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
