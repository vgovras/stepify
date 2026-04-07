import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import 'home_state.dart';

/// Manages the home screen state — recipe list and favorites.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required RecipeRepository recipeRepository})
    : _recipeRepository = recipeRepository,
      super(const HomeState());

  final RecipeRepository _recipeRepository;

  /// Loads all recipes from the repository.
  void loadRecipes() {
    final recipes = _recipeRepository.getAll();
    emit(state.copyWith(recipes: recipes));
  }

  /// Toggles the favorite status of [recipeId].
  void toggleFavorite(String recipeId) {
    final updated = Set<String>.from(state.favorites);
    if (updated.contains(recipeId)) {
      updated.remove(recipeId);
    } else {
      updated.add(recipeId);
    }
    emit(state.copyWith(favorites: updated));
  }
}
