import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import 'cook_state.dart';
import 'step_graph.dart';
import 'timer_service.dart';

/// Orchestrates the cooking session — step graph, timers, and state.
///
/// Ported from demo.html `stepDone()` (lines 1958-1991) and
/// `_updateDoneBtn` (lines 1914-1955).
class CookCubit extends Cubit<CookState> {
  CookCubit({
    required Recipe recipe,
    required NotificationService notificationService,
  }) : _notificationService = notificationService,
       super(CookState.initial(recipe)) {
    _timerService = TimerService(onTick: _onTimerTick);
  }

  final NotificationService _notificationService;
  late final TimerService _timerService;

  /// Starts the cooking session — picks the first step.
  void startCooking() {
    final next = pickNextStep(state.recipe.steps, state.stepStates);
    if (next == null) return;
    emit(
      state.copyWith(
        currentStepId: () => next.id,
        isWaiting: false,
        buttonState: _computeButtonState(stepId: next.id),
      ),
    );
  }

  /// Handles the main action button press.
  ///
  /// Behavior depends on [ButtonState]:
  /// - [ButtonState.next] / [ButtonState.bgTimerNext]: complete step
  /// - [ButtonState.blockingStart]: start the blocking timer
  /// - [ButtonState.blockingRunning]: pause the timer
  /// - [ButtonState.blockingPaused]: resume the timer
  /// - [ButtonState.blockingDone]: complete step
  /// - [ButtonState.lastStep]: complete last step
  void onActionPressed() {
    switch (state.buttonState) {
      case ButtonState.next:
      case ButtonState.bgTimerNext:
      case ButtonState.blockingDone:
      case ButtonState.lastStep:
        _completeStep();
      case ButtonState.blockingStart:
        _startBlockingTimer();
      case ButtonState.blockingRunning:
        _pauseTimer();
      case ButtonState.blockingPaused:
        _resumeTimer();
      case ButtonState.waiting:
        break; // no-op
    }
  }

  /// Called when the app goes to background.
  void onAppPaused() {
    for (final entry in _timerService.activeTimers.entries) {
      final ts = entry.value;
      if (!ts.isRunning || ts.isDone) continue;
      if (!_timerService.isBackgroundTimer(entry.key)) continue;
      final readyAt = _timerService.getReadyAt(entry.key);
      if (readyAt == null) continue;
      _notificationService.scheduleTimerNotification(
        stepId: entry.key,
        label: _findTimerLabel(entry.key),
        fireAt: readyAt,
      );
    }
  }

  /// Called when the app returns to foreground.
  void onAppResumed() {
    _notificationService.cancelAll();
    _timerService.recalculateFromNow();
  }

  /// Stops the cooking session — cancels all timers.
  void stopCooking() {
    _timerService.dispose();
    _notificationService.cancelAll();
  }

  @override
  Future<void> close() {
    _timerService.dispose();
    return super.close();
  }

  // ── Private methods ───────────────────────────────────────

  void _completeStep() {
    final step = state.currentStep;
    if (step == null) return;

    // Launch bg timer if this step has one and it hasn't started
    if (step.timer != null &&
        step.timer!.isBackground &&
        !_timerService.activeTimers.containsKey(step.id)) {
      _timerService.startTimer(
        step.id,
        step.timer!.minutes * 60,
        isBackground: true,
      );
    }

    // Mark step as done
    final newStates = Map<int, StepState>.from(state.stepStates);
    final readyAt = _timerService.getReadyAt(step.id);
    newStates[step.id] = newStates[step.id]!.copyWith(
      isDone: true,
      readyAt: () => readyAt ?? DateTime.now(),
    );

    final completedCount = newStates.values.where((s) => s.isDone).length;
    final timers = _timerService.activeTimers;

    // Pick next step
    final next = pickNextStep(state.recipe.steps, newStates);

    if (next == null) {
      final allDone = isAllDone(newStates);
      emit(
        state.copyWith(
          stepStates: newStates,
          currentStepId: () => null,
          isWaiting: !allDone,
          completedCount: completedCount,
          buttonState: ButtonState.waiting,
          activeTimers: timers,
        ),
      );
      if (allDone) stopCooking();
      return;
    }

    emit(
      state.copyWith(
        stepStates: newStates,
        currentStepId: () => next.id,
        isWaiting: false,
        completedCount: completedCount,
        buttonState: _computeButtonState(
          stepId: next.id,
          stepStates: newStates,
        ),
        activeTimers: timers,
      ),
    );
  }

