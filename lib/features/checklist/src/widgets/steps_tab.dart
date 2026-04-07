import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../checklist_cubit.dart';
import '../checklist_state.dart';

/// Steps overview tab — numbered list of all recipe steps
/// sorted by weight, with optional timer badges.
class StepsTab extends StatelessWidget {
  const StepsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistCubit, ChecklistState>(
      builder: (context, state) {
        final sorted = state.sortedSteps;

        return ListView.builder(
          cacheExtent: 300,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHorizontal,
            vertical: 12,
          ),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final step = sorted[index];
            return _StepOverviewItem(
              number: index + 1,
              text: step.text,
              timer: step.timer,
            );
          },
        );
      },
    );
  }
}

class _StepOverviewItem extends StatelessWidget {
  const _StepOverviewItem({
    required this.number,
    required this.text,
    this.timer,
  });

  final int number;
  final String text;
  final StepTimer? timer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberCircle(number: number),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: AppSizes.fontMain,
                    color: AppColors.tx,
                    height: 1.4,
                  ),
                ),
                if (timer != null) ...[
                  const SizedBox(height: 6),
                  _TimerBadge(timer: timer!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberCircle extends StatelessWidget {
  const _NumberCircle({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.s2,
        border: Border.all(color: AppColors.br),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
          color: AppColors.t2,
        ),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.timer});

  final StepTimer timer;

  @override
  Widget build(BuildContext context) {
    final label = timer.isBackground
        ? '\u{26A1} ${timer.minutes} хв \u{00B7} у фоні'
        : '\u{23F1} ${timer.minutes} хв';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.br),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.fontLabel,
          color: timer.isBackground ? AppColors.ac : AppColors.t2,
        ),
      ),
    );
  }
}
