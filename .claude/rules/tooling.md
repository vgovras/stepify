# Tooling & Analysis

> Linting, formatting, and CI rules for Stepify

## Required Pre-Commit Checks

| Step | Command | Must Pass |
|---|---|---|
| 1. Format | `dart format .` | No diffs |
| 2. Analyze | `flutter analyze` | Zero issues |
| 3. Test | `flutter test` | All pass |

## `analysis_options.yaml` — Recommended Setup

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Style
    - directives_ordering
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - unnecessary_this
    - prefer_single_quotes
    - always_use_package_imports    # false — use relative imports

    # Safety
    - avoid_dynamic_calls
    - avoid_print
    - cancel_subscriptions          # critical — Stepify has many timer streams
    - close_sinks
    - always_declare_return_types

    # Readability
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - use_enums
    - unnecessary_lambdas

analyzer:
  errors:
    missing_return: error
    dead_code: warning
    unused_import: warning
    unused_local_variable: warning
  exclude:
    - "**/*.g.dart"                 # generated code (freezed, json_serializable)
    - "**/*.freezed.dart"
```

## Key Lint Rules for Stepify

| Rule | Why It Matters |
|---|---|
| `cancel_subscriptions` | Cooking sessions create timer streams — uncancelled = memory leak |
| `close_sinks` | StreamControllers in timer service must be closed |
| `avoid_print` | Use proper logging, not `print()` in production |
| `prefer_const_constructors` | Essential for preventing unnecessary widget rebuilds during timer ticks |
| `prefer_final_locals` | Immutable by default — matches our state management pattern |

## Recommended Packages

| Package | Purpose | Why for Stepify |
|---|---|---|
| `flutter_lints` | Official lint rules | Already in pubspec |
| `freezed` | Immutable data classes + unions | Models (Recipe, StepState) + sealed state classes |
| `json_annotation` | JSON serialization | Recipe data from JSON assets |
| `build_runner` | Code generation | For freezed + json_serializable |

Run code generation after model changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## IDE Setup

- **VSCode**: enable `editor.formatOnSave` in Dart extension settings
- **Android Studio**: enable "Format on save" in Dart settings
- Both: keep the Analysis/Problems pane visible — fix warnings before committing

## Performance Profiling

Run periodically during cook screen development:

```bash
flutter run --profile                  # Profile mode (real device only)
flutter run --enable-impeller          # Test Impeller rendering (iOS)
```

Use Flutter DevTools:
- **Widget Inspector** → check rebuild counts on timer tick (StepCard should NOT rebuild every second)
- **Performance overlay** → ensure 60fps during step transitions and timer animations
- **Memory profiler** → verify no timer leaks after cooking session ends

## Test Organization

```
test/
├── unit/
│   ├── step_graph_test.dart           # pickNextStep logic — most critical
│   ├── timer_service_test.dart        # Timer tick, completion callbacks
│   └── serving_scaler_test.dart       # Ingredient amount scaling
├── widget/
│   ├── step_card_test.dart
│   ├── float_bar_test.dart
│   └── bottom_action_btn_test.dart
└── integration/
    └── cook_flow_test.dart            # Full cooking session end-to-end
```

**Priority:** unit test `pickNextStep()` exhaustively first — it's the core algorithm. Cover:
- Linear steps (all deps sequential)
- Parallel branches (Borscht: chop vegs while broth simmers)
- Timer dep blocking (step available only after bg timer completes)
- Waiting state (no available steps)
- Completion state (all steps done)
