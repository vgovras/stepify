# Stepify MVP Implementation Plan

## Context

Stepify (CookFlow) is a mobile cooking app that guides users through recipes one step at a time using a DAG (directed acyclic graph) of dependencies between steps. Background timers allow parallel cooking processes (e.g., broth simmering while chopping vegetables). The user never needs to think about "what's next" — the app decides based on step dependencies and timer states. The MVP proves this concept with two recipes: Borscht (24 steps with complex parallelism) and Omelette (13 linear steps).

The project is a fresh Flutter scaffold — only the default counter app exists. Everything must be built from scratch following the rules in `.claude/rules/`.

---

## Business Goal

Users lose track of parallel cooking processes and miss timer deadlines. Existing recipe apps show static text like a cookbook. Stepify acts like GPS for cooking: one step at a time, automatic parallel process management, and persistent timer notifications. The MVP must prove this core engine works end-to-end with real recipes.

**"MVP done" means:** A user can pick a recipe, check ingredients, cook step-by-step with working background/blocking timers and correct DAG traversal, receive push notifications, and complete the recipe with a celebration screen. Shopping list persists between sessions.

---

## User Stories

### US-1: Browse Recipes
User sees recipe catalog cards with emoji, name, time, kcal, rating, difficulty badge. Taps card → opens detail screen. Can bookmark with heart button.

### US-2: View Recipe Details & Scale Servings
User sees full recipe info, adjusts servings with +/- control. Ingredient amounts scale proportionally. CTA button leads to checklist.

### US-3: Check Ingredients Before Cooking
User opens 2-tab screen. Tab 1: ingredient checklist with progress bar — tap to mark "have at home". Button adds missing to shopping list. Tab 2: read-only step overview sorted by weight with timer badges. Footer: "Start cooking" button.

### US-4: Step-by-Step Cooking with DAG
User sees one step at a time with a single dynamic button. Steps appear in DAG order. Notes (warn/tip/pro) show inline. Progress bar and step counter at top.

### US-5: Background Timers
When user presses "Next" on a step with `isBackground=true` timer, timer launches in background and a float bar appears at top showing label + countdown. User continues with next available steps. Float bar pulses red when < 1 minute. Max 2 float bars.

### US-6: Blocking Timers
Steps with `waitTimer=true`: pressing "Next" starts the timer but does NOT advance. Button becomes "Pause". Timer must complete before user can advance. Button state cycles: Next → (start timer) → Pause ↔ Resume → (timer done) → Next.

### US-7: Waiting State
When `pickNextStep()` returns null but steps remain (waiting on bg timer): show waiting screen with active timer countdowns. Auto-transition when timer completes and step becomes available.

### US-8: Push Notifications
When app goes to background, schedule `flutter_local_notifications` for each active bg timer. On return, recalculate timer states from `readyAt` vs `DateTime.now()`.

### US-9: Completion
All steps done → confetti screen with stats (time, servings, +1 dish). Rating bottom sheet with stars + comment. Buttons: Rate, Share, Home.

### US-10: Shopping List
Missing ingredients added from checklist persist via Hive. Grouped by category (vegs, meat, dairy, other). Checkboxes for "bought". Persists between app launches.

### US-11: Profile
Simple screen: avatar emoji, name, cooked count, saved count, menu items (placeholders for post-MVP).

---

## Prior Art

- **Mealime**: Linear step-by-step only, no parallel timers. Simpler but cannot handle Borscht-level complexity.
- **Kitchen Stories**: Separate timer tab requires navigating away from current step.
- **SideChef**: Step-by-step with built-in timers, but no DAG-awareness.
- **Stepify approach**: Inline float bars (zero navigation), DAG-driven step ordering, single master tick for all concurrent timers.

---

## Scope

