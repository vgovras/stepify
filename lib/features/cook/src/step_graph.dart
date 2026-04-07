// Step graph algorithm — pure Dart, zero Flutter dependencies.
// Ported 1:1 from `tasks/demo.html` lines 1833-1848.

import '../../../core/core.dart';

/// Returns the next available step in the recipe's dependency graph.
///
/// Filters steps where all [RecipeStep.deps] are completed and
/// [RecipeStep.timerDep] has elapsed, then returns the one with
/// the lowest [RecipeStep.weight].
///
/// Returns `null` if no steps are available (triggers waiting screen)
/// or all steps are done (triggers completion screen).
RecipeStep? pickNextStep(List<RecipeStep> steps, Map<int, StepState> states) {
  final now = DateTime.now();
  final available = steps.where((s) {
    final st = states[s.id];
    if (st == null || st.isDone) return false;
    if (!s.deps.every((d) => states[d]?.isDone ?? false)) return false;
    if (s.timerDep != null) {
      final readyAt = states[s.timerDep]?.readyAt;
      if (readyAt == null || readyAt.isAfter(now)) return false;
    }
    return true;
  }).toList()..sort((a, b) => a.weight.compareTo(b.weight));

  return available.firstOrNull;
}

/// Whether all steps are marked as done.
bool isAllDone(Map<int, StepState> states) {
  return states.values.every((s) => s.isDone);
}

/// Whether there are undone steps remaining.
bool hasRemainingSteps(List<RecipeStep> steps, Map<int, StepState> states) {
  return steps.any((s) => !(states[s.id]?.isDone ?? true));
}
