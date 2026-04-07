import 'package:flutter/foundation.dart';

@immutable
class TimerState {
  const TimerState({
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.isRunning,
    required this.isDone,
  });

  const TimerState.initial(this.totalSeconds)
    : secondsRemaining = totalSeconds,
      isRunning = false,
      isDone = false;

  final int secondsRemaining;
  final int totalSeconds;
  final bool isRunning;
  final bool isDone;

  double get progress => totalSeconds > 0 ? secondsRemaining / totalSeconds : 0;

  /// Whether the timer is in the urgency zone (last 15%).
  bool get isUrgent => isRunning && !isDone && progress <= 0.15;

  TimerState copyWith({
    int? secondsRemaining,
    int? totalSeconds,
    bool? isRunning,
    bool? isDone,
  }) {
    return TimerState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerState &&
          runtimeType == other.runtimeType &&
          secondsRemaining == other.secondsRemaining &&
          totalSeconds == other.totalSeconds &&
          isRunning == other.isRunning &&
          isDone == other.isDone;

  @override
  int get hashCode =>
      Object.hash(secondsRemaining, totalSeconds, isRunning, isDone);
}