### IN
- 2 hardcoded recipes (Borscht 24 steps with parallel DAG, Omelette 13 linear steps)
- 7 screens: Home, Detail, Checklist, Cook (with Waiting state), Done, Shopping, Profile
- DAG-based `pickNextStep()` algorithm (pure Dart, zero Flutter deps)
- Background + blocking timer engine with single `Timer.periodic(1s)`
- Float bars for active bg timers (max 2, urgency animation < 1 min)
- Push notifications via `flutter_local_notifications`
- Serving size scaling on Detail screen
- Shopping list persisted with Hive
- Dark theme only with full design system
- Confetti on Done screen
- GoRouter with ShellRoute for bottom nav
- BLoC/Cubit state management
- **Modular architecture** with barrel files and explicit public APIs per module

### OUT
- Auth, cloud sync, user accounts
- Custom recipes, recipe editor
- Search functionality (placeholder tab only)
- Video instructions
- Social features (share, likes)
- AI recipe generation
- Meal planner
- QR scanning
- Diet/allergy filters
- Multi-language (Ukrainian only for MVP)
- Cooking session persistence (lost on app kill — acceptable for MVP)

---

## Key Design Decisions

### 1. Modular architecture (NestJS/Angular-inspired)

**Pattern:** Each module is a directory with:
- A **barrel file** (`<module_name>.dart`) at the root — this IS the module's public API. It re-exports only what other modules may use.
- A `src/` directory for **all implementation files** — internal, not imported directly by other modules.
- Optionally, a `<module_name>_module.dart` file with a static `register(GetIt di)` method for DI bindings and a `routes` getter for GoRouter routes.

**Cross-module rule:** Modules import each other ONLY through barrel files. Never import `features/cook/src/anything.dart` from outside the cook module.

**Why:** Encapsulation by default. Internal refactoring within a module cannot break other modules. Clear dependency graph. Scales to teams. Matches NestJS mental model where each @Module() declares imports/exports.

### 2. Module DI registration with get_it

Each module registers its own dependencies in a static `register()` method. The app wires all modules at startup. This mirrors NestJS's `@Module({ providers, exports })`.

### 3. Module-level route declaration

Each feature module declares its own GoRouter routes. The app router composes all module routes. This mirrors Angular's lazy-loaded route modules.

### 4. Local storage: Hive for shopping list, SharedPreferences for simple prefs
Shopping list is a structured typed list → Hive. User name, cooked count, favorites → SharedPreferences key-value pairs.

### 5. Recipe data: Hardcoded Dart const objects (not JSON assets)
Only 2 recipes. `RecipeRepository` abstraction means switching to JSON/API later changes only the repository implementation.

### 6. Manual copyWith (not freezed)
5-6 small immutable classes don't justify build_runner overhead. Revisit post-MVP.

### 7. App lifecycle for timers
On background: schedule notifications for each active bg timer's `readyAt`. On resume: recalculate from `DateTime.now()`.

---

## Architecture — Modular Pattern

### The Pattern

Inspired by NestJS/Angular modules. Each module:
1. **Encapsulates** its logic in `src/` (private implementation)
2. **Exposes** a public API via a barrel file (selective `export` statements)
3. **Registers** its own DI bindings and routes
4. **Imports** other modules only through their barrel files

```dart
// Example: features/cook/cook.dart (barrel file = public API)
// This is the ONLY file other modules import from cook.

export 'src/cook_screen.dart' show CookScreen;
export 'src/cook_cubit.dart' show CookCubit;
export 'src/cook_state.dart' show CookState;
export 'src/cook_module.dart' show CookModule;
// NOT exported: step_graph.dart, timer_service.dart, widgets/*
// These are private implementation details.
```

```dart
// Example: features/cook/src/cook_module.dart
class CookModule {
  static void register(GetIt di) {
    di.registerFactory<TimerService>(() => TimerService());
    di.registerFactoryParam<CookCubit, Recipe, void>(
      (recipe, _) => CookCubit(
        timerService: di.get<TimerService>(),
        notificationService: di.get<NotificationService>(),
        recipe: recipe,
      ),
    );
  }

  static List<RouteBase> get routes => [
    GoRoute(path: '/recipe/:id/cook', builder: ...),
    GoRoute(path: '/recipe/:id/done', builder: ...),
  ];
}
```

