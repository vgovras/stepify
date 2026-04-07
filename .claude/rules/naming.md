# Naming Conventions

> Based on [Effective Dart: Style](https://dart.dev/effective-dart/style) — tailored for Stepify

## Casing Rules

| Context | Convention | Stepify Example |
|---|---|---|
| Classes, enums, typedefs | `UpperCamelCase` | `RecipeStep`, `CookCubit`, `TimerState` |
| Variables, functions, params | `lowerCamelCase` | `pickNextStep()`, `currentStepId` |
| Constants (`const`) | `lowerCamelCase` | `defaultServings`, `timerTickDuration` |
| Files, directories | `lowercase_with_underscores` | `step_graph.dart`, `cook_screen.dart` |
| Private members | prefix `_` | `_counter`, `_isRunning` |
| Enums values | `lowerCamelCase` | `Difficulty.easy`, `NoteType.warn` |

**Never** use `SCREAMING_CAPS` — Dart dropped this convention.
**Never** prefix local variables or params with `_`.

## Acronyms

- 3+ letters → capitalize as a word: `Api`, `Http`, `Uri`
- 2 letters → keep both caps: `ID`, `IO`
- At start of lowerCamelCase → both lower: `idToken`, `bgTimer`

## Booleans — Always Prefixed

```dart
// GOOD — clear intent
bool isBackground = false;
bool isDone = true;
bool hasTimerDep = step.timerDep != null;
bool canAdvance = !isWaiting;
bool shouldNotify = timer.isBackground;

// BAD — ambiguous
bool background = false;
bool done = true;
bool waiting = false;
```

## Domain-Specific Naming

Use the domain vocabulary from the spec consistently:

| Concept | Name | NOT |
|---|---|---|
| Recipe cooking step | `RecipeStep` | `Step` (conflicts with `dart:core`) |
| Step dependency list | `deps` | `dependencies`, `requires` |
| Background timer dep | `timerDep` | `timerDependency`, `bgDep` |
| Step priority | `weight` | `priority`, `order`, `sortKey` |
| Step advice block | `StepNote` | `Hint`, `Tip`, `Advice` |
| Note severity | `NoteType.warn` / `.tip` / `.pro` | `warning`, `hint` |
| Cook session timer | `TimerService` | `TimerManager`, `Clock` |
| Next step algorithm | `pickNextStep()` | `getNext()`, `advance()` |

## Magic Numbers — Name Them

```dart
// GOOD — self-documenting
const maxBackgroundTimers = 2;
const urgencyThresholdSeconds = 60;
const confettiParticleCount = 55;
const stepTransitionDuration = Duration(milliseconds: 200);

// BAD — magic
if (secondsRemaining < 60) { ... }
ConfettiWidget(numberOfParticles: 55);
```

## File Naming for Features

```
features/cook/
├── cook_screen.dart          # screen = full-page widget
├── cook_cubit.dart           # cubit/notifier = state logic
├── step_graph.dart           # pure logic, no Flutter deps
├── timer_service.dart        # service = background process
└── widgets/
    ├── step_card.dart        # widget = reusable UI component
    ├── float_bar.dart
    └── bottom_action_btn.dart
```

Suffix convention: `_screen`, `_cubit` / `_notifier`, `_service`, `_repository`, `_model`.
