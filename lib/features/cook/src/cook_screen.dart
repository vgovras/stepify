import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cook_cubit.dart';
import 'cook_state.dart';
import 'widgets/bottom_action_btn.dart';
import 'widgets/cook_top_bar.dart';
import 'widgets/exit_dialog.dart';
import 'widgets/float_bar_section.dart';
import 'widgets/step_card.dart';
import 'widgets/waiting_view.dart';

/// The core cooking screen — one step at a time.
class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CookCubit>().startCooking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<CookCubit>();
    if (state == AppLifecycleState.paused) {
      cubit.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      cubit.onAppResumed();
    }
  }

  Future<void> _handleExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitDialog(),
    );
    if (shouldExit == true && mounted) {
      context.read<CookCubit>().stopCooking();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<CookCubit, CookState>(
            listenWhen: (prev, curr) =>
                prev.completedCount != curr.completedCount &&
                curr.currentStepId == null &&
                !curr.isWaiting,
            listener: (context, state) {
              // All steps done — navigate to done screen
              final recipeId = state.recipe.id;
              context.go('/recipe/$recipeId/done');
            },
            builder: (context, state) {
              final cubit = context.read<CookCubit>();
              final step = state.currentStep;
              final remaining = state.recipe.steps
                  .where((s) => !state.stepStates[s.id]!.isDone)
                  .length;

              return Column(
                children: [
                  // Float bars
                  FloatBarSection(state: state),
                  // Top bar
                  CookTopBar(
                    completedCount: state.completedCount,
                    totalSteps: state.totalSteps,
                    onExit: _handleExit,
                  ),
                  // Step card or waiting view
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: state.isWaiting
                          ? WaitingView(
                              key: const ValueKey('waiting'),
                              state: state,
                            )
                          : step != null
                          ? StepCard(
                              key: ValueKey(step.id),
                              step: step,
                              stepNumber: state.completedCount + 1,
                              totalSteps: state.totalSteps,
                              timerState: state.activeTimers[step.id],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // Bottom action button
                  BottomActionBtn(
                    buttonState: state.buttonState,
                    onPressed: cubit.onActionPressed,
                    isLastStep: remaining <= 1,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