### Module Dependency Graph

```
app (wiring only — imports all modules, composes router + DI)
 ├── core (models, constants, utils — no Flutter deps in pure logic)
 ├── shared_ui (reusable widgets — depends on core)
 ├── data (repositories, local storage — depends on core)
 │
 ├── feature: home (depends on core, shared_ui, data)
 ├── feature: detail (depends on core, shared_ui, data)
 ├── feature: checklist (depends on core, shared_ui, data, shopping API)
 ├── feature: cook (depends on core, shared_ui, data)
 ├── feature: done (depends on core, shared_ui)
 ├── feature: shopping (depends on core, shared_ui, data)
 └── feature: profile (depends on core, shared_ui, data)
```

**Rules:**
- `core` NEVER depends on any feature or shared_ui
- `shared_ui` depends only on `core`
- `data` depends only on `core`
- Features depend on `core`, `shared_ui`, `data`, and optionally other features' barrel APIs
- Features NEVER import another feature's `src/` internals
- `app` is the composition root — imports all modules, wires DI, composes routes

### Folder Structure

```
lib/
├── main.dart                              # Entry point: init Hive, register modules, runApp
├── app/
│   ├── app.dart                           # MaterialApp.router + MultiBlocProvider
│   ├── router.dart                        # GoRouter — composes routes from all modules
│   ├── di.dart                            # Calls Module.register() for all modules
│   └── shell_scaffold.dart                # Bottom nav scaffold (ShellRoute)
│
├── core/                                  # CORE MODULE — shared types, pure logic
│   ├── core.dart                          # ← BARREL: public API
│   └── src/
│       ├── models/
│       │   ├── recipe.dart
│       │   ├── ingredient.dart
│       │   ├── recipe_step.dart
│       │   ├── step_note.dart
│       │   ├── step_timer.dart
│       │   ├── step_state.dart
│       │   ├── timer_state.dart
│       │   └── enums.dart                 # Difficulty, RecipeCategory, IngredientCategory, NoteType
│       ├── constants/
│       │   ├── app_colors.dart
│       │   ├── app_sizes.dart
│       │   └── app_durations.dart
│       └── utils/
│           ├── serving_scaler.dart        # Pure Dart — no Flutter imports
│           └── time_format.dart           # MM:SS formatter
│
├── shared_ui/                             # SHARED UI MODULE — reusable widgets
│   ├── shared_ui.dart                     # ← BARREL: public API
│   └── src/
│       ├── primary_button.dart
│       ├── ghost_button.dart
│       ├── note_block.dart
│       ├── timer_display.dart
│       ├── float_bar.dart
│       ├── stat_grid.dart
│       ├── serving_control.dart
│       ├── progress_bar.dart
│       ├── recipe_card.dart
│       └── toast_notification.dart
│
├── data/                                  # DATA MODULE — repositories, local storage
│   ├── data.dart                          # ← BARREL: public API (repository interfaces + impls)
│   ├── src/
│   │   ├── repositories/
│   │   │   ├── recipe_repository.dart     # Abstract + LocalRecipeRepository
│   │   │   ├── shopping_repository.dart   # Abstract + HiveShoppingRepository
│   │   │   └── user_prefs_repository.dart # SharedPreferences wrapper
│   │   ├── local/
│   │   │   ├── recipes.dart              # borschRecipe, omeletteRecipe const objects
│   │   │   └── shopping_box.dart         # Hive TypeAdapter for ShoppingItem
│   │   └── data_module.dart              # DataModule.register(GetIt) — registers all repos
│
├── features/
│   ├── home/                              # HOME MODULE
│   │   ├── home.dart                      # ← BARREL: exports HomeScreen, HomeModule
│   │   └── src/
│   │       ├── home_screen.dart
│   │       ├── home_cubit.dart
│   │       ├── home_state.dart
│   │       ├── home_module.dart           # HomeModule.register(), .routes
│   │       └── widgets/
│   │           └── greeting_header.dart
│   │
│   ├── detail/                            # DETAIL MODULE
│   │   ├── detail.dart                    # ← BARREL
│   │   └── src/
│   │       ├── detail_screen.dart
│   │       ├── detail_cubit.dart
│   │       ├── detail_state.dart
│   │       └── detail_module.dart
│   │
│   ├── checklist/                         # CHECKLIST MODULE
│   │   ├── checklist.dart                 # ← BARREL
│   │   └── src/
│   │       ├── checklist_screen.dart
│   │       ├── checklist_cubit.dart
│   │       ├── checklist_state.dart
│   │       ├── checklist_module.dart
│   │       └── widgets/
│   │           ├── ingredient_tab.dart
│   │           └── steps_tab.dart
│   │
│   ├── cook/                              # COOK MODULE (most complex)
│   │   ├── cook.dart                      # ← BARREL: exports CookScreen, CookCubit, CookState, CookModule
│   │   └── src/
│   │       ├── cook_screen.dart
│   │       ├── cook_cubit.dart
│   │       ├── cook_state.dart
│   │       ├── cook_module.dart
│   │       ├── step_graph.dart            # pickNextStep() — pure Dart, INTERNAL
│   │       ├── timer_service.dart         # Single Timer.periodic manager, INTERNAL
│   │       └── widgets/
│   │           ├── step_card.dart
│   │           ├── float_bar_section.dart
│   │           ├── bottom_action_btn.dart
│   │           ├── cook_top_bar.dart
│   │           ├── waiting_view.dart
│   │           └── exit_dialog.dart
│   │
│   ├── done/                              # DONE MODULE
│   │   ├── done.dart                      # ← BARREL
│   │   └── src/
│   │       ├── done_screen.dart
│   │       ├── done_cubit.dart
│   │       └── done_module.dart
│   │
│   ├── shopping/                          # SHOPPING MODULE
│   │   ├── shopping.dart                  # ← BARREL
│   │   └── src/
│   │       ├── shopping_screen.dart
│   │       ├── shopping_cubit.dart
│   │       ├── shopping_state.dart
│   │       └── shopping_module.dart
│   │
│   └── profile/                           # PROFILE MODULE
│       ├── profile.dart                   # ← BARREL
│       └── src/
│           ├── profile_screen.dart
│           ├── profile_cubit.dart
│           ├── profile_state.dart
│           └── profile_module.dart
│
└── shared/                                # SHARED SERVICES MODULE
    ├── shared.dart                         # ← BARREL
    └── src/
        ├── notification_service.dart
        └── shared_module.dart             # SharedModule.register() — notification service
```

