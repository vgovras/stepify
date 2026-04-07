import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'ingredient.dart';
import 'recipe_step.dart';

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.emoji,
    required this.baseServings,
    required this.timeMinutes,
    required this.kcalPerServing,
    required this.difficulty,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.rating,
    required this.reviewCount,
    this.tags = const [],
    this.gradientColors,
  });

  final String id;
  final String name;
  final String emoji;
  final int baseServings;
  final int timeMinutes;
  final int kcalPerServing;
  final Difficulty difficulty;
  final RecipeCategory category;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final double rating;
  final int reviewCount;

  /// Display tags for the recipe card (e.g. "🇺🇦 Українська").
  final List<String> tags;

  /// Gradient background for the card image area [start, end].
  /// If null, a default dark gradient is used.
  final (int, int)? gradientColors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe($id, "$name")';
}
