import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/core.dart';

/// Background timer indicator bar at the top of the cook screen.
class FloatBar extends StatelessWidget {
  const FloatBar({
    super.key,
    required this.label,
    required this.secondsRemaining,
  });

  final String label;
  final int secondsRemaining;

  bool get _isUrgent => secondsRemaining <= AppDurations.floatBarUrgencySeconds;

  @override
  Widget build(BuildContext context) {
    final dotColor = _isUrgent ? AppColors.rd : AppColors.ac;
    final timeColor = _isUrgent ? AppColors.rd : AppColors.ac;
    final borderColor = _isUrgent
        ? const Color(0x66_D46060)
        : const Color(0x2E_E8B44C);

    return Container(
      height: AppSizes.floatBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xF8_100D08),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppSizes.fontLabel,
                color: AppColors.t2,
              ),
            ),
          ),
          Text(
            formatTimer(secondsRemaining),
            style: GoogleFonts.playfairDisplay(
              fontSize: AppSizes.fontFloatBarTimer,
              fontWeight: FontWeight.w700,
              color: timeColor,
            ),
          ),
          const SizedBox(width: 6),
          const Text('→', style: TextStyle(fontSize: 11, color: AppColors.t3)),
        ],
      ),
    );
  }
}
