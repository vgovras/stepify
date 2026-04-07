# CLAUDE.md — Stepify Project Rules

This is a **Flutter** project written in **Dart**.
Follow all rules below when writing, reviewing, or modifying code.

---

## Project Overview

**Stepify** (codename CookFlow) is a mobile app for step-by-step cooking with a dependency graph between steps and background timers. The user sees one step at a time; parallel processes (e.g., broth simmering while chopping vegetables) are managed automatically via a DAG.

The product spec lives in `tasks/cookflow_tz.md` (in Ukrainian). The HTML demo `cookflow-demo-v5.html` is the UI/UX reference — port its `pickNextStep()` logic to Dart 1:1.

---

## Core Principles

1. **Simple > Clever.** Code is read 10x more than it's written.
2. **One thing per function/class/widget.** No God objects.
3. **Explicit over implicit.** Name things clearly. Annotate public APIs.
4. **No dead code.** Commented-out code, unused imports, and `print()` statements must not be committed.
5. **Format before commit.** `dart format .` + `flutter analyze` — zero issues.

---

## Common Commands

```bash
flutter pub get                     # Install dependencies
dart format .                       # Format all code
flutter analyze                     # Static analysis (uses flutter_lints)
flutter test                        # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter run                         # Run app (debug, connected device/emulator)
flutter build apk                   # Build Android APK
flutter build ios                   # Build iOS
```

### Before Every Commit

```bash
dart format .
flutter analyze
flutter test
```

---

## Rules

| Topic | File |
|---|---|
| Naming conventions (casing, booleans, magic numbers) | [.claude/rules/naming.md](.claude/rules/naming.md) |
| Project & folder structure | [.claude/rules/project_structure.md](.claude/rules/project_structure.md) |
| Widget best practices | [.claude/rules/widgets.md](.claude/rules/widgets.md) |
| Code style & formatting | [.claude/rules/code_style.md](.claude/rules/code_style.md) |
| Documentation & comments | [.claude/rules/documentation.md](.claude/rules/documentation.md) |
| Architecture & state management | [.claude/rules/architecture.md](.claude/rules/architecture.md) |
| Tooling & analysis options | [.claude/rules/tooling.md](.claude/rules/tooling.md) |
| Plan mode behavior | [.claude/rules/plan_mode.md](.claude/rules/plan_mode.md) |

---

## Quick Reference

### Naming

```dart
class UserRepository {}         // UpperCamelCase — classes
void fetchUser() {}             // lowerCamelCase — functions
const defaultTimeout = 30;      // lowerCamelCase — constants (not SCREAMING_CAPS)
String _cache = '';              // _prefix — private members only
// lowercase_with_underscores   // files & directories
```

### Widgets

```dart
const Text('hello');            // always const where possible
// Keep build() pure — no side effects, no heavy logic
// Dispose streams/controllers in dispose()
// Extract widget if build() > ~50 lines
```

### Architecture

```
presentation → domain ← data   // dependency direction
Use cases: one class = one action
State: immutable + copyWith
DI: constructor injection only
```

---

## Architecture

Dart SDK ^3.11.4. Feature-first structure:

```
lib/
├── main.dart              # App entry point
├── app/                   # Router (GoRouter), theme
├── data/
│   ├── models/            # Recipe, Step, Ingredient, StepState
│   ├── repositories/      # RecipeRepository, CartRepository
│   └── local/             # Local storage (Hive/SharedPreferences)
├── features/
│   ├── home/              # Recipe catalog
│   ├── detail/            # Recipe details, serving scaler
│   ├── checklist/         # Ingredient checklist + step overview tabs
│   ├── cook/              # Core cooking screen (step graph, timers)
│   ├── done/              # Completion screen with confetti
│   ├── shopping/          # Shopping list
│   └── profile/           # User stats
└── shared/                # Shared widgets and utilities
```

---

## Key Domain Concepts

- **Step Graph**: Steps have `deps` (prerequisite step IDs that must be done) and optional `timerDep` (a background timer that must finish). `pickNextStep()` filters steps where all deps are done and timerDeps have elapsed, then sorts by `weight` (ascending).
- **Background timers**: `isBackground: true` timers continue running while the user advances to the next step. Shown as float bars at the top of the cook screen.
- **Blocking timers**: `waitTimer: true` prevents advancing until the timer completes. Button toggles between pause/resume/next states.
- **Single timer tick**: One `Timer.periodic(1 second)` per cooking session decrements all active timers — not one timer per step.

