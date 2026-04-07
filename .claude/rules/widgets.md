# Widget Best Practices

> Flutter widget rules tailored for Stepify's cooking UI

## Keep Widgets Small

Each widget does one thing. Extract if `build()` exceeds ~50 lines.

```dart
// GOOD — cook screen composed from focused widgets
class CookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const FloatBarSection(),   // active background timers
          const ProgressBar(),       // step N of M
          const Expanded(child: StepCard()),  // current step
          const BottomActionBtn(),   // dynamic next/pause/done button
        ],
      ),
    );
  }
}
```

## Use `const` Constructors Aggressively

`const` lets Flutter skip rebuild entirely for that subtree. Use whenever possible — especially for static UI elements in the cook screen.

```dart
// GOOD — never rebuilds on timer tick
const Text('You have pushed the button this many times:');
const SizedBox(height: 16);
const Icon(Icons.timer);

// BAD — rebuilds every time parent rebuilds
Text('You have pushed the button this many times:');
SizedBox(height: 16);
```

## Prefer StatelessWidget Over Helper Functions

Helper functions rebuild every time. `const StatelessWidget` subclasses do not.

```dart
// BAD — rebuilds on every parent rebuild
Widget _buildNoteBlock(StepNote note) {
  return Container(
    color: _colorForType(note.type),
    child: Text(note.text),
  );
}

// GOOD — can be const, skips rebuilds
class NoteBlock extends StatelessWidget {
  final StepNote note;
  const NoteBlock({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _colorForType(note.type),
      child: Text(note.text),
    );
  }
}
```

## Keep `build()` Pure

Never put side effects, async calls, or heavy computation in `build()`. It runs on every frame during animations.

```dart
// BAD — runs on every rebuild
@override
Widget build(BuildContext context) {
  final nextStep = pickNextStep(steps, states); // CPU work every frame
  return StepCard(step: nextStep);
}

// GOOD — compute in cubit/notifier, read result in build
@override
Widget build(BuildContext context) {
  final state = context.watch<CookCubit>().state;
  return StepCard(step: state.currentStep);
}
```

## Localize setState to Smallest Subtree

For timer countdown display — only rebuild the timer text, not the entire cook screen.

```dart
// BAD — rebuilds entire screen every second
class _CookScreenState extends State<CookScreen> {
  void _onTick() => setState(() {}); // rebuilds everything
}

// GOOD — only the timer widget rebuilds
// Use a separate widget or BlocBuilder/Consumer scoped to timer state
class TimerCountdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seconds = context.select<CookCubit, int>(
      (cubit) => cubit.state.currentTimerSeconds,
    );
    return Text(_formatTime(seconds));
  }
}
```

## Animation Rules for Stepify

Step transitions use fade + slideUp (200ms). Follow these rules:

```dart
// GOOD — static children passed as child, not inside builder
AnimatedBuilder(
  animation: _controller,
  child: const StepContent(), // static, built once
  builder: (context, child) {
    return Opacity(
      opacity: _controller.value,
      child: child, // reused, not rebuilt
    );
  },
);

// BAD — Opacity widget in animation (triggers saveLayer per frame)
// Use AnimatedOpacity or FadeTransition instead
AnimatedOpacity(
  opacity: _opacity,
  duration: const Duration(milliseconds: 200),
  child: StepCard(step: currentStep),
);
```

## Dispose Everything

Critical for Stepify — cooking sessions have timers, streams, and animation controllers.

```dart
class _CookScreenState extends State<CookScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  StreamSubscription<int>? _timerSub;

  @override
  void dispose() {
    _animController.dispose();
    _timerSub?.cancel();
    super.dispose();
  }
}
```

## Layout Constraint Rule

**Constraints go down, sizes go up, parent sets position.**

For the cook screen: `StepCard` should be wrapped in `Expanded` so it fills available space between the float bars and bottom button. Use `SingleChildScrollView` inside if step text overflows.

## ListView.builder for Lists

Recipe catalog and ingredient lists — always use lazy builders:

```dart
// GOOD — only builds visible items
ListView.builder(
  itemCount: recipes.length,
  itemBuilder: (context, index) => RecipeCard(recipe: recipes[index]),
);

// BAD — builds all items immediately
ListView(
  children: recipes.map((r) => RecipeCard(recipe: r)).toList(),
);
```
