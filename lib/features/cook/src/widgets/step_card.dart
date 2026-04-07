import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';

/// Displays the current step's content with optional note and timer.
class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    this.timerState,
  });

  final RecipeStep step;
  final int stepNumber;
  final int totalSteps;
  final TimerState? timerState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'КРОК $stepNumber З $totalSteps',
            style: const TextStyle(
              fontSize: AppSizes.fontLabel,
              fontWeight: FontWeight.w600,
              color: AppColors.t3,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.text,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: AppSizes.fontStepTitle,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (step.note != null) ...[
            const SizedBox(height: 14),
            NoteBlock(note: step.note!),
          ],
          if (step.timer != null) ...[
            const SizedBox(height: 12),
            TimerDisplay(
              timerState:
                  timerState ?? TimerState.initial(step.timer!.minutes * 60),
              label: step.timer!.label,
              isBackground: step.timer!.isBackground,
            ),
          ],
        ],
      ),
    );
  }
}