### Barrel File Examples

```dart
// core/core.dart — exports ALL public types from core
export 'src/models/recipe.dart';
export 'src/models/ingredient.dart';
export 'src/models/recipe_step.dart';
export 'src/models/step_note.dart';
export 'src/models/step_timer.dart';
export 'src/models/step_state.dart';
export 'src/models/timer_state.dart';
export 'src/models/enums.dart';
export 'src/constants/app_colors.dart';
export 'src/constants/app_sizes.dart';
export 'src/constants/app_durations.dart';
export 'src/utils/serving_scaler.dart';
export 'src/utils/time_format.dart';
```

```dart
// features/cook/cook.dart — exports ONLY the public API
export 'src/cook_screen.dart' show CookScreen;
export 'src/cook_cubit.dart' show CookCubit;
export 'src/cook_state.dart' show CookState;
export 'src/cook_module.dart' show CookModule;
// step_graph.dart — NOT exported (internal algorithm)
// timer_service.dart — NOT exported (internal service)
// widgets/* — NOT exported (internal UI components)
```

```dart
// data/data.dart — exports repository interfaces + module
export 'src/repositories/recipe_repository.dart';
export 'src/repositories/shopping_repository.dart';
export 'src/repositories/user_prefs_repository.dart';
export 'src/data_module.dart' show DataModule;
// local/recipes.dart — NOT exported (internal data source)
// local/shopping_box.dart — NOT exported (internal Hive adapter)
```

