import '../../../core/core.dart';
import '../local/recipes.dart';

/// Abstraction for recipe data access.
///
/// MVP uses [LocalRecipeRepository] with hardcoded data.
/// Swap implementation for API/DB access post-MVP.
abstract class RecipeRepository {
  List<Recipe> getAll();
  Recipe? getById(String id);
}

class LocalRecipeRepository implements RecipeRepository {
  @override
  List<Recipe> getAll() => allRecipes;

  @override
  Recipe? getById(String id) {
    return allRecipes.cast<Recipe?>().firstWhere(
      (r) => r?.id == id,
      orElse: () => null,
    );
  }
}
