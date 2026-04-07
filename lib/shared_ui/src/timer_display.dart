import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/text_styles.dart';
import '../../core/core.dart';
import 'svg_icon.dart';

/// Inline timer block displayed within a step card.
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.timerState,
    required this.label,
    this.isBackground = false,
  });

  final TimerState timerState;
  final String label;
  final bool isBackground;

  @override
  Widget build(BuildContext context) {
    final isUrgent = timerState.isUrgent;
    final isDone = timerState.isDone;

    final borderColor = isDone
        ? const Color(0x66_6AAF6A)
        : timerState.isRunning
        ? const Color(0x8C_E8B44C)
        : const Color(0x42_E8B44C);

    final digitColor = isDone
        ? AppColors.gr
        : isUrgent
        ? AppColors.rd
        : AppColors.ac;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1C_E8B44C), Color(0x12_D4793A)],
        ),
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: AppSizes.fontLabel,
                        fontWeight: FontWeight.w600,
                        color: AppColors.t3,
                        letterSpacing: 0.9,
                      ),
                    ),
                    if (isBackground) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.highVoltage,
                            width: 13,
                            height: 13,
                          ),
                          const SizedBox(width: 2),
                          const Flexible(
                            child: Text(
                              'Продовжується у фоні після "Далі"',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppSizes.fontLabel,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ac2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                formatTimer(timerState.secondsRemaining),
                style: AppTextStyles.timer.copyWith(color: digitColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: timerState.progress,
              minHeight: 3,
              backgroundColor: AppColors.br,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ac),
            ),
          ),
        ],
      ),
    );
  }
}