### App Wiring (Composition Root)

```dart
// app/di.dart — registers all modules
Future<void> registerModules(GetIt di) async {
  // Infrastructure modules first (no deps on features)
  SharedModule.register(di);
  await DataModule.register(di);  // async for Hive init

  // Feature modules (may depend on data/shared)
  HomeModule.register(di);
  DetailModule.register(di);
  ChecklistModule.register(di);
  CookModule.register(di);
  DoneModule.register(di);
  ShoppingModule.register(di);
  ProfileModule.register(di);
}

// app/router.dart — composes all module routes
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        ...HomeModule.routes,
        ...ShoppingModule.routes,
        ...ProfileModule.routes,
      ],
    ),
    // Standalone routes (no bottom nav)
    ...DetailModule.routes,
    ...ChecklistModule.routes,
    ...CookModule.routes,
    ...DoneModule.routes,
  ],
);
```

### Dependency Flow
```
app (composition root)
 │
 ├─imports→ core.dart (models, constants, utils)
 ├─imports→ shared_ui.dart (reusable widgets)
 ├─imports→ shared.dart (notification service)
 ├─imports→ data.dart (repositories)
 │
 └─imports→ each feature barrel:
             home.dart, detail.dart, checklist.dart,
             cook.dart, done.dart, shopping.dart, profile.dart
```

Within each feature module, internal files import each other freely. The boundary is the barrel file — only what's exported there is accessible to the outside world.

### Navigation (GoRouter)
```
ShellRoute (bottom nav: Home / Search(placeholder) / Shopping / Profile)
├── /                      → HomeScreen
├── /shopping              → ShoppingScreen
└── /profile               → ProfileScreen

Standalone (no bottom nav):
├── /recipe/:id            → DetailScreen
├── /recipe/:id/checklist  → ChecklistScreen
├── /recipe/:id/cook       → CookScreen
└── /recipe/:id/done       → DoneScreen
```

---

## Data Models

All in `lib/core/src/models/`. Exported via `core/core.dart`. All classes `@immutable`, `const` constructor, manual `copyWith()`.

### Enums (`enums.dart`)
- `Difficulty { easy, medium, hard }`
- `RecipeCategory { soup, main, breakfast, salad }`
- `IngredientCategory { meat, vegs, dairy, eggs, other }`
- `NoteType { warn, tip, pro }`

### Recipe (`recipe.dart`)
`id` (String), `name`, `emoji`, `baseServings` (int), `timeMinutes` (int), `kcalPerServing` (int), `difficulty` (Difficulty), `category` (RecipeCategory), `ingredients` (List\<Ingredient\>), `steps` (List\<RecipeStep\>), `rating` (double), `reviewCount` (int)

### Ingredient (`ingredient.dart`)
`name`, `amount` (double? — null = "за смаком"), `unit`, `category` (IngredientCategory)

### RecipeStep (`recipe_step.dart`)
`id` (int), `weight` (int), `deps` (List\<int\>), `timerDep` (int?), `text`, `note` (StepNote?), `timer` (StepTimer?), `waitTimer` (bool)

### StepNote (`step_note.dart`)
`type` (NoteType), `text`

### StepTimer (`step_timer.dart`)
`minutes` (int), `label`, `isBackground` (bool)

### StepState (`step_state.dart`)
`isDone` (bool), `readyAt` (DateTime?), `timerState` (TimerState?)

### TimerState (`timer_state.dart`)
`secondsRemaining` (int), `totalSeconds` (int), `isRunning` (bool), `isDone` (bool)

---

## Reuse Inventory (from demo.html — port to Dart)

