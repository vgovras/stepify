import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

/// Immutable state for the home recipe catalog.
@immutable
class HomeState {
  const HomeState({this.recipes = const [], this.favorites = const {}});

  /// All available recipes.
  final List<Recipe> recipes;

  /// Set of favorited recipe IDs.
  final Set<String> favorites;

  /// Whether [recipeId] is in the favorites set.
  bool isFavorite(String recipeId) => favorites.contains(recipeId);

  /// Creates a copy with the given fields replaced.
  HomeState copyWith({List<Recipe>? recipes, Set<String>? favorites}) {
    return HomeState(
      recipes: recipes ?? this.recipes,
      favorites: favorites ?? this.favorites,
    );
  }
}
