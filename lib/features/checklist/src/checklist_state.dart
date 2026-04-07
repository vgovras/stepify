import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

/// Immutable state for the pre-cooking checklist screen.
///
/// Tracks which ingredients the user has at home and which tab
/// (ingredients vs. steps overview) is currently active.
@immutable
class ChecklistState {
  const ChecklistState({
    required this.recipe,
    required this.currentServings,
    required this.ingredientChecks,
    required this.activeTab,
  });

  /// Creates the initial state with all ingredients unchecked.
  factory ChecklistState.initial({
    required Recipe recipe,
    required int currentServings,
  }) {
    return ChecklistState(
      recipe: recipe,
      currentServings: currentServings,
      ingredientChecks: List.filled(recipe.ingredients.length, false),
      activeTab: 0,
    );
  }

  final Recipe recipe;
  final int currentServings;

  /// Parallel list to [recipe.ingredients] — true if the user has it.
  final List<bool> ingredientChecks;

  /// 0 = ingredients tab, 1 = steps overview tab.
  final int activeTab;

  /// Steps sorted by weight for the overview tab.
  List<RecipeStep> get sortedSteps {
    return List<RecipeStep>.from(recipe.steps)
      ..sort((a, b) => a.weight.compareTo(b.weight));
  }

  /// Ingredients scaled to [currentServings].
  List<Ingredient> get scaledIngredients {
    return recipe.ingredients.map((ing) {
      final scaled = scaleAmount(
        baseAmount: ing.amount,
        baseServings: recipe.baseServings,
        currentServings: currentServings,
      );
      return ing.copyWith(amount: () => scaled);
    }).toList();
  }

  /// Number of ingredients the user has checked off.
  int get checkedCount => ingredientChecks.where((c) => c).length;

  /// Total number of ingredients in the recipe.
  int get totalCount => ingredientChecks.length;

  /// Returns a copy with the given fields replaced.
  ChecklistState copyWith({
    Recipe? recipe,
    int? currentServings,
    List<bool>? ingredientChecks,
    int? activeTab,
  }) {
    return ChecklistState(
      recipe: recipe ?? this.recipe,
      currentServings: currentServings ?? this.currentServings,
      ingredientChecks: ingredientChecks ?? this.ingredientChecks,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