| Source | Target | Description |
|---|---|---|
| demo.html:1833-1848 `pickNextStep()` | `cook/src/step_graph.dart` | DAG filter + sort algorithm |
| demo.html:2146-2172 `_startMasterTick` | `cook/src/timer_service.dart` | Single Timer.periodic tick loop |
| demo.html:1914-1955 `_updateDoneBtn` | `ButtonState` enum + switch | Button state machine |
| demo.html:1958-1991 `stepDone()` | `cook_cubit.dart:completeStep()` | Step completion + readyAt logic |
| demo.html:1684-1810 `STEPS_BORSCHT` | `data/src/local/recipes.dart` | 24 steps with exact ids/weights/deps |
| demo.html:1454-1520 `STEPS_OMELETTE` | `data/src/local/recipes.dart` | 13 steps |
| demo.html:1312-1452 recipe metadata | `data/src/local/recipes.dart` | Ingredients + metadata for both |
| demo.html CSS `:root` variables | `core/src/constants/app_colors.dart` | All color tokens |

---

## Implementation Tasks (Ordered)

### Task 0: Project Setup & Dependencies — S
**Goal:** Foundation — packages, folder structure, linting, module skeleton.
**Deps:** None
**Files:**
- Modify: `pubspec.yaml` (add flutter_bloc, get_it, go_router, hive_flutter, hive, flutter_local_notifications, confetti_widget, google_fonts, shared_preferences)
- Modify: `analysis_options.yaml` (strict lint rules per `tooling.md`)
- Create: All directories and empty barrel files for every module
- Create: `lib/main.dart` (replace counter app — Hive init, module registration, runApp)
- Create: `lib/app/app.dart`, `lib/app/router.dart` (stubs), `lib/app/di.dart` (stubs)

### Task 1: Core Module — Models & Constants — S
**Goal:** All shared domain types + design tokens.
**Deps:** Task 0
**Files:**
- `core/src/models/` — all 8 model files
- `core/src/constants/` — `app_colors.dart`, `app_sizes.dart`, `app_durations.dart`
- `core/core.dart` — barrel exporting all public types
- `lib/app/theme.dart` — dark theme consuming core constants

### Task 2: Core Module — Utils — S
**Goal:** Pure Dart logic shared across modules.
**Deps:** Task 1
**Files:**
- `core/src/utils/serving_scaler.dart`
- `core/src/utils/time_format.dart`
- Update `core/core.dart` barrel

### Task 3: Data Module — Recipe Data — M
**Goal:** Port exact recipe data from HTML demo. Repository abstraction.
**Deps:** Task 1
**Files:**
- `data/src/local/recipes.dart` — `borschRecipe`, `omeletteRecipe` const objects
- `data/src/repositories/recipe_repository.dart` — abstract `RecipeRepository` + `LocalRecipeRepository`
- `data/src/data_module.dart` — `DataModule.register()`
- `data/data.dart` — barrel
**Critical:** Step IDs, weights, deps, timerDeps must match demo exactly. Borscht IDs: 1,7,9,10,11,12,13,14,16,18,19,3,2,5,6,20,21,22,23,24,26,27,28,29. Omelette IDs: 1-13.

### Task 4: Cook Module — Step Graph (Pure Logic) — S
**Goal:** Port `pickNextStep()` 1:1. The heart of the cooking engine. Internal to cook module.
**Deps:** Task 1
**Files:** `features/cook/src/step_graph.dart`
**Signature:** `RecipeStep? pickNextStep(List<RecipeStep> steps, Map<int, StepState> states)`
**Also:** `bool isAllDone(...)`, `bool hasRemainingSteps(...)`
**Note:** NOT exported in cook barrel — internal implementation detail.

### Task 5: Cook Module — Timer Service — M
**Goal:** Single `Timer.periodic(1s)` managing all active timers. Internal to cook module.
**Deps:** Task 1
**Files:** `features/cook/src/timer_service.dart`
**Key methods:** `startTimer(stepId, totalSeconds, isBackground)`, `pauseTimer(stepId)`, `resumeTimer(stepId)`, `recalculateFromReadyAt(...)`, `dispose()`
**Note:** NOT exported — internal to cook module. Only CookCubit uses it.

### Task 6: Shared Module — Notification Service — M
**Goal:** Schedule/cancel local push notifications for bg timers. Shared across modules.
**Deps:** Task 0
**Files:**
- `shared/src/notification_service.dart`
- `shared/src/shared_module.dart`
- `shared/shared.dart` — barrel
**Platform config:** Android manifest, iOS Info.plist

