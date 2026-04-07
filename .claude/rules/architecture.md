# Architecture & State Management

> Clean architecture rules for Stepify's cooking engine

## Layer Dependency Rule

```
Screens (UI) → Cubits/Notifiers → Repositories → Local Storage
                     ↓
              Pure Logic (step_graph.dart)
```

- **Screens** read state and dispatch actions. No business logic.
- **Cubits/Notifiers** orchestrate domain logic and manage state.
- **Repositories** abstract data access (Hive boxes, SharedPreferences).
- **Pure logic** (`pickNextStep`, serving scaler) is plain Dart — no Flutter imports, fully unit-testable.

## State Management — BLoC/Cubit or Riverpod

Pick one, use it everywhere. One cubit/notifier per feature screen:

| Feature | State Manager | Key State |
|---|---|---|
| Cook | `CookCubit` | Current step, all step states, active timers, waiting flag |
| Detail | `DetailCubit` | Recipe, current servings |
| Checklist | `ChecklistCubit` | Ingredient check states, tab index |
| Shopping | `ShoppingCubit` | Shopping list items, checked states |
| Home | `HomeCubit` | Recipe list, favorites |

## CookCubit — The Heart of the App

```dart
@immutable
class CookState {
  final Recipe recipe;
  final Map<int, StepState> stepStates;
  final int? currentStepId;
  final bool isWaiting;        // no available steps, waiting on timer
  final int completedCount;

  const CookState({ ... });
  CookState copyWith({ ... }) => CookState( ... );
}
```

**Critical flows:**
1. `completeStep()` → mark done → `pickNextStep()` → emit new state
2. `startBlockingTimer()` → timer ticks → on complete → unlock "Next" button
3. `startBgTimer()` → timer ticks in background → on complete → unlock dependent steps → auto-transition if waiting
4. Timer tick every 1s → decrement all active timers → check completions → emit

## Immutable State — Always

State classes must be `@immutable` with `copyWith`. Never mutate state objects.

```dart
// GOOD — new state object
emit(state.copyWith(
  currentStepId: nextStep.id,
  isWaiting: false,
));

// BAD — mutation
state.currentStepId = nextStep.id; // breaks BLoC contract
emit(state);
```

## Timer Service Pattern

One `Timer.periodic(Duration(seconds: 1))` per cooking session. Managed inside `CookCubit` or a separate `TimerService`.

```dart
class TimerService {
  Timer? _ticker;
  final Map<int, TimerState> _activeTimers = {};

  void start() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    for (final entry in _activeTimers.entries) {
      // decrement, check completion, notify via callback
    }
  }

  void dispose() {
    _ticker?.cancel();
    _activeTimers.clear();
  }
}
```

**Rules:**
- Never create a separate `Timer.periodic` per step — causes drift with 20+ concurrent timers.
- Always `cancel()` on dispose. Uncancelled timers leak memory.
- Store `DateTime` for `readyAt` — real clock time, not demo speed.
- On app background: schedule `flutter_local_notifications` for each active bg timer.
- On app resume: recalculate remaining seconds from `readyAt` vs `DateTime.now()`.

## Step Graph — Pure Logic

`step_graph.dart` must have zero Flutter dependencies:

```dart
// Pure Dart — import only dart:core
RecipeStep? pickNextStep(
  List<RecipeStep> steps,
  Map<int, StepState> states,
) {
  return steps
      .where((s) => !states[s.id]!.isDone)
      .where((s) => s.deps.every((id) => states[id]?.isDone ?? false))
      .where((s) => s.timerDep == null ||
          states[s.timerDep]?.timerState?.isDone == true)
      .sorted((a, b) => a.weight.compareTo(b.weight))
      .firstOrNull;
}
```

This is directly unit-testable without `WidgetTester`.

## Repository Pattern (MVP-Simple)

```dart
// Abstract interface
abstract class RecipeRepository {
  List<Recipe> getAll();
  Recipe? getById(String id);
}

// Implementation — hardcoded for MVP, swappable later
class LocalRecipeRepository implements RecipeRepository {
  @override
  List<Recipe> getAll() => [borschRecipe, omeletteRecipe];
}
```

Keep the abstraction even for hardcoded data — makes it trivial to add API/DB later.

## Dependency Injection

Constructor injection only. Wire up in `main.dart` or provider declarations:

```dart
// GOOD — injectable
class CookCubit extends Cubit<CookState> {
  final TimerService _timerService;
  final RecipeRepository _recipeRepository;

  CookCubit(this._timerService, this._recipeRepository) : super(CookState.initial());
}

// BAD — hardcoded dependency
class CookCubit extends Cubit<CookState> {
  final _timerService = TimerService(); // untestable
}
```

## Navigation Rules (GoRouter)

- Cook flow (`checklist → cook → done`) is a linear flow — use `context.go()` or `context.push()`.
- Exit cooking shows a confirmation dialog — handle via `WillPopScope` / `PopScope`.
- On exit: cancel all timers, clear session state.
- Deep links: `/recipe/:id/cook` should redirect to `/recipe/:id` if no active session.

## What Not To Do

- Never access `BuildContext` inside cubits/notifiers.
- Never put business logic in `build()` methods.
- Never import feature code into another feature directly.
- Never store `Widget` references in state.
- Never use `dynamic` when a concrete type is known.