---

## Design System

- **Dark theme only** for MVP
- Primary accent: gold `#E8B44C`, secondary: orange `#D4793A`
- Fonts: Playfair Display (headings/timers), DM Sans (body)
- See `tasks/cookflow_tz.md` section 7 for full color palette and component specs

---

## State Management

Riverpod or BLoC/Cubit — pick one, be consistent. `CookCubit`/provider is the most complex — manages step states, active timers, and graph traversal. State classes must be immutable with `copyWith`.

---

## MVP Scope

- Two hardcoded recipes: Borscht (24 steps with parallel bg timers) and Omelette (13 linear steps)
- Local-only data (no auth, no cloud sync)
- Push notifications for background timer completion (`flutter_local_notifications`)
- Serving size scaling on detail screen
- Shopping list persisted locally

---

## Installed Skills

Skills are reference guides in `.claude/skills/` that provide best-practice patterns for specific Flutter topics. Use them when working on the corresponding area of the app.

### Core Skills (use frequently)

| Skill | When to Use | Stepify Context |
|---|---|---|
| `flutter-managing-state` | Setting up Cubit/Riverpod, MVVM pattern | CookCubit, ChecklistCubit, all feature state |
| `flutter-architecting-apps` | Structuring layers (UI → Logic → Data) | Feature folder layout, repository pattern |
| `flutter-building-layouts` | Building screen layouts, constraint system | StepCard, cook screen layout, recipe cards |
| `flutter-theming-apps` | Dark theme, color tokens, Material theming | App-wide dark theme setup (`app/theme.dart`) |
| `flutter-animating-apps` | Transitions, motion, animated effects | Step fade+slideUp transitions, float bar animations, confetti |
| `flutter-implementing-navigation-and-routing` | GoRouter setup, deep links, route guards | Cook flow navigation, ShellRoute for bottom nav |
| `flutter-building-forms` | Form validation, user input | Rating form on done screen, serving size input |

### Secondary Skills (use when needed)

| Skill | When to Use | Stepify Context |
|---|---|---|
| `flutter-handling-concurrency` | Background isolates, async patterns | Timer service, background timer management |
| `flutter-caching-data` | Offline support, caching strategies | Shopping list persistence, recipe caching |
| `flutter-working-with-databases` | SQLite, local DB setup | If switching from Hive to SQLite for structured data |
| `flutter-handling-http-and-json` | REST API, JSON serialization | Recipe JSON loading from assets (post-MVP: remote API) |
| `flutter-reducing-app-size` | Bundle optimization | MVP target: APK < 30 MB |
| `flutter-improving-accessibility` | Screen readers, semantic widgets | Cooking screen must be usable hands-free |
| `flutter-localizing-apps` | Multi-language support | Post-MVP: Ukrainian → English localization |

### Platform & Setup Skills (use on initial setup or platform issues)

| Skill | When to Use |
|---|---|
| `flutter-setting-up-on-macos` | macOS dev environment, Xcode, CocoaPods |
| `flutter-setting-up-on-linux` | Linux dev environment |
| `flutter-setting-up-on-windows` | Windows dev environment, Visual Studio |
| `flutter-adding-home-screen-widgets` | iOS/Android home screen widgets (post-MVP) |
| `flutter-embedding-native-views` | Embedding native views (not needed for MVP) |
| `flutter-interoperating-with-native-apis` | Platform channels, FFI (notifications setup) |
| `flutter-building-plugins` | Creating reusable plugins (not needed for MVP) |

### Meta Skills

| Skill | When to Use |
|---|---|
| `frontend-design` | Creating polished, non-generic UI — use for cook screen and recipe card design |
| `agent-development` | Building Claude Code agents/plugins |
| `skill-development` | Creating new reusable skills |

---

## External References

- [Effective Dart (official)](https://dart.dev/effective-dart)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Effective Dart: Design](https://dart.dev/effective-dart/design)
- [Effective Dart: Documentation](https://dart.dev/effective-dart/documentation)
