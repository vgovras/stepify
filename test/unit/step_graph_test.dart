import 'package:flutter_test/flutter_test.dart';

import 'package:stepify/core/core.dart';
import 'package:stepify/features/cook/src/step_graph.dart';

void main() {
  Map<int, StepState> makeStates(List<RecipeStep> steps) {
    return {for (final s in steps) s.id: const StepState.initial()};
  }

  StepState done({DateTime? readyAt}) => StepState(
    isDone: true,
    readyAt: readyAt ?? DateTime.now().subtract(const Duration(seconds: 1)),
  );

  group('pickNextStep', () {
    test('returns first step when none are done (linear)', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'A',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 20,
          deps: [1],
          text: 'B',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);

      final next = pickNextStep(steps, states);
      expect(next?.id, 1);
    });

    test('returns second step after first is done', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'A',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 20,
          deps: [1],
          text: 'B',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);
      states[1] = done();

      final next = pickNextStep(steps, states);
      expect(next?.id, 2);
    });

    test('returns null when all steps are done', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'A',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);
      states[1] = done();

      final next = pickNextStep(steps, states);
      expect(next, isNull);
    });

    test('sorts by weight — lowest weight first', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 90,
          deps: [],
          text: 'High weight',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 10,
          deps: [],
          text: 'Low weight',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 3,
          weight: 50,
          deps: [],
          text: 'Mid weight',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);

      final next = pickNextStep(steps, states);
      expect(next?.id, 2);
    });

    test('parallel branches — multiple steps available at once', () {
      // After step 1 is done, steps 7, 9, 10 all become available.
      // Step 3 also has no deps. Lowest weight wins.
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'Start',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 3,
          weight: 30,
          deps: [1],
          text: 'Water',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 7,
          weight: 70,
          deps: [1],
          text: 'Potato',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 9,
          weight: 90,
          deps: [1],
          text: 'Beet',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 10,
          weight: 100,
          deps: [1],
          text: 'Carrot',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);
      states[1] = done();

      final next = pickNextStep(steps, states);
      expect(next?.id, 3); // lowest weight = 30
    });

    test('timerDep blocks until readyAt is in the past', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'Meat warming',
          timer: StepTimer(minutes: 20, label: 'Warming', isBackground: true),
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 200,
          deps: [1],
          timerDep: 1,
          text: 'Wash meat',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 7,
          weight: 70,
          deps: [1],
          text: 'Cut potato',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);

      // Step 1 is done but timer still running (readyAt in future)
      states[1] = StepState(
        isDone: true,
        readyAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      final next = pickNextStep(steps, states);
      // Step 2 is blocked by timerDep, step 7 is available
      expect(next?.id, 7);
    });

    test('timerDep unblocks when readyAt is in the past', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'Meat warming',
          timer: StepTimer(minutes: 20, label: 'Warming', isBackground: true),
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 200,
          deps: [1],
          timerDep: 1,
          text: 'Wash meat',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);

      // Step 1 done and timer finished (readyAt in past)
      states[1] = StepState(
        isDone: true,
        readyAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      final next = pickNextStep(steps, states);
      expect(next?.id, 2);
    });

    test('waiting state — no available steps but undone remain', () {
      // Step 1 done with bg timer still running.
      // Step 2 depends on timerDep:1 (not ready yet).
      // No other steps.
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'Start',
          timer: StepTimer(minutes: 90, label: 'Broth', isBackground: true),
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 200,
          deps: [1],
          timerDep: 1,
          text: 'After broth',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);
      states[1] = StepState(
        isDone: true,
        readyAt: DateTime.now().add(const Duration(minutes: 80)),
      );

      final next = pickNextStep(steps, states);
      expect(next, isNull);
      expect(hasRemainingSteps(steps, states), isTrue);
    });

    test('multi-dep step — only available when ALL deps are done', () {
      // Borscht step 20 depends on [6, 12, 19]
      final steps = [
        const RecipeStep(
          id: 6,
          weight: 230,
          deps: [],
          text: 'Broth',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 12,
          weight: 120,
          deps: [],
          text: 'Cabbage',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 19,
          weight: 190,
          deps: [],
          text: 'Zasmajka',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 20,
          weight: 300,
          deps: [6, 12, 19],
          timerDep: 6,
          text: 'Assemble',
          waitTimer: false,
        ),
      ];
      final states = makeStates(steps);

      // Only 2 of 3 deps done — step 20 not available
      states[6] = done();
      states[12] = done();

      var next = pickNextStep(steps, states);
      expect(next?.id, 19); // only undone step without blockers

      // All 3 deps done + timerDep ready
      states[19] = done();
      next = pickNextStep(steps, states);
      expect(next?.id, 20);
    });
  });

  group('isAllDone', () {
    test('returns true when all done', () {
      final states = {1: done(), 2: done()};
      expect(isAllDone(states), isTrue);
    });

    test('returns false when some undone', () {
      final states = {1: done(), 2: const StepState.initial()};
      expect(isAllDone(states), isFalse);
    });
  });

  group('hasRemainingSteps', () {
    test('returns false when all done', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'A',
          waitTimer: false,
        ),
      ];
      final states = {1: done()};
      expect(hasRemainingSteps(steps, states), isFalse);
    });

    test('returns true when some undone', () {
      final steps = [
        const RecipeStep(
          id: 1,
          weight: 10,
          deps: [],
          text: 'A',
          waitTimer: false,
        ),
        const RecipeStep(
          id: 2,
          weight: 20,
          deps: [1],
          text: 'B',
          waitTimer: false,
        ),
      ];
      final states = {1: done(), 2: const StepState.initial()};
      expect(hasRemainingSteps(steps, states), isTrue);
    });
  });
}
