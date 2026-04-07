import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

/// Dynamic button states during cooking.
///
/// Ported from demo.html `_updateDoneBtn` (lines 1914-1955).
enum ButtonState {
  /// No timer on current step — just advance.
  next,

  /// Background timer idle — launch + advance.
  bgTimerNext,

  /// Blocking timer not yet started — start it.
  blockingStart,

  /// Blocking timer running — show pause.
  blockingRunning,

  /// Blocking timer paused — show resume.
  blockingPaused,

  /// Blocking timer done — advance.
  blockingDone,

  /// Last step — show completion.
  lastStep,

  /// Waiting for bg timer — no available steps.
  waiting,
}

@immutable
class CookState {
  const CookState({
    required this.recipe,
    required this.stepStates,
    required this.currentStepId,
    required this.isWaiting,
    required this.completedCount,
    required this.buttonState,
    required this.activeTimers,
  });

  factory CookState.initial(Recipe recipe) {
    return CookState(
      recipe: recipe,
      stepStates: {
        for (final s in recipe.steps) s.id: const StepState.initial(),
      },
      currentStepId: null,
      isWaiting: false,
      completedCount: 0,
      buttonState: ButtonState.next,
      activeTimers: const {},
    );
  }

  final Recipe recipe;
  final Map<int, StepState> stepStates;
  final int? currentStepId;
  final bool isWaiting;
  final int completedCount;
  final ButtonState buttonState;

  /// Active timer states keyed by step ID — for float bars and timer display.
  final Map<int, TimerState> activeTimers;

  int get totalSteps => recipe.steps.length;

  /// The current [RecipeStep], or null if waiting/done.
  RecipeStep? get currentStep {
    if (currentStepId == null) return null;
    return recipe.steps.cast<RecipeStep?>().firstWhere(
      (s) => s?.id == currentStepId,
      orElse: () => null,
    );
  }

  /// Background timers that should be shown as float bars.
  /// Excludes the current step's timer (shown inline).
  /// Max [AppDurations.maxFloatBars], sorted by step ID.
  Map<int, TimerState> get floatBarTimers {
    final bars = <int, TimerState>{};
    final sorted = activeTimers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sorted) {
      if (bars.length >= AppDurations.maxFloatBars) break;
      final ts = entry.value;
      if (ts.isDone || ts.secondsRemaining <= 0) continue;
      // Skip if this is the current step's timer shown inline
      if (entry.key == currentStepId) continue;
      bars[entry.key] = ts;
    }
    return bars;
  }

  CookState copyWith({
    Recipe? recipe,
    Map<int, StepState>? stepStates,
    int? Function()? currentStepId,
    bool? isWaiting,
    int? completedCount,
    ButtonState? buttonState,
    Map<int, TimerState>? activeTimers,
  }) {
    return CookState(
      recipe: recipe ?? this.recipe,
      stepStates: stepStates ?? this.stepStates,
      currentStepId: currentStepId != null
          ? currentStepId()
          : this.currentStepId,
      isWaiting: isWaiting ?? this.isWaiting,
      completedCount: completedCount ?? this.completedCount,
      buttonState: buttonState ?? this.buttonState,
      activeTimers: activeTimers ?? this.activeTimers,
    );
  }
}
