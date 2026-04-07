import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

/// Immutable state for the recipe detail screen.
@immutable
class DetailState {
  const DetailState({required this.recipe, required this.currentServings});

  /// The recipe being viewed.
  final Recipe recipe;

  /// User-selected serving count (1–12).
  final int currentServings;

  /// Ingredients scaled to [currentServings].
  ///
  /// Uses [scaleAmount] from core to adjust quantities
  /// proportionally to the base serving count.
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

  /// Creates a copy with the given fields replaced.
  DetailState copyWith({Recipe? recipe, int? currentServings}) {
    return DetailState(
      recipe: recipe ?? this.recipe,
      currentServings: currentServings ?? this.currentServings,
    );
  }
}
