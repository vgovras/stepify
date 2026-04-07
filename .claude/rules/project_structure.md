# Project Structure

> Feature-first architecture for Stepify MVP

## Folder Layout

```
lib/
├── main.dart                  # Entry point, Hive init, runApp
├── app/
│   ├── app.dart               # MaterialApp + ProviderScope
│   ├── router.dart            # GoRouter config, all routes
│   └── theme.dart             # Dark theme, color tokens, text styles
├── core/
│   ├── constants/             # App-wide constants (colors, sizes, durations)
│   ├── extensions/            # Dart/Flutter extensions
│   └── utils/                 # Pure utility functions
├── data/
│   ├── models/                # Recipe, RecipeStep, Ingredient, StepState, TimerState
│   ├── repositories/          # RecipeRepository, CartRepository, UserPrefsRepository
│   └── local/                 # Hive boxes, SharedPreferences wrappers
├── features/
│   ├── home/                  # Recipe catalog screen
│   ├── detail/                # Recipe details, serving scaler
│   ├── checklist/             # Ingredient checklist + step overview (2 tabs)
│   ├── cook/                  # Core cooking engine (step graph, timers, float bars)
│   ├── done/                  # Completion screen with confetti
│   ├── shopping/              # Shopping list
│   └── profile/               # User stats
└── shared/
    ├── widgets/               # Reusable widgets across features
    └── services/              # Notification service, timer service
```

## Feature Folder Structure

Each feature follows a flat structure (no data/domain/presentation split for MVP — keep it simple):

```
features/cook/
├── cook_screen.dart           # Screen widget
├── cook_cubit.dart            # State management (Cubit or Notifier)
├── cook_state.dart            # Immutable state class
├── step_graph.dart            # pickNextStep() — pure Dart, no Flutter deps
├── timer_service.dart         # Single Timer.periodic manager
└── widgets/
    ├── step_card.dart         # Current step display
    ├── float_bar.dart         # Background timer indicator bar
    ├── bottom_action_btn.dart # Dynamic action button
    ├── note_block.dart        # Tip/warn/pro block
    └── timer_block.dart       # Timer countdown display
```

## Key Rules

- **One feature = one folder.** Never import across features directly — go through `shared/` or `data/`.
- **Models live in `data/models/`.** All features share the same models. No per-feature DTOs in MVP.
- **Pure logic has zero Flutter deps.** `step_graph.dart` imports only `dart:core` — testable without widget tester.
- **Screens are thin.** A screen wires together widgets and reads state. No business logic in screens.
- **`shared/widgets/`** is for components used by 2+ features (e.g., recipe card used in home and detail).
- **`shared/services/`** is for cross-feature services (notification scheduling, timer tick engine).

## Routing Structure (GoRouter)

```dart
// app/router.dart
/                         → HomeScreen
/recipe/:id               → DetailScreen
/recipe/:id/checklist     → ChecklistScreen
/recipe/:id/cook          → CookScreen
/recipe/:id/done          → DoneScreen
/shopping                 → ShoppingScreen
/profile                  → ProfileScreen
```

Use `ShellRoute` for the bottom navigation bar (home, shopping, profile).
Cook flow screens (`checklist → cook → done`) are outside the shell — no bottom nav during cooking.

## Asset Organization

```
assets/
├── recipes/               # JSON recipe data (borsch.json, omelette.json)
└── fonts/                 # Playfair Display, DM Sans (if bundled)
```

Register in `pubspec.yaml` under `flutter > assets`.
