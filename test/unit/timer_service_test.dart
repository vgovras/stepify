import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stepify/core/core.dart';
import 'package:stepify/features/cook/src/timer_service.dart';

void main() {
  group('TimerService', () {
    test('tick decrements secondsRemaining', () {
      fakeAsync((async) {
        Map<int, TimerState>? lastTimers;
        final service = TimerService(
          onTick: (timers, _) => lastTimers = timers,
        );

        service.startTimer(1, 10, isBackground: false);
        async.elapse(const Duration(seconds: 3));

        expect(lastTimers?[1]?.secondsRemaining, 7);
        service.dispose();
      });
    });

    test('timer completes and reports completedStepId', () {
      fakeAsync((async) {
        int? completedId;
        final service = TimerService(
          onTick: (_, id) {
            if (id != null) completedId = id;
          },
        );

        service.startTimer(5, 3, isBackground: false);
        async.elapse(const Duration(seconds: 3));

        expect(completedId, 5);
        service.dispose();
      });
    });

    test('completed timer has isDone=true and secondsRemaining=0', () {
      fakeAsync((async) {
        Map<int, TimerState>? lastTimers;
        final service = TimerService(
          onTick: (timers, _) => lastTimers = timers,
        );

        service.startTimer(1, 2, isBackground: false);
        async.elapse(const Duration(seconds: 2));

        final state = lastTimers?[1];
        expect(state?.isDone, isTrue);
        expect(state?.isRunning, isFalse);
        expect(state?.secondsRemaining, 0);
        service.dispose();
      });
    });

    test('pause stops decrementing', () {
      fakeAsync((async) {
        Map<int, TimerState>? lastTimers;
        final service = TimerService(
          onTick: (timers, _) => lastTimers = timers,
        );

        service.startTimer(1, 10, isBackground: false);
        async.elapse(const Duration(seconds: 2));
        expect(lastTimers?[1]?.secondsRemaining, 8);

        service.pauseTimer(1);
        async.elapse(const Duration(seconds: 5));
        // Should still be 8 — paused
        expect(lastTimers?[1]?.secondsRemaining, 8);

        service.dispose();
      });
    });

    test('resume continues from where it paused', () {
      fakeAsync((async) {
        Map<int, TimerState>? lastTimers;
        final service = TimerService(
          onTick: (timers, _) => lastTimers = timers,
        );

        service.startTimer(1, 10, isBackground: false);
        async.elapse(const Duration(seconds: 3));
        service.pauseTimer(1);
        async.elapse(const Duration(seconds: 5));
        service.resumeTimer(1);
        async.elapse(const Duration(seconds: 2));

        // 10 - 3 (before pause) - 2 (after resume) = 5
        expect(lastTimers?[1]?.secondsRemaining, 5);
        service.dispose();
      });
    });

    test('multiple concurrent timers tick independently', () {
      fakeAsync((async) {
        Map<int, TimerState>? lastTimers;
        final service = TimerService(
          onTick: (timers, _) => lastTimers = timers,
        );

        service.startTimer(1, 10, isBackground: true);
        service.startTimer(2, 5, isBackground: false);
        async.elapse(const Duration(seconds: 3));

        expect(lastTimers?[1]?.secondsRemaining, 7);
        expect(lastTimers?[2]?.secondsRemaining, 2);
        service.dispose();
      });
    });

    test('getReadyAt returns expected time for bg timer', () {
      fakeAsync((async) {
        final service = TimerService(onTick: (_, _) {});
        service.startTimer(1, 60, isBackground: true);

        final readyAt = service.getReadyAt(1);
        expect(readyAt, isNotNull);
        expect(service.isBackgroundTimer(1), isTrue);
        service.dispose();
      });
    });

    test('dispose cancels all timers', () {
      fakeAsync((async) {
        var tickCount = 0;
        final service = TimerService(onTick: (_, _) => tickCount++);

        service.startTimer(1, 100, isBackground: false);
        async.elapse(const Duration(seconds: 2));
        final countBeforeDispose = tickCount;

        service.dispose();
        async.elapse(const Duration(seconds: 5));
        expect(tickCount, countBeforeDispose);
      });
    });
  });
}
