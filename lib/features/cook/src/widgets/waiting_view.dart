import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared_ui/shared_ui.dart';
import '../cook_state.dart';

/// Displayed when [pickNextStep] returns null but steps remain.
/// Shows active bg timer countdowns.
class WaitingView extends StatelessWidget {
  const WaitingView({super.key, required this.state});

  final CookState state;

  @override
  Widget build(BuildContext context) {
    final bgTimers = state.activeTimers.entries
        .where((e) => !e.value.isDone && e.value.secondsRemaining > 0)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ЗАЧЕКАЙТЕ...',
            style: TextStyle(
              fontSize: AppSizes.fontLabel,
              fontWeight: FontWeight.w600,
              color: AppColors.t3,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Наступний крок буде доступний після таймера',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: AppSizes.fontStepTitle,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in bgTimers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WaitingTimerCard(
                label: _findLabel(entry.key),
                timerState: entry.value,
              ),
            ),
          const SizedBox(height: 8),
          const NoteBlock(
            note: StepNote(
              type: NoteType.tip,
              text:
                  '💡 Можна відійти — таймер у фоні. Повернетесь '
                  "— крок з'явиться сам",
            ),
          ),
        ],
      ),
    );
  }

  String _findLabel(int stepId) {
    return state.recipe.steps
            .cast<RecipeStep?>()
            .firstWhere((s) => s?.id == stepId, orElse: () => null)
            ?.timer
            ?.label ??
        '';
  }
}

class _WaitingTimerCard extends StatelessWidget {
  const _WaitingTimerCard({required this.label, required this.timerState});

  final String label;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1A_E8B44C), Color(0x0F_D4793A)],
        ),
        border: Border.all(color: const Color(0x4D_E8B44C), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
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
                const SizedBox(height: 4),
                const Text(
                  "Наступний крок з'явиться автоматично",
                  style: TextStyle(fontSize: 13, color: AppColors.t2),
                ),
              ],
            ),
          ),
          Text(
            formatTimer(timerState.secondsRemaining),
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: AppColors.ac,
            ),
          ),
        ],
      ),
    );
  }
}
