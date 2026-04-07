import 'package:flutter/foundation.dart';

import 'timer_state.dart';

@immutable
class StepState {
  const StepState({required this.isDone, this.readyAt, this.timerState});

  const StepState.initial() : isDone = false, readyAt = null, timerState = null;

  final bool isDone;

  /// Real-clock time when this step's bg timer will be done.
  /// Used by [timerDep] checks in `pickNextStep()`.
  final DateTime? readyAt;

  final TimerState? timerState;

  StepState copyWith({
    bool? isDone,
    DateTime? Function()? readyAt,
    TimerState? Function()? timerState,
  }) {
    return StepState(
      isDone: isDone ?? this.isDone,
      readyAt: readyAt != null ? readyAt() : this.readyAt,
      timerState: timerState != null ? timerState() : this.timerState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepState &&
          runtimeType == other.runtimeType &&
          isDone == other.isDone &&
          readyAt == other.readyAt &&
          timerState == other.timerState;

  @override
  int get hashCode => Object.hash(isDone, readyAt, timerState);
}
