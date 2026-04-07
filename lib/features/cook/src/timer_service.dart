import 'dart:async';

import '../../../core/core.dart';

/// Callback invoked on each tick with the current state of all
/// active timers and the ID of a timer that just completed (if any).
typedef TimerTickCallback =
    void Function(Map<int, TimerState> activeTimers, int? completedStepId);

/// Manages all active timers during a cooking session.
///
/// Uses a single [Timer.periodic] with 1-second resolution to tick
/// all background and blocking timers simultaneously.
/// Ported from `tasks/demo.html` `_startMasterTick` (lines 2146-2172).
class TimerService {
  TimerService({required TimerTickCallback onTick}) : _onTick = onTick;

  final TimerTickCallback _onTick;
  final Map<int, _ActiveTimer> _timers = {};
  Timer? _ticker;

  /// All current timer states, keyed by step ID.
  Map<int, TimerState> get activeTimers =>
      _timers.map((id, t) => MapEntry(id, t.state));

  /// Starts a timer for [stepId].
  void startTimer(int stepId, int totalSeconds, {required bool isBackground}) {
    _timers[stepId] = _ActiveTimer(
      state: TimerState(
        secondsRemaining: totalSeconds,
        totalSeconds: totalSeconds,
        isRunning: true,
        isDone: false,
      ),
      isBackground: isBackground,
      readyAt: DateTime.now().add(Duration(seconds: totalSeconds)),
    );
    _ensureTickerRunning();
  }

  /// Pauses the timer for [stepId].
  void pauseTimer(int stepId) {
    final timer = _timers[stepId];
    if (timer == null || timer.state.isDone) return;
    _timers[stepId] = timer.withState(timer.state.copyWith(isRunning: false));
    _stopTickerIfIdle();
  }

  /// Resumes the timer for [stepId].
  void resumeTimer(int stepId) {
    final timer = _timers[stepId];
    if (timer == null || timer.state.isDone) return;
    _timers[stepId] = timer.withState(timer.state.copyWith(isRunning: true));
    _timers[stepId] = _timers[stepId]!.withReadyAt(
      DateTime.now().add(Duration(seconds: timer.state.secondsRemaining)),
    );
    _ensureTickerRunning();
  }

  /// Returns the [readyAt] DateTime for a background timer,
  /// used by [StepState.readyAt] for [timerDep] checks.
  DateTime? getReadyAt(int stepId) => _timers[stepId]?.readyAt;

  /// Whether a timer for [stepId] exists and is a background timer.
  bool isBackgroundTimer(int stepId) => _timers[stepId]?.isBackground ?? false;

  /// Recalculates timer states after app resume from background.
  ///
  /// For each active timer, computes remaining seconds from [readyAt]
  /// vs [DateTime.now()]. Timers that have passed are marked done.
  void recalculateFromNow() {
    final now = DateTime.now();
    int? completedId;

    for (final entry in _timers.entries) {
      final timer = entry.value;
      if (timer.state.isDone || !timer.state.isRunning) continue;

      final remaining = timer.readyAt.difference(now).inSeconds;
      if (remaining <= 0) {
        _timers[entry.key] = timer.withState(
          timer.state.copyWith(
            secondsRemaining: 0,
            isRunning: false,
            isDone: true,
          ),
        );
        completedId = entry.key;
      } else {
        _timers[entry.key] = timer.withState(
          timer.state.copyWith(secondsRemaining: remaining),
        );
      }
    }

    _onTick(activeTimers, completedId);
    _stopTickerIfIdle();
  }

  /// Cancels all timers and stops the ticker.
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    _timers.clear();
  }

  void _ensureTickerRunning() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    int? completedId;

    for (final entry in _timers.entries) {
      final timer = entry.value;
      if (!timer.state.isRunning || timer.state.isDone) continue;

      final newRemaining = timer.state.secondsRemaining - 1;
      if (newRemaining <= 0) {
        _timers[entry.key] = timer.withState(
          timer.state.copyWith(
            secondsRemaining: 0,
            isRunning: false,
            isDone: true,
          ),
        );
        completedId = entry.key;
      } else {
        _timers[entry.key] = timer.withState(
          timer.state.copyWith(secondsRemaining: newRemaining),
        );
      }
    }

    _onTick(activeTimers, completedId);
    _stopTickerIfIdle();
  }

  void _stopTickerIfIdle() {
    final hasActive = _timers.values.any(
      (t) => t.state.isRunning && !t.state.isDone,
    );
    if (!hasActive) {
      _ticker?.cancel();
      _ticker = null;
    }
  }
}

class _ActiveTimer {
  _ActiveTimer({
    required this.state,
    required this.isBackground,
    required this.readyAt,
  });

  final TimerState state;
  final bool isBackground;
  final DateTime readyAt;

  _ActiveTimer withState(TimerState newState) => _ActiveTimer(
    state: newState,
    isBackground: isBackground,
    readyAt: readyAt,
  );

  _ActiveTimer withReadyAt(DateTime newReadyAt) => _ActiveTimer(
    state: state,
    isBackground: isBackground,
    readyAt: newReadyAt,
  );
}
