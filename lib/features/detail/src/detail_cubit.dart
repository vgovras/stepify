import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import 'detail_state.dart';

/// Manages the recipe detail screen state.
///
/// Handles serving count changes and provides scaled
/// ingredient data via [DetailState.scaledIngredients].
class DetailCubit extends Cubit<DetailState> {
  DetailCubit({required Recipe recipe})
    : super(DetailState(recipe: recipe, currentServings: recipe.baseServings));

  /// Updates the serving count, clamped to 1–12.
  void changeServings(int servings) {
    final clamped = min(12, max(1, servings));
    emit(state.copyWith(currentServings: clamped));
  }
}
