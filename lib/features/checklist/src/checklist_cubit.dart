import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import 'checklist_state.dart';

/// Manages the pre-cooking checklist — ingredient checks and tab
/// switching.
///
/// Does not depend on [ShoppingCubit] directly. Instead,
/// [addMissingToShopping] returns the list of unchecked
/// [Ingredient] objects for the caller to forward.
class ChecklistCubit extends Cubit<ChecklistState> {
  ChecklistCubit({required Recipe recipe, required int currentServings})
    : super(
        ChecklistState.initial(
          recipe: recipe,
          currentServings: currentServings,
        ),
      );

  /// Toggles the checked state of the ingredient at [index].
  void toggleIngredient(int index) {
    if (index < 0 || index >= state.ingredientChecks.length) {
      return;
    }
    final updated = List<bool>.from(state.ingredientChecks);
    updated[index] = !updated[index];
    emit(state.copyWith(ingredientChecks: updated));
  }

  /// Switches to the given [tab] index (0 or 1).
  void switchTab(int tab) {
    if (tab == state.activeTab) return;
    emit(state.copyWith(activeTab: tab));
  }

  /// Returns the list of unchecked [Ingredient] objects.
  ///
  /// The caller is responsible for forwarding these to the
  /// shopping module. Amounts are scaled to [currentServings].
  List<Ingredient> addMissingToShopping() {
    final missing = <Ingredient>[];
    for (var i = 0; i < state.ingredientChecks.length; i++) {
      if (!state.ingredientChecks[i]) {
        final base = state.recipe.ingredients[i];
        final scaled = scaleAmount(
          baseAmount: base.amount,
          baseServings: state.recipe.baseServings,
          currentServings: state.currentServings,
        );
        missing.add(base.copyWith(amount: () => scaled));
      }
    }
    return missing;
  }
}
