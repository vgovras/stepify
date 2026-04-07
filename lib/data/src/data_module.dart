import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local/shopping_box.dart';
import 'repositories/recipe_repository.dart';
import 'repositories/shopping_repository.dart';
import 'repositories/user_prefs_repository.dart';

/// Registers all data module dependencies.
abstract final class DataModule {
  static Future<void> register(GetIt di) async {
    di.registerLazySingleton<RecipeRepository>(LocalRecipeRepository.new);

    final shoppingBox = await openShoppingBox();
    di.registerLazySingleton<ShoppingRepository>(
      () => HiveShoppingRepository(box: shoppingBox),
    );

    final prefs = await SharedPreferences.getInstance();
    di.registerLazySingleton<UserPrefsRepository>(
      () => UserPrefsRepository(prefs: prefs),
    );
  }
}
