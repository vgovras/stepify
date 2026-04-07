import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data.dart';
import 'checklist_cubit.dart';
import 'checklist_screen.dart';

/// Registers checklist module dependencies and routes.
abstract final class ChecklistModule {
  /// Registers the [ChecklistCubit] factory in [di].
  static void register(GetIt di) {
    // ChecklistCubit is created per-screen via BlocProvider,
    // no singleton registration needed.
  }

  /// GoRouter routes for the checklist screen.
  static List<RouteBase> routes() {
    return [
      GoRoute(
        path: 'checklist',
        builder: (context, routerState) {
          final recipeId = routerState.pathParameters['id'] ?? '';
          final di = GetIt.instance;
          final repo = di.get<RecipeRepository>();
          final recipe = repo.getById(recipeId);
          if (recipe == null) {
            throw StateError('Recipe "$recipeId" not found');
          }
          final servings =
              int.tryParse(routerState.uri.queryParameters['servings'] ?? '') ??
              recipe.baseServings;
          return BlocProvider(
            create: (_) =>
                ChecklistCubit(recipe: recipe, currentServings: servings),
            child: const ChecklistScreen(),
          );
        },
      ),
    ];
  }
}