  void _startBlockingTimer() {
    final step = state.currentStep;
    if (step?.timer == null) return;
    _timerService.startTimer(
      step!.id,
      step.timer!.minutes * 60,
      isBackground: false,
    );
    emit(
      state.copyWith(
        activeTimers: _timerService.activeTimers,
        buttonState: _computeButtonState(),
      ),
    );
  }

  void _pauseTimer() {
    final stepId = state.currentStepId;
    if (stepId == null) return;
    _timerService.pauseTimer(stepId);
    emit(
      state.copyWith(
        activeTimers: _timerService.activeTimers,
        buttonState: _computeButtonState(),
      ),
    );
  }

  void _resumeTimer() {
    final stepId = state.currentStepId;
    if (stepId == null) return;
    _timerService.resumeTimer(stepId);
    emit(
      state.copyWith(
        activeTimers: _timerService.activeTimers,
        buttonState: _computeButtonState(),
      ),
    );
  }

  void _onTimerTick(Map<int, TimerState> timers, int? completedId) {
    // Update step states with timer info
    final newStates = Map<int, StepState>.from(state.stepStates);
    for (final entry in timers.entries) {
      final existing = newStates[entry.key];
      if (existing == null) continue;
      newStates[entry.key] = existing.copyWith(
        timerState: () => entry.value,
        readyAt: () {
          if (entry.value.isDone &&
              _timerService.isBackgroundTimer(entry.key)) {
            return DateTime.now();
          }
          return _timerService.getReadyAt(entry.key) ?? existing.readyAt;
        },
      );
    }

    // If a bg timer completed while we're waiting, try to advance
    if (completedId != null && state.isWaiting) {
      final next = pickNextStep(state.recipe.steps, newStates);
      if (next != null) {
        emit(
          state.copyWith(
            currentStepId: () => next.id,
            isWaiting: false,
            stepStates: newStates,
            activeTimers: timers,
            buttonState: _computeButtonState(
              stepId: next.id,
              stepStates: newStates,
            ),
          ),
        );
        return;
      }
      if (isAllDone(newStates)) {
        emit(
          state.copyWith(
            currentStepId: () => null,
            isWaiting: false,
            stepStates: newStates,
            activeTimers: timers,
          ),
        );
        stopCooking();
        return;
      }
    }

    // Single emit for regular tick — recompute button if current timer changed
    final newButton = completedId == state.currentStepId
        ? _computeButtonState(stepStates: newStates)
        : null;

    emit(
      state.copyWith(
        stepStates: newStates,
        activeTimers: timers,
        buttonState: newButton,
      ),
    );
  }

  /// Pure function — computes the button state without emitting.
  ///
  /// Optionally accepts [stepId] and [stepStates] overrides for computing
  /// button state for a step that hasn't been emitted yet.
  ButtonState _computeButtonState({
    int? stepId,
    Map<int, StepState>? stepStates,
  }) {
    final targetId = stepId ?? state.currentStepId;
    final states = stepStates ?? state.stepStates;

    if (targetId == null) return ButtonState.waiting;

    final step = state.recipe.steps.cast<RecipeStep?>().firstWhere(
      (s) => s?.id == targetId,
      orElse: () => null,
    );
    if (step == null) return ButtonState.waiting;

    final remaining = state.recipe.steps.where(
      (s) => !states[s.id]!.isDone,
    );
    final isLast = remaining.length <= 1;

    if (step.timer == null) {
      return isLast ? ButtonState.lastStep : ButtonState.next;
    }

    if (step.timer!.isBackground) {
      return isLast ? ButtonState.lastStep : ButtonState.bgTimerNext;
    }

    // Blocking timer
    final timerState = _timerService.activeTimers[step.id];
    if (timerState == null) return ButtonState.blockingStart;
    if (timerState.isDone) {
      return isLast ? ButtonState.lastStep : ButtonState.blockingDone;
    }
    if (timerState.isRunning) return ButtonState.blockingRunning;
    return ButtonState.blockingPaused;
  }

  String _findTimerLabel(int stepId) {
    return state.recipe.steps
            .cast<RecipeStep?>()
            .firstWhere((s) => s?.id == stepId, orElse: () => null)
            ?.timer
            ?.label ??
        'Таймер';
  }
}
