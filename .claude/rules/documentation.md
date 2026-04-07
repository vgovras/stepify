# Documentation & Comments

> Based on [Effective Dart: Documentation](https://dart.dev/effective-dart/documentation) — tailored for Stepify

## Doc Comments (`///`) — When Required

Document all public classes, methods, and fields. These are parsed by `dart doc`.

```dart
/// Returns the next available step in the recipe's dependency graph.
///
/// Filters steps where all [deps] are completed and [timerDep] has elapsed,
/// then returns the one with the lowest [weight].
///
/// Returns `null` if no steps are available (triggers waiting screen)
/// or all steps are done (triggers completion screen).
RecipeStep? pickNextStep(List<RecipeStep> steps, Map<int, StepState> states) { ... }
```

## First Sentence = Summary

The first sentence of a doc comment must stand alone — it appears in API summaries. Put a blank line before elaboration.

```dart
/// Manages all active timers during a cooking session.
///
/// Uses a single [Timer.periodic] with 1-second resolution to tick
/// all background and blocking timers simultaneously.
class TimerService { ... }
```

## Use Square Brackets for References

```dart
/// Advances to the next step after marking [currentStepId] as done.
///
/// Calls [pickNextStep] to determine the next available step.
/// If the current step has a background [StepTimer], it continues
/// running in [_activeTimers].
void completeCurrentStep() { ... }
```

## Boolean Properties — Start with "Whether"

```dart
/// Whether the timer runs in the background while the user advances.
final bool isBackground;

/// Whether the user must wait for this timer to complete before advancing.
final bool waitTimer;
```

## Comments Explain Why, Not What

```dart
// GOOD — non-obvious reason
// Single Timer.periodic instead of per-step timers to avoid
// accumulating drift across 20+ concurrent countdowns.
_ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

// GOOD — domain context
// Weight determines display order; lower = shown first.
// Steps with equal weight are resolved by insertion order.
steps.sort((a, b) => a.weight.compareTo(b.weight));

// BAD — restates the code
// Sort steps by weight
steps.sort((a, b) => a.weight.compareTo(b.weight));
```

## Self-Documenting Code Over Comments

Extract to a named function before adding a comment:

```dart
// BAD — comment compensates for unclear code
// Check if step is ready (all deps done and timer dep elapsed)
if (step.deps.every((id) => states[id]?.isDone ?? false) &&
    (step.timerDep == null || states[step.timerDep]?.timerState?.isDone == true)) { ... }

// GOOD — self-documenting
if (_isStepReady(step, states)) { ... }

bool _isStepReady(RecipeStep step, Map<int, StepState> states) {
  final depsComplete = step.deps.every((id) => states[id]?.isDone ?? false);
  final timerDepComplete = step.timerDep == null ||
      states[step.timerDep]?.timerState?.isDone == true;
  return depsComplete && timerDepComplete;
}
```

## TODOs — Consistent Format

```dart
// TODO(slav): Replace hardcoded recipes with JSON asset loading.
// TODO(slav): Add push notification scheduling for bg timer completion.
```

## Don't Over-Document

Skip doc comments for:
- Private methods with clear names
- Simple model fields with obvious meaning (`String name`, `int id`)
- Widget `build()` methods (the widget class doc is enough)
- Overrides that don't change behavior