### Task 7: Cook Module — CookCubit — L
**Goal:** Orchestrate step graph, timers, and all cook screen state. The heart of the app.
**Deps:** Tasks 4, 5, 6
**Files:**
- `features/cook/src/cook_cubit.dart`
- `features/cook/src/cook_state.dart`
- `features/cook/src/cook_module.dart`
- Update `features/cook/cook.dart` barrel
**Key:** `startCooking()`, `completeStep()`, `startBlockingTimer()`, `pauseTimer()`, `resumeTimer()`, `stopCooking()`, `onAppPaused()`, `onAppResumed()`, `ButtonState` enum + `getButtonState()`

### Task 8: Shared UI Module — M
**Goal:** All reusable UI components exported via barrel.
**Deps:** Task 1
**Files:**
- `shared_ui/src/` — 10 widget files (primary_button, ghost_button, note_block, timer_display, float_bar, stat_grid, serving_control, progress_bar, recipe_card, toast_notification)
- `shared_ui/shared_ui.dart` — barrel exporting all widgets

### Task 9: Cook Module — Screen & Widgets — L
**Goal:** The core cooking experience UI. Widgets are internal to cook module.
**Deps:** Tasks 7, 8
**Files:**
- `features/cook/src/cook_screen.dart`
- `features/cook/src/widgets/step_card.dart`
- `features/cook/src/widgets/float_bar_section.dart`
- `features/cook/src/widgets/bottom_action_btn.dart`
- `features/cook/src/widgets/cook_top_bar.dart`
- `features/cook/src/widgets/waiting_view.dart`
- `features/cook/src/widgets/exit_dialog.dart`
**Includes:** Fade + slideUp transitions (200ms), WidgetsBindingObserver for lifecycle

### Task 10: Home Module — M
**Goal:** Recipe catalog with cards and bottom navigation.
**Deps:** Tasks 3, 8
**Files:**
- `features/home/src/home_screen.dart`, `home_cubit.dart`, `home_state.dart`, `home_module.dart`
- `features/home/src/widgets/greeting_header.dart`
- `features/home/home.dart` — barrel

### Task 11: Detail Module — M
**Goal:** Recipe info + serving scaler.
**Deps:** Tasks 2, 3, 8
**Files:**
- `features/detail/src/detail_screen.dart`, `detail_cubit.dart`, `detail_state.dart`, `detail_module.dart`
- `features/detail/detail.dart` — barrel

### Task 12: Checklist Module — M
**Goal:** 2-tab pre-cooking screen with ingredient checks and step overview.
**Deps:** Tasks 3, 8
**Files:**
- `features/checklist/src/checklist_screen.dart`, `checklist_cubit.dart`, `checklist_state.dart`, `checklist_module.dart`
- `features/checklist/src/widgets/ingredient_tab.dart`, `steps_tab.dart`
- `features/checklist/checklist.dart` — barrel

### Task 13: Done Module — S
**Goal:** Celebration with confetti and rating.
**Deps:** Task 8
**Files:**
- `features/done/src/done_screen.dart`, `done_cubit.dart`, `done_module.dart`
- `features/done/done.dart` — barrel

### Task 14: Shopping Module — M
**Goal:** Persistent shopping list with Hive.
**Deps:** Tasks 1, 8
**Files:**
- `features/shopping/src/shopping_screen.dart`, `shopping_cubit.dart`, `shopping_state.dart`, `shopping_module.dart`
- `data/src/repositories/shopping_repository.dart`
- `data/src/local/shopping_box.dart`
- `features/shopping/shopping.dart` — barrel

### Task 15: Profile Module — S
**Goal:** User stats screen.
**Deps:** Tasks 1, 8
**Files:**
- `features/profile/src/profile_screen.dart`, `profile_cubit.dart`, `profile_state.dart`, `profile_module.dart`
- `data/src/repositories/user_prefs_repository.dart`
- `features/profile/profile.dart` — barrel

