# Code Style & Formatting

> Based on [Effective Dart](https://dart.dev/effective-dart) — tailored for Stepify

## Formatting — Non-Negotiable

- Run `dart format .` before every commit. No exceptions.
- Max line length: **80 characters**.
- Indentation: **2 spaces**.
- Always use **trailing commas** in multi-line argument/parameter lists.

```dart
// GOOD — trailing comma enables vertical formatting
final widget = StepCard(
  step: currentStep,
  onComplete: _handleComplete,
  showTimer: true, // ← trailing comma
);

// BAD — hard to scan
final widget = StepCard(step: currentStep, onComplete: _handleComplete, showTimer: true);
```

## Imports Order

Separate each group with a blank line, sort alphabetically within:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/recipe_step.dart';
import '../cook/cook_cubit.dart';
import 'widgets/step_card.dart';
```

Order: `dart:` → `package:` → relative. Never use `package:stepify/...` for internal imports — use relative paths.

## Type Annotations

- **Always** annotate public API return types and parameters.
- Local variables: infer freely with `final` / `var`.

```dart
// GOOD — public method, explicit types
Future<RecipeStep?> pickNextStep(List<RecipeStep> steps, Map<int, StepState> states) { ... }

// OK — local variable, inference
final nextStep = pickNextStep(steps, states);
```

## Prefer `final` Everywhere

```dart
// GOOD
final recipe = recipes.first;
final isReady = step.deps.every((id) => states[id]?.isDone ?? false);

// BAD — mutable when it doesn't need to be
var recipe = recipes.first;
```

## Flow Control — Always Use Braces

```dart
// GOOD
if (timer.isDone) {
  advance();
}

// BAD — dangling else risk
if (timer.isDone)
  advance();
```

## Pattern Matching (Dart 3+)

Use switch expressions and patterns for step/timer state logic:

```dart
// GOOD — exhaustive, clear
String buttonLabel(ButtonState state) => switch (state) {
  ButtonState.noTimer => 'Далі →',
  ButtonState.bgTimerIdle => 'Далі →',
  ButtonState.blockingRunning => '⏸ Пауза',
  ButtonState.blockingPaused => '▶ Продовжити',
  ButtonState.blockingDone => 'Далі →',
  ButtonState.lastStep => '🎉 Готово!',
};

// GOOD — if-case for nullable unwrap
if (step.timer case final timer?) {
  startTimer(timer);
}
```

## Unused Callback Parameters

Use `_` for unused params:

```dart
// GOOD
Timer.periodic(const Duration(seconds: 1), (_) => _tick());

// BAD
Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
```

## Collections

```dart
// GOOD — .isEmpty over .length == 0
if (activeBgTimers.isEmpty) { ... }

// GOOD — whereType for type filtering
final readySteps = steps.whereType<ReadyStep>();

// GOOD — spread for combining lists
final allIngredients = [...baseIngredients, ...extraIngredients];
```

## Async

Use `async`/`await` over `.then()` chains. Use `Future.wait` for independent parallel work:

```dart
// GOOD — parallel loading
final (recipes, prefs) = await (
  recipeRepository.loadAll(),
  userPrefsRepository.load(),
).wait;

// BAD — sequential when parallel is possible
final recipes = await recipeRepository.loadAll();
final prefs = await userPrefsRepository.load();
```

## Avoid Nested Ternaries

Common in UI code — extract to a method or use switch instead:

```dart
// BAD
color: isUrgent ? Colors.red : isRunning ? Colors.green : Colors.grey;

// GOOD
Color timerColor(TimerState state) => switch (state) {
  TimerState(isUrgent: true) => AppColors.rd,
  TimerState(isRunning: true) => AppColors.gr,
  _ => AppColors.t3,
};
```