### Task 16: App Wiring — Router + DI + Shell — M
**Goal:** Compose all module routes and DI registrations. ShellRoute for bottom nav.
**Deps:** Tasks 9-15 (all modules exist)
**Files:**
- `lib/app/router.dart` — full GoRouter composing all module routes
- `lib/app/di.dart` — full module registration
- `lib/app/shell_scaffold.dart` — bottom nav (Home/Search/Shopping/Profile)
- `lib/app/app.dart` — MaterialApp.router with theme
- `lib/main.dart` — final wiring

### Task 17: Integration & Polish — M
**Goal:** Platform configs, edge cases, final testing.
**Deps:** All prior
**Files:** Android manifest, iOS Info.plist, `pubspec.yaml` fonts

---

## Edge Cases

1. **Timer completes while app backgrounded**: Recalculate from `readyAt` on resume. If completed, set `isDone=true`, `secondsRemaining=0`. Call `pickNextStep()`.
2. **Multiple bg timers complete simultaneously**: Tick loop processes all completions. Each may unlock different dependent steps.
3. **User exits mid-session**: Confirmation dialog → cancel all timers → cancel notifications → navigate back.
4. **pickNextStep returns null + remaining steps**: Show waiting view. Auto-transition when bg timer completes.
5. **Blocking timer paused → user tries to advance**: Button shows "Resume", not "Next".
6. **Null ingredient amount ("за смаком")**: Scaler returns null, UI shows "за смаком" string.
7. **Borscht step 2 (timerDep=1)**: Blocked until step 1's bg timer `readyAt` is in the past, even though step 1 is marked done.
8. **Float bar overflow**: Max 2, sorted by stepId.
9. **Hot restart during cooking**: Session lost (in-memory only). Acceptable for MVP.

---

## Test Plan

### Unit Tests (Priority 1)
- **`step_graph_test.dart`**: Linear steps, parallel branches, timerDep blocking, waiting state, completion, weight sorting, multi-dep steps (Borscht step 20 with 3 deps)
- **`timer_service_test.dart`**: Tick decrement, bg completion sets readyAt, pause/resume, concurrent timers, dispose
- **`serving_scaler_test.dart`**: Scale up/down, null amount, fractional amounts
- **`cook_cubit_test.dart`**: Start, completeStep (with bg/blocking/no timer), waiting state, auto-transition, button states, stop

### Widget Tests (Priority 2)
- `step_card_test.dart`: Renders text, note blocks, timer block
- `float_bar_test.dart`: Label, countdown, urgency class
- `bottom_action_btn_test.dart`: All ButtonState variants
- `serving_control_test.dart`: +/- changes value, min 1

### Integration Tests (Priority 3)
- `cook_flow_test.dart`: Full Omelette cook-through (13 steps → done)
- `borscht_parallel_test.dart`: Verify DAG traversal with bg timers

---

## Open Questions

1. **Hive type adapters**: Manual adapters (only 1 type) vs `hive_generator`? → Recommend manual to avoid build_runner.
2. **Notification sound**: Default system vs custom? → Default for MVP.
3. **Borscht data structure**: Demo has both phase-based (display) and flat step list (logic). Flutter uses flat list only. Confirm.
4. **Rating persistence**: Store in SharedPreferences, display as "your rating" on Detail. No visible effect on recipe's rating.
5. **Search tab**: Show as placeholder (4 tabs) vs hide (3 tabs)? → 4 tabs with "Coming soon" placeholder.

---

## Verification

To verify the MVP works end-to-end:
1. `flutter test` — all unit + widget tests pass
2. `flutter analyze` — zero issues
3. Run on device: Home → tap Borscht → Detail → scale servings → Checklist → mark some ingredients → add missing to shopping → Start cooking → complete all 24 steps including bg timers + waiting states → Done screen with confetti → Rate → Home
4. Repeat with Omelette (linear, simpler)
5. Check shopping list persists after app restart
6. Background the app during a bg timer → verify notification fires → resume → verify timer state recalculated
